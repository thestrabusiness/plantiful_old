module Routes exposing (Route(..), extractRoute, matchRoute, newPlantPath, pathFor, plantsPath, signInPath)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = HomeRoute
    | PlantsRoute
    | NotFoundRoute
    | NewPlantRoute
    | NewUserRoute
    | SignInRoute


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
        , map NewUserRoute (s "sign_up")
        , map SignInRoute (s "sign_in")
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

        NewUserRoute ->
            "/sign_up"

        SignInRoute ->
            "/sign_in"

        NotFoundRoute ->
            "/"


plantsPath : String
plantsPath =
    pathFor PlantsRoute


newPlantPath : String
newPlantPath =
    pathFor NewPlantRoute


signInPath : String
signInPath =
    pathFor SignInRoute
