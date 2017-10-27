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
    , results : List CommandResult
    }


type alias CommandResult =
    { kind : CommandResultKind }


type CommandResultKind
    = StoryKind
    | UnknownKind
