module Path exposing (join)

import Jim
import Json.Decode as D
import Json.Encode as E


join : List String -> String
join components =
    Jim.function "path.join"
        [ E.list E.string components ]
        D.string
        |> Result.withDefault ""
