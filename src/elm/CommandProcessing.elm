module CommandProcessing exposing (..)

import Types exposing (..)


applyResultsToModel : Model -> List RawCommandResult -> Model
applyResultsToModel originalModel rawCommandResults =
    List.foldl (applyResultToModel) originalModel rawCommandResults


applyResultToModel : RawCommandResult -> Model -> Model
applyResultToModel rawCommandResult originalModel =
    case rawCommandResult.kind of
        StoryKind ->
            originalModel

        UnknownKind ->
            originalModel
