module Pages.PlantDetails exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import CheckIn
import DateAndTime
import File
import File.Select as Select
import Html exposing (Html, a, div, h2, h3, img, text)
import Html.Attributes exposing (class, href, src, style)
import Html.Events exposing (onClick)
import Http
import Plant
import Routes
import Task
import Time
import User


type alias Model =
    { plant : Maybe Plant.Plant
    , currentUser : User.User
    , timeZone : Time.Zone
    , upload : Upload
    }


type Upload
    = None
    | Uploading Float
    | Done
    | Fail


type Msg
    = ReceivedGetPlantResponse (Result Http.Error Plant.Plant)
    | UserSelectedUploadNewPhoto
    | NewImageSelected File.File
    | ReceivedUploadPhotoResponse (Result Http.Error Plant.Plant)
    | GotUploadProgress Http.Progress


init : Int -> User.User -> Time.Zone -> ( Model, Cmd Msg )
init plantId user timeZone =
    ( Model Nothing user timeZone None, getPlant plantId )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedGetPlantResponse (Ok plant) ->
            ( { model | plant = Just plant }, Cmd.none )

        ReceivedGetPlantResponse (Err error) ->
            let
                _ =
                    Debug.log "Error" error
            in
            ( model, Cmd.none )

        UserSelectedUploadNewPhoto ->
            ( model, Select.file [ "image/*" ] NewImageSelected )

        NewImageSelected file ->
            case model.plant of
                Just plant ->
                    ( { model
                        | upload = Uploading 0
                      }
                    , uploadPhoto file plant
                    )

                Nothing ->
                    ( model, Cmd.none )

        ReceivedUploadPhotoResponse (Ok plant) ->
            ( { model | upload = Done, plant = Just plant }, Cmd.none )

        ReceivedUploadPhotoResponse (Err error) ->
            let
                _ =
                    Debug.log "Error" error
            in
            ( model, Cmd.none )

        GotUploadProgress progress ->
            case progress of
                Http.Sending p ->
                    let
                        fractionSent =
                            Http.fractionSent p
                    in
                    ( { model | upload = Uploading fractionSent }, Cmd.none )

                Http.Receiving _ ->
                    ( model, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Http.track "photoUpload" GotUploadProgress


uploadPhoto file plant =
    Plant.uploadPhoto file plant ReceivedUploadPhotoResponse


getPlant : Int -> Cmd Msg
getPlant id =
    Plant.getPlant id ReceivedGetPlantResponse


view : Model -> Html Msg
view model =
    case model.plant of
        Just plant ->
            div [ class "container__center" ]
                [ div [ class "container__center centered-text" ]
                    [ div
                        [ class "container__center avatar with_loader" ]
                        [ img
                            [ src plant.photoUrl
                            , onClick UserSelectedUploadNewPhoto
                            ]
                            []
                        , loadingOverlay model.upload
                        ]
                    , h2 [ class "centered-text" ] [ text plant.name ]
                    , a [ href Routes.plantsPath ] [ text "Back to Plants" ]
                    ]
                , viewCheckInsList plant.checkIns model.timeZone
                ]

        Nothing ->
            div [ class "container__center centered-text" ]
                [ div [] [ text "Loading..." ] ]


loadingOverlay : Upload -> Html Msg
loadingOverlay loading =
    case loading of
        Uploading fraction ->
            let
                percentage =
                    round (fraction * 100)

                percentageString =
                    String.fromInt percentage ++ "%"

                uploadingText =
                    "Uploading: " ++ percentageString
            in
            div [ class "loader_bar__overlay" ]
                [ div [ class "loader_bar__container" ]
                    [ div [ class "loader_bar__background" ]
                        [ div
                            [ class "loader_bar__foreground", style "width" percentageString ]
                            []
                        , div [ class "loader_bar__text" ] [ text uploadingText ]
                        ]
                    ]
                ]

        _ ->
            text ""


viewCheckInsList : List CheckIn.CheckIn -> Time.Zone -> Html msg
viewCheckInsList checkInsList timeZone =
    let
        checkInRows =
            List.map (viewCheckInRow timeZone) checkInsList
    in
    div [] <| [ h3 [] [ text "Latest Check-ins" ] ] ++ checkInRows


viewCheckInRow : Time.Zone -> CheckIn.CheckIn -> Html msg
viewCheckInRow timeZone checkIn =
    div [ class "check_in__row" ]
        [ div []
            [ text <|
                "Checked-in on "
                    ++ DateAndTime.monthDayYearTime
                        checkIn.createdAt
                        Time.utc
            ]
        , div [] [ text <| "Watered: " ++ yesOrNo checkIn.watered ]
        , div [] [ text <| "Fertilized: " ++ yesOrNo checkIn.fertilized ]
        , div [] [ text checkIn.notes ]
        ]


yesOrNo : Bool -> String
yesOrNo bool =
    if bool then
        "Yes"

    else
        "No"
