module Pages.List exposing (Model, Msg(..), getPlants, init, update, view, viewPlant, viewPlantList)

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


viewPlant : Plant.Plant -> Html msg
viewPlant plant =
    li [] [ text plant.name ]


viewPlantList : List Plant.Plant -> Html msg
viewPlantList plants =
    let
        listOfPlants =
            List.map viewPlant plants
    in
    ul [] listOfPlants



-- API


getPlants : Cmd Msg
getPlants =
    Plant.getPlants NewPlants
