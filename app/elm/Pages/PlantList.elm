module Pages.PlantList exposing (Model, Msg(..), card, cardImageUrl, getPlants, init, update, updatePlantsList, view, viewPlantList)

import DateAndTime
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Plant
import Routes exposing (newPlantPath)
import Task
import Time exposing (Posix)
import User exposing (User)


type alias Model =
    { plants : List Plant.Plant
    , currentUser : User
    , currentTime : Posix
    , currentTimeZone : Time.Zone
    }


type Msg
    = NewPlants (Result Http.Error (List Plant.Plant))
    | WaterPlant Plant.Plant
    | UpdatePlant (Result Http.Error Plant.Plant)
    | ReceivedCurrentTime Time.Posix
    | ReceivedTimeZone Time.Zone


init : User -> ( Model, Cmd Msg )
init user =
    ( Model [] user initialTime Time.utc
    , Cmd.batch [ getCurrentTime, getTimeZone, getPlants ]
    )


getCurrentTime : Cmd Msg
getCurrentTime =
    Task.perform ReceivedCurrentTime Time.now


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform ReceivedTimeZone Time.here


initialTime : Posix
initialTime =
    Time.millisToPosix 0


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewPlants (Ok newPlants) ->
            ( { model | plants = newPlants }, Cmd.none )

        NewPlants (Err error) ->
            let
                _ =
                    Debug.log "Whoops!" error
            in
            ( model, Cmd.none )

        UpdatePlant (Ok updatedPlant) ->
            let
                newPlantsList =
                    updatePlantsList model.plants updatedPlant
            in
            ( { model | plants = newPlantsList }, Cmd.none )

        UpdatePlant (Err error) ->
            let
                _ =
                    Debug.log "Whoops!" error
            in
            ( model, Cmd.none )

        WaterPlant plant ->
            ( model, waterPlant plant )

        ReceivedTimeZone zone ->
            ( { model | currentTimeZone = zone }, Cmd.none )

        ReceivedCurrentTime time ->
            ( { model | currentTime = time }, Cmd.none )


updatePlantsList : List Plant.Plant -> Plant.Plant -> List Plant.Plant
updatePlantsList currentPlantList updatedPlant =
    let
        updatePlant plant =
            if plant.id == updatedPlant.id then
                { plant | lastWateredAt = updatedPlant.lastWateredAt }

            else
                plant
    in
    List.map updatePlant currentPlantList



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewPlantList model
        , a [ class "add-record-btn", href newPlantPath ] [ text "Add New Plant" ]
        ]


viewPlantList : Model -> Html Msg
viewPlantList model =
    let
        listOfPlants =
            List.map (card model.currentTime) model.plants
    in
    div [ class "cards" ] listOfPlants


cardImageUrl : String
cardImageUrl =
    "https://thumbs.dreamstime.com/z/growing-plant-3599470.jpg"


card : Posix -> Plant.Plant -> Html Msg
card currentTime plant =
    div [ class "card" ]
        [ div [ class "card-image" ]
            [ img [ src cardImageUrl ] [] ]
        , div [ class "card-header" ] [ text plant.name ]
        , div [ class "card-copy" ]
            [ ul []
                [ li [] [ text "Botanical Name" ]
                , li [] [ text <| distanceInDays currentTime plant.lastWateredAt ]
                , li []
                    [ button [ onClick (WaterPlant plant) ]
                        [ text "Water" ]
                    ]
                ]
            ]
        ]


distanceInDays : Posix -> Posix -> String
distanceInDays currentTime wateredAt =
    if Time.posixToMillis wateredAt == 0 then
        "Not Yet Watered"

    else
        DateAndTime.distanceInDays currentTime wateredAt



-- API


getPlants : Cmd Msg
getPlants =
    Plant.getPlants NewPlants


waterPlant : Plant.Plant -> Cmd Msg
waterPlant plant =
    Plant.waterPlant UpdatePlant plant
