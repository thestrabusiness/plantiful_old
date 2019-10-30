module Pages.PlantForm exposing (Model, Msg, init, update, view)

import Api exposing (networkError, somethingWentWrongError, unauthorizedError)
import Browser.Navigation as Nav
import Form exposing (errorsForField, onEnter)
import Html exposing (..)
import Html.Attributes exposing (class, id, name, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Loadable exposing (Loadable(..))
import Plant
import Routes
import Session exposing (Session)
import User exposing (User)
import Validate exposing (Validator, fromValid, ifBlank, ifNotInt, validate)


type alias Model =
    { session : Session
    , plant : PlantForm
    , errors : List Error
    , apiError : String
    , formAction : Form.FormAction
    , plantId : Maybe Int
    , gardenId : Maybe Int
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


init : Session -> Maybe Int -> Maybe Int -> ( Model, Cmd Msg )
init session maybePlantId maybeGardenId =
    let
        formAction =
            case maybePlantId of
                Just _ ->
                    Form.Update

                Nothing ->
                    Form.Create

        initialModel =
            Model session
                initialPlantForm
                []
                ""
                formAction
                maybePlantId
                maybeGardenId
    in
    ( initialModel, loadPlant session maybePlantId )


initialPlantForm : PlantForm
initialPlantForm =
    { name = "", checkFrequencyScalar = "", checkFrequencyUnit = "day" }


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
            case ( validateForm, model.formAction ) of
                ( Ok validatedForm, Form.Create ) ->
                    let
                        validPlant =
                            fromValid validatedForm
                    in
                    case model.gardenId of
                        Just gardenId ->
                            ( model
                            , createNewPlant model.session gardenId validPlant
                            )

                        Nothing ->
                            ( model, Cmd.none )

                ( Ok validatedForm, Form.Update ) ->
                    let
                        validPlant =
                            fromValid validatedForm
                    in
                    case model.plantId of
                        Just plantId ->
                            ( model
                            , updatePlant model.session plantId validPlant
                            )

                        Nothing ->
                            ( model, Cmd.none )

                ( Err errorList, _ ) ->
                    ( { model | errors = errorList }, Cmd.none )

        UserCancelledForm ->
            case ( model.formAction, model.plantId, model.gardenId ) of
                ( Form.Create, _, Just gardenId ) ->
                    ( model, goBackToPlantsList key gardenId )

                ( Form.Update, Just plantId, Just gardenId ) ->
                    ( model, goBackToPlantDetails key plantId )

                ( _, _, _ ) ->
                    ( model, Cmd.none )

        ReceivedCreatePlantResponse (Ok plant) ->
            case ( model.gardenId, model.session.currentUser ) of
                ( Just gardenId, _ ) ->
                    ( model, goBackToPlantsList key gardenId )

                ( Nothing, Success user ) ->
                    ( model
                    , goBackToPlantsList key user.defaultGardenId
                    )

                ( _, _ ) ->
                    ( model, Cmd.none )

        ReceivedCreatePlantResponse (Err error) ->
            handleErrorResponse model error key

        ReceivedGetPlantResponse (Ok plant) ->
            ( { model
                | plant = plantToForm plant
                , gardenId = Just plant.gardenId
              }
            , Cmd.none
            )

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


goBackToPlantsList : Nav.Key -> Int -> Cmd Msg
goBackToPlantsList key gardenId =
    Nav.pushUrl key (Routes.gardenPath gardenId)


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



-- VIEW


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



-- API


loadPlant : Session -> Maybe Int -> Cmd Msg
loadPlant session maybePlantId =
    case maybePlantId of
        Just plantId ->
            Plant.getPlant session plantId ReceivedGetPlantResponse

        Nothing ->
            Cmd.none


createNewPlant : Session -> Int -> PlantForm -> Cmd Msg
createNewPlant session gardenId plantForm =
    Plant.createPlant session gardenId ReceivedCreatePlantResponse plantForm


updatePlant : Session -> Int -> PlantForm -> Cmd Msg
updatePlant session plantId plantForm =
    Plant.updatePlant session plantId ReceivedUpdatePlantResponse plantForm
