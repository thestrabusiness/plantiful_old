module NoticeQueue exposing (NoticeQueue(..), append, currentNotice, empty)

import Notice exposing (Notice)


type NoticeQueue
    = NoticeQueue (List Notice)


append : Notice -> NoticeQueue -> NoticeQueue
append notice (NoticeQueue queue) =
    case notice of
        Notice.Notice _ _ ->
            NoticeQueue (queue ++ [ notice ])

        Notice.EmptyNotice ->
            NoticeQueue queue


currentNotice : NoticeQueue -> Maybe Notice
currentNotice (NoticeQueue queue) =
    case queue of
        [] ->
            Nothing

        [ x ] ->
            Just x

        x :: _ ->
            Just x


empty : NoticeQueue
empty =
    NoticeQueue []
