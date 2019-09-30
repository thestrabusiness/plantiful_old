module Pages.UserForm exposing (Model, Msg, init, update, view)

import Api exposing (networkError, somethingWentWrongError)
import Browser.Navigation as Nav
import Form exposing (errorsForField)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Routes
import User exposing (User)
import Validate exposing (Validator, fromValid, ifBlank, ifFalse, ifInvalidEmail, validate)


type alias Model =
    { firstName : String
    , lastName : String
    , email : String
    , password : String
    , passwordConfirmation : String
    , errors : List Error
    , apiError : String
    , csrfToken : String
    }


type Msg
    = UserSubmittedForm
    | UserCreated (Result Http.Error User.User)
    | UserEditedField Field String


type Field
    = FirstName
    | LastName
    | Email
    | Password
    | PasswordConfirmation


type alias Error =
    ( Field, String )


init : String -> ( Model, Cmd Msg )
init csrfToken =
    ( Model "" "" "" "" "" [] "" csrfToken, Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg, Maybe User )
update msg model key =
    case msg of
        UserSubmittedForm ->
            case validate modelValidator model of
                Ok validatedModel ->
                    let
                        validModel =
                            fromValid validatedModel
                    in
                    ( { validModel | errors = [] }
                    , createUser model.csrfToken (toNewUser model)
                    , Nothing
                    )

                Err errorList ->
                    ( { model | errors = errorList }, Cmd.none, Nothing )

        UserCreated (Ok user) ->
            ( model, Nav.pushUrl key Routes.plantsPath, Just user )

        UserCreated (Err error) ->
            case error of
                Http.NetworkError ->
                    ( { model | apiError = networkError }, Cmd.none, Nothing )

                Http.BadStatus code ->
                    case code of
                        422 ->
                            ( { model | apiError = unProcessableError }, Cmd.none, Nothing )

                        _ ->
                            ( { model | apiError = somethingWentWrongError }
                            , Cmd.none
                            , Nothing
                            )

                _ ->
                    ( { model | apiError = somethingWentWrongError }
                    , Cmd.none
                    , Nothing
                    )

        UserEditedField field value ->
            ( setField field value model, Cmd.none, Nothing )


unProcessableError : String
unProcessableError =
    "Are you sure you didn't already sign up?"


setField : Field -> String -> Model -> Model
setField field value model =
    case field of
        FirstName ->
            { model | firstName = value }

        LastName ->
            { model | lastName = value }

        Email ->
            { model | email = value }

        Password ->
            { model | password = value }

        PasswordConfirmation ->
            { model | passwordConfirmation = value }


view : Model -> Html Msg
view model =
    div [ class "form container__center container__shadow" ]
        [ h2 [] [ text "Sign Up" ]
        , div [ class "errors" ] [ text model.apiError ]
        , textField FirstName model.errors "First Name" model.firstName
        , textField LastName model.errors "Last Name" model.lastName
        , textField Email model.errors "Email" model.email
        , passwordField Password model.errors "Password" model.password
        , passwordField PasswordConfirmation
            model.errors
            "Confirm Password"
            model.passwordConfirmation
        , button [ onClick UserSubmittedForm ] [ text "Submit" ]
        ]


passwordField : Field -> List Error -> String -> String -> Html Msg
passwordField field errors =
    let
        fieldErrors =
            errorsForField field errors
    in
    Form.passwordField (UserEditedField field) UserSubmittedForm fieldErrors


textField : Field -> List Error -> String -> String -> Html Msg
textField field errors =
    let
        fieldErrors =
            errorsForField field errors
    in
    Form.textField (UserEditedField field) UserSubmittedForm fieldErrors


createUser : String -> User.NewUser -> Cmd Msg
createUser csrfToken newUser =
    User.createUser csrfToken UserCreated newUser


toNewUser : Model -> User.NewUser
toNewUser { firstName, lastName, email, password } =
    User.NewUser firstName lastName email password


modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifBlank .email ( Email, "Email can't be blank" )
        , ifInvalidEmail .email (\_ -> ( Email, "Isn't the right format" ))
        , ifBlank .password ( Password, "Password can't be blank" )
        , ifBlank .firstName ( FirstName, "First name can't be blank" )
        , ifBlank .lastName ( LastName, "Last name can't be blank" )
        , ifFalse (\model -> model.password == model.passwordConfirmation)
            ( Password, "Passwords must match" )
        , ifFalse (\model -> model.password == model.passwordConfirmation)
            ( PasswordConfirmation
            , "Passwords must match"
            )
        ]
