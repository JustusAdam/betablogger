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


(:=) = (,)


headerStyle = 
  [ "top" := "0"
  , "width" := "100%"
  , "background-color" := "rgb(62, 62, 62)"
  , "color" := "white"
  ]


headerImpl : TemplateBuilder Html
headerImpl =
  getInterface `T.andThen` \{navigator, currentUrl} ->
  let
    query_ = currentUrl 
              |> Erl.removeQuery "page" 
              |> Erl.removeQuery "type"
              |> .query 
  in
    return <|
      header [ style headerStyle ]
        [ div [ style [ "padding" := "10px 15px"] ]
            [ a [ onClick navigator <| Just query_ ] [ text "Justus's homepage v3.0" ] ]
        ]



footerBlock : List Html -> Html 
footerBlock inner = 
  div [ style [ "width" := "33%", "float":= "left"] ]
    [ div [ style [ "margin" := "15px 15px"] ] inner
    ]


centerBlock = 
  [ "width" := "960px"
  , "margin-left" := "auto"
  , "margin-right" := "auto"
  ]


pageTemplate : Template
pageTemplate =
  headerImpl `T.andThen` \header ->
  render <| \main ->
  div
    []
    [ header
    , div [ style centerBlock ]
      [ main ]
    , footer [ style 
                [ "margin" := "20px"
                , "border" := "1px solid rgb(233, 233, 233)"
                ] ]
      [ div [ style centerBlock ]
        [ footerBlock
          [ text "This site is built with the wonderful Elm language" ]
        
        , footerBlock [ text "" ]
        , footerBlock
          [ text "©️ 2016 Justus Adam" ]
        ]
      ]
    ]


postTemplate : Template
postTemplate = 
  pageTemplate `nest` render (\main ->
    div []
      [ section [] 
        [ main ]
      ]
  )


indexTemplate : Template
indexTemplate = 
  acquire sidebar `T.andThen` \sb ->
  pageTemplate `nest` 
    render (\main ->
        div []
          [ section [ style [ "float" := "left", "width" := "66%" ] ] [ main ]
          , div [ style [ "float" := "left", "width" := "33%" ] ] 
            [ div [ style [ "margin" := "20px" ] ] 
              <| (\a -> [a]) <| withDefault (text "no sidebar") sb
            ]
          , div [ style [ "clear" := "both" ]] []
          ])
