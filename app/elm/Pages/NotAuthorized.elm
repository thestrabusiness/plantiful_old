module Pages.NotAuthorized exposing (Model, Msg, init, view)

import Html exposing (Html, a, div, p, text)
import Html.Attributes exposing (class, href)


type alias Model =
    {}


type Msg
    = Noop


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


view : Html Msg
view =
    div [ class "form container__center container__shadow" ]
        [ p [] [ text "You aren't authorized to view that page" ]
        , p []
            [ text "Click "
            , a [ href "/sign_in" ] [ text "here" ]
            , text " to sign in"
            ]
        ]
