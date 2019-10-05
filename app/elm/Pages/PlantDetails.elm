port module Pages.PlantDetails exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation as Nav
import CheckIn
import DateAndTime
import File
import File.Select as Select
import Html exposing (Html, a, button, div, h2, h3, h4, img, p, text)
import Html.Attributes exposing (class, href, id, src, style, target)
import Html.Events exposing (onClick)
import Http
import Json.Encode
import Modal exposing (..)
import Octicons exposing (defaultOptions)
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
    , modal : Modal.Modal Msg
    , csrfToken : String
    , key : Nav.Key
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
    | PhotoConvertedToBase64 String
    | GotCroppedPhoto String
    | UserCroppedPhoto
    | UserClickedDeletePlant Int
    | ReceivedDeletePlantResponse (Result Http.Error ())
    | UserClickedEditPlant Int


init : Nav.Key -> String -> Int -> User.User -> Time.Zone -> ( Model, Cmd Msg )
init key csrfToken plantId user timeZone =
    ( Model Nothing user timeZone None Modal.ModalClosed csrfToken key, getPlant plantId )


port initJsCropper : String -> Cmd msg


port sendCroppedImage : (String -> msg) -> Sub msg


photoToBase64 : File.File -> Cmd Msg
photoToBase64 photo =
    Task.perform PhotoConvertedToBase64 (File.toUrl photo)


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

        NewImageSelected photo ->
            case model.plant of
                Just plant ->
                    ( { model | modal = Modal.Modal <| cropperModal model }
                    , photoToBase64 photo
                    )

                Nothing ->
                    ( model, Cmd.none )

        PhotoConvertedToBase64 base64Url ->
            ( model, initJsCropper base64Url )

        UserCroppedPhoto ->
            ( { model | modal = ModalClosed }, Cmd.none )

        GotCroppedPhoto photo ->
            case model.plant of
                Just plant ->
                    let
                        updatedPlant =
                            { plant | avatarUrl = photo }
                    in
                    ( { model | upload = Uploading 0 }
                    , uploadPhoto model.csrfToken photo plant
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

        UserClickedDeletePlant plantId ->
            ( model, deletePlant model.csrfToken plantId )

        ReceivedDeletePlantResponse (Ok _) ->
            ( model, Nav.pushUrl model.key Routes.plantsPath )

        ReceivedDeletePlantResponse (Err _) ->
            ( model, Cmd.none )

        UserClickedEditPlant plantId ->
            ( model, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Http.track "photoUpload" GotUploadProgress
        , sendCroppedImage GotCroppedPhoto
        ]


uploadPhoto : String -> String -> Plant.Plant -> Cmd Msg
uploadPhoto csrfToken base64Photo plant =
    Plant.uploadPhoto csrfToken base64Photo plant ReceivedUploadPhotoResponse


getPlant : Int -> Cmd Msg
getPlant id =
    Plant.getPlant id ReceivedGetPlantResponse


deletePlant : String -> Int -> Cmd Msg
deletePlant csrfToken id =
    Plant.deletePlant csrfToken id ReceivedDeletePlantResponse


view : Model -> Html Msg
view model =
    case model.plant of
        Just plant ->
            div [ class "container__center" ]
                [ div [ class "details__container container__grid" ]
                    [ div [ class "details__controls details__controls-left" ]
                        [ a [ href Routes.plantsPath ]
                            [ backButton, text "Back to Plants" ]
                        ]
                    , div [ class "details__controls details__controls-right" ]
                        [ a
                            [ href <| Routes.editPlantPath plant.id
                            ]
                            [ editButton, text "Edit" ]
                        , div
                            [ onClick (UserClickedDeletePlant plant.id) ]
                            [ deleteButton, text "Delete" ]
                        ]
                    , div
                        [ class "details__image with_loader" ]
                        [ img
                            [ src plant.avatarUrl
                            , onClick UserSelectedUploadNewPhoto
                            , class "avatar"
                            ]
                            []
                        , loadingOverlay model.upload
                        ]
                    , viewPlantDetails plant
                    ]
                , viewCheckInsList plant.checkIns model.timeZone
                , viewModal model.modal
                ]

        Nothing ->
            div [ class "container__center centered-text" ]
                [ div [] [ text "Loading..." ] ]


viewPlantDetails : Plant.Plant -> Html Msg
viewPlantDetails plant =
    div [ class "details__section" ]
        [ h2 [ class "details__name" ] [ text plant.name ]
        , h4 [ class "details__botanical-name" ] [ text "Botanical Name" ]
        , p [ class "details__copy" ] [ text lorem ]
        ]


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
                            [ class "loader_bar__foreground"
                            , style "width" percentageString
                            ]
                            []
                        , div [ class "loader_bar__text" ]
                            [ text uploadingText ]
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
    div [ class "check_in__container" ] checkInRows


viewCheckInRow : Time.Zone -> CheckIn.CheckIn -> Html msg
viewCheckInRow timeZone checkIn =
    div [ class "check_in__item" ]
        [ div [ class "check_in__item-header" ] (checkInRowHeader checkIn)
        , div [ class "check_in__item-body" ] [ text checkIn.notes ]
        , div [ class "check_in__item-footer" ] [ text "tags" ]
        ]


checkInRowHeader : CheckIn.CheckIn -> List (Html msg)
checkInRowHeader checkIn =
    [ div [ class "check_in__item-calendar" ]
        [ div [ class "month" ] [ text <| monthText checkIn.createdAt ]
        , div [ class "day" ] [ text <| dayText checkIn.createdAt ]
        ]
    , div [ class "check_in__item-actions" ]
        [ div [] [ text <| "Watered: " ++ yesOrNo checkIn.watered ]
        , div [] [ text <| "Fertilized: " ++ yesOrNo checkIn.fertilized ]
        ]
    , div [ class "check_in__item-photos" ] <| checkInPhotos checkIn.photos
    ]


checkInPhotos : List CheckIn.PhotoUrls -> List (Html msg)
checkInPhotos photoUrls =
    let
        imageTags =
            List.map toImageTag photoUrls
    in
    imageTags


toImageTag : CheckIn.PhotoUrls -> Html msg
toImageTag photoUrls =
    a [ href photoUrls.original, target "_blank" ]
        [ img [ src photoUrls.preview ] [] ]


monthText : Time.Posix -> String
monthText time =
    Time.toMonth Time.utc time
        |> DateAndTime.englishMonthAbbreviation
        |> String.toUpper


dayText : Time.Posix -> String
dayText time =
    Time.toDay Time.utc time
        |> String.fromInt


yesOrNo : Bool -> String
yesOrNo bool =
    if bool then
        "Yes"

    else
        "No"


lorem : String
lorem =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc convallis"
        ++ "laoreet risus, vel condimentum ligula iaculis id. Suspendisse mi turpis,"
        ++ "aliquet id dignissim non, iaculis in risus. Mauris mattis augue in quam"
        ++ "ultrices, sed mattis urna laoreet. Quisque blandit ac nunc sit amet"
        ++ "ullamcorper. Pellentesque ultrices felis quis lorem eleifend, et placerat"
        ++ "nulla molestie. "



-- MODAL


viewModal : Modal.Modal Msg -> Html Msg
viewModal modal =
    case modal of
        Modal content ->
            content

        _ ->
            div [] []


cropperModal : Model -> Html Msg
cropperModal model =
    div [ class "modal__bg" ]
        [ div [ class "modal__container--large" ]
            [ Modal.modalHeader "Crop your image"
            , div [ class "modal__content--large" ]
                [ div [ class "modal__cropper" ]
                    [ div [ id "croppie" ] [] ]
                , Modal.modalFooter
                    [ button [ id "croppie_rotate_l" ]
                        [ text "Rotate Left"
                        ]
                    , button [ onClick UserCroppedPhoto, id "croppie_button" ]
                        [ text "Crop"
                        ]
                    , button [ id "croppie_rotate_r" ]
                        [ text "Rotate Right"
                        ]
                    ]
                ]
            ]
        ]



-- ICONS


backButton : Html Msg
backButton =
    defaultOptions
        |> Octicons.chevronLeft


editButton : Html Msg
editButton =
    defaultOptions
        |> Octicons.pencil


deleteButton : Html Msg
deleteButton =
    defaultOptions
        |> Octicons.trashcan
