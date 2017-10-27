module Types exposing (..)


type alias Story =
    { id : Int
    , name : String
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
