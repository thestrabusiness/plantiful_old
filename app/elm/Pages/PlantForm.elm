module Pages.PlantForm exposing (Model, Msg, init, update, view)

import Api exposing (networkError, somethingWentWrongError, unauthorizedError)
import Browser.Navigation as Nav
import Form exposing (errorsForField, onEnter)
import Html exposing (..)
import Html.Attributes exposing (class, id, name, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Plant
import Routes
import User exposing (User)
import Validate exposing (Validator, fromValid, ifBlank, ifNotInt, validate)


type alias Model =
    { plant : PlantForm
    , currentUser : User
    , errors : List Error
    , apiError : String
    , csrfToken : String
    , formAction : Form.FormAction
    , plantId : Maybe Int
    }


type Msg
    = UserEditedField Field String
    | UserSubmittedForm
    | UserCancelledForm
    | ReceivedCreatePlantResponse (Result Http.Error Plant.Plant)
    | ReceivedGetPlantResponse (Result Http.Error Plant.Plant)
    | ReceivedUpdatePlantResponse (Result Http.Error Plant.Plant)


type Field
    = Name
    | CheckFrequencyUnit
    | CheckFrequencyScalar


type alias Error =
    ( Field, String )


type alias PlantForm =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    }


init : String -> User -> Maybe Int -> ( Model, Cmd Msg )
init csrfToken user maybeId =
    let
        formAction =
            case maybeId of
                Just _ ->
                    Form.Update

                Nothing ->
                    Form.Create

        initialModel =
            Model initialPlantForm user [] "" csrfToken formAction maybeId
    in
    ( initialModel, loadPlant maybeId )


initialPlantForm : PlantForm
initialPlantForm =
    { name = "", checkFrequencyScalar = "", checkFrequencyUnit = "day" }


loadPlant : Maybe Int -> Cmd Msg
loadPlant maybeId =
    case maybeId of
        Just id ->
            Plant.getPlant id ReceivedGetPlantResponse

        Nothing ->
            Cmd.none


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model key =
    case msg of
        UserEditedField field value ->
            ( setField field value model, Cmd.none )

        UserSubmittedForm ->
            let
                validateForm =
                    validate formValidator model.plant
            in
            case ( validateForm, model.formAction, model.plantId ) of
                ( Ok validatedForm, Form.Create, _ ) ->
                    let
                        validPlant =
                            fromValid validatedForm
                    in
                    ( model, createNewPlant model.csrfToken validPlant )

                ( Ok validatedForm, Form.Update, Just plantId ) ->
                    let
                        validPlant =
                            fromValid validatedForm
                    in
                    ( model, updatePlant model.csrfToken plantId validPlant )

                ( Ok _, _, _ ) ->
                    ( model, Cmd.none )

                ( Err errorList, _, _ ) ->
                    ( { model | errors = errorList }, Cmd.none )

        UserCancelledForm ->
            case ( model.formAction, model.plantId ) of
                ( Form.Create, _ ) ->
                    ( model, goBackToPlantsList key )

                ( Form.Update, Just plantId ) ->
                    ( model, goBackToPlantDetails key plantId )

                ( _, _ ) ->
                    ( model, Cmd.none )

        ReceivedCreatePlantResponse (Ok plant) ->
            ( model, goBackToPlantsList key )

        ReceivedCreatePlantResponse (Err error) ->
            handleErrorResponse model error key

        ReceivedGetPlantResponse (Ok plant) ->
            ( { model | plant = plantToForm plant }, Cmd.none )

        ReceivedGetPlantResponse (Err error) ->
            handleErrorResponse model error key

        ReceivedUpdatePlantResponse (Ok plant) ->
            ( model, goBackToPlantDetails key plant.id )

        ReceivedUpdatePlantResponse (Err error) ->
            handleErrorResponse model error key


handleErrorResponse : Model -> Http.Error -> Nav.Key -> ( Model, Cmd Msg )
handleErrorResponse model error key =
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


