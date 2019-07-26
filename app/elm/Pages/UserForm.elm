module Pages.UserForm exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Form exposing (errorsForField)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Routes
import User exposing (User)
import Validate exposing (Validator, fromValid, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { firstName : String
    , lastName : String
    , email : String
    , password : String
    , errors : List Error
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


type alias Error =
    ( Field, String )


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" "" [], Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg, Maybe User )
update msg model key =
    case msg of
        UserSubmittedForm ->
            case validate modelValidator model of
                Ok validatedModel ->
                    ( fromValid validatedModel, createUser (toNewUser model), Nothing )

                Err errorList ->
                    ( { model | errors = errorList }, Cmd.none, Nothing )

        UserCreated (Ok user) ->
            ( model, Nav.pushUrl key Routes.plantsPath, Just user )

        UserCreated (Err error) ->
            ( model, Cmd.none, Nothing )

        UserEditedField field value ->
            ( setField field value model, Cmd.none, Nothing )


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


view : Model -> Html Msg
view model =
    div [ class "form container" ]
        [ h2 [] [ text "Sign Up" ]
        , textField FirstName model.errors "First Name" model.firstName
        , textField LastName model.errors "Last Name" model.lastName
        , textField Email model.errors "Email" model.email
        , textField Password model.errors "Password" model.password
        , button [ onClick UserSubmittedForm ] [ text "Submit" ]
        ]


textField : Field -> List Error -> String -> String -> Html Msg
textField field errors =
    let
        fieldErrors =
            errorsForField field errors
    in
    Form.textField (UserEditedField field) fieldErrors


createUser : User.NewUser -> Cmd Msg
createUser newUser =
    User.createUser UserCreated newUser


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
        ]
