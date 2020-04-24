module Fs exposing (readFile, writeFile)

import Jim exposing (..)
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)


writeFile : String -> String -> Task D.Error ()
writeFile path content =
    task
        "writeFile"
        (a2 (E.string path) (E.string content))
        (D.succeed ())


readFile : String -> Task D.Error String
readFile path =
    task
        "readFile"
        (a1 <| E.string path)
        D.string
