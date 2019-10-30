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
import Session exposing (Session)
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
    , gardenId : Int
    }


type alias NewPlant =
    { name : String
    , checkFrequencyUnit : String
    , checkFrequencyScalar : String
    }


emptyPlant : Plant
emptyPlant =
    Plant 0
        ""
        (Time.millisToPosix 0)
        []
        ""
        False
        ""
        ""
        0


getPlant : Session -> Int -> (Result Http.Error Plant -> msg) -> Cmd msg
getPlant session plantId msg =
    Http.request
        { method = "GET"
        , url = Api.plantEndpoint plantId
        , body = Http.emptyBody
        , expect = Http.expectJson msg plantDecoder
        , headers = [ Api.authorizationHeader session.currentUser ]
        , timeout = Nothing
        , tracker = Nothing
        }


getPlants : Session -> Int -> (Result Http.Error (List Plant) -> msg) -> Cmd msg
getPlants session gardenId msg =
    Http.request
        { method = "GET"
        , url = Api.gardenPlantsEndpoint gardenId
        , body = Http.emptyBody
        , expect = Http.expectJson msg plantListDecoder
        , headers = [ Api.authorizationHeader session.currentUser ]
        , timeout = Nothing
        , tracker = Nothing
        }


encodePlant : NewPlant -> Encode.Value
encodePlant plant =
    Encode.object
        [ ( "name", Encode.string plant.name )
        , ( "check_frequency_unit", Encode.string plant.checkFrequencyUnit )
        , ( "check_frequency_scalar", Encode.string plant.checkFrequencyScalar )
        ]


createPlant :
    Session
    -> Int
    -> (Result Http.Error Plant -> msg)
    -> NewPlant
    -> Cmd msg
createPlant session gardenId msg newPlant =
    let
        params =
            encodePlant newPlant
    in
    Http.request
        { method = "POST"
        , url = Api.gardenPlantsEndpoint gardenId
        , body = Http.jsonBody params
        , expect = Http.expectJson msg plantDecoder
        , headers =
            [ Http.header "X-CSRF-Token" session.csrfToken
            , Api.authorizationHeader session.currentUser
            ]
        , timeout = Nothing
        , tracker = Nothing
        }


updatePlant :
    Session
    -> Int
    -> (Result Http.Error Plant -> msg)
    -> NewPlant
    -> Cmd msg
updatePlant session plantId msg plantForm =
    let
        params =
            encodePlant plantForm
    in
    Http.request
        { method = "PUT"
        , url = Api.plantEndpoint plantId
        , body = Http.jsonBody params
        , expect = Http.expectJson msg plantDecoder
        , headers =
            [ Http.header "X-CSRF-Token" session.csrfToken
            , Api.authorizationHeader session.currentUser
            ]
        , timeout = Nothing
        , tracker = Nothing
        }


uploadPhoto : Session -> String -> Plant -> (Result Http.Error Plant -> msg) -> Cmd msg
uploadPhoto session base64Photo plant msg =
    Http.request
        { method = "POST"
        , url = Api.plantAvatarEndpoint plant.id
        , body = Http.multipartBody [ Http.stringPart "plant[avatar]" base64Photo ]
        , expect = Http.expectJson msg plantDecoder
        , headers =
            [ Http.header "X-CSRF-Token" session.csrfToken
            , Api.authorizationHeader session.currentUser
            ]
        , timeout = Nothing
        , tracker = Just "photoUpload"
        }


deletePlant : Session -> Int -> (Result Http.Error () -> msg) -> Cmd msg
deletePlant session plantId msg =
    Http.request
        { method = "DELETE"
        , url = Api.plantEndpoint plantId
        , body = Http.emptyBody
        , expect = Http.expectWhatever msg
        , headers =
            [ Http.header "X-CSRF-Token" session.csrfToken
            , Api.authorizationHeader session.currentUser
            ]
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
    "https://raw.githubusercontent.com/thestrabusiness/plantiful/master/spec/fixtures/plant_stock4.jpg"


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
        |> required "garden_id" int


intToString : Decoder String
intToString =
    Json.Decode.map String.fromInt int
