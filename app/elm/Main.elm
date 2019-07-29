module Main exposing (Model, Msg(..), Page(..), currentPage, init, loadCurrentPage, main, nav, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Pages.NotAuthorized as NotAuthorized
import Pages.PlantForm as PlantForm
import Pages.PlantList as PlantList
import Pages.SignIn as SignIn
import Pages.UserForm as UserForm
import Routes exposing (Route)
import Url
import User exposing (User)



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , route : Route
    , currentUser : Maybe User
    }



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { key = key
            , page = PageNone
            , route = Routes.extractRoute url
            , currentUser = Nothing
            }
    in
    ( model, User.getCurrentUser ReceivedCurrentUserResponse )
        |> loadCurrentPage



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | PlantListMsg PlantList.Msg
    | PlantFormMsg PlantForm.Msg
    | UserFormMsg UserForm.Msg
    | NotAuthorizedMsg NotAuthorized.Msg
    | SignInMsg SignIn.Msg
    | UserClickedSignOutButton
    | ReceivedUserSignOutResponse (Result Http.Error ())
    | ReceivedCurrentUserResponse (Result Http.Error User)


type Page
    = PageNone
    | PlantListPage PlantList.Model
    | PlantFormPage PlantForm.Model
    | UserPage UserForm.Model
    | NotAuthorizedPage NotAuthorized.Model
    | SignInPage SignIn.Model


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

        ( UserClickedSignOutButton, _ ) ->
            ( model, User.signOut ReceivedUserSignOutResponse )

        ( ReceivedUserSignOutResponse (Ok _), _ ) ->
            ( { model | currentUser = Nothing }, Nav.pushUrl model.key Routes.signInPath )

        ( ReceivedUserSignOutResponse (Err _), _ ) ->
            ( model, Cmd.none )

        ( ReceivedCurrentUserResponse (Ok user), _ ) ->
            ( { model | currentUser = Just user }, Nav.pushUrl model.key Routes.plantsPath )

        ( ReceivedCurrentUserResponse (Err error), _ ) ->
            ( { model | currentUser = Nothing }, Cmd.none )

        ( PlantListMsg subMsg, PlantListPage pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    PlantList.update subMsg pageModel
            in
            ( { model | page = PlantListPage newPageModel }
            , Cmd.map PlantListMsg newCmd
            )

        ( PlantFormMsg subMsg, PlantFormPage pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    PlantForm.update subMsg pageModel model.key
            in
            ( { model | page = PlantFormPage newPageModel }
            , Cmd.map PlantFormMsg newCmd
            )

        ( UserFormMsg subMsg, UserPage pageModel ) ->
            let
                ( newPageModel, newCmd, currentUser ) =
                    UserForm.update subMsg pageModel model.key
            in
            ( { model
                | page = UserPage newPageModel
                , currentUser = currentUser
              }
            , Cmd.map UserFormMsg newCmd
            )

        ( SignInMsg subMsg, SignInPage pageModel ) ->
            let
                ( newPageModel, newCmd, currentUser ) =
                    SignIn.update subMsg pageModel model.key
            in
            ( { model
                | page = SignInPage newPageModel
                , currentUser = currentUser
              }
            , Cmd.map SignInMsg newCmd
            )

        ( _, _ ) ->
            ( model, Cmd.none )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    let
        ( page, newCmd ) =
            case model.route of
                Routes.PlantsRoute ->
                    case model.currentUser of
                        Just user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init user
                            in
                            ( PlantListPage pageModel, Cmd.map PlantListMsg pageCmd )

                        Nothing ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )

                Routes.NewPlantRoute ->
                    case model.currentUser of
                        Just user ->
                            let
                                ( formModel, formCmd ) =
                                    PlantForm.init user
                            in
                            ( PlantFormPage formModel, Cmd.map PlantFormMsg formCmd )

                        Nothing ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )

                Routes.NewUserRoute ->
                    let
                        ( formModel, formCmd ) =
                            UserForm.init
                    in
                    ( UserPage formModel, Cmd.map UserFormMsg formCmd )

                Routes.SignInRoute ->
                    case model.currentUser of
                        Just user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init user
                            in
                            ( PlantListPage pageModel, Cmd.map PlantListMsg pageCmd )

                        Nothing ->
                            let
                                ( pageModel, pageCmd ) =
                                    SignIn.init
                            in
                            ( SignInPage pageModel, Cmd.map SignInMsg pageCmd )

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

                NotAuthorizedPage _ ->
                    NotAuthorized.view
                        |> Html.map NotAuthorizedMsg

                SignInPage pageModel ->
                    SignIn.view pageModel
                        |> Html.map SignInMsg

                PageNone ->
                    text "Page Not Found"
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
        Routes.PlantsRoute ->
            signOutButton

        Routes.NewPlantRoute ->
            signOutButton

        Routes.NewUserRoute ->
            signOutButton

        Routes.SignInRoute ->
            signUpLink

        Routes.NotFoundRoute ->
            text ""


signUpLink : Html Msg
signUpLink =
    a [ class "l-pr", href "/sign_up" ] [ text "Sign Up" ]


signOutButton : Html Msg
signOutButton =
    button
        [ class "l-pr"
        , onClick UserClickedSignOutButton
        ]
        [ text "Sign Out" ]



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
