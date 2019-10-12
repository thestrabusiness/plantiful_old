module Garden exposing (Garden, gardenListDecoder)

import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Garden =
    { id : Int, name : String }



-- DECODER


gardenDecoder : Decoder Garden
gardenDecoder =
    succeed Garden
        |> required "id" int
        |> required "name" string


gardenListDecoder : Decoder (List Garden)
gardenListDecoder =
    Json.Decode.list gardenDecoder
