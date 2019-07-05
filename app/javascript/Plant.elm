module Plant exposing (..)

import Http
import HttpBuilder
import Json.Decode as Decode exposing (Decoder, field, succeed)

type alias Plant =
  { id: Int
  , name: String
  , last_watering_date : Maybe String
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

plantListDecoder : Decoder (List Plant)
plantListDecoder =
    Decode.list plantDecoder


plantDecoder : Decoder Plant
plantDecoder =
    Decode.map3 Plant
        (field "id" Decode.int)
        (field "name" Decode.string)
        (Decode.maybe (field "last_watering_date" Decode.string))

