module Routes exposing
    ( Route(..)
    , editPlantPath
    , extractRoute
    , matchRoute
    , newPlantPath
    , pathFor
    , plantPath
    , plantsPath
    , signInPath
    )

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = PlantsRoute
    | PlantRoute Int
    | NotFoundRoute
    | NewPlantRoute
    | NewUserRoute
    | SignInRoute
    | EditPlantRoute Int


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
        [ map SignInRoute top
        , map PlantsRoute (s "plants")
        , map PlantRoute (s "plants" </> int)
        , map NewPlantRoute (s "plants" </> s "new")
        , map NewUserRoute (s "sign_up")
        , map SignInRoute (s "sign_in")
        , map EditPlantRoute (s "plants" </> int </> s "edit")
        ]


pathFor : Route -> String
pathFor route =
    case route of
        PlantRoute id ->
            "/plants/" ++ String.fromInt id

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

        EditPlantRoute id ->
            pathFor (PlantRoute id) ++ "/edit"


plantPath : Int -> String
plantPath id =
    pathFor <| PlantRoute id


plantsPath : String
plantsPath =
    pathFor PlantsRoute


newPlantPath : String
newPlantPath =
    pathFor NewPlantRoute


signInPath : String
signInPath =
    pathFor SignInRoute


editPlantPath : Int -> String
editPlantPath id =
    pathFor <| EditPlantRoute id
