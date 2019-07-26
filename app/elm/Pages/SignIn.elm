module Pages.SignIn exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Html exposing (Html, button, div, h2, input, label, text)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Http
import Routes
import User exposing (User)


type alias Model =
    { email : String
    , password : String
    }


type Msg
    = UserEnteredEmail String
    | UserEnteredPassword String
    | UserClickedSubmitButton
    | ReceivedSignInResponse (Result Http.Error User)


init : ( Model, Cmd Msg )
init =
    ( Model "" "", Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg, Maybe User )
update msg model key =
    case msg of
        UserEnteredEmail value ->
            ( { model | email = value }, Cmd.none, Nothing )

        UserEnteredPassword value ->
            ( { model | password = value }, Cmd.none, Nothing )

        UserClickedSubmitButton ->
            ( model, User.signIn ReceivedSignInResponse model, Nothing )

        ReceivedSignInResponse (Ok user) ->
            ( model, Nav.pushUrl key Routes.plantsPath, Just user )

        ReceivedSignInResponse (Err error) ->
            ( model, Cmd.none, Nothing )


view : Model -> Html Msg
view model =
    div [ class "form container" ]
        [ h2 [] [ text "Sign In" ]
        , label []
            [ text "Email"
            , input
                [ value model.email
                , onInput UserEnteredEmail
                ]
                []
            ]
        , label []
            [ text "Password"
            , input
                [ value model.password
                , onInput UserEnteredPassword
                ]
                []
            ]
        , button
            [ onClick UserClickedSubmitButton ]
            [ text "Sign in" ]
        ]
