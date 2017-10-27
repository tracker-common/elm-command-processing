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
                updateStory : RawCommandResult -> Maybe Story -> Story
                updateStory rawCommandResult maybeStory =
                    maybeStory
                        |> Maybe.withDefault { name = "", description = "", currentState = "" }
                        |> (\story -> { story | name = Maybe.withDefault story.name rawCommandResult.name })
                        |> (\story -> { story | description = Maybe.withDefault story.description rawCommandResult.description })
                        |> (\story -> { story | currentState = Maybe.withDefault story.currentState rawCommandResult.currentState })
            in
                { model
                    | stories = newDict rawCommandResult (updateStory) model.stories
                    , highlightedStoryIds = newHighlightedList rawCommandResult.id model.highlightedStoryIds
                }

        CommentKind ->
            let
                updateComment : RawCommandResult -> Maybe Comment -> Comment
                updateComment rawCommandResult maybeComment =
                    maybeComment
                        |> Maybe.withDefault { text = "", storyId = 0 }
                        |> (\comment -> { comment | text = Maybe.withDefault comment.text rawCommandResult.text })
                        |> (\comment -> { comment | storyId = Maybe.withDefault comment.storyId rawCommandResult.storyId })
            in
                { model
                    | comments = newDict rawCommandResult (updateComment) model.comments
                    , highlightedStoryIds = newHighlightedList rawCommandResult.storyId model.highlightedStoryIds
                }

        UnknownKind ->
            model


newDict : RawCommandResult -> (RawCommandResult -> Maybe a -> a) -> Dict Int a -> Dict Int a
newDict rawCommandResult func dict =
    rawCommandResult.id
        |> Maybe.map (\id -> Dict.insert id (func rawCommandResult (Dict.get id dict)) dict)
        |> Maybe.withDefault dict


newHighlightedList : Maybe Int -> List Int -> List Int
newHighlightedList maybeInt highlightedStoryIds =
    maybeInt
        |> Maybe.map (\id -> List.append highlightedStoryIds [ id ])
        |> Maybe.withDefault highlightedStoryIds
