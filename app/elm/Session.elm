module Session exposing
    ( Session
    , getCurrentSession
    , getCurrentUser
    , signIn
    , signOut
    , toCredentials
    )

import Api
import Http
import HttpBuilder
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Loadable exposing (Loadable)
import User


type alias Session =
    { csrfToken : String, currentUser : Loadable User.User }


type alias Credentials =
    { email : String
    , password : String
    }


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


getCurrentSession : String -> (Result Http.Error User.User -> msg) -> Cmd msg
getCurrentSession csrfToken msg =
    Http.request
        { method = "POST"
        , url = Api.sessionStatusEndpoint
        , body = Http.emptyBody
        , expect = Http.expectJson msg User.userDecoder
        , headers = [ Api.sessionTypeHeader, Http.header "X-CSRF-Token" csrfToken ]
        , timeout = Nothing
        , tracker = Nothing
        }


getCurrentUser : Session -> (Result Http.Error User.User -> msg) -> Cmd msg
getCurrentUser session msg =
    Http.request
        { method = "GET"
        , url = Api.currentUserEndpoint
        , body = Http.emptyBody
        , expect = Http.expectJson msg User.userDecoder
        , headers = [ Api.sessionTypeHeader, Api.authorizationHeader session.currentUser ]
        , timeout = Nothing
        , tracker = Nothing
        }


signIn : String -> (Result Http.Error User.User -> msg) -> Credentials -> Cmd msg
signIn csrfToken msg credentials =
    let
        params =
            encodeCredentials credentials
    in
    HttpBuilder.post Api.signInEndpoint
        |> HttpBuilder.withHeader "X-CSRF-Token" csrfToken
        |> HttpBuilder.withJsonBody params
        |> HttpBuilder.withExpect (Http.expectJson msg User.userDecoder)
        |> HttpBuilder.request


signOut : Session -> (Result Http.Error () -> msg) -> Cmd msg
signOut session msg =
    Http.request
        { method = "DELETE"
        , url = Api.signOutEndpoint
        , body = Http.emptyBody
        , expect = Http.expectWhatever msg
        , headers =
            [ Api.sessionTypeHeader
            , Http.header "X-CSRF-Token" session.csrfToken
            , Api.authorizationHeader session.currentUser
            ]
        , timeout = Nothing
        , tracker = Nothing
        }
