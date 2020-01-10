module Main exposing
    ( Model
    , Msg(..)
    , Page(..)
    , currentPage
    , init
    , loadCurrentPage
    , main
    , nav
    , subscriptions
    , update
    , view
    )

import Api
import Browser
import Browser.Navigation as Nav
import Dict
import Garden exposing (Garden)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Loadable exposing (Loadable(..))
import Menu
import Notice exposing (Notice(..))
import NoticeQueue exposing (NoticeQueue(..))
import Pages.NotAuthorized as NotAuthorized
import Pages.PlantDetails as PlantDetails
import Pages.PlantForm as PlantForm
import Pages.PlantList as PlantList
import Pages.SignIn as SignIn
import Pages.UserForm as UserForm
import Routes exposing (Route)
import Session
import Task
import Time
import Url
import User exposing (User)



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , route : Route
    , currentTime : Time.Posix
    , timeZone : Time.Zone
    , session : Session.Session
    , menu : Menu
    , noticeQueue : NoticeQueue
    }


type Menu
    = MenuNone
    | Menu Menu.Model



-- INIT


init : { csrfToken : String } -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { key = key
            , page = PageNone
            , route = Routes.extractRoute url
            , currentTime = Time.millisToPosix 0
            , timeZone = Time.utc
            , session = Session.Session flags.csrfToken Loading
            , menu = MenuNone
            , noticeQueue = NoticeQueue.empty
            }

        initCmds =
            [ getCurrentTime
            , getTimeZone
            , Session.getCurrentSession flags.csrfToken ReceivedSessionStatus
            ]
    in
    ( model, Cmd.batch initCmds )
        |> loadCurrentPage


initMenu : Session.Session -> Nav.Key -> List Garden -> List Garden -> Menu
initMenu session key ownedGardens sharedGardens =
    let
        ( initialModel, _ ) =
            Menu.init session key ownedGardens sharedGardens
    in
    Menu initialModel


