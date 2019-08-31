module Pages.PlantDetails exposing (Model, Msg, init, update, view)

import CheckIn
import DateAndTime
import Html exposing (Html, div, h2, text)
import Html.Attributes exposing (class)
import Http
import Plant
import Time
import User


type alias Model =
    { plant : Maybe Plant.Plant
    , currentUser : User.User
    , timeZone : Time.Zone
    }


type Msg
    = ReceivedGetPlantResponse (Result Http.Error Plant.Plant)


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


init : Int -> User.User -> Time.Zone -> ( Model, Cmd Msg )
init plantId user timeZone =
    ( Model Nothing user timeZone, getPlant plantId )


getPlant : Int -> Cmd Msg
getPlant id =
    Plant.getPlant id ReceivedGetPlantResponse


view : Model -> Html msg
view model =
    case model.plant of
        Just plant ->
            div [ class "container__center" ]
                [ h2 [ class "centered-text" ] [ text plant.name ]
                , viewCheckInsList plant.checkIns model.timeZone
                ]

        Nothing ->
            div [ class "container__center centered-text" ]
                [ div [] [ text "Loading..." ] ]


viewCheckInsList : List CheckIn.CheckIn -> Time.Zone -> Html msg
viewCheckInsList checkInsList timeZone =
    let
        checkInRows =
            List.map (viewCheckInRow timeZone) checkInsList
    in
    div [] checkInRows


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
