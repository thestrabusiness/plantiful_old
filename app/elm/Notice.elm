module Notice exposing
    ( Notice(..)
    , alert
    , empty
    , error
    , info
    , noticeToClass
    , noticeToMessage
    , success
    )


type Notice
    = Alert String
    | Error String
    | Info String
    | Success String


empty : Maybe a
empty =
    Nothing


alert : String -> Notice
alert message =
    Alert message


error : String -> Notice
error message =
    Error message


info : String -> Notice
info message =
    Info message


success : String -> Notice
success message =
    Success message


noticeToClass : Notice -> String
noticeToClass notice =
    case notice of
        Alert _ ->
            "notice-alert"

        Error _ ->
            "notice-error"

        Info _ ->
            "notice-info"

        Success _ ->
            "notice-success"


noticeToMessage : Notice -> String
noticeToMessage notice =
    case notice of
        Alert message ->
            message

        Error message ->
            message

        Info message ->
            message

        Success message ->
            message
