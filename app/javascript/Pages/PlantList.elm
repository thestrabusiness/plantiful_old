module Pages.PlantList exposing (Model, Msg(..), card, getPlants, init, lastWateringDateText, update, view, viewPlantList)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Plant
import Routes


type alias Model =
    { plants : List Plant.Plant }


type Msg
    = NewPlants (Result Http.Error (List Plant.Plant))


init : ( Model, Cmd Msg )
init =
    ( Model [], getPlants )


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



-- VIEW


view : Model -> Html Msg
view model =
    viewPlantList model.plants


viewPlantList : List Plant.Plant -> Html msg
viewPlantList plants =
    let
        listOfPlants =
            List.map card plants
    in
    div [ class "cards" ] listOfPlants


lastWateringDateText : Maybe String -> Html msg
lastWateringDateText lastWateringDate =
    case lastWateringDate of
        Just dateString ->
            text dateString

        Nothing ->
            text "Not yet watered"


card : Plant.Plant -> Html msg
card plant =
    div [ class "card" ]
        [ div [ class "card-image" ]
            [ img
                [ src
                    "https://raw.githubusercontent.com/thoughtbot/refills/master/source/images/mountains.png"
                ]
                []
            ]
        , div [ class "card-header" ] [ text plant.name ]
        , div [ class "card-copy" ]
            [ ul []
                [ li [] [ text "Botanical Name" ]
                , li [] [ lastWateringDateText plant.last_watering_date ]
                , li [] [ text "Placeholder Text" ]
                ]
            ]
        ]



-- API


getPlants : Cmd Msg
getPlants =
    Plant.getPlants NewPlants
