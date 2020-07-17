module Console exposing (log)

import Jim exposing (..)
import Json.Decode as D
import Json.Encode as E exposing (Value)
import Task exposing (Task)


log : Value -> Task D.Error ()
log value =
    task "console.log"
        [ value ]
        (D.succeed ())
