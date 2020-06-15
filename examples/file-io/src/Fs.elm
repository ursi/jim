module Fs exposing
    ( exists
    , mkdir
    , readFile
    , readdir
    , unlink
    , writeFile
    )

import Jim
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)


writeFile : String -> String -> Task D.Error ()
writeFile path content =
    Jim.task "fsp.writeFile"
        [ E.string path, E.string content ]
        (D.succeed ())


readFile : String -> Task D.Error String
readFile path =
    Jim.task "fsp.readFile"
        [ E.string path ]
        D.string


readdir : String -> Task D.Error (List String)
readdir path =
    Jim.task "fsp.readdir"
        [ E.string path ]
        (D.list D.string)


exists : String -> Task D.Error Bool
exists path =
    Jim.task "fs.existsSync"
        [ E.string path ]
        D.bool


mkdir : String -> Task D.Error ()
mkdir path =
    fileOp "fsp.mkdir" path


unlink : String -> Task D.Error ()
unlink path =
    fileOp "fsp.unlink" path


fileOp : String -> String -> Task D.Error ()
fileOp task path =
    Jim.task task
        [ E.string path ]
        (D.succeed ())