getCurrentUser : Session.Session -> Routes.Route -> Cmd Msg
getCurrentUser session route =
    Session.getCurrentUser session <| ReceivedCurrentUserResponse route


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
    | ReceivedSessionStatus (Result Http.Error User)
    | MenuMsg Menu.Msg
    | NoticeTimeoutFinished


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
        ( NoticeTimeoutFinished, _ ) ->
            ( { model | noticeQueue = NoticeQueue.pop model.noticeQueue }
            , Cmd.none
            )

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
            ( model, Session.signOut model.session ReceivedUserSignOutResponse )

        ( ReceivedUserSignOutResponse (Ok _), _ ) ->
            let
                session =
                    model.session

                updatedSession =
                    { session | currentUser = None }

                newNotice =
                    Notice "Signed out succesfully" Notice.NoticeSuccess
            in
            ( { model | session = updatedSession }
            , Nav.pushUrl model.key Routes.signInPath
            )
                |> updateNoticeQueue (Just newNotice)

        ( ReceivedUserSignOutResponse (Err _), _ ) ->
            let
                newNotice =
                    Notice "Something went wrong. Try again later." Notice.NoticeError
            in
            ( model, Cmd.none )
                |> updateNoticeQueue (Just newNotice)

        ( ReceivedCurrentUserResponse route (Ok user), _ ) ->
            let
                session =
                    model.session

                updatedSession =
                    { session | currentUser = Success user }

                initialMenu =
                    initMenu updatedSession
                        model.key
                        user.ownedGardens
                        user.sharedGardens
            in
            ( { model | session = updatedSession, menu = initialMenu }
            , Nav.pushUrl model.key (Routes.pathFor route)
            )

        ( ReceivedCurrentUserResponse _ (Err error), _ ) ->
            let
                session =
                    model.session

                updatedSession =
                    { session | currentUser = None }
            in
            ( { model | session = updatedSession }, Cmd.none )
                |> loadCurrentPage

        ( ReceivedSessionStatus (Ok user), _ ) ->
            let
                session =
                    model.session

                updatedSession =
                    { session | currentUser = Success user }

                initialMenu =
                    initMenu updatedSession
                        model.key
                        user.ownedGardens
                        user.sharedGardens
            in
            ( { model | session = updatedSession, menu = initialMenu }, Cmd.none )
                |> loadCurrentPage

        ( ReceivedSessionStatus (Err error), _ ) ->
            let
                _ =
                    Debug.log "error:" error

                session =
                    model.session

                updatedSession =
                    { session | currentUser = None }
            in
            ( { model | session = updatedSession }, Cmd.none )
                |> loadCurrentPage

        ( PlantListMsg subMsg, PlantListPage pageModel ) ->
            let
                ( newPageModel, newCmd, maybeNotice ) =
                    PlantList.update subMsg pageModel
            in
            ( { model | page = PlantListPage newPageModel }
            , Cmd.map PlantListMsg newCmd
            )
                |> updateNoticeQueue maybeNotice

        ( PlantFormMsg subMsg, PlantFormPage pageModel ) ->
            let
                ( newPageModel, newCmd, maybeNotice ) =
                    PlantForm.update subMsg pageModel model.key
            in
            ( { model | page = PlantFormPage newPageModel }
            , Cmd.map PlantFormMsg newCmd
            )
                |> updateNoticeQueue maybeNotice

        ( UserFormMsg subMsg, UserPage pageModel ) ->
            let
                session =
                    model.session

                ( newPageModel, newCmd, currentUser ) =
                    UserForm.update subMsg pageModel model.key

                ( newMenu, newSession, newNotice ) =
                    case currentUser of
                        Just user ->
                            let
                                updatedSession =
                                    { session | currentUser = Success user }
                            in
                            ( initMenu updatedSession
                                model.key
                                user.ownedGardens
                                user.sharedGardens
                            , updatedSession
                            , Just
                                (Notice "Welcome to Plantiful!"
                                    Notice.NoticeSuccess
                                )
                            )

                        Nothing ->
                            ( MenuNone, session, Notice.empty )
            in
            ( { model
                | page = UserPage newPageModel
                , session = newSession
                , menu = newMenu
              }
            , Cmd.map UserFormMsg newCmd
            )

        ( SignInMsg subMsg, SignInPage pageModel ) ->
            let
                ( newPageModel, newCmd, currentUser ) =
                    SignIn.update subMsg pageModel model.key

                ( loadableUser, newMenu, newNotice ) =
                    case currentUser of
                        Just user ->
                            let
                                noticeMessage =
                                    "Welcome back, " ++ user.firstName
                            in
                            ( Success user
                            , initMenu model.session
                                model.key
                                user.ownedGardens
                                user.sharedGardens
                            , Just (Notice noticeMessage Notice.NoticeSuccess)
                            )

                        Nothing ->
                            ( None, MenuNone, Notice.empty )

                session =
                    model.session

                updatedSession =
                    { session | currentUser = loadableUser }
            in
            ( { model
                | page = SignInPage newPageModel
                , session = updatedSession
                , menu = newMenu
              }
            , Cmd.map SignInMsg newCmd
            )
                |> updateNoticeQueue newNotice

        ( PlantDetailsMsg subMsg, PlantDetailsPage pageModel ) ->
            let
                ( newPageModel, newCmd, maybeNotice ) =
                    PlantDetails.update subMsg pageModel
            in
            ( { model | page = PlantDetailsPage newPageModel }
            , Cmd.map PlantDetailsMsg newCmd
            )
                |> updateNoticeQueue maybeNotice

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
                    case model.session.currentUser of
                        Success user ->
                            let
                                ( formModel, formCmd ) =
                                    PlantForm.init model.session
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
                            UserForm.init model.session
                    in
                    ( UserPage formModel, Cmd.map UserFormMsg formCmd )

                Routes.SignInRoute ->
                    case model.session.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init model.session
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
                                    SignIn.init model.session.csrfToken
                            in
                            ( SignInPage pageModel, Cmd.map SignInMsg pageCmd )

                Routes.NotFoundRoute ->
                    ( PageNone, Cmd.none )

                Routes.PlantRoute id ->
                    case model.session.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantDetails.init model.key
                                        model.session
                                        id
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
                                    SignIn.init model.session.csrfToken
                            in
                            ( SignInPage pageModel, Cmd.map SignInMsg pageCmd )

                Routes.EditPlantRoute plantId ->
                    case model.session.currentUser of
                        Success user ->
                            let
                                ( formModel, formCmd ) =
                                    PlantForm.init model.session
                                        (Just plantId)
                                        Nothing
                            in
                            ( PlantFormPage formModel, Cmd.map PlantFormMsg formCmd )

                        Loading ->
                            ( LoadingPage, Cmd.none )

                        None ->
                            ( NotAuthorizedPage {}, Cmd.map NotAuthorizedMsg Cmd.none )

                Routes.GardenRoute gardenId ->
                    case model.session.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init model.session
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
                    case model.session.currentUser of
                        Success user ->
                            let
                                ( pageModel, pageCmd ) =
                                    PlantList.init model.session
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


startNoticeTimeout : Cmd Msg
startNoticeTimeout =
    NoticeQueue.noticeTimeout NoticeTimeoutFinished


updateNoticeQueue : Maybe Notice -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateNoticeQueue maybeNotice ( model, msg ) =
    case maybeNotice of
        Just notice ->
            let
                updatedQueue =
                    NoticeQueue.append notice model.noticeQueue
            in
            ( { model | noticeQueue = updatedQueue }
            , Cmd.batch
                [ msg
                , startNoticeTimeout
                ]
            )

        Nothing ->
            ( model, msg )



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
        , viewNotice model.noticeQueue
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


viewNotice : NoticeQueue -> Html Msg
viewNotice queue =
    let
        currentNotice =
            NoticeQueue.currentNotice queue
    in
    case currentNotice of
        Just (Notice message noticeClass) ->
            let
                noticeClassString =
                    Notice.noticeClassToString noticeClass

                classString =
                    "notice " ++ noticeClassString
            in
            div [ class classString ] [ text message ]

        _ ->
            text ""


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
