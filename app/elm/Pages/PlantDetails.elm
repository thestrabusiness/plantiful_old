module Pages.PlantDetails exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text)
import Plant
import User


type alias Model =
    { plantId : Int, currentUser : User.User }


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


init : User.User -> Int -> ( Model, Cmd msg )
init user plantId =
    ( Model plantId user, Cmd.none )


view : Model -> Html msg
view model =
    div []
        [ div [] [ text <| "Plant ID: " ++ String.fromInt model.plantId ]
        ]
