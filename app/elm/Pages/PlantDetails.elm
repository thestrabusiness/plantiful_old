module Pages.PlantDetails exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Http
import Plant
import User


type alias Model =
    { plant : Maybe Plant.Plant, currentUser : User.User }


type Msg
    = ReceivedGetPlantResponse (Result Http.Error Plant.Plant)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedGetPlantResponse (Ok plant) ->
            ( { model | plant = Just plant }, Cmd.none )

        ReceivedGetPlantResponse (Err error) ->
            ( model, Cmd.none )


init : User.User -> Int -> ( Model, Cmd Msg )
init user plantId =
    ( Model Nothing user, getPlant plantId )


getPlant : Int -> Cmd Msg
getPlant id =
    Plant.getPlant id ReceivedGetPlantResponse


view : Model -> Html msg
view model =
    case model.plant of
        Just plant ->
            div [ class "container__center centered-text" ]
                [ div [] [ text <| "Plant name: " ++ plant.name ]
                ]

        Nothing ->
            div [ class "container__center centered-text" ] [ div [] [ text "Loading..." ] ]
