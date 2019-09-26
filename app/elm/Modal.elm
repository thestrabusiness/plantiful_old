module Modal exposing (Modal(..), modalFooter, modalHeader, modalRow)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


type Modal msg
    = Modal (Html msg)
    | ModalClosed


modalHeader : String -> Html msg
modalHeader headerText =
    div [ class "modal__header--default" ]
        [ h1 [ class "modal__heading" ]
            [ text headerText ]
        ]


modalRow : List (Html a) -> Html a
modalRow children =
    div [ class "modal-row" ] children


modalFooter : List (Html a) -> Html a
modalFooter children =
    div [ class "modal__footer" ] children
