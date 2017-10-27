module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (..)
import Api exposing (..)
import Http exposing (..)
import CommandProcessing
import Dict exposing (..)


-- APP


main : Program Never Model Msg
main =
    Html.program
        { init = ( model, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


subscriptions : model -> Sub Msg
subscriptions model =
    Sub.none


model : Model
model =
    { projectVersion = 0
    , stories = Dict.empty
    , comments = Dict.empty
    , canPoll = True
    , highlightedStoryIds = []
    }



-- UPDATE


type Msg
    = NoOp
    | PollRequest
    | PollResponse (Result Error CommandCreateResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PollRequest ->
            let
                thing =
                    Debug.log "I polled" 1
            in
                ( { model | canPoll = False, highlightedStoryIds = [] }, Http.send (PollResponse) <| fetchCommandsCmd model.projectVersion )

        PollResponse result ->
            case result of
                Ok commandCreateResponse ->
                    let
                        thing =
                            Debug.log "RESULT!!!!!!!!!!" commandCreateResponse

                        projectVersion =
                            List.reverse commandCreateResponse.staleCommands
                                |> List.head
                                |> Maybe.map (.projectVersion)
                                |> Maybe.withDefault model.projectVersion
                                |> Debug.log "$$$$$$$$$$ project version"

                        allResults =
                            commandCreateResponse.staleCommands
                                |> List.concatMap (\command -> command.results)

                        updatedModel =
                            CommandProcessing.applyResultsToModel model allResults
                    in
                        ( { updatedModel | projectVersion = projectVersion, canPoll = True }, Cmd.none )

                Err string ->
                    let
                        foo =
                            (Debug.log "Error" string)
                    in
                        ( { model | canPoll = True }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        storyStyle id =
            if List.member id model.highlightedStoryIds then
                [ ( "background-color", "yellow" ) ]
            else
                []

        renderStory : ( Int, Story ) -> Html Msg
        renderStory ( id, story ) =
            div [ style <| storyStyle id ]
                [ h3 [] [ text <| story.name ++ " - " ++ (toString id) ]
                , div [] [ text story.description ]
                , div [] [ text story.currentState ]
                , ul [] []
                ]
    in
        div []
            [ button [ onClick PollRequest, disabled <| not model.canPoll ] [ text "Poll" ]
            , div [] <|
                List.map
                    (renderStory)
                    (Dict.toList model.stories)
            ]
