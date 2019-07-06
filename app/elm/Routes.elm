module Routes exposing (Route(..), extractRoute, matchRoute, pathFor, plantsPath)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = HomeRoute
    | ViewPlantsRoute
    | NotFoundRoute


extractRoute : Url -> Route
extractRoute url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map HomeRoute top
        , map ViewPlantsRoute (s "plants")
        ]


pathFor : Route -> String
pathFor route =
    case route of
        HomeRoute ->
            "/"

        ViewPlantsRoute ->
            "plants"

        NotFoundRoute ->
            "/"

plantsPath : String
plantsPath =
  pathFor ViewPlantsRoute
