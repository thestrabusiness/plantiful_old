module Form exposing
    ( errorsForField
    , onEnter
    , passwordField
    , textField
    )

import Html exposing (Html, input, label, li, text, ul)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (keyCode, on, onInput)
import Json.Decode


textField :
    (String -> b)
    -> b
    -> List ( field, String )
    -> String
    -> String
    -> Html b
textField inputMsg enterMsg errors name fieldValue =
    fieldNeedsType "text" inputMsg enterMsg errors name fieldValue


passwordField :
    (String -> b)
    -> b
    -> List ( field, String )
    -> String
    -> String
    -> Html b
passwordField inputMsg enterMsg errors name fieldValue =
    fieldNeedsType "password" inputMsg enterMsg errors name fieldValue


fieldNeedsType :
    String
    -> (String -> b)
    -> b
    -> List ( field, String )
    -> String
    -> String
    -> Html b
fieldNeedsType fieldType inputMsg enterMsg errors name fieldValue =
    label []
        [ text name
        , input
            [ class <| textFieldClass errors
            , value fieldValue
            , onInput inputMsg
            , onEnter enterMsg
            , type_ fieldType
            ]
            []
        , viewFormErrors errors
        ]


textFieldClass : List ( field, String ) -> String
textFieldClass errors =
    case errors of
        [] ->
            ""

        _ ->
            "field_with_errors"


viewFormErrors : List ( field, String ) -> Html msg
viewFormErrors errors =
    errors
        |> List.map (\( _, error ) -> li [] [ text error ])
        |> List.take 1
        |> ul [ class "errors" ]


errorsForField : field -> List ( field, String ) -> List ( field, String )
errorsForField field errors =
    errors
        |> List.filter (\( errorField, _ ) -> errorField == field)


onEnter : msg -> Html.Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg

            else
                Json.Decode.fail "Not enter"
    in
    on "keydown" (Json.Decode.andThen isEnter keyCode)
