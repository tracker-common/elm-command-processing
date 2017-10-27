module FixtureStories exposing (..)

import Types exposing (..)
import Dict exposing (..)


stories : Dict Int Story
stories =
    Dict.fromList
        [ ( 2213
          , { name = "My story, morning glory"
            , description = "The birds are chirping"
            }
          )
        , ( 2191
          , { name = "It was the best of times..."
            , description = "It was the worst of times."
            }
          )
        ]
