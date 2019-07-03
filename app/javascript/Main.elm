module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import HttpBuilder
import Json.Decode as Decode exposing (Decoder, field, succeed)
import Url


type alias Plant =
    { id : Int
    , name : String
    , last_watering_date : Maybe String
    }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , plants : List Plant
    }



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url [], getPlants )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Plantiful"
    , body =
        [ h2 [] [ text "Welcome to Plantiful" ]
        , viewPlantList model.plants
        ]
    }


viewPlant : Plant -> Html msg
viewPlant plant =
    li [] [ text plant.name ]


viewPlantList : List Plant -> Html msg
viewPlantList plants =
    let
        listOfPlants =
            List.map viewPlant plants
    in
    ul [] listOfPlants



-- UPDATE


type Msg
    = NewPlants (Result Http.Error (List Plant))
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewPlants (Ok newPlants) ->
            ( { model | plants = newPlants }, Cmd.none )

        NewPlants (Err error) ->
            let
                _ =
                    Debug.log "Whoops!" error
            in
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )



-- API


plantListDecoder : Decoder (List Plant)
plantListDecoder =
    Decode.list plantDecoder


plantDecoder : Decoder Plant
plantDecoder =
    Decode.map3 Plant
        (field "id" Decode.int)
        (field "name" Decode.string)
        (Decode.maybe (field "last_watering_date" Decode.string))


getPlants : Cmd Msg
getPlants =
    HttpBuilder.get "api/plants"
        |> HttpBuilder.withHeaders
            [ ( "Content-Type", "application/json" )
            , ( "Accept"
              , "application/json"
              )
            ]
        |> HttpBuilder.withExpect (Http.expectJson NewPlants plantListDecoder)
        |> HttpBuilder.request



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
