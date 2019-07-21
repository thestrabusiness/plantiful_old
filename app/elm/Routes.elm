module Routes exposing (Route(..), extractRoute, matchRoute, newPlantPath, pathFor, plantsPath)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = HomeRoute
    | PlantsRoute
    | NotFoundRoute
    | NewPlantRoute


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
        , map PlantsRoute (s "plants")
        , map NewPlantRoute (s "plants" </> s "new")
        ]


pathFor : Route -> String
pathFor route =
    case route of
        HomeRoute ->
            "/"

        PlantsRoute ->
            "/plants"

        NewPlantRoute ->
            "/plants/new"

        NotFoundRoute ->
            "/"


plantsPath : String
plantsPath =
    pathFor PlantsRoute


newPlantPath : String
newPlantPath =
    pathFor NewPlantRoute
