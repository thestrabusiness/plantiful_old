module Api exposing (networkError, somethingWentWrongError, unauthorizedError)


unauthorizedError : String
unauthorizedError =
    "Wrong combination of email and password"


networkError : String
networkError =
    "Are you sure you're connected to the internet?"


somethingWentWrongError : String
somethingWentWrongError =
    "Something went wrong. It this problem persists, contact moffa.an@gmail.com"
