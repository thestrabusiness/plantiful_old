module Api exposing
    ( authorizationHeader
    , baseUrl
    , checkInEndpoint
    , currentUserEndpoint
    , gardenEndpoint
    , gardenPlantEndpoint
    , gardenPlantsEndpoint
    , gardensEndpoint
    , networkError
    , plantAvatarEndpoint
    , plantEndpoint
    , plantsEndpoint
    , sessionStatusEndpoint
    , sessionTypeHeader
    , signInEndpoint
    , signOutEndpoint
    , somethingWentWrongError
    , unauthorizedError
    , usersEndpoint
    )

import Http exposing (Header)
import Loadable exposing (Loadable(..))
import User exposing (AuthToken(..), User)


sessionTypeHeader : Header
sessionTypeHeader =
    Http.header "Session-Type" "desktop"


authorizationHeader : Loadable User -> Header
authorizationHeader loadableUser =
    case loadableUser of
        Success user ->
            authoriationHeaderValue user.rememberToken
                |> Http.header "Authorization"

        _ ->
            Http.header "Authorization" ""


authoriationHeaderValue : AuthToken -> String
authoriationHeaderValue (AuthToken token) =
    "Bearer " ++ token


baseUrl : String
baseUrl =
    "/api"


gardensEndpoint : String
gardensEndpoint =
    baseUrl ++ "/gardens"


gardenEndpoint : Int -> String
gardenEndpoint gardenId =
    gardensEndpoint ++ "/" ++ String.fromInt gardenId


gardenPlantsEndpoint : Int -> String
gardenPlantsEndpoint gardenId =
    gardenEndpoint gardenId ++ "/plants/"


gardenPlantEndpoint : Int -> Int -> String
gardenPlantEndpoint gardenId plantId =
    gardenPlantsEndpoint gardenId ++ "/" ++ String.fromInt plantId


plantsEndpoint : String
plantsEndpoint =
    baseUrl ++ "/plants"


plantEndpoint : Int -> String
plantEndpoint plantId =
    plantsEndpoint ++ "/" ++ String.fromInt plantId


plantAvatarEndpoint : Int -> String
plantAvatarEndpoint plantId =
    plantEndpoint plantId ++ "/avatar"


checkInEndpoint : Int -> String
checkInEndpoint plantId =
    plantEndpoint plantId ++ "/check_ins"


usersEndpoint : String
usersEndpoint =
    baseUrl ++ "/users"


currentUserEndpoint : String
currentUserEndpoint =
    baseUrl ++ "/current_user"


signInEndpoint : String
signInEndpoint =
    baseUrl ++ "/sessions"


signOutEndpoint : String
signOutEndpoint =
    baseUrl ++ "/sign_out"


sessionStatusEndpoint : String
sessionStatusEndpoint =
    signInEndpoint ++ "/status"


unauthorizedError : String
unauthorizedError =
    "Wrong combination of email and password"


networkError : String
networkError =
    "Are you sure you're connected to the internet?"


somethingWentWrongError : String
somethingWentWrongError =
    "Something went wrong. It this problem persists, contact moffa.an@gmail.com"
