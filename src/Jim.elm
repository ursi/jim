module Jim exposing
    ( Args, a0, a1, a2, a3, a4, a5
    , task, taskWithError
    , function
    )

{-|

@docs Args, a0, a1, a2, a3, a4, a5
@docs task, taskWithError
@docs function

-}

import Json.Decode as D exposing (Decoder)
import Json.Encode as E exposing (Value)
import Process
import Task exposing (Task)


{-| This type corresponds the the arguments pased to the JavaScript function. Use the functions below to pass in 0 to 5 arguments. If you'd like to pass in more than 5 arguments, consider using an object instead.
-}
type Args
    = Args Value


jimKey : String
jimKey =
    "__jim"


{-| -}
a0 : Args
a0 =
    Args <| E.object []


{-| -}
a1 : Value -> Args
a1 a =
    Args <|
        E.object
            [ ( "0", a )
            , ( "length", E.int 1 )
            ]


{-| -}
a2 : Value -> Value -> Args
a2 a b =
    Args <|
        E.object
            [ ( "0", a )
            , ( "1", b )
            , ( "length", E.int 2 )
            ]


{-| -}
a3 : Value -> Value -> Value -> Args
a3 a b c =
    Args <|
        E.object
            [ ( "0", a )
            , ( "1", b )
            , ( "2", c )
            , ( "length", E.int 3 )
            ]


{-| -}
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


{-| -}
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


{-| Create a task using a JavaScript function.

    import Json.Decode as D
    import Json.Encode as E


    -- make 2 http requests that respond with numbers, then add them together
    addResponse : String -> String -> Task D.Error Float
    addResponse url1 url2 =
        task
            -- the name used to register the JavaScript functions that represents this task
            "add"
            -- the arguments passed into the function
            (a2 (E.string url1) (E.string url2))
            -- a decoder for the return value of the function
            D.float

-}
task : String -> Args -> Decoder a -> Task D.Error a
task name args decoder =
    taskWithError
        name
        args
        (D.map Ok decoder)
        identity


{-| Create a `Task` with a custom error type.

    import Json.Decode as D
    import Json.Encode as E

    type Error
        = ResponseError String
        | DecodeError D.Error

    -- make 2 http requests that respond with numbers, then add them together
    addResponse : String -> String -> Task Error Float
    addResponse url1 url2 =
        taskWithError
            "add"
            (a2 (E.String url1) (E.string url2))
            (D.oneOf
                [ D.map Ok D.float
                , D.map (Err << ResponseError) D.string
                ]
            )
            DecodeError

-}
taskWithError : String -> Args -> Decoder (Result x a) -> (D.Error -> x) -> Task x a
taskWithError name (Args args) decoder toError =
    (\_ ->
        E.object
            [ ( jimKey
              , E.object
                    [ ( "type", E.string "prime task" )
                    , ( "name", E.string name )
                    , ( "args", args )
                    ]
              )
            ]
    )
        |> Task.succeed
        |> Task.map ((|>) ())
        |> Task.andThen (\_ -> Process.sleep -0.10913)
        |> Task.andThen
            (\_ ->
                case
                    D.decodeValue
                        (D.at [ "result", "Ok" ] decoder)
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
                        case error of
                            D.Field "result" (D.Field "Ok" (D.Failure _ value)) ->
                                D.Failure mismatchErrorMessage value
                                    |> toError
                                    |> Task.fail

                            D.Field "result" (D.Failure _ value) ->
                                runtimeError
                                    |> toError
                                    |> Task.fail

                            _ ->
                                error
                                    |> toError
                                    |> Task.fail
            )


{-| It is recommended to stay away from this function unless it's absolutely necessary. Implementing a function in Jim gives many more guarantees than is possible in JavaScript. If you're looking to implement a function that isn't pure, consider reaching for a [task](#task) or a [port](https://guide.elm-lang.org/interop/ports.html).

    import Json.Decode as D
    import Json.Encode as E

    addToResult : Float -> Float -> Result D.Error Float
    addToResult a b =
        function
            -- the name used to register the function
            "add"
            -- the arguments passed into the function
            (a2 (E.float a) (E.float b))
            -- a decoder for the return value of the function
            D.float

    add : Float -> Float -> Float
    add a b =
        addToResult a b
            |> Result.withDefault 0

-}
function : String -> Args -> Decoder a -> Result D.Error a
function name (Args args) decoder =
    D.decodeValue
        (D.at [ "result", "Ok" ] decoder)
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
        |> Result.mapError
            (\error ->
                case error of
                    D.Field "result" (D.Field "Ok" (D.Failure _ value)) ->
                        D.Failure mismatchErrorMessage value

                    _ ->
                        runtimeError
            )


mismatchErrorMessage : String
mismatchErrorMessage =
    "Your decoder did not match the return value of the function"


runtimeError : D.Error
runtimeError =
    D.Failure
        "There was a runtime error in your JavaScript code. Check the console for information."
        (E.string "runtime error")
