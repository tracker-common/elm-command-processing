module CommandProcessing exposing (..)

import Types exposing (..)
import Dict exposing (..)


applyResultsToModel : Model -> List RawCommandResult -> Model
applyResultsToModel model rawCommandResults =
    List.foldl (applyResultToModel) model rawCommandResults


applyResultToModel : RawCommandResult -> Model -> Model
applyResultToModel rawCommandResult model =
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
                        |> Maybe.map (\id -> Dict.insert id (updateStory (Dict.get id model.stories)) model.stories)
                        |> Maybe.withDefault model.stories

                newHighlightedList =
                    rawCommandResult.id
                        |> Maybe.map (\id -> List.append model.highlightedStoryIds [ id ])
                        |> Maybe.withDefault model.highlightedStoryIds
            in
                { model | stories = newStories, highlightedStoryIds = newHighlightedList }

        CommentKind ->
            model

        UnknownKind ->
            model
