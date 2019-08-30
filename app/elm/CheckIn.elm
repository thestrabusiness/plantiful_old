module CheckIn exposing (CheckIn, Event(..), submitCheckIn)

import Http
import HttpBuilder
import Json.Decode exposing (Decoder, bool, int, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Plant
import Process
import Task


type alias CheckIn =
    { watered : Bool, fertilized : Bool, notes : String, plant : Plant.Plant }


type Event
    = Watered
    | Fertilized
    | NoEvent


submitCheckIn : CheckIn -> (Result Http.Error CheckIn -> a) -> Cmd a
submitCheckIn form a =
    let
        plantId =
            form.plant.id

        url =
            "api/plants/" ++ String.fromInt plantId ++ "/check_ins"

        params =
            encodeCheckInForm form
    in
    HttpBuilder.post url
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson a checkInDecoder)
        |> HttpBuilder.request


encodeCheckInForm : CheckIn -> Encode.Value
encodeCheckInForm form =
    Encode.object
        [ ( "watered", Encode.bool form.watered )
        , ( "fertilized", Encode.bool form.fertilized )
        , ( "notes", Encode.string form.notes )
        ]


checkInDecoder : Decoder CheckIn
checkInDecoder =
    succeed CheckIn
        |> required "watered" bool
        |> required "fertilized" bool
        |> optional "notes" string ""
        |> required "plant" Plant.plantDecoder
