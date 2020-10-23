module Main exposing (..)

import Console
import Fs
import Json.Decode as D
import Json.Encode as E
import Path
import Task exposing (Task)


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = always Sub.none
        }


type alias Flags =
    { args : List String
    , dirname : String
    }


init : Flags -> ( (), Cmd () )
init { args, dirname } =
    let
        path =
            Path.join [ dirname, "args" ]

        mkdir =
            Fs.mkdir path

        writeArgs : Task D.Error ()
        writeArgs =
            path
                |> Fs.readdir
                |> Task.andThen
                    (List.map
                        (\file ->
                            [ path, file ]
                                |> Path.join
                                |> Fs.unlink
                        )
                        >> Task.sequence
                    )
                |> Task.andThen
                    (\_ ->
                        args
                            |> List.indexedMap
                                (\i arg ->
                                    Fs.writeFile
                                        (Path.join [ path, String.fromInt i ++ ".txt" ])
                                        arg
                                )
                            |> Task.sequence
                            |> Task.map (always ())
                    )
    in
    ( ()
    , Fs.exists path
        |> Task.andThen
            (\exists ->
                case ( exists, List.isEmpty args ) of
                    ( True, True ) ->
                        Fs.readdir path
                            |> Task.andThen
                                (List.map
                                    (\file ->
                                        [ path, file ]
                                            |> Path.join
                                            |> Fs.readFile
                                    )
                                    >> Task.sequence
                                )
                            |> Task.map (String.join " ")
                            |> Task.andThen (E.string >> Console.log)

                    ( True, False ) ->
                        writeArgs

                    ( False, True ) ->
                        mkdir

                    ( False, False ) ->
                        mkdir
                            |> Task.andThen
                                (\_ -> writeArgs)
            )
        |> Task.attempt (\_ -> ())
    )
