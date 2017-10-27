module CommandProcessing exposing (..)

import Types exposing (..)
import Dict exposing (..)


applyResultsToModel : Model -> List CommandResultKind -> Model
applyResultsToModel model commandResultKinds =
    List.foldl (applyResultToModel) model commandResultKinds


applyResultToModel : CommandResultKind -> Model -> Model
applyResultToModel commandResultKind model =
    case commandResultKind of
        StoryKind storyUpdate ->
            let
                updateStory : StoryUpdate -> Maybe Story -> Story
                updateStory storyUpdate maybeStory =
                    maybeStory
                        |> Maybe.withDefault { name = "", description = "", currentState = "" }
                        |> (\story -> { story | name = Maybe.withDefault story.name storyUpdate.name })
                        |> (\story -> { story | description = Maybe.withDefault story.description storyUpdate.description })
                        |> (\story -> { story | currentState = Maybe.withDefault story.currentState storyUpdate.currentState })

                newDict =
                    storyUpdate.id
                        |> Maybe.map (\id -> Dict.insert id (updateStory storyUpdate (Dict.get id model.stories)) model.stories)
                        |> Maybe.withDefault model.stories
            in
                { model
                    | stories = newDict
                    , highlightedStoryIds = newHighlightedList storyUpdate.id model.highlightedStoryIds
                }

        CommentKind ->
            model

        --            let
        --                updateComment : RawCommandResult -> Maybe Comment -> Comment
        --                updateComment rawCommandResult maybeComment =
        --                    maybeComment
        --                        |> Maybe.withDefault { text = "", storyId = 0 }
        --                        |> (\comment -> { comment | text = Maybe.withDefault comment.text rawCommandResult.text })
        --                        |> (\comment -> { comment | storyId = Maybe.withDefault comment.storyId rawCommandResult.storyId })
        --            in
        --                { model
        --                    | comments = newDict rawCommandResult (updateComment) model.comments
        --                    , highlightedStoryIds = newHighlightedList rawCommandResult.storyId model.highlightedStoryIds
        --                }
        UnknownKind ->
            model


newHighlightedList : Maybe Int -> List Int -> List Int
newHighlightedList maybeInt highlightedStoryIds =
    maybeInt
        |> Maybe.map (\id -> List.append highlightedStoryIds [ id ])
        |> Maybe.withDefault highlightedStoryIds
