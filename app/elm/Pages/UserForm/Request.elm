module Pages.UserForm.Request exposing (createUser)

import Api
import Http
import HttpBuilder
import User exposing (NewUser, User, encodeUser, userDecoder)


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
