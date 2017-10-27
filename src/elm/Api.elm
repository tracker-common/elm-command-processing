module Api exposing (..)

import Http exposing (..)
import Json.Decode as Decode
import Json.Decode.Extra as Decode exposing ((|:))
import Types exposing (..)


type CommandResult
    = Executed
    | Failed
    | Ineffectual
    | Current
    | Stale
    | TooStale


type alias CommandCreateResponse =
    { result : CommandResult
    , staleCommands : List Command
    }


fetchCommandsCmd : Int -> Request CommandCreateResponse
fetchCommandsCmd projectVersion =
    let
        projectId =
            101

        apiToken =
            "TestToken"
    in
        request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "X-TrackerToken" apiToken
                ]
            , url = "http://localhost:3000/services/v5/project_stale_commands/" ++ toString projectId ++ "/" ++ toString projectVersion
            , body = emptyBody
            , expect = expectJson commandCreateResponseDecoder
            , timeout = Nothing
            , withCredentials = False
            }


commandCreateResponseDecoder : Decode.Decoder CommandCreateResponse
commandCreateResponseDecoder =
    Decode.field "data" <|
        Decode.succeed CommandCreateResponse
            |: (Decode.field "result" Decode.string |> Decode.andThen toCommandResult)
            |: (Decode.field "stale_commands" commandsDecoder)


toCommandResult : String -> Decode.Decoder CommandResult
toCommandResult commandResult =
    case String.toLower commandResult of
        "executed" ->
            Decode.succeed Executed

        "failed" ->
            Decode.succeed Failed

        "ineffectual" ->
            Decode.succeed Ineffectual

        "current" ->
            Decode.succeed Current

        "stale" ->
            Decode.succeed Stale

        "too_stale" ->
            Decode.succeed TooStale

        _ ->
            Decode.fail <| "Badly formed command_create_response.result. Received:" ++ commandResult


commandsDecoder : Decode.Decoder (List Command)
commandsDecoder =
    Decode.list commandDecoder


commandDecoder : Decode.Decoder Command
commandDecoder =
    Decode.succeed Command
        |: (Decode.at [ "project", "version" ] Decode.int)
