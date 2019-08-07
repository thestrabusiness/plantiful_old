module Plant exposing (Plant, createPlant, getPlants, plantDecoder, plantListDecoder, toNewPlant, waterPlant)

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


type alias NewPlant =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
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
            "/api/plants/" ++ String.fromInt plant.id ++ "/plant_care_events"

        params =
            encodeCareEvent "watering"
    in
    HttpBuilder.post wateringPath
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
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
        |> optional "last_watering_date" string "Not Yet Watered"
