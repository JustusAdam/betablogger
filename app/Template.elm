module Template where


import OnePageStack.Template as T exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Dict exposing (Dict)
import Maybe exposing (withDefault)
import Http
import Erl


sidebar : AcquireComponent
sidebar = acquired <| div [] [text "hello sidebar"]


headerStyle = [("top", "0"), ("width", "100%"), ("background-color", "black"), ("color", "white")]


headerImpl : TemplateBuilder Html
headerImpl =
  getInterface `T.andThen` \{navigator, currentUrl} ->
  let
    query_ = .query <| Erl.removeQuery "type" <| Erl.removeQuery "page" currentUrl
  in
    return <|
      header [style headerStyle]
        [ div [style [("padding", "10px 15px")]]
            [a [onClick navigator <| Just query_] [text "Justus's homepage v3.0"]]
        ]



footerBlock = [("width", "33%"), ("float", "left")]


centerBlock = [("width", "960px"), ("margin-left", "auto"), ("margin-right", "auto")]


pageTemplate : Template
pageTemplate =
  headerImpl `T.andThen` \header ->
  render <| \main ->
  div
    []
    [ header
    , div [style centerBlock]
      [ main ]
    , footer []
      [ div [style centerBlock]
        [ div [style footerBlock]
          [text "This site is built with the wonderful Elm language"]
        ]
      , div [style footerBlock] [text ""]
      , div [style footerBlock]
        [text "Copyright 2016 Justus Adam"]
      ]
    ]


postTemplate : Template
postTemplate = 
  acquire sidebar `T.andThen` \sb ->
  pageTemplate `nest` 
    render (\main ->
        div []
          [ section [] [main]
          , div [] <| (\a -> [a]) <| withDefault (text "no sidebar") sb
          ])
