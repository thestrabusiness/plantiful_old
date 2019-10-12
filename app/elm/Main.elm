module Main exposing (Model, Msg(..), Page(..), currentPage, init, loadCurrentPage, main, nav, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Garden exposing (Garden)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Menu
import Pages.NotAuthorized as NotAuthorized
import Pages.PlantDetails as PlantDetails
import Pages.PlantForm as PlantForm
import Pages.PlantList as PlantList
import Pages.SignIn as SignIn
import Pages.UserForm as UserForm
import Routes exposing (Route)
import Task
import Time
import Url
import User exposing (User)



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , route : Route
    , currentUser : Loadable User
    , currentTime : Time.Posix
    , timeZone : Time.Zone
    , csrfToken : String
    , menu : Menu
    }


type Menu
    = MenuNone
    | Menu Menu.Model


type Loadable a
    = Loading
    | Success a
    | None



-- INIT


init : { csrfToken : String } -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { key = key
            , page = PageNone
            , route = Routes.extractRoute url
            , currentUser = Loading
            , currentTime = Time.millisToPosix 0
            , timeZone = Time.utc
            , csrfToken = flags.csrfToken
            , menu = MenuNone
            }

        initCmds =
            [ getCurrentTime, getTimeZone, getCurrentUser model.route ]
    in
    ( model, Cmd.batch initCmds )
        |> loadCurrentPage


initMenu : List Garden -> List Garden -> Menu
initMenu ownedGardens sharedGardens =
    let
        ( initialModel, _ ) =
            Menu.init ownedGardens sharedGardens
    in
    Menu initialModel


getCurrentUser : Routes.Route -> Cmd Msg
getCurrentUser route =
    User.getCurrentUser <| ReceivedCurrentUserResponse route


getCurrentTime : Cmd Msg
getCurrentTime =
    Task.perform ReceivedCurrentTime Time.now


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform ReceivedTimeZone Time.here



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | PlantDetailsMsg PlantDetails.Msg
    | PlantListMsg PlantList.Msg
    | PlantFormMsg PlantForm.Msg
    | UserFormMsg UserForm.Msg
    | NotAuthorizedMsg NotAuthorized.Msg
    | SignInMsg SignIn.Msg
    | UserClickedSignOutButton
    | ReceivedUserSignOutResponse (Result Http.Error ())
    | ReceivedCurrentUserResponse Route (Result Http.Error User)
    | ReceivedCurrentTime Time.Posix
    | ReceivedTimeZone Time.Zone
    | MenuMsg Menu.Msg


