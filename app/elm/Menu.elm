module Menu exposing (Model, Msg, init, menu, menuButton, update, view)

import Api
import Browser.Navigation as Nav
import Garden exposing (Garden)
import Html exposing (Html, a, button, div, input, label, li, text, ul)
import Html.Attributes exposing (class, disabled, href, value)
import Html.Events exposing (onClick, onInput)
import Http
import Octicons
import Routes
import Session exposing (Session)


type alias Model =
    { session : Session
    , key : Nav.Key
    , ownedGardens : List Garden
    , sharedGardens : List Garden
    , isOpen : Bool
    , gardenFormState : GardenFormState
    , newGardenName : String
    }


type Msg
    = UserClickedMenuButton
    | UserOpenedGardenForm
    | UserClosedGardenForm
    | UserSubmittedGardenForm
    | UserTypedGardenName String
    | ReceivedCreateGardenResponse (Result Http.Error Garden)


type GardenFormState
    = Closed
    | Open
    | Submitting
    | Invalid


init : Session -> Nav.Key -> List Garden -> List Garden -> ( Model, Cmd Msg )
init session key ownedGardens sharedGardens =
    let
        initialModel =
            Model session key ownedGardens sharedGardens False Closed ""
    in
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserClickedMenuButton ->
            ( { model
                | isOpen = not model.isOpen
                , gardenFormState = Closed
                , newGardenName = ""
              }
            , Cmd.none
            )

        UserOpenedGardenForm ->
            ( { model | gardenFormState = Open }, Cmd.none )

        UserTypedGardenName name ->
            ( { model | newGardenName = name, gardenFormState = Open }, Cmd.none )

        UserClosedGardenForm ->
            ( { model | gardenFormState = Closed }, Cmd.none )

        UserSubmittedGardenForm ->
            if String.isEmpty model.newGardenName then
                ( { model | gardenFormState = Invalid }, Cmd.none )

            else
                ( { model | gardenFormState = Submitting }
                , createGarden model.session
                    model.newGardenName
                    ReceivedCreateGardenResponse
                )

        ReceivedCreateGardenResponse (Ok garden) ->
            let
                newOwnedGardensList =
                    model.ownedGardens ++ [ garden ]
            in
            ( { model
                | gardenFormState = Closed
                , newGardenName = ""
                , ownedGardens = newOwnedGardensList
              }
            , Nav.pushUrl model.key (Routes.gardenPath garden.id)
            )

        ReceivedCreateGardenResponse (Err error) ->
            ( { model | gardenFormState = Open }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ menuButton
        , menu model
        ]


menu : Model -> Html Msg
menu model =
    ul [ class (menuClass model.isOpen) ]
        [ gardensList model.ownedGardens
            "My Gardens"
            addGardenButton
            model.gardenFormState
            model.newGardenName
        , gardensList
            model.sharedGardens
            "Shared Gardens"
            (text "")
            Closed
            ""
        ]


menuClass : Bool -> String
menuClass menuOpen =
    let
        baseString =
            "menu"

        finalString =
            case menuOpen of
                True ->
                    baseString ++ " menu-open"

                False ->
                    baseString
    in
    finalString


menuButton : Html Msg
menuButton =
    let
        icon =
            Octicons.defaultOptions
                |> Octicons.size 30
                |> Octicons.threeBars
    in
    div [ class "menu__button", onClick UserClickedMenuButton ] [ icon ]


addGardenButton : Html Msg
addGardenButton =
    let
        icon =
            Octicons.defaultOptions
                |> Octicons.plus
    in
    div
        [ class "menu__button menu__button--add-garden"
        , onClick UserOpenedGardenForm
        ]
        [ icon ]


gardensList : List Garden -> String -> Html Msg -> GardenFormState -> String -> Html Msg
gardensList gardens listLabel icon showNewGardenForm newGardenName =
    if List.isEmpty gardens then
        text ""

    else
        let
            listItems =
                List.map gardenListItem gardens

            listDiv =
                div [ class "menu__items" ] listItems

            headerDiv =
                div [ class "menu__header" ] [ text listLabel, icon ]

            listSection =
                case showNewGardenForm of
                    Closed ->
                        div [] [ headerDiv, listDiv ]

                    _ ->
                        div []
                            [ headerDiv
                            , newGardenForm newGardenName showNewGardenForm
                            , listDiv
                            ]
        in
        listSection


newGardenForm : String -> GardenFormState -> Html Msg
newGardenForm newGardenName formState =
    let
        submitButtonText =
            case formState of
                Submitting ->
                    "Submitting..."

                _ ->
                    "Submit"

        formDisabled =
            case formState of
                Submitting ->
                    True

                _ ->
                    False

        errorMessage =
            case formState of
                Invalid ->
                    div
                        [ class "errors" ]
                        [ text "You must provide a name" ]

                _ ->
                    text ""
    in
    div [ class "menu__input" ]
        [ label []
            [ text "Add a new garden"
            , errorMessage
            , input
                [ onInput UserTypedGardenName
                , value newGardenName
                , disabled formDisabled
                ]
                []
            ]
        , button
            [ onClick UserClosedGardenForm
            , class "secondary"
            , disabled formDisabled
            ]
            [ text "Cancel" ]
        , button
            [ onClick UserSubmittedGardenForm
            , disabled formDisabled
            ]
            [ text submitButtonText ]
        ]


gardenListItem : Garden -> Html Msg
gardenListItem garden =
    let
        linkToGarden =
            Routes.GardenRoute garden.id
                |> Routes.pathFor
    in
    li []
        [ a [ href linkToGarden ] [ text garden.name ] ]



-- API


createGarden : Session -> String -> (Result Http.Error Garden -> msg) -> Cmd msg
createGarden session name msg =
    let
        body =
            Garden.encodeGarden name
    in
    Http.request
        { method = "POST"
        , url = Api.gardensEndpoint
        , body = Http.jsonBody body
        , expect = Http.expectJson msg Garden.gardenDecoder
        , headers =
            [ Api.sessionTypeHeader
            , Http.header "X-CSRF-Token" session.csrfToken
            , Api.authorizationHeader session.currentUser
            ]
        , timeout = Nothing
        , tracker = Nothing
        }
