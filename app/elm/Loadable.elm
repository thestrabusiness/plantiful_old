module Loadable exposing (Loadable(..))


type Loadable a
    = Loading
    | Success a
    | None
