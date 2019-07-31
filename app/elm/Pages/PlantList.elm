module Pages.PlantList exposing (Model, Msg(..), card, cardImageUrl, getPlants, init, update, updatePlantsList, view, viewPlantList)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Plant
import Routes exposing (newPlantPath)
import User exposing (User)


type alias Model =
    { plants : List Plant.Plant
    , currentUser : User
    }


type Msg
    = NewPlants (Result Http.Error (List Plant.Plant))
    | WaterPlant Plant.Plant
    | UpdatePlant (Result Http.Error Plant.Plant)


init : User -> ( Model, Cmd Msg )
init user =
    ( Model [] user, getPlants )


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


updatePlantsList : List Plant.Plant -> Plant.Plant -> List Plant.Plant
updatePlantsList currentPlantList updatedPlant =
    let
        updatePlant plant =
            if plant.id == updatedPlant.id then
                { plant | lastWateringDate = updatedPlant.lastWateringDate }

            else
                plant
    in
    List.map updatePlant currentPlantList



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewPlantList model.plants
        , a [ class "add-record-btn", href newPlantPath ] [ text "Add New Plant" ]
        ]


viewPlantList : List Plant.Plant -> Html Msg
viewPlantList plants =
    let
        listOfPlants =
            List.map card plants
    in
    div [ class "cards" ] listOfPlants


cardImageUrl : String
cardImageUrl =
    "https://raw.githubusercontent.com/thoughtbot/refills/master/source/images/mountains.png"


card : Plant.Plant -> Html Msg
card plant =
    div [ class "card" ]
        [ div [ class "card-image" ]
            [ img [ src cardImageUrl ] [] ]
        , div [ class "card-header" ] [ text plant.name ]
        , div [ class "card-copy" ]
            [ ul []
                [ li [] [ text "Botanical Name" ]
                , li [] [ text plant.lastWateringDate ]
                , li []
                    [ button [ onClick (WaterPlant plant) ]
                        [ text "Water" ]
                    ]
                ]
            ]
        ]



-- API


getPlants : Cmd Msg
getPlants =
    Plant.getPlants NewPlants


waterPlant : Plant.Plant -> Cmd Msg
waterPlant plant =
    Plant.waterPlant UpdatePlant plant
