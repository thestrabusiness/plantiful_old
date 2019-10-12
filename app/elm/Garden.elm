module Garden exposing (Garden, createGarden, gardenListDecoder)

import Api
import Http
import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias Garden =
    { id : Int, name : String }



-- API


createGarden : String -> String -> (Result Http.Error Garden -> msg) -> Cmd msg
createGarden csrfToken name msg =
    let
        body =
            encodeGarden name
    in
    Http.request
        { method = "POST"
        , url = Api.gardensEndpoint
        , body = Http.jsonBody body
        , expect = Http.expectJson msg gardenDecoder
        , headers = [ Http.header "X-CSRF-Token" csrfToken ]
        , timeout = Nothing
        , tracker = Nothing
        }



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
