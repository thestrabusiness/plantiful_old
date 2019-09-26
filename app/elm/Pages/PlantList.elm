module Pages.PlantList exposing
    ( Model
    , Msg(..)
    , card
    , getPlants
    , init
    , update
    , updatePlantWateredAt
    , view
    , viewPlantList
    )

import CheckIn exposing (Event(..))
import DateAndTime
import File
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import Http
import Json.Decode exposing (Decoder, succeed)
import Modal exposing (..)
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
    , modal : Modal.Modal Msg
    , checkInForm : CheckInForm
    , loading : Loading
    }


type alias CheckInForm =
    { watered : Bool
    , fertilized : Bool
    , notes : String
    , photo : Maybe File.File
    , plantId : Int
    , plantName : String
    }


type Msg
    = NewPlants (Result Http.Error (List Plant.Plant))
    | UserOpenedCheckInModal Plant.Plant
    | UserClosedModal
    | UserSubmittedCheckIn
    | CheckboxSelected CheckIn.Event
    | UserTypedCheckInNotes String
    | ReceivedPlantCheckInResponse (Result Http.Error CheckIn.CheckIn)
    | UserClickedFileSelect
    | NewImageSelected File.File


type Loading
    = Loading
    | Success
    | Failed


init : User -> Time.Posix -> Time.Zone -> ( Model, Cmd Msg )
init user currentTime timeZone =
    ( initialModel user currentTime timeZone, getPlants )


initialModel : User -> Time.Posix -> Time.Zone -> Model
initialModel user currentTime timeZone =
    Model [] user currentTime timeZone ModalClosed initialCheckInForm Loading


initialCheckInForm : CheckInForm
initialCheckInForm =
    CheckInForm False False "" Nothing 0 ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewPlants (Ok newPlants) ->
            ( { model | plants = newPlants, loading = Success }, Cmd.none )

        NewPlants (Err error) ->
            let
                _ =
                    Debug.log "Whoops!" error
            in
            ( { model | loading = Failed }, Cmd.none )

        UserOpenedCheckInModal plant ->
            let
                checkInForm =
                    model.checkInForm

                newCheckInForm =
                    { checkInForm | plantId = plant.id, plantName = plant.name }
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

        UserClickedFileSelect ->
            ( model, Select.file [ "image/*" ] NewImageSelected )

        NewImageSelected file ->
            let
                checkInForm =
                    model.checkInForm

                updatedForm =
                    { checkInForm | photo = Just file }
            in
            ( { model | checkInForm = updatedForm }, Cmd.none )

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

        ReceivedPlantCheckInResponse (Ok checkIn) ->
            case checkIn.watered of
                True ->
                    let
                        updatedPlant =
                            findPlantById checkIn.plantId model.plants
                    in
                    case updatedPlant of
                        Just plant ->
                            ( model, Cmd.none )
                                |> updatePlantWateredAt plant checkIn.createdAt
                                |> updateForm initialCheckInForm
                                |> closeModal

                        Nothing ->
                            ( model, Cmd.none )

                False ->
                    ( model, Cmd.none )

        ReceivedPlantCheckInResponse (Err error) ->
            ( model, Cmd.none )


updateFormCheckboxes : CheckInForm -> CheckIn.Event -> CheckInForm
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


updateForm : CheckInForm -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateForm form ( model, cmd ) =
    ( { model | checkInForm = form }, cmd )


updateModal : (CheckInForm -> Html Msg) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateModal modal ( model, cmd ) =
    ( { model | modal = Modal <| modal model.checkInForm }, cmd )


closeModal : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
closeModal ( model, cmd ) =
    ( { model | modal = ModalClosed }, cmd )


findPlantById : Int -> List Plant.Plant -> Maybe Plant.Plant
findPlantById id plantList =
    List.head (List.filter (\plant -> plant.id == id) plantList)


updatePlantWateredAt :
    Plant.Plant
    -> Time.Posix
    -> ( Model, Cmd Msg )
    -> ( Model, Cmd Msg )
updatePlantWateredAt updatedPlant wateredAt ( model, cmd ) =
    let
        updatePlant plant =
            if plant.id == updatedPlant.id then
                { plant | lastWateredAt = wateredAt }

            else
                plant

        newPlantList =
            List.map updatePlant model.plants
    in
    ( { model | plants = newPlantList }, cmd )



-- VIEW


view : Model -> Html Msg
view model =
    case model.loading of
        Loading ->
            div [ class "container__center centered-text" ]
                [ text "Loading..." ]

        Failed ->
            div [ class "container__center centered-text" ]
                [ text "Something went wrong..." ]

        Success ->
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


card currentTime plant =
    div [ class "card" ]
        [ a [ href <| Routes.plantPath plant.id ]
            [ div [ class "card-image" ]
                [ img [ src plant.avatarUrl ] [] ]
            , div [ class "card-header" ] [ text plant.name ]
            ]
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


submitCheckIn : CheckInForm -> Cmd Msg
submitCheckIn form =
    CheckIn.submitCheckIn form ReceivedPlantCheckInResponse



-- MODAL


viewModal : Modal.Modal Msg -> Html Msg
viewModal modal =
    case modal of
        Modal content ->
            content

        _ ->
            div [] []


checkInModal : CheckInForm -> Html Msg
checkInModal form =
    div [ class "modal__bg" ]
        [ div [ class "modal__container--large" ]
            [ Modal.modalHeader <| "Check-in: " ++ form.plantName
            , div [ class "modal__content--large" ]
                [ Modal.modalRow [ h2 [] [ text "Today I:" ] ]
                , Modal.modalRow
                    [ checkbox Watered
                        form.watered
                    ]
                , Modal.modalRow
                    [ checkbox Fertilized
                        form.fertilized
                    ]
                , Modal.modalRow
                    [ button [ onClick UserClickedFileSelect ]
                        [ text "Add a photo"
                        ]
                    ]
                , Modal.modalRow
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
            , Modal.modalFooter
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
