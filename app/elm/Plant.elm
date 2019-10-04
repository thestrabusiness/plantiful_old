module Plant exposing
    ( NewPlant
    , Plant
    , createPlant
    , deletePlant
    , emptyPlant
    , getPlant
    , getPlants
    , plantDecoder
    , plantListDecoder
    , toNewPlant
    , updatePlant
    , uploadPhoto
    )

import Api
import CheckIn
import DateAndTime
import File
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, bool, int, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Time exposing (Posix)


type alias Plant =
    { id : Int
    , name : String
    , lastWateredAt : Posix
    , checkIns : List CheckIn.CheckIn
    , avatarUrl : String
    , overdueForCheckIn : Bool
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    }


type alias NewPlant =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    }


emptyPlant : Plant
emptyPlant =
    Plant 0 "" (Time.millisToPosix 0) [] "" False "" ""


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


updatePlant : String -> (Result Http.Error Plant -> msg) -> Int -> NewPlant -> Cmd msg
updatePlant csrfToken msg plantId plantForm =
    let
        params =
            encodePlant plantForm
    in
    HttpBuilder.put (Api.plantEndpoint plantId)
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


deletePlant : String -> Int -> (Result Http.Error () -> msg) -> Cmd msg
deletePlant csrfToken plantId msg =
    Http.request
        { method = "DELETE"
        , url = Api.plantEndpoint plantId
        , body = Http.emptyBody
        , expect = Http.expectWhatever msg
        , headers = [ Http.header "X-CSRF-Token" csrfToken ]
        , timeout = Nothing
        , tracker = Nothing
        }


toNewPlant : { a | name : String, checkFrequencyUnit : String, checkFrequencyScalar : String } -> NewPlant
toNewPlant { name, checkFrequencyUnit, checkFrequencyScalar } =
    NewPlant name checkFrequencyUnit checkFrequencyScalar


plantListDecoder : Decoder (List Plant)
plantListDecoder =
    Json.Decode.list plantDecoder


placeholderImage : String
placeholderImage =
    "https://raw.githubusercontent.com/thestrabusiness/plantiful/change-plant-list-styling/app/assets/images/default_plant.jpg"


plantDecoder : Decoder Plant
plantDecoder =
    succeed Plant
        |> required "id" int
        |> required "name" string
        |> optional "last_watered_at" DateAndTime.posixDecoder (Time.millisToPosix 0)
        |> optional "check_ins" CheckIn.checkInListDecoder []
        |> optional "avatar" string placeholderImage
        |> required "overdue_for_check_in" bool
        |> required "check_frequency_unit" string
        |> required "check_frequency_scalar" intToString


intToString : Decoder String
intToString =
    Json.Decode.map String.fromInt int
