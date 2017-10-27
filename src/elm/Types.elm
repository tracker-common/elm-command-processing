module Types exposing (..)

import Dict exposing (..)


type alias Model =
    { projectVersion : Int
    , stories : Dict Int Story
    , comments : Dict Int Comment
    , canPoll : Bool
    , highlightedStoryIds : List Int
    }


type alias Story =
    { name : String
    , description : String
    , currentState : String
    }


type alias Comment =
    { text : String
    , storyId : Int
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
    , results : List CommandResultKind
    }


type CommandResultKind
    = StoryKind StoryUpdate
    | CommentKind
    | UnknownKind


type alias StoryUpdate =
    { id : Maybe Int
    , name : Maybe String
    , description : Maybe String
    , currentState : Maybe String
    }
