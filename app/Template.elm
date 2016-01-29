module Template where


import OnePageStack.Template as T exposing (..)
import Html exposing (..)
import Dict exposing (Dict)
import Maybe exposing (withDefault)


components : Components
components = Dict.fromList
  [("sidebar", acquired <| div [] [text "hello sidebar"])]

template : Template
template = withComponents components <|
  getComponent "sidebar" `T.andThen` \sb ->
  getComponent "panelthing" `T.andThen` \panel ->
    render <| \main ->
      div
        []
        [ div [] [text "panel", withDefault (text "no panel") panel, text "sidebar", withDefault (text "no sidebar") sb]
        , div [] [main]
        ]
