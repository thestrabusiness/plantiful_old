module Pages.SignIn exposing (Model, Msg, init, update, view)

import Api exposing (networkError, somethingWentWrongError, unauthorizedError)
import Browser.Navigation as Nav
import Form exposing (errorsForField)
import Html exposing (Html, a, button, div, h2, input, label, text)
import Html.Attributes exposing (class, href, value)
import Html.Events exposing (onClick, onInput)
import Http
import Routes
import Session
import User exposing (User)
import Validate exposing (Validator, fromValid, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { email : String
    , password : String
    , errors : List Error
    , apiError : String
    , csrfToken : String
    }


type Msg
    = UserEditedField Field String
    | UserSubmittedForm
    | ReceivedSignInResponse (Result Http.Error User)


type Field
    = Email
    | Password


type alias Error =
    ( Field, String )


init : String -> ( Model, Cmd Msg )
init csrfToken =
    ( Model "" "" [] "" csrfToken, Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg, Maybe User )
update msg model key =
    case msg of
        UserEditedField field value ->
            ( setField field value model, Cmd.none, Nothing )

        UserSubmittedForm ->
            case validate modelValidator model of
                Ok validatedModel ->
                    let
                        validModel =
                            fromValid validatedModel
                    in
                    ( { validModel | errors = [] }
                    , Session.signIn model.csrfToken
                        ReceivedSignInResponse
                        (Session.toCredentials model)
                    , Nothing
                    )

                Err errorList ->
                    ( { model | errors = errorList }, Cmd.none, Nothing )

        ReceivedSignInResponse (Ok user) ->
            ( model
            , Nav.pushUrl key (Routes.gardenPath user.defaultGardenId)
            , Just user
            )

        ReceivedSignInResponse (Err error) ->
            case error of
                Http.BadStatus code ->
                    case code of
                        401 ->
                            ( { model | apiError = unauthorizedError }, Cmd.none, Nothing )

                        _ ->
                            ( { model | apiError = somethingWentWrongError }, Cmd.none, Nothing )

                Http.NetworkError ->
                    ( { model | apiError = networkError }
                    , Cmd.none
                    , Nothing
                    )

                _ ->
                    ( { model | apiError = somethingWentWrongError }, Cmd.none, Nothing )


setField : Field -> String -> Model -> Model
setField field value model =
    case field of
        Email ->
            { model | email = value }

        Password ->
            { model | password = value }


view : Model -> Html Msg
view model =
    div [ class "form container__center container__shadow" ]
        [ h2 [] [ text "Sign In" ]
        , div [ class "errors" ] [ text model.apiError ]
        , textField Email model.errors "Email" model.email
        , passwordField Password model.errors "Password" model.password
        , div [ class "hint" ]
            [ text "Don't have an account yet? "
            , a [ href "/sign_up" ]
                [ text "Sign up"
                ]
            ]
        , button
            [ onClick UserSubmittedForm ]
            [ text "Sign in" ]
        ]


textField : Field -> List Error -> String -> String -> Html Msg
textField field errors =
    let
        fieldErrors =
            errorsForField field errors
    in
    Form.textField (UserEditedField field) UserSubmittedForm fieldErrors


passwordField : Field -> List Error -> String -> String -> Html Msg
passwordField field errors =
    let
        fieldErrors =
            errorsForField field errors
    in
    Form.passwordField (UserEditedField field) UserSubmittedForm fieldErrors


modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifBlank .email ( Email, "Email can't be blank" )
        , ifInvalidEmail .email (\_ -> ( Email, "Isn't the right format" ))
        , ifBlank .password ( Password, "Password can't be blank" )
        ]
