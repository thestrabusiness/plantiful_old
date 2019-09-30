module Plant exposing
    ( Plant
    , createPlant
    , emptyPlant
    , getPlant
    , getPlants
    , plantDecoder
    , plantListDecoder
    , toNewPlant
    , uploadPhoto
    )

import Api
import CheckIn
import DateAndTime
import File
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
    , avatarUrl : String
    }


type alias NewPlant =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    }


emptyPlant : Plant
emptyPlant =
    Plant 0 "" (Time.millisToPosix 0) [] ""


getPlant : Int -> (Result Http.Error Plant -> msg) -> Cmd msg
getPlant plantId msg =
    HttpBuilder.get (Api.plantEndpoint plantId)
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
        |> HttpBuilder.request


getPlants : (Result Http.Error (List Plant) -> msg) -> Cmd msg
getPlants msg =
    HttpBuilder.get Api.plantsEndpoint
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


createPlant : String -> (Result Http.Error Plant -> msg) -> NewPlant -> Cmd msg
createPlant csrfToken msg newPlant =
    let
        params =
            encodePlant newPlant
    in
    HttpBuilder.post Api.plantsEndpoint
        |> HttpBuilder.withHeader "X-CSRF-Token" csrfToken
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg plantDecoder)
        |> HttpBuilder.request


uploadPhoto : String -> String -> Plant -> (Result Http.Error Plant -> msg) -> Cmd msg
uploadPhoto csrfToken base64Photo plant msg =
    Http.request
        { method = "POST"
        , url = Api.plantAvatarEndpoint plant.id
        , body = Http.multipartBody [ Http.stringPart "plant[avatar]" base64Photo ]
        , expect = Http.expectJson msg plantDecoder
        , headers = [ Http.header "X-CSRF-Token" csrfToken ]
        , timeout = Nothing
        , tracker = Just "photoUpload"
        }


toNewPlant : { a | name : String, checkFrequencyUnit : String, checkFrequencyScalar : String } -> NewPlant
toNewPlant { name, checkFrequencyUnit, checkFrequencyScalar } =
    NewPlant name checkFrequencyUnit checkFrequencyScalar


plantListDecoder : Decoder (List Plant)
plantListDecoder =
    Json.Decode.list plantDecoder


placeholderImage : String
placeholderImage =
    "https://cdn.shopify.com/s/files/1/0662/5489/products/Zamioculcas_zamiifolia_-_ZZ_Plant_-_pistils_nursery_1024x1024.jpg?v=1553629568"


plantDecoder : Decoder Plant
plantDecoder =
    succeed Plant
        |> required "id" int
        |> required "name" string
        |> optional "last_watered_at" DateAndTime.posixDecoder (Time.millisToPosix 0)
        |> optional "check_ins" CheckIn.checkInListDecoder []
        |> optional "avatar" string placeholderImage
