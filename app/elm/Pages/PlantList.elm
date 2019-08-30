module Pages.PlantList exposing
    ( Model
    , Msg(..)
    , card
    , cardImageUrl
    , getPlants
    , init
    , update
    , updatePlantsList
    , view
    , viewPlantList
    )

import CheckIn exposing (Event(..))
import DateAndTime
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Plant
import Process
import Routes exposing (newPlantPath)
import Task
import Time exposing (Posix)
import User exposing (User)


type alias Model =
    { plants : List Plant.Plant
    , currentUser : User
    , currentTime : Posix
    , currentTimeZone : Time.Zone
    , modal : Modal
    , checkInForm : CheckIn.CheckIn
    }


type Msg
    = NewPlants (Result Http.Error (List Plant.Plant))
    | UserOpenedCheckInModal Plant.Plant
    | UserClosedModal
    | UserSubmittedCheckIn
    | UpdatePlant (Result Http.Error Plant.Plant)
    | ReceivedCurrentTime Time.Posix
    | ReceivedTimeZone Time.Zone
    | CheckboxSelected CheckIn.Event
    | UserTypedCheckInNotes String
    | ReceivedPlantCheckInResponse (Result Http.Error CheckIn.CheckIn)


type Modal
    = Modal (Html Msg)
    | ModalClosed


init : User -> ( Model, Cmd Msg )
init user =
    ( initialModel user
    , Cmd.batch [ getCurrentTime, getTimeZone, getPlants ]
    )


initialModel : User -> Model
initialModel user =
    Model [] user initialTime Time.utc ModalClosed initialCheckInForm


initialCheckInForm : CheckIn.CheckIn
initialCheckInForm =
    CheckIn.CheckIn False False "" Plant.emptyPlant


getCurrentTime : Cmd Msg
getCurrentTime =
    Task.perform ReceivedCurrentTime Time.now


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform ReceivedTimeZone Time.here


initialTime : Posix
initialTime =
    Time.millisToPosix 0


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

        UserOpenedCheckInModal plant ->
            let
                checkInForm =
                    model.checkInForm

                newCheckInForm =
                    { checkInForm | plant = plant }
            in
            ( model, Cmd.none )
                |> updateForm newCheckInForm
                |> updateModal checkInModal

        CheckboxSelected eventType ->
            let
                newCheckInForm =
                    updateFormCheckboxes model.checkInForm eventType
            in
            ( model, Cmd.none )
                |> updateForm newCheckInForm
                |> updateModal checkInModal

        UserTypedCheckInNotes notes ->
            let
                checkInForm =
                    model.checkInForm

                newCheckInForm =
                    { checkInForm | notes = notes }
            in
            ( model, Cmd.none )
                |> updateForm newCheckInForm
                |> updateModal checkInModal

        UserClosedModal ->
            ( model, Cmd.none )
                |> updateForm initialCheckInForm
                |> closeModal

        UserSubmittedCheckIn ->
            ( model, submitCheckIn model.checkInForm )

        ReceivedPlantCheckInResponse (Ok response) ->
            let
                updatedPlant =
                    response.plant

                updatedPlantList =
                    updatePlantsList model.plants updatedPlant
            in
            ( { model | plants = updatedPlantList }, Cmd.none )
                |> updateForm initialCheckInForm
                |> closeModal

        ReceivedPlantCheckInResponse (Err error) ->
            ( model, Cmd.none )

        ReceivedTimeZone zone ->
            ( { model | currentTimeZone = zone }, Cmd.none )

        ReceivedCurrentTime time ->
            ( { model | currentTime = time }, Cmd.none )


updateFormCheckboxes : CheckIn.CheckIn -> CheckIn.Event -> CheckIn.CheckIn
updateFormCheckboxes checkInForm event =
    case event of
        Watered ->
            { checkInForm
                | watered = not checkInForm.watered
            }

        Fertilized ->
            { checkInForm
                | fertilized = not checkInForm.fertilized
            }

        NoEvent ->
            checkInForm


updateForm : CheckIn.CheckIn -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm form ( model, cmd ) =
    ( { model | checkInForm = form }, cmd )


updateModal : (CheckIn.CheckIn -> Html Msg) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateModal modal ( model, cmd ) =
    ( { model | modal = Modal <| modal model.checkInForm }, cmd )


closeModal : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
closeModal ( model, cmd ) =
    ( { model | modal = ModalClosed }, cmd )


