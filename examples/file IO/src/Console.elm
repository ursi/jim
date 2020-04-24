module Console exposing (log)

import Jim exposing (..)
import Json.Decode as D
import Json.Encode as E exposing (Value)
import Task exposing (Task)


log : Value -> ()
log value =
    function
        "log"
        (a1 value)
        (D.succeed ())
        |> Result.withDefault ()
