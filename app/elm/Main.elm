module Main exposing (Model, Msg(..), Page(..), currentPage, init, loadCurrentPage, main, nav, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.PlantForm as PlantForm
import Pages.PlantList as PlantList
import Pages.UserForm as UserForm
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
    | PlantListMsg PlantList.Msg
    | PlantFormMsg PlantForm.Msg
    | UserFormMsg UserForm.Msg


type Page
    = PageNone
    | PlantListPage PlantList.Model
    | PlantFormPage PlantForm.Model
    | UserPage UserForm.Model


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

        ( PlantListMsg subMsg, PlantListPage pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    PlantList.update subMsg pageModel
            in
            ( { model | page = PlantListPage newPageModel }
            , Cmd.map PlantListMsg newCmd
            )

        ( PlantListMsg subMsg, _ ) ->
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

        ( UserFormMsg subMsg, UserPage pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    UserForm.update subMsg pageModel model.key
            in
            ( { model | page = UserPage newPageModel }
            , Cmd.map UserFormMsg newCmd
            )

        ( UserFormMsg subMsg, _ ) ->
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
                    ( PlantListPage pageModel, Cmd.map PlantListMsg pageCmd )

                Routes.NewPlantRoute ->
                    let
                        ( formModel, formCmd ) =
                            PlantForm.init
                    in
                    ( PlantFormPage formModel, Cmd.map PlantFormMsg formCmd )

                Routes.NewUserRoute ->
                    let
                        ( formModel, formCmd ) =
                            UserForm.init
                    in
                    ( UserPage formModel, Cmd.map UserFormMsg formCmd )

                Routes.NotFoundRoute ->
                    ( PageNone, Cmd.none )
    in
    ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Plantiful"
    , body =
        [ currentPage model
        ]
    }


currentPage : Model -> Html Msg
currentPage model =
    let
        page =
            case model.page of
                PlantListPage pageModel ->
                    PlantList.view pageModel
                        |> Html.map PlantListMsg

                PlantFormPage pageModel ->
                    PlantForm.view pageModel
                        |> Html.map PlantFormMsg

                UserPage pageModel ->
                    UserForm.view pageModel
                        |> Html.map UserFormMsg

                PageNone ->
                    text "Home Page"
    in
    div []
        [ nav model
        , div [ class "container" ] [ page ]
        ]


nav : Model -> Html Msg
nav model =
    div
        [ class "header" ]
        [ h2 [] [ text "Plantiful" ]
        , headerLink model
        ]


headerLink : Model -> Html Msg
headerLink model =
    case model.route of
        Routes.HomeRoute ->
            signUpLink

        Routes.PlantsRoute ->
            signOutLink

        Routes.NewPlantRoute ->
            signOutLink

        Routes.NewUserRoute ->
            signOutLink

        Routes.NotFoundRoute ->
            text ""


signUpLink : Html Msg
signUpLink =
    a [ class "l-pr", href "/sign_up" ] [ text "Sign Up" ]


signOutLink : Html Msg
signOutLink =
    a [ class "l-pr", href "/sign_out" ] [ text "Sign Out" ]



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
