module OnePageStack.Server where


import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import List
import History
import Http exposing (Error)
import Dict
import Json.Decode as Decode exposing ((:=))
import Task exposing (Task)
import Erl exposing (Url, Query)
import Debug
import Markdown
import Maybe exposing (withDefault)
import OnePageStack.Types exposing (..)
import Path.Url as PU exposing ((</>))
import String
import Maybe.Extra exposing (or)
import Debug
import List.Extra exposing (last, init)


handleRequest : Providers -> AppInterface -> Task String ()
handleRequest providers interface =
  let
    finder str rest =
      Maybe.map (\a -> (a, rest)) (Dict.get str providers)
      `or` if String.isEmpty str
             then Nothing
             else
               let
                 s = String.split "/" str
                 newRest = withDefault rest <| Maybe.map (\s -> s::rest) <| last s
                 base = String.join "/" <| withDefault [] <| init s
               in
                 finder base newRest

  in
    case finder interface.currentUrl [] of
      Nothing -> Signal.send interface.canvas <| PageNotFound <| toString "No suitable provider found"
      Just (provider, rest) ->
        provider interface (String.join "/" rest)
        `Task.andThen` (Signal.send interface.canvas << Page)
        `Task.onError` (Signal.send interface.canvas << PageNotFound << toString)


view : Page -> Html
view p =
  case p of
    PageLoading -> div [] [text "loading ..."]
    PageNotFound message -> div [] [text "page unable to load due to: ", text message]
    Page p -> p


contentHook : Signal.Mailbox Page
contentHook = Signal.mailbox PageLoading


locationChanger : Signal.Mailbox LocationChange
locationChanger = Signal.mailbox Nothing


lcTask : Signal (Task String ())
lcTask = Signal.map2 (\orig change ->
  case change of
    Nothing -> Task.succeed ()
    Just chng ->
      let
        basepath = String.split "#" orig
                    |> List.head
                    |> withDefault ""
      in
        History.setPath <| basepath ++ "#" ++ chng)
  (Signal.sampleOn locationChanger.signal History.path)
  locationChanger.signal


interfaceSignal : Signal AppInterface
interfaceSignal =
  Signal.map
  (String.dropLeft 1 >> AppInterface contentHook.address locationChanger.address)
  History.hash


server : Providers -> Signal (Task String ())
server p = Signal.map (handleRequest p << Debug.log "change triggered") interfaceSignal


serverOutput : Signal Html
serverOutput = Signal.map view contentHook.signal
