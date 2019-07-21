module Main exposing (Model, Msg(..), Page(..), currentPage, init, loadCurrentPage, main, nav, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.PlantForm as PlantForm
import Pages.PlantList as PlantList
import Routes exposing (Route)
import Url



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , route : Route
    }



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { key = key
            , page = PageNone
            , route = Routes.extractRoute url
            }
    in
    ( model, Cmd.none )
        |> loadCurrentPage



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ListMsg PlantList.Msg
    | PlantFormMsg PlantForm.Msg


type Page
    = PageNone
    | PageList PlantList.Model
    | PlantFormPage PlantForm.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model, Nav.load url )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Routes.extractRoute url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> loadCurrentPage

        ( ListMsg subMsg, PageList pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    PlantList.update subMsg pageModel
            in
            ( { model | page = PageList newPageModel }
            , Cmd.map ListMsg newCmd
            )

        ( ListMsg subMsg, _ ) ->
            ( model, Cmd.none )

        ( PlantFormMsg subMsg, PlantFormPage pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    PlantForm.update subMsg pageModel model.key
            in
            ( { model | page = PlantFormPage newPageModel }
            , Cmd.map PlantFormMsg newCmd
            )

        ( PlantFormMsg subMsg, _ ) ->
            ( model, Cmd.none )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    let
        ( page, newCmd ) =
            case model.route of
                Routes.HomeRoute ->
                    ( PageNone, Cmd.none )

                Routes.PlantsRoute ->
                    let
                        ( pageModel, pageCmd ) =
                            PlantList.init
                    in
                    ( PageList pageModel, Cmd.map ListMsg pageCmd )

                Routes.NewPlantRoute ->
                    let
                        ( formModel, formCmd ) =
                            PlantForm.init
                    in
                    ( PlantFormPage formModel, Cmd.map PlantFormMsg formCmd )

                Routes.NotFoundRoute ->
                    ( PageNone, Cmd.none )
    in
    ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Plantiful"
    , body =
        [ h2 [] [ text "Welcome to Plantiful" ]
        , currentPage model
        ]
    }


currentPage : Model -> Html Msg
currentPage model =
    let
        page =
            case model.page of
                PageList pageModel ->
                    PlantList.view pageModel
                        |> Html.map ListMsg

                PlantFormPage pageModel ->
                    PlantForm.view pageModel
                        |> Html.map PlantFormMsg

                PageNone ->
                    text "Home Page"
    in
    section []
        [ nav model
        , page
        ]


nav : Model -> Html Msg
nav model =
    let
        links =
            case model.route of
                Routes.HomeRoute ->
                    [ linkToPlants ]

                Routes.PlantsRoute ->
                    [ text "Here are some plants" ]

                Routes.NewPlantRoute ->
                    [ text "Make a new plant" ]

                Routes.NotFoundRoute ->
                    [ linkToPlants ]

        linkToPlants =
            a [ href Routes.plantsPath ] [ text "Plants" ]
    in
    div
        []
        links



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
