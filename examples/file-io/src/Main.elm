module Main exposing (..)

import Console
import Fs
import Json.Decode as D
import Json.Encode as E
import Path
import Task exposing (Task)


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { args : List String
    , path : String
    }


init : Flags -> ( Model, Cmd Msg )
init { args, dirname } =
    let
        path =
            Path.join [ dirname, "args" ]
    in
    ( { args = args
      , path = path
      }
    , path
        |> Fs.exists
        |> Task.attempt DirExistanceReceived
    )


type alias Flags =
    { args : List String
    , dirname : String
    }



-- UPDATE


type Msg
    = DirExistanceReceived (Result D.Error Bool)
    | ArgsRead String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArgsRead args ->
            let
                _ =
                    Console.log <| E.string args
            in
            ( model, Cmd.none )

        DirExistanceReceived result ->
            case result of
                Ok exists ->
                    ( model
                    , let
                        mkdir =
                            Fs.mkdir model.path

                        writeArgs =
                            model.path
                                |> Fs.readdir
                                |> Task.andThen
                                    (List.map
                                        (\file ->
                                            [ model.path, file ]
                                                |> Path.join
                                                |> Fs.unlink
                                        )
                                        >> Task.sequence
                                    )
                                |> Task.andThen
                                    (\_ ->
                                        model.args
                                            |> List.indexedMap
                                                (\i arg ->
                                                    Fs.writeFile
                                                        (Path.join [ model.path, String.fromInt i ++ ".txt" ])
                                                        arg
                                                )
                                            |> Task.sequence
                                    )
                      in
                      case ( exists, List.isEmpty model.args ) of
                        ( True, True ) ->
                            model.path
                                |> Fs.readdir
                                |> Task.andThen
                                    (List.map
                                        (\file ->
                                            [ model.path, file ]
                                                |> Path.join
                                                |> Fs.readFile
                                        )
                                        >> Task.sequence
                                    )
                                |> Task.map (String.join " ")
                                |> Task.attempt (errorToNoOp ArgsRead)

                        ( True, False ) ->
                            Task.attempt (\_ -> NoOp) writeArgs

                        ( False, True ) ->
                            Task.attempt (\_ -> NoOp) mkdir

                        ( False, False ) ->
                            mkdir
                                |> Task.andThen
                                    (\_ -> writeArgs)
                                |> Task.attempt (\_ -> NoOp)
                    )

                Err _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


errorToNoOp : (a -> Msg) -> (Result D.Error a -> Msg)
errorToNoOp toMsg result =
    case result of
        Ok value ->
            toMsg value

        Err _ ->
            NoOp



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
