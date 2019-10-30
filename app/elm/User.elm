module User exposing
    ( AuthToken(..)
    , Errors
    , NewUser
    , User
    , encodeUser
    , userDecoder
    )

import Garden exposing (Garden, gardenListDecoder)
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type AuthToken
    = AuthToken String


type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    , email : String
    , defaultGardenId : Int
    , ownedGardens : List Garden
    , sharedGardens : List Garden
    , rememberToken : AuthToken
    }


type alias NewUser =
    { firstName : String
    , lastName : String
    , email : String
    , password : String
    }


type alias Errors =
    { firstName : List String
    , lastName : List String
    , email : List String
    , password : List String
    }


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "id" int
        |> required "first_name" string
        |> required "last_name" string
        |> required "email" string
        |> required "default_garden_id" int
        |> required "owned_gardens" gardenListDecoder
        |> required "shared_gardens" gardenListDecoder
        |> required "remember_token" authTokenDecoder


authTokenDecoder : Decoder AuthToken
authTokenDecoder =
    Json.Decode.map AuthToken string


encodeUser : NewUser -> Encode.Value
encodeUser newUser =
    Encode.object
        [ ( "user"
          , Encode.object
                [ ( "first_name", Encode.string newUser.firstName )
                , ( "last_name", Encode.string newUser.lastName )
                , ( "email", Encode.string newUser.email )
                , ( "password", Encode.string newUser.password )
                ]
          )
        ]
