module Menu exposing (Model, Msg, init, menu, menuButton, update, view)

import Garden exposing (Garden)
import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Octicons
import Routes


type alias Model =
    { ownedGardens : List Garden, sharedGardens : List Garden, isOpen : Bool }


type Msg
    = UserClickedMenuButton
    | UserOpenedGardenForm
    | UserClosedGardenForm
    | UserSubmittedGardenForm


init : List Garden -> List Garden -> ( Model, Cmd Msg )
init ownedGardens sharedGardens =
    let
        initialModel =
            Model ownedGardens sharedGardens False
    in
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserClickedMenuButton ->
            let
                updatedModel =
                    { model | isOpen = not model.isOpen }

                newView =
                    view updatedModel
            in
            ( updatedModel, Cmd.none )

        UserOpenedGardenForm ->
            ( model, Cmd.none )

        UserClosedGardenForm ->
            ( model, Cmd.none )

        UserSubmittedGardenForm ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ menuButton
        , menu model.ownedGardens model.sharedGardens model.isOpen
        ]


menu : List Garden -> List Garden -> Bool -> Html Msg
menu ownedGardens sharedGardens menuOpen =
    ul [ class (menuClass menuOpen) ]
        [ gardensList ownedGardens "My Gardens"
        , gardensList sharedGardens "Shared Gardens"
        ]


menuClass : Bool -> String
menuClass menuOpen =
    let
        baseString =
            "menu"

        finalString =
            case menuOpen of
                True ->
                    baseString ++ " menu-toggled"

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
        [ class "menu__button--add-garden"
        , onClick UserOpenedGardenForm
        ]
        [ icon ]


gardensList : List Garden -> String -> Html Msg
gardensList ownedGardens label =
    if List.isEmpty ownedGardens then
        text ""

    else
        let
            listItems =
                List.map gardenListItem ownedGardens
        in
        div [] (text label :: listItems)


gardenListItem : Garden -> Html Msg
gardenListItem garden =
    let
        linkToGarden =
            Routes.GardenRoute garden.id
                |> Routes.pathFor
    in
    li []
        [ a [ href linkToGarden ] [ text garden.name ]
        , addGardenButton
        ]
