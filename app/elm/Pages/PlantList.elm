module Pages.PlantList exposing
    ( Model
    , Msg(..)
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
import List.Extra exposing (removeAt)
import Modal exposing (..)
import Notice exposing (Notice(..))
import Octicons exposing (defaultOptions)
import Plant
import Process
import Routes exposing (newPlantPath)
import Session exposing (Session)
import Task
import Time exposing (Posix)
import User exposing (User)


type alias Model =
    { session : Session
    , plants : List Plant.Plant
    , currentTime : Posix
    , currentTimeZone : Time.Zone
    , modal : Modal.Modal Msg
    , checkInForm : CheckInForm
    , loading : Loading
    , gardenId : Int
    }


type alias CheckInForm =
    { watered : Bool
    , fertilized : Bool
    , notes : String
    , photos : List String
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
    | PhotoConvertedToBase64 String
    | UserRemovedImageFromModal Int


type Loading
    = Loading
    | Success
    | Failed


init : Session -> Int -> Time.Posix -> Time.Zone -> ( Model, Cmd Msg )
init session gardenId currentTime timeZone =
    ( initialModel session currentTime timeZone gardenId
    , getPlants session gardenId
    )


initialModel : Session -> Time.Posix -> Time.Zone -> Int -> Model
initialModel session currentTime timeZone gardenId =
    Model
        session
        []
        currentTime
        timeZone
        ModalClosed
        initialCheckInForm
        Loading
        gardenId


initialCheckInForm : CheckInForm
initialCheckInForm =
    CheckInForm False False "" [] 0 ""


update : Msg -> Model -> ( Model, Cmd Msg, Notice )
update msg model =
    case msg of
        NewPlants (Ok newPlants) ->
            ( { model | plants = newPlants, loading = Success }
            , Cmd.none
            , EmptyNotice
            )

        NewPlants (Err error) ->
            let
                _ =
                    Debug.log "Whoops!" error
            in
            ( { model | loading = Failed }, Cmd.none, EmptyNotice )

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
            ( model, Select.file [ "image/*" ] NewImageSelected, EmptyNotice )

        NewImageSelected file ->
            ( model, photoToBase64 file, EmptyNotice )

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
            ( model, submitCheckIn model.session model.checkInForm, EmptyNotice )

        ReceivedPlantCheckInResponse (Ok checkIn) ->
            let
                updatedPlant =
                    findPlantById checkIn.plantId model.plants
            in
            case updatedPlant of
                Just plant ->
                    let
                        noticeMessage =
                            "Added check-in: " ++ plant.name
                    in
                    ( model, Cmd.none )
                        |> updatePlantWateredAt plant checkIn.createdAt
                        |> updateForm initialCheckInForm
                        |> closeModal
                        |> modifyNotice noticeMessage

                Nothing ->
                    ( model, Cmd.none )
                        |> closeModal

        ReceivedPlantCheckInResponse (Err error) ->
            ( model, Cmd.none, Notice "Something went wrong. Try again later" )

        PhotoConvertedToBase64 base64Photo ->
            let
                checkInForm =
                    model.checkInForm

                updatedForm =
                    { checkInForm | photos = checkInForm.photos ++ [ base64Photo ] }
            in
            ( model, Cmd.none )
                |> updateForm updatedForm
                |> updateModal checkInModal

        UserRemovedImageFromModal index ->
            let
                checkInForm =
                    model.checkInForm

                photosWithoutDeleted =
                    removeAt index checkInForm.photos

                updatedForm =
                    { checkInForm | photos = photosWithoutDeleted }
            in
            ( model, Cmd.none )
                |> updateForm updatedForm
                |> updateModal checkInModal


photoToBase64 : File.File -> Cmd Msg
photoToBase64 photo =
    Task.perform PhotoConvertedToBase64 (File.toUrl photo)


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


updateModal :
    (CheckInForm -> Html Msg)
    -> ( Model, Cmd Msg )
    -> ( Model, Cmd Msg, Notice )
updateModal modal ( model, cmd ) =
    ( { model | modal = Modal <| modal model.checkInForm }, cmd, EmptyNotice )


closeModal : ( Model, Cmd Msg ) -> ( Model, Cmd Msg, Notice )
closeModal ( model, cmd ) =
    ( { model | modal = ModalClosed }, cmd, EmptyNotice )


modifyNotice : String -> ( Model, Cmd Msg, Notice ) -> ( Model, Cmd Msg, Notice )
modifyNotice newNotice ( model, msg, _ ) =
    ( model, msg, Notice newNotice )


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
            div [ class "container__center-wide" ]
                [ viewPlantList model
                , a [ class "add-record-btn", href (newPlantPath model.gardenId) ]
                    [ text "Add New Plant" ]
                , viewModal model.modal
                ]


viewPlantList : Model -> Html Msg
viewPlantList model =
    let
        listOfPlants =
            List.map (plantListItem model.currentTime) model.plants
    in
    if List.length model.plants > 0 then
        div [ class "plant__list" ] listOfPlants

    else
        div [ class "container__center centered-text" ] [ text noPlantsMessage ]


noPlantsMessage : String
noPlantsMessage =
    "You dont have any plants in this garden yet! Add some new friends with the + button."


plantListItem currentTime plant =
    div [ class "plant__list-item" ]
        [ a [ href <| Routes.plantPath plant.id ]
            [ img [ class "plant__list-image", src plant.avatarUrl ] [] ]
        , div [ class "plant__list-details" ]
            [ ul []
                [ li [] [ text plant.name ]
                , li [] [ text "Botanical Name" ]
                , li [] [ text <| distanceInDays currentTime plant.lastWateredAt ]
                ]
            , button
                [ class "plant__list-button", onClick (UserOpenedCheckInModal plant) ]
                [ text "Check In" ]
            ]
        , overdueIndicator plant
        ]


clockIcon : Html msg
clockIcon =
    defaultOptions
        |> Octicons.size 20
        |> Octicons.color "#999"
        |> Octicons.watch


overdueIndicator : Plant.Plant -> Html msg
overdueIndicator plant =
    if plant.overdueForCheckIn then
        div [ class " plant__list-indicator" ] [ clockIcon ]

    else
        div [] []


distanceInDays : Posix -> Posix -> String
distanceInDays currentTime wateredAt =
    if Time.posixToMillis wateredAt == 0 then
        "Not Yet Watered"

    else
        DateAndTime.distanceInDays currentTime wateredAt



-- API


getPlants : Session -> Int -> Cmd Msg
getPlants session gardenId =
    Plant.getPlants session gardenId NewPlants


submitCheckIn : Session -> CheckInForm -> Cmd Msg
submitCheckIn session form =
    CheckIn.submitCheckIn session form ReceivedPlantCheckInResponse



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
                , Modal.modalRow [ photoPreviews form.photos ]
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


photoPreviews : List String -> Html Msg
photoPreviews photos =
    let
        imagesWithIndex =
            List.indexedMap Tuple.pair photos

        imageTags =
            List.map toImageTag imagesWithIndex
    in
    div [ class "modal__image-preview-container" ] imageTags


toImageTag : ( Int, String ) -> Html Msg
toImageTag ( index, photoUrl ) =
    div [ class "modal__image-preview" ]
        [ img [ src photoUrl ] []
        , div
            [ class "modal__image-delete"
            , onClick <| UserRemovedImageFromModal index
            ]
            [ closeIcon ]
        ]


closeIcon : Html msg
closeIcon =
    defaultOptions
        |> Octicons.size 20
        |> Octicons.x


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
