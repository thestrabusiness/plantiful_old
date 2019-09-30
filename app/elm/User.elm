module User exposing (Errors, NewUser, User, createUser, getCurrentUser, signIn, signOut, toCredentials)

import Api
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias Credentials =
    { email : String
    , password : String
    }


type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    , email : String
    , rememberToken : String
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


createUser : String -> (Result Http.Error User -> msg) -> NewUser -> Cmd msg
createUser csrfToken msg newUser =
    let
        params =
            encodeUser newUser
    in
    HttpBuilder.post Api.usersEndpoint
        |> HttpBuilder.withHeader "X-CSRF-Token" csrfToken
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg userDecoder)
        |> HttpBuilder.request


signIn : String -> (Result Http.Error User -> msg) -> Credentials -> Cmd msg
signIn csrfToken msg credentials =
    let
        params =
            encodeCredentials credentials
    in
    HttpBuilder.post Api.signInEndpoint
        |> HttpBuilder.withHeader "X-CSRF-Token" csrfToken
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg userDecoder)
        |> HttpBuilder.request


signOut : String -> (Result Http.Error () -> msg) -> Cmd msg
signOut csrfToken msg =
    HttpBuilder.delete Api.signOutEndpoint
        |> HttpBuilder.withHeader "X-CSRF-Token" csrfToken
        |> HttpBuilder.withExpect (Http.expectWhatever msg)
        |> HttpBuilder.request


getCurrentUser : (Result Http.Error User -> msg) -> Cmd msg
getCurrentUser msg =
    HttpBuilder.get Api.currentUserEndpoint
        |> HttpBuilder.withExpect (Http.expectJson msg userDecoder)
        |> HttpBuilder.request


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "id" int
        |> required "first_name" string
        |> required "last_name" string
        |> required "email" string
        |> required "remember_token" string


errorsDecoder : Decoder Errors
errorsDecoder =
    succeed Errors
        |> optional "first_name" (list string) []
        |> optional "last_name" (list string) []
        |> optional "email" (list string) []
        |> optional "password" (list string) []


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


encodeCredentials : Credentials -> Encode.Value
encodeCredentials credentials =
    Encode.object
        [ ( "user"
          , Encode.object
                [ ( "email", Encode.string credentials.email )
                , ( "password", Encode.string credentials.password )
                ]
          )
        ]


toCredentials : { a | email : String, password : String } -> Credentials
toCredentials { email, password } =
    Credentials email password
