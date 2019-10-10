module Routes exposing
    ( Route(..)
    , editPlantPath
    , extractRoute
    , gardenPath
    , matchRoute
    , newPlantPath
    , pathFor
    , plantPath
    , signInPath
    )

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFoundRoute
    | NewPlantRoute Int
    | NewUserRoute
    | SignInRoute
    | EditPlantRoute Int
    | GardenRoute Int
    | GardensRoute
    | PlantRoute Int


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
        , map NewPlantRoute (s "gardens" </> int </> s "plants" </> s "new")
        , map NewUserRoute (s "sign_up")
        , map SignInRoute (s "sign_in")
        , map EditPlantRoute (s "plants" </> int </> s "edit")
        , map GardensRoute (s "gardens")
        , map GardenRoute (s "gardens" </> int)
        , map PlantRoute (s "plants" </> int)
        ]


pathFor : Route -> String
pathFor route =
    case route of
        NewPlantRoute gardenId ->
            "/gardens/" ++ String.fromInt gardenId ++ "/plants/new"

        NewUserRoute ->
            "/sign_up"

        SignInRoute ->
            "/sign_in"

        NotFoundRoute ->
            "/"

        EditPlantRoute plantId ->
            "/plants/" ++ String.fromInt plantId ++ "/edit"

        GardenRoute id ->
            "/gardens/" ++ String.fromInt id

        GardensRoute ->
            "/gardens"

        PlantRoute id ->
            "/plants/" ++ String.fromInt id


newPlantPath : Int -> String
newPlantPath gardenId =
    pathFor <| NewPlantRoute gardenId


signInPath : String
signInPath =
    pathFor SignInRoute


editPlantPath : Int -> String
editPlantPath plantId =
    pathFor <| EditPlantRoute plantId


gardenPath : Int -> String
gardenPath id =
    pathFor <| GardenRoute id


plantPath : Int -> String
plantPath id =
    "/plants/" ++ String.fromInt id
