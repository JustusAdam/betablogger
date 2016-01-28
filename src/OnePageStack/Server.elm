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


-- MODEL

handleRequest : ProviderFunc -> Providers -> AppInterface -> Task String ()
handleRequest defaultProvider providers interface =
  let
    provider = Dict.get "type" interface.currentUrl.query `Maybe.andThen` flip Dict.get providers |> withDefault defaultProvider
  in
    provider interface
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

interfaceSignal : Signal Url -> Signal AppInterface
interfaceSignal = Signal.map (AppInterface contentHook.address locationChanger.address)

server : ProviderFunc -> Providers -> Signal Url -> Signal (Task String ())
server defaultProvider p = Signal.map (handleRequest defaultProvider p) << interfaceSignal

currentLocation : Signal String -> Signal Url
currentLocation = Signal.map2
  (\new initial ->
    let
      url = Erl.parse initial
    in
      case new of
        Nothing -> url
        Just q -> { url | query = q}
  )
  locationChanger.signal

serverOutput : Signal Html
serverOutput = Signal.map view contentHook.signal
