module DateAndTime exposing (distanceInDays, monthDayYearTime, secondsToPosix)

import Time exposing (..)



-- CONSTANTS


millisPerDay : Int
millisPerDay =
    86400000



-- STRING HELPERS


monthDayYearTime : Posix -> Time.Zone -> String
monthDayYearTime posix zone =
    (englishMonthName <| Time.toMonth zone posix)
        ++ " "
        ++ (String.fromInt <| Time.toDay zone posix)
        ++ ", "
        ++ (String.fromInt <| Time.toYear zone posix)
        ++ " at "
        ++ (String.fromInt <| Time.toHour zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toMinute zone posix)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toSecond zone posix)


distanceInDays : Time.Posix -> Time.Posix -> String
distanceInDays currentPosix inputPosix =
    let
        durationInMillis =
            findElapsedDuration currentPosix inputPosix
    in
    if withinTheDay durationInMillis then
        "Today"

    else if durationInMillis > 0 then
        daysAgoString <| millisToDays durationInMillis

    else
        daysFromCurrentString <| millisToDays durationInMillis


daysAgoString : Int -> String
daysAgoString duration =
    String.fromInt duration ++ " days ago"


daysFromCurrentString : Int -> String
daysFromCurrentString duration =
    String.fromInt duration ++ " days from now"



-- CONVERSIONS


secondsToPosix : Int -> Posix
secondsToPosix seconds =
    millisToPosix (seconds * 1000)


millisToDays : Int -> Int
millisToDays duration =
    let
        durationFloat =
            toFloat duration

        millisFloat =
            toFloat millisPerDay
    in
    (durationFloat / millisFloat)
        |> ceiling
        |> abs


englishMonthName : Time.Month -> String
englishMonthName month =
    case month of
        Time.Jan ->
            "January"

        Time.Feb ->
            "February"

        Time.Mar ->
            "March"

        Time.Apr ->
            "April"

        Time.May ->
            "May"

        Time.Jun ->
            "June"

        Time.Jul ->
            "July"

        Time.Aug ->
            "August"

        Time.Sep ->
            "September"

        Time.Oct ->
            "October"

        Time.Nov ->
            "November"

        Time.Dec ->
            "December"



-- CALCULATIONS


withinTheDay : Int -> Bool
withinTheDay duration =
    let
        absoluteDuration =
            abs duration
    in
    absoluteDuration <= millisPerDay && absoluteDuration >= 0


findElapsedDuration : Time.Posix -> Time.Posix -> Int
findElapsedDuration currentPosix inputPosix =
    let
        currentTime =
            Time.posixToMillis currentPosix

        inputTime =
            Time.posixToMillis inputPosix
    in
    currentTime - inputTime
