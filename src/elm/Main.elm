module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (..)
import Api exposing (..)
import Http exposing (..)


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


type alias Model =
    { stories : List Story
    , projectVersion : Int
    }


model : Model
model =
    { stories = [ { name = "My story, morning glory" }, { name = "It was the best of times..." } ]
    , projectVersion = 0
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
                ( model, Http.send (PollResponse) <| fetchCommandsCmd model.projectVersion )

        PollResponse result ->
            case result of
                Ok commandCreateResponse ->
                    let
                        thing =
                            Debug.log "RESULT!!!!!!!!!!" commandCreateResponse

                        --                        projectVersion = case commandCreateResponse.result
                        --                            Stale ->
                        --                            -- get version from command list
                        --                            _ ->
                        --                             model.projectVersion
                    in
                        ( model, Cmd.none )

                Err string ->
                    let
                        foo =
                            (Debug.log "Error" string)
                    in
                        ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        renderStory : Story -> Html Msg
        renderStory story =
            div [] [ text story.name ]
    in
        div []
            [ button [ onClick PollRequest ] [ text "Poll" ]
            , div [] <|
                List.map
                    (renderStory)
                    model.stories
            ]