type Page
    = PageNone
    | PlantListPage PlantList.Model
    | PlantDetailsPage PlantDetails.Model
    | PlantFormPage PlantForm.Model
    | UserPage UserForm.Model
    | NotAuthorizedPage NotAuthorized.Model
    | SignInPage SignIn.Model
    | LoadingPage


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

        ( ReceivedCurrentTime time, _ ) ->
            ( { model | currentTime = time }, Cmd.none )

        ( ReceivedTimeZone zone, _ ) ->
            ( { model | timeZone = zone }, Cmd.none )

        ( UserClickedSignOutButton, _ ) ->
            ( model, User.signOut model.csrfToken ReceivedUserSignOutResponse )

        ( ReceivedUserSignOutResponse (Ok _), _ ) ->
            ( { model | currentUser = None }, Nav.pushUrl model.key Routes.signInPath )

        ( ReceivedUserSignOutResponse (Err _), _ ) ->
            ( model, Cmd.none )

        ( ReceivedCurrentUserResponse route (Ok user), _ ) ->
            let
                initialMenu =
                    initMenu user.ownedGardens user.sharedGardens
            in
            ( { model | currentUser = Success user, menu = initialMenu }
            , Nav.pushUrl model.key (Routes.pathFor route)
            )

        ( ReceivedCurrentUserResponse _ (Err error), _ ) ->
            ( { model | currentUser = None }, Cmd.none )
                |> loadCurrentPage

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

                ( loadableUser, newMenu ) =
                    case currentUser of
                        Just user ->
                            ( Success user
                            , initMenu user.ownedGardens user.sharedGardens
                            )

                        Nothing ->
                            ( None, MenuNone )
            in
            ( { model
                | page = UserPage newPageModel
                , currentUser = loadableUser
                , menu = newMenu
              }
            , Cmd.map UserFormMsg newCmd
            )

        ( SignInMsg subMsg, SignInPage pageModel ) ->
            let
                ( newPageModel, newCmd, currentUser ) =
                    SignIn.update subMsg pageModel model.key

                ( loadableUser, newMenu ) =
                    case currentUser of
                        Just user ->
                            ( Success user
                            , initMenu user.ownedGardens user.sharedGardens
                            )

                        Nothing ->
                            ( None, MenuNone )
            in
            ( { model
                | page = SignInPage newPageModel
                , currentUser = loadableUser
                , menu = newMenu
              }
            , Cmd.map SignInMsg newCmd
            )

        ( PlantDetailsMsg subMsg, PlantDetailsPage pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    PlantDetails.update subMsg pageModel
            in
            ( { model
                | page = PlantDetailsPage newPageModel
              }
            , Cmd.map PlantDetailsMsg newCmd
            )

        ( MenuMsg subMsg, _ ) ->
            case model.menu of
                Menu menuModel ->
                    let
                        ( newMenuModel, newCmd ) =
                            Menu.update subMsg menuModel
                    in
                    ( { model | menu = Menu newMenuModel }
                    , Cmd.map MenuMsg newCmd
                    )

                MenuNone ->
                    ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    let
        ( page, newCmd ) =
            case model.route of
                Routes.NewPlantRoute gardenId ->
                    case model.currentUser of
                        Success user ->
                            let
                                ( formModel, formCmd ) =
                                    PlantForm.init model.csrfToken
                                        user
                                        Nothing
                                        (Just gardenId)
                            in
                            ( PlantFormPage formModel, Cmd.map PlantFormMsg formCmd )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )

                Routes.NewUserRoute ->
                    let
                        ( formModel, formCmd ) =
                            UserForm.init model.csrfToken
                    in
                    ( UserPage formModel, Cmd.map UserFormMsg formCmd )

                Routes.SignInRoute ->
                    case model.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init model.csrfToken
                                        user
                                        user.defaultGardenId
                                        model.currentTime
                                        model.timeZone
                            in
                            ( PlantListPage pageModel
                            , Nav.pushUrl model.key (Routes.gardenPath user.defaultGardenId)
                            )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            let
                                ( pageModel, pageCmd ) =
                                    SignIn.init model.csrfToken
                            in
                            ( SignInPage pageModel, Cmd.map SignInMsg pageCmd )

                Routes.NotFoundRoute ->
                    ( PageNone, Cmd.none )

                Routes.PlantRoute id ->
                    case model.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantDetails.init model.key
                                        model.csrfToken
                                        id
                                        user
                                        model.timeZone
                            in
                            ( PlantDetailsPage pageModel
                            , Cmd.map PlantDetailsMsg
                                pageCmd
                            )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            let
                                ( pageModel, pageCmd ) =
                                    SignIn.init model.csrfToken
                            in
                            ( SignInPage pageModel, Cmd.map SignInMsg pageCmd )

                Routes.EditPlantRoute plantId ->
                    case model.currentUser of
                        Success user ->
                            let
                                ( formModel, formCmd ) =
                                    PlantForm.init model.csrfToken
                                        user
                                        (Just plantId)
                                        Nothing
                            in
                            ( PlantFormPage formModel, Cmd.map PlantFormMsg formCmd )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )

                Routes.GardenRoute gardenId ->
                    case model.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init model.csrfToken
                                        user
                                        gardenId
                                        model.currentTime
                                        model.timeZone
                            in
                            ( PlantListPage pageModel, Cmd.map PlantListMsg pageCmd )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )

                Routes.GardensRoute ->
                    case model.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init model.csrfToken
                                        user
                                        user.defaultGardenId
                                        model.currentTime
                                        model.timeZone
                            in
                            ( PlantListPage pageModel, Cmd.map PlantListMsg pageCmd )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )
    in
    ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Plantiful"
    , body = [ currentPage model ]
    }


currentPage : Model -> Html Msg
currentPage model =
    let
        page =
            case model.page of
                PlantDetailsPage pageModel ->
                    PlantDetails.view pageModel
                        |> Html.map PlantDetailsMsg

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

                LoadingPage ->
                    div [ class "container__center centered-text" ]
                        [ text "Loading..." ]
    in
    div []
        [ nav model
        , div [ class "main" ] [ page ]
        ]


nav : Model -> Html Msg
nav model =
    div
        [ class "header" ]
        [ h2 [ class "header__item--full" ]
            [ viewMenu model.menu
            , div [ class "header__text" ] [ text "Plantiful" ]
            ]
        , headerLink model
        ]


viewMenu : Menu -> Html Msg
viewMenu menu =
    case menu of
        Menu model ->
            Menu.view model
                |> Html.map MenuMsg

        MenuNone ->
            text ""


headerLink : Model -> Html Msg
headerLink model =
    case model.route of
        Routes.NewPlantRoute _ ->
            signOutButton

        Routes.NewUserRoute ->
            signInLink

        Routes.SignInRoute ->
            signUpLink

        Routes.NotFoundRoute ->
            text ""

        Routes.PlantRoute _ ->
            signOutButton

        Routes.EditPlantRoute _ ->
            signOutButton

        Routes.GardenRoute _ ->
            signOutButton

        Routes.GardensRoute ->
            signOutButton


signUpLink : Html Msg
signUpLink =
    a [ class "header__item", href "/sign_up" ] [ text "Sign Up" ]


signOutButton : Html Msg
signOutButton =
    button
        [ class "header__item"
        , onClick UserClickedSignOutButton
        ]
        [ text "Sign Out" ]


signInLink : Html Msg
signInLink =
    a [ class "header__item", href "/sign_in" ] [ text "Sign In" ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map PlantDetailsMsg PlantDetails.subscriptions ]



-- MAIN


main : Program { csrfToken : String } Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
