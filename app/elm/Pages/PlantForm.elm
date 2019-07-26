module Pages.PlantForm exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Plant
import Routes
import User exposing (User)


type alias Model =
    { name : String
    , currentUser : User
    }


type Msg
    = UserEnteredPlantName String
    | UserSubmittedForm
    | PlantCreated (Result Http.Error Plant.Plant)


init : User -> ( Model, Cmd Msg )
init user =
    ( Model "" user, Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model key =
    case msg of
        UserEnteredPlantName string ->
            ( { model | name = string }, Cmd.none )

        UserSubmittedForm ->
            ( model, createNewPlant model.name )

        PlantCreated (Ok plant) ->
            ( model, Nav.pushUrl key Routes.plantsPath )

        PlantCreated (Err error) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "form container" ]
        [ h2 [] [ text "Add a Plant" ]
        , input
            [ placeholder "Name"
            , value model.name
            , onInput UserEnteredPlantName
            ]
            []
        , button [ onClick UserSubmittedForm ] [ text "Submit" ]
        ]


createNewPlant : String -> Cmd Msg
createNewPlant name =
    Plant.createPlant PlantCreated name
