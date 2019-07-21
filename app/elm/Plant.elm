module Plant exposing (Plant, createPlant, getPlants, plantDecoder, plantListDecoder, waterPlant)

import Http
import HttpBuilder
import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias Plant =
    { id : Int
    , name : String
    , lastWateringDate : String
    }


getPlants : (Result Http.Error (List Plant) -> msg) -> Cmd msg
getPlants msg =
    HttpBuilder.get "api/plants"
        |> HttpBuilder.withHeaders
            [ ( "Content-Type", "application/json" )
            , ( "Accept"
              , "application/json"
              )
            ]
        |> HttpBuilder.withExpect (Http.expectJson msg plantListDecoder)
        |> HttpBuilder.request


waterPlant : (Result Http.Error Plant -> msg) -> Plant -> Cmd msg
waterPlant msg plant =
    let
        wateringPath =
            "/api/plants/" ++ String.fromInt plant.id ++ "/waterings"
    in
    HttpBuilder.post wateringPath
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
        |> HttpBuilder.request


encodePlant : String -> Encode.Value
encodePlant name =
    Encode.object [ ( "name", Encode.string name ) ]


createPlant : (Result Http.Error Plant -> msg) -> String -> Cmd msg
createPlant msg name =
    let
        url =
            "/api/plants"

        params =
            encodePlant name
    in
    HttpBuilder.post url
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
        |> HttpBuilder.request


plantListDecoder : Decoder (List Plant)
plantListDecoder =
    Json.Decode.list plantDecoder


plantDecoder : Decoder Plant
plantDecoder =
    succeed Plant
        |> required "id" int
        |> required "name" string
        |> optional "last_watering_date" string "Not Yet Watered"
