module Notice exposing (Class(..), Notice(..), noticeClassToString)


type Notice
    = EmptyNotice
    | Notice String Class


type Class
    = NoticeAlert
    | NoticeError
    | NoticeInfo
    | NoticeSuccess


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
