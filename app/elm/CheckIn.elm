module CheckIn exposing (CheckIn, Event(..), checkInListDecoder, submitCheckIn)

import DateAndTime
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, bool, int, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Process
import Task
import Time exposing (Posix)


type alias CheckIn =
    { id : Int
    , createdAt : Posix
    , watered : Bool
    , fertilized : Bool
    , notes : String
    , plantId : Int
    }


type alias NewCheckIn =
    { watered : Bool, fertilized : Bool, notes : String, plantId : Int }


type Event
    = Watered
    | Fertilized
    | NoEvent


submitCheckIn :
    { watered : Bool
    , fertilized : Bool
    , notes : String
    , plantId : Int
    , plantName : String
    }
    -> (Result Http.Error CheckIn -> a)
    -> Cmd a
submitCheckIn form a =
    let
        plantId =
            form.plantId

        url =
            "api/plants/" ++ String.fromInt plantId ++ "/check_ins"

        params =
            encodeCheckInForm <| checkInFromForm form
    in
    HttpBuilder.post url
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson a checkInDecoder)
        |> HttpBuilder.request


checkInFromForm :
    { watered : Bool
    , fertilized : Bool
    , notes : String
    , plantId : Int
    , plantName : String
    }
    -> NewCheckIn
checkInFromForm form =
    NewCheckIn form.watered form.fertilized form.notes form.plantId


encodeCheckInForm : NewCheckIn -> Encode.Value
encodeCheckInForm form =
    Encode.object
        [ ( "watered", Encode.bool form.watered )
        , ( "fertilized", Encode.bool form.fertilized )
        , ( "notes", Encode.string form.notes )
        ]


checkInDecoder : Decoder CheckIn
checkInDecoder =
    succeed CheckIn
        |> required "id" int
        |> required "created_at" DateAndTime.posixDecoder
        |> required "watered" bool
        |> required "fertilized" bool
        |> optional "notes" string ""
        |> required "plant_id" int


checkInListDecoder : Decoder (List CheckIn)
checkInListDecoder =
    Json.Decode.list checkInDecoder