goBackToPlantsList : Nav.Key -> Cmd Msg
goBackToPlantsList key =
    Nav.pushUrl key Routes.plantsPath


goBackToPlantDetails : Nav.Key -> Int -> Cmd Msg
goBackToPlantDetails key plantId =
    Nav.pushUrl key (Routes.plantPath plantId)


plantToForm : Plant.Plant -> PlantForm
plantToForm plant =
    { name = plant.name
    , checkFrequencyUnit = plant.checkFrequencyUnit
    , checkFrequencyScalar = plant.checkFrequencyScalar
    }


setField : Field -> String -> Model -> Model
setField field value model =
    let
        plant =
            model.plant

        updatedPlant =
            case field of
                Name ->
                    { plant | name = value }

                CheckFrequencyUnit ->
                    { plant | checkFrequencyUnit = value }

                CheckFrequencyScalar ->
                    { plant | checkFrequencyScalar = value }
    in
    { model | plant = updatedPlant }


view : Model -> Html Msg
view model =
    let
        form =
            model.plant
    in
    div [ class "form container__center container__shadow" ]
        [ viewHeaderText model.formAction
        , textField Name model.errors "Name" form.name
        , label [ id "check_frequency" ]
            [ text "Check Frequency"
            , div [ class "check_frequency_inputs" ]
                [ input
                    [ type_ "number"
                    , name "check_frequency_scalar"
                    , class "input__number input__check"
                    , value form.checkFrequencyScalar
                    , onInput <| UserEditedField CheckFrequencyScalar
                    , onEnter UserSubmittedForm
                    ]
                    []
                , checkFrequencySelect form
                ]
            ]
        , button [ class "secondary", onClick UserCancelledForm ] [ text "Cancel" ]
        , button [ onClick UserSubmittedForm ] [ text "Submit" ]
        ]


viewHeaderText : Form.FormAction -> Html Msg
viewHeaderText formAction =
    let
        headerText =
            case formAction of
                Form.Create ->
                    "Add a plant"

                Form.Update ->
                    "Edit plant"
    in
    h2 [] [ text headerText ]


checkFrequencySelect : PlantForm -> Html Msg
checkFrequencySelect form =
    let
        selectedUnit =
            form.checkFrequencyUnit

        selectedScalar =
            form.checkFrequencyScalar

        dayLabel =
            daySelectLabel <| String.toInt selectedScalar

        weekLabel =
            weekSelectLabel <| String.toInt selectedScalar
    in
    select
        [ class "input__select input__check"
        , name "check_frequency_unit"
        , onInput <| UserEditedField CheckFrequencyUnit
        ]
        [ selectOption dayLabel "day" selectedUnit
        , selectOption weekLabel "week" selectedUnit
        ]


pluralize : String -> String -> Maybe Int -> String
pluralize singular plural maybeCount =
    case maybeCount of
        Just count ->
            if count > 1 then
                plural

            else
                singular

        Nothing ->
            singular


daySelectLabel : Maybe Int -> String
daySelectLabel count =
    pluralize "Day" "Days" count


weekSelectLabel : Maybe Int -> String
weekSelectLabel count =
    pluralize "Week" "Weeks" count


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


formValidator : Validator Error PlantForm
formValidator =
    Validate.all
        [ ifBlank .name ( Name, "Name can't be blank" )
        , ifBlank .checkFrequencyScalar ( CheckFrequencyScalar, "Can't be blank" )
        , ifNotInt .checkFrequencyScalar (\_ -> ( CheckFrequencyScalar, "Must be a number" ))
        ]


createNewPlant : String -> PlantForm -> Cmd Msg
createNewPlant csrfToken plantForm =
    Plant.createPlant csrfToken ReceivedCreatePlantResponse plantForm


updatePlant : String -> Int -> PlantForm -> Cmd Msg
updatePlant csrfToken plantId plantForm =
    Plant.updatePlant csrfToken ReceivedUpdatePlantResponse plantId plantForm
