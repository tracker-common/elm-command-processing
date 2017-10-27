module CommandProcessing exposing (..)

import Types exposing (..)
import Dict exposing (..)


applyResultsToModel : Model -> List RawCommandResult -> Model
applyResultsToModel originalModel rawCommandResults =
    List.foldl (applyResultToModel) originalModel rawCommandResults


applyResultToModel : RawCommandResult -> Model -> Model
applyResultToModel rawCommandResult originalModel =
    case rawCommandResult.kind of
        StoryKind ->
            let
                updateName story =
                    { story | name = Maybe.withDefault story.name rawCommandResult.name }

                updateDescription story =
                    { story | description = Maybe.withDefault story.description rawCommandResult.description }

                updateCurrentState story =
                    { story | currentState = Maybe.withDefault story.currentState rawCommandResult.currentState }

                updateStory : Maybe Story -> Story
                updateStory maybeStory =
                    maybeStory
                        |> Maybe.withDefault { name = "", description = "", currentState = "" }
                        |> updateName
                        |> updateDescription
                        |> updateCurrentState

                newStories =
                    rawCommandResult.id
                        |> Maybe.map (\id -> Dict.insert id (updateStory (Dict.get id originalModel.stories)) originalModel.stories)
                        |> Maybe.withDefault originalModel.stories
            in
                { originalModel | stories = newStories }

        CommentKind ->
            originalModel

        UnknownKind ->
            originalModel
