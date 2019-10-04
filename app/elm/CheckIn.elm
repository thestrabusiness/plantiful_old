module CheckIn exposing (CheckIn, Event(..), checkInListDecoder, submitCheckIn)

import Api
import DateAndTime
import File
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, bool, int, list, string, succeed)
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
    , photos : List String
    }


type alias NewCheckIn =
    { watered : Bool
    , fertilized : Bool
    , notes : String
    , photos : List String
    , plantId : Int
    }


type Event
    = Watered
    | Fertilized
    | NoEvent


submitCheckIn :
    String
    ->
        { watered : Bool
        , fertilized : Bool
        , notes : String
        , photos : List String
        , plantId : Int
        , plantName : String
        }
    -> (Result Http.Error CheckIn -> a)
    -> Cmd a
submitCheckIn csrfToken form a =
    let
        plantId =
            form.plantId

        params =
            encodeCheckInForm <| checkInFromForm form
    in
    Http.request
        { method = "POST"
        , url = Api.checkInEndpoint plantId
        , body = checkInRequestBody <| checkInFromForm form
        , expect = Http.expectJson a checkInDecoder
        , headers = [ Http.header "X-CSRF-Token" csrfToken ]
        , timeout = Nothing
        , tracker = Nothing
        }


checkInRequestBody : NewCheckIn -> Http.Body
checkInRequestBody checkIn =
    checkIn
        |> addFilePartToBody
        |> addStringPartsToBody
        |> Http.multipartBody


addFilePartToBody : NewCheckIn -> ( NewCheckIn, List Http.Part )
addFilePartToBody checkIn =
    let
        photoFileParts =
            List.map (Http.stringPart "check_in[photos][]") checkIn.photos
    in
    ( checkIn, photoFileParts )


addStringPartsToBody : ( NewCheckIn, List Http.Part ) -> List Http.Part
addStringPartsToBody ( checkIn, partList ) =
    partList
        ++ [ Http.stringPart "check_in[watered]" (boolToString checkIn.watered)
           , Http.stringPart "check_in[fertilized]" (boolToString checkIn.fertilized)
           , Http.stringPart "check_in[notes]" checkIn.notes
           ]


boolToString : Bool -> String
boolToString bool =
    case bool of
        True ->
            "true"

        False ->
            "false"


checkInFromForm :
    { watered : Bool
    , fertilized : Bool
    , notes : String
    , photos : List String
    , plantId : Int
    , plantName : String
    }
    -> NewCheckIn
checkInFromForm form =
    NewCheckIn form.watered form.fertilized form.notes form.photos form.plantId


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
        |> required "photo_urls" (list string)


checkInListDecoder : Decoder (List CheckIn)
checkInListDecoder =
    Json.Decode.list checkInDecoder
