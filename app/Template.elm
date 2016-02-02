module Template where


import OnePageStack.Template as T exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Dict exposing (Dict)
import Maybe exposing (withDefault)
import Http
import Erl
import Path.Url exposing ((</>))
import Task
import Markdown
import Json.Decode as Decode
import Util exposing (singleton)


clearfix = div [class "clearfix"] []


sidebar : String -> AcquireComponent
sidebar basePath _ =
  Http.get (Decode.list Decode.string) (basePath </> "sidebar.json")
  |> Task.map
      (List.map (
        Markdown.toHtml
        >> singleton
        >> li []
        )
      >> ul []
      >> Just)
  |> Task.mapError toString



(:=) = (,)


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
      header [ ]
        [ div [ class "wrapper" ]
            [ a [ onClick navigator <| Just query_ ] [ text "Justus's homepage v3.0" ] ]
        ]



footerBlock : List Html -> Html
footerBlock inner =
  div [ class "footer-block" ]
    [ div [ class "inner" ] inner ]


pageTemplate : Template
pageTemplate =
  headerImpl `T.andThen` \header ->
  render <| \main ->
  div
    [ class "page-container" ]
    [ header
    , div [ class "center-block" ]
      [ main ]
    , clearfix
    , footer []
      [ div [ class "center-block" ]
        [ footerBlock
          [ text "This site is built with the wonderful ", a [href "http://elm-lang.org"] [ text "Elm"], text " language" ]

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


indexTemplate : String -> Template
indexTemplate basePath =
  acquire (sidebar basePath) `T.andThen` \sb ->
  pageTemplate `nest`
    render (\main ->
        div []
          [ section [ style [ "float" := "left", "width" := "66%" ] ] [ main ]
          , div [ style [ "float" := "left", "width" := "33%" ] ]
            [ div [ class "sidebar" ]
              <| (\a -> [a]) <| withDefault (text "no sidebar") sb
            ]
          , clearfix
          ])
