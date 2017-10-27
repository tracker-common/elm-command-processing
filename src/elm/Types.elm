module Types exposing (..)

import Dict exposing (..)


type alias Model =
    { stories : Dict Int Story
    , projectVersion : Int
    }


type alias Story =
    { name : String
    , description : String
    }


type PollResult
    = Executed
    | Failed
    | Ineffectual
    | Current
    | Stale
    | TooStale


type alias Command =
    { projectVersion : Int
    , results : List RawCommandResult
    }


type CommandResultKind
    = StoryKind
    | UnknownKind


type alias RawCommandResult =
    { kind : CommandResultKind
    , name : Maybe String
    , description : Maybe String
    }
