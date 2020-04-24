module Jim exposing (..)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E exposing (Value)
import Process
import Task exposing (Task)


type Args
    = Args Value


jimKey : String
jimKey =
    "__jim"


a0 : Args
a0 =
    Args <| E.object []


a1 : Value -> Args
a1 a =
    Args <|
        E.object
            [ ( "0", a )
            , ( "length", E.int 1 )
            ]


a2 : Value -> Value -> Args
a2 a b =
    Args <|
        E.object
            [ ( "0", a )
            , ( "1", b )
            , ( "length", E.int 2 )
            ]


a3 : Value -> Value -> Value -> Args
a3 a b c =
    Args <|
        E.object
            [ ( "0", a )
            , ( "1", b )
            , ( "2", c )
            , ( "length", E.int 3 )
            ]


a4 : Value -> Value -> Value -> Value -> Args
a4 a b c d =
    Args <|
        E.object
            [ ( "0", a )
            , ( "1", b )
            , ( "2", c )
            , ( "3", d )
            , ( "length", E.int 4 )
            ]


a5 : Value -> Value -> Value -> Value -> Value -> Args
a5 a b c d e =
    Args <|
        E.object
            [ ( "0", a )
            , ( "1", b )
            , ( "2", c )
            , ( "3", d )
            , ( "4", e )
            , ( "length", E.int 5 )
            ]


function : String -> Args -> Decoder a -> Result D.Error a
function name (Args args) decoder =
    D.decodeValue
        (D.field "return" decoder)
        (E.object
            [ ( jimKey
              , E.object
                    [ ( "type", E.string "function" )
                    , ( "name", E.string name )
                    , ( "args", args )
                    ]
              )
            ]
        )


task : String -> Args -> Decoder a -> Task D.Error a
task name args decoder =
    taskWithError
        name
        args
        (D.map Ok decoder)
        identity


taskWithError : String -> Args -> Decoder (Result a b) -> (D.Error -> a) -> Task a b
taskWithError name (Args args) decoder toError =
    let
        _ =
            E.object
                [ ( jimKey
                  , E.object
                        [ ( "type", E.string "prime task" )
                        , ( "name", E.string name )
                        , ( "args", args )
                        ]
                  )
                ]
    in
    Process.sleep -1
        |> Task.andThen
            (\_ ->
                case
                    D.decodeValue
                        (D.field "result" decoder)
                        (E.object
                            [ ( jimKey
                              , E.object
                                    [ ( "type", E.string "task result" )
                                    , ( "name", E.string name )
                                    , ( "args", args )
                                    ]
                              )
                            ]
                        )
                of
                    Ok result ->
                        case result of
                            Ok value ->
                                Task.succeed value

                            Err error ->
                                Task.fail error

                    Err error ->
                        Task.fail <| toError error
            )

