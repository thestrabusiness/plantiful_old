module Api exposing
    ( baseUrl
    , checkInEndpoint
    , currentUserEndpoint
    , networkError
    , plantAvatarEndpoint
    , plantEndpoint
    , plantsEndpoint
    , signInEndpoint
    , signOutEndpoint
    , somethingWentWrongError
    , unauthorizedError
    , usersEndpoint
    )


baseUrl : String
baseUrl =
    "/api"


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


unauthorizedError : String
unauthorizedError =
    "Wrong combination of email and password"


networkError : String
networkError =
    "Are you sure you're connected to the internet?"


somethingWentWrongError : String
somethingWentWrongError =
    "Something went wrong. It this problem persists, contact moffa.an@gmail.com"
