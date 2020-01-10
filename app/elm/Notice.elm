module Notice exposing (Class(..), Notice(..), empty, noticeClassToString)


type Notice
    = Notice String Class


type Class
    = NoticeAlert
    | NoticeError
    | NoticeInfo
    | NoticeSuccess


empty : Maybe a
empty =
    Nothing


noticeClassToString : Class -> String
noticeClassToString class =
    case class of
        NoticeAlert ->
            "notice-alert"

        NoticeError ->
            "notice-error"

        NoticeInfo ->
            "notice-info"

        NoticeSuccess ->
            "notice-success"
