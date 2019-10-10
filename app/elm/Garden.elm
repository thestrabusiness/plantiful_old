module Garden exposing (Garden, gardenListDecoder, menu, menuButton)

import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Octicons
import Routes


type alias Garden =
    { id : Int, name : String }



-- VIEW


menu : List Garden -> List Garden -> Bool -> Html msg
menu ownedGardens sharedGardens menuOpen =
    ul [ class (menuClass menuOpen) ]
        [ gardensList ownedGardens "My Gardens"
        , gardensList sharedGardens "Shared Gardens"
        ]


gardensList : List Garden -> String -> Html msg
gardensList ownedGardens label =
    if List.isEmpty ownedGardens then
        text ""

    else
        let
            listItems =
                List.map gardenListItem ownedGardens
        in
        div [] (text label :: listItems)


gardenListItem : Garden -> Html msg
gardenListItem garden =
    let
        linkToGarden =
            Routes.GardenRoute garden.id
                |> Routes.pathFor
    in
    li [] [ a [ href linkToGarden ] [ text garden.name ] ]


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


menuButton : msg -> Html msg
menuButton msg =
    let
        icon =
            Octicons.defaultOptions
                |> Octicons.size 30
                |> Octicons.threeBars
    in
    div [ class "menu__button", onClick msg ] [ icon ]



-- DECODER


gardenDecoder : Decoder Garden
gardenDecoder =
    succeed Garden
        |> required "id" int
        |> required "name" string


gardenListDecoder : Decoder (List Garden)
gardenListDecoder =
    Json.Decode.list gardenDecoder
