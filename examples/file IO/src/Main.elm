module Main exposing (..)

import Console
import Fs
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)


main : Program String Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    ()


init : String -> ( Model, Cmd Msg )
init args =
    ( ()
    , if String.isEmpty args then
        Task.attempt FileRead <| Fs.readFile "args.txt"

      else
        Task.attempt (\_ -> NoOp) <| Fs.writeFile "args.txt" args
    )



-- UPDATE


type Msg
    = FileRead (Result D.Error String)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileRead result ->
            case result of
                Ok str ->
                    let
                        _ =
                            Console.log <| E.string str
                    in
                    ( model, Cmd.none )

                Err _ ->
                    let
                        _ =
                            Console.log <| E.string "the file doesn't exist"
                    in
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
