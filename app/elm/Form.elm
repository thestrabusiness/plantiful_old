module Form exposing (errorsForField, textField)

import Html exposing (Html, input, label, li, text, ul)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onInput)


textField : (String -> b) -> List ( field, String ) -> String -> String -> Html b
textField inputMsg errors name fieldValue =
    label []
        [ text name
        , input
            [ class <| textFieldClass errors
            , value fieldValue
            , onInput inputMsg
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
