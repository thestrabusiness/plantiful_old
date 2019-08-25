module Pages.PlantForm exposing (Model, Msg, init, update, view)

import Api exposing (networkError, somethingWentWrongError, unauthorizedError)
import Browser.Navigation as Nav
import Form exposing (errorsForField, onEnter)
import Html exposing (..)
import Html.Attributes exposing (class, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Plant
import Routes
import User exposing (User)
import Validate exposing (Validator, fromValid, ifBlank, ifNotInt, validate)


type alias Model =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    , currentUser : User
    , errors : List Error
    , apiError : String
    }


type Msg
    = UserEditedField Field String
    | UserSubmittedForm
    | PlantCreated (Result Http.Error Plant.Plant)


type Field
    = Name
    | CheckFrequencyUnit
    | CheckFrequencyScalar


type alias Error =
    ( Field, String )


init : User -> ( Model, Cmd Msg )
init user =
    ( Model "" "day" "3" user [] "", Cmd.none )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model key =
    case msg of
        UserEditedField field value ->
            ( setField field value model, Cmd.none )

        UserSubmittedForm ->
            case validate modelValidator model of
                Ok validatedModel ->
                    ( fromValid validatedModel, createNewPlant model )

                Err errorList ->
                    ( { model | errors = errorList }, Cmd.none )

        PlantCreated (Ok plant) ->
            ( model, Nav.pushUrl key Routes.plantsPath )

        PlantCreated (Err error) ->
            case error of
                Http.BadStatus code ->
                    case code of
                        401 ->
                            ( model, Nav.pushUrl key Routes.signInPath )

                        _ ->
                            ( { model | apiError = somethingWentWrongError }, Cmd.none )

                Http.NetworkError ->
                    ( { model | apiError = networkError }, Cmd.none )

                _ ->
                    ( { model | apiError = somethingWentWrongError }, Cmd.none )


setField : Field -> String -> Model -> Model
setField field value model =
    case field of
        Name ->
            { model | name = value }

        CheckFrequencyUnit ->
            { model | checkFrequencyUnit = value }

        CheckFrequencyScalar ->
            { model | checkFrequencyScalar = value }


view : Model -> Html Msg
view model =
    div [ class "form container__center container__shadow" ]
        [ h2 [] [ text "Add a Plant" ]
        , textField Name model.errors "Name" model.name
        , label []
            [ text "Check Frequency"
            , div [ class "clearfix" ] []
            , input
                [ type_ "number"
                , class "input__number input__check"
                , value model.checkFrequencyScalar
                , onInput <| UserEditedField CheckFrequencyScalar
                , onEnter UserSubmittedForm
                ]
                []
            , checkFrequencySelect model
            ]
        , button [ onClick UserSubmittedForm ] [ text "Submit" ]
        ]


checkFrequencySelect : Model -> Html Msg
checkFrequencySelect model =
    select
        [ class "input__select input__check"
        , onInput <| UserEditedField CheckFrequencyUnit
        ]
        [ selectOption "Day" "day" model.checkFrequencyUnit
        , selectOption "Week" "week" model.checkFrequencyUnit
        ]


selectOption : String -> String -> String -> Html Msg
selectOption label optionValue selection =
    let
        isSelected =
            optionValue == selection
    in
    option [ value optionValue, selected isSelected ] [ text label ]


textField : Field -> List Error -> String -> String -> Html Msg
textField field errors =
    let
        fieldErrors =
            errorsForField field errors
    in
    Form.textField (UserEditedField field) UserSubmittedForm fieldErrors


modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, "Name can't be blank" )
        , ifBlank .checkFrequencyScalar ( CheckFrequencyScalar, "Can't be blank" )
        , ifNotInt .checkFrequencyScalar (\_ -> ( CheckFrequencyScalar, "Must be a number" ))
        ]


createNewPlant : Model -> Cmd Msg
createNewPlant model =
    Plant.createPlant PlantCreated (Plant.toNewPlant model)
