module Pages.UserForm exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Routes
import User


type alias Model =
    { firstName : String, lastName : String, email : String, password : String }


type Msg
    = UserEnteredFirstName String
    | UserEnteredLastName String
    | UserEnteredEmail String
    | UserEnteredPassword String
    | UserSubmittedForm
    | UserCreated (Result Http.Error User.User)


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" "", Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model key =
    case msg of
        UserEnteredFirstName value ->
            ( { model | firstName = value }, Cmd.none )

        UserEnteredLastName value ->
            ( { model | lastName = value }, Cmd.none )

        UserEnteredEmail value ->
            ( { model | email = value }, Cmd.none )

        UserEnteredPassword value ->
            ( { model | password = value }, Cmd.none )

        UserSubmittedForm ->
            ( model, createUser model )

        UserCreated (Ok user) ->
            ( model, Nav.pushUrl key Routes.plantsPath )

        UserCreated (Err error) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "form container" ]
        [ h2 [] [ text "Sign Up" ]
        , input
            [ placeholder "First Name"
            , value model.firstName
            , onInput UserEnteredFirstName
            ]
            []
        , input
            [ placeholder "Last Name"
            , value model.lastName
            , onInput UserEnteredLastName
            ]
            []
        , input
            [ placeholder "Email"
            , value model.email
            , onInput UserEnteredEmail
            ]
            []
        , input
            [ placeholder "Password"
            , value model.password
            , onInput UserEnteredPassword
            ]
            []
        , button [ onClick UserSubmittedForm ] [ text "Submit" ]
        ]


createUser : Model -> Cmd Msg
createUser model =
    User.createUser UserCreated model
