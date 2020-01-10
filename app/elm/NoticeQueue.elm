module NoticeQueue exposing
    ( NoticeQueue(..)
    , append
    , currentNotice
    , empty
    , noticeTimeout
    , pop
    )

import Notice exposing (Notice)
import Process
import Task


type NoticeQueue
    = NoticeQueue (List Notice)


append : Notice -> NoticeQueue -> NoticeQueue
append notice (NoticeQueue queue) =
    NoticeQueue (queue ++ [ notice ])


currentNotice : NoticeQueue -> Maybe Notice
currentNotice (NoticeQueue queue) =
    case queue of
        [] ->
            Nothing

        x :: _ ->
            Just x


empty : NoticeQueue
empty =
    NoticeQueue []


noticeDuration : Float
noticeDuration =
    2000


noticeTimeout : a -> Cmd a
noticeTimeout msg =
    Process.sleep noticeDuration
        |> Task.perform (always msg)


pop : NoticeQueue -> NoticeQueue
pop (NoticeQueue queue) =
    case queue of
        _ :: tail ->
            NoticeQueue tail

        _ ->
            NoticeQueue []
