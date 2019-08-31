module Plant exposing
    ( Plant
    , createPlant
    , emptyPlant
    , getPlant
    , getPlants
    , plantDecoder
    , plantListDecoder
    , toNewPlant
    )

import CheckIn
import DateAndTime
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Time exposing (Posix)


type alias Plant =
    { id : Int
    , name : String
    , lastWateredAt : Posix
    , checkIns : List CheckIn.CheckIn
    }


type alias NewPlant =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    }


emptyPlant : Plant
emptyPlant =
    Plant 0 "" (Time.millisToPosix 0) []


getPlant : Int -> (Result Http.Error Plant -> msg) -> Cmd msg
getPlant int msg =
    let
        url =
            "/api/plants/" ++ String.fromInt int
    in
    HttpBuilder.get url
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
        |> HttpBuilder.request


getPlants : (Result Http.Error (List Plant) -> msg) -> Cmd msg
getPlants msg =
    HttpBuilder.get "/api/plants"
        |> HttpBuilder.withExpect (Http.expectJson msg plantListDecoder)
        |> HttpBuilder.request


encodeCareEvent : String -> Encode.Value
encodeCareEvent kind =
    Encode.object [ ( "kind", Encode.string kind ) ]


encodePlant : NewPlant -> Encode.Value
encodePlant plant =
    Encode.object
        [ ( "name", Encode.string plant.name )
        , ( "check_frequency_unit", Encode.string plant.checkFrequencyUnit )
        , ( "check_frequency_scalar", Encode.string plant.checkFrequencyScalar )
        ]


createPlant : (Result Http.Error Plant -> msg) -> NewPlant -> Cmd msg
createPlant msg newPlant =
    let
        url =
            "/api/plants"

        params =
            encodePlant newPlant
    in
    HttpBuilder.post url
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
        |> HttpBuilder.request


toNewPlant : { a | name : String, checkFrequencyUnit : String, checkFrequencyScalar : String } -> NewPlant
toNewPlant { name, checkFrequencyUnit, checkFrequencyScalar } =
    NewPlant name checkFrequencyUnit checkFrequencyScalar


plantListDecoder : Decoder (List Plant)
plantListDecoder =
    Json.Decode.list plantDecoder


plantDecoder : Decoder Plant
plantDecoder =
    succeed Plant
        |> required "id" int
        |> required "name" string
        |> optional "last_watered_at" DateAndTime.posixDecoder (Time.millisToPosix 0)
        |> optional "check_ins" CheckIn.checkInListDecoder []
