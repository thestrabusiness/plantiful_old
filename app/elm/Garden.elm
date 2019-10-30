module Garden exposing (Garden, encodeGarden, gardenDecoder, gardenListDecoder)

import Http
import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias Garden =
    { id : Int, name : String }



-- DECODER


encodeGarden : String -> Encode.Value
encodeGarden name =
    Encode.object [ ( "name", Encode.string name ) ]


gardenDecoder : Decoder Garden
gardenDecoder =
    succeed Garden
        |> required "id" int
        |> required "name" string


gardenListDecoder : Decoder (List Garden)
gardenListDecoder =
    Json.Decode.list gardenDecoder