updatePlantsList : List Plant.Plant -> Plant.Plant -> List Plant.Plant
updatePlantsList currentPlantList updatedPlant =
    let
        updatePlant plant =
            if plant.id == updatedPlant.id then
                { plant | lastWateredAt = updatedPlant.lastWateredAt }

            else
                plant
    in
    List.map updatePlant currentPlantList



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewPlantList model
        , a [ class "add-record-btn", href newPlantPath ] [ text "Add New Plant" ]
        , viewModal model.modal
        ]


viewPlantList : Model -> Html Msg
viewPlantList model =
    let
        listOfPlants =
            List.map (card model.currentTime) model.plants
    in
    if List.length model.plants > 0 then
        div [ class "cards" ] listOfPlants

    else
        div [ class "container__center centered-text" ] [ text noPlantsMessage ]


noPlantsMessage : String
noPlantsMessage =
    "You dont have any plants yet! Add some new friends with the + button."


cardImageUrl : String
cardImageUrl =
    "https://thumbs.dreamstime.com/z/growing-plant-3599470.jpg"


card : Posix -> Plant.Plant -> Html Msg
card currentTime plant =
    div [ class "card" ]
        [ div [ class "card-image" ]
            [ img [ src cardImageUrl ] [] ]
        , div [ class "card-header" ] [ text plant.name ]
        , div [ class "card-copy" ]
            [ ul []
                [ li [] [ text "Botanical Name" ]
                , li [] [ text <| distanceInDays currentTime plant.lastWateredAt ]
                , li []
                    [ button
                        [ onClick (UserOpenedCheckInModal plant) ]
                        [ text "Check In" ]
                    ]
                ]
            ]
        ]


distanceInDays : Posix -> Posix -> String
distanceInDays currentTime wateredAt =
    if Time.posixToMillis wateredAt == 0 then
        "Not Yet Watered"

    else
        DateAndTime.distanceInDays currentTime wateredAt



-- API


getPlants : Cmd Msg
getPlants =
    Plant.getPlants NewPlants


waterPlant : Plant.Plant -> Cmd Msg
waterPlant plant =
    Plant.waterPlant UpdatePlant plant


submitCheckIn : CheckIn.CheckIn -> Cmd Msg
submitCheckIn form =
    CheckIn.submitCheckIn form ReceivedPlantCheckInResponse



-- MODAL


viewModal : Modal -> Html Msg
viewModal modal =
    case modal of
        Modal content ->
            content

        _ ->
            div [] []


checkInModal : CheckIn.CheckIn -> Html Msg
checkInModal form =
    div [ class "modal__bg" ]
        [ div [ class "modal__container--large" ]
            [ modalHeader <| "Check-in: " ++ form.plant.name
            , div [ class "modal__content--large" ]
                [ modalRow [ h2 [] [ text "Today I:" ] ]
                , modalRow
                    [ checkbox Watered
                        form.watered
                    ]
                , modalRow
                    [ checkbox Fertilized
                        form.fertilized
                    ]
                , modalRow
                    [ label []
                        [ text "Notes"
                        , textarea
                            [ onInput UserTypedCheckInNotes
                            , style "height" "125px"
                            ]
                            []
                        ]
                    ]
                ]
            , modalFooter
                [ button [ class "secondary", onClick UserClosedModal ] [ text "Cancel" ]
                , button [ onClick UserSubmittedCheckIn ] [ text "Submit" ]
                ]
            ]
        ]


checkbox : CheckIn.Event -> Bool -> Html Msg
checkbox eventType isChecked =
    label
        [ style "padding" "20px" ]
        [ input
            [ type_ "checkbox"
            , checked isChecked
            , onClick <| CheckboxSelected eventType
            ]
            []
        , text (eventToString eventType)
        ]


eventToString : CheckIn.Event -> String
eventToString event =
    case event of
        Watered ->
            "Watered"

        Fertilized ->
            "Fertilized"

        NoEvent ->
            "NoEvent"


modalHeader : String -> Html Msg
modalHeader headerText =
    div [ class "modal__header--default" ]
        [ h1 [ class "modal__heading" ]
            [ text headerText ]
        ]


modalFooter : List (Html a) -> Html a
modalFooter children =
    div [ class "modal__footer" ] children


modalRow : List (Html a) -> Html a
modalRow children =
    div [ class "modal-row" ] children
