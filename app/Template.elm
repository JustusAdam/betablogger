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
      div [ class "top-bar" ]
        [ div [ class "wrapper" ]
            [ a [ onClick navigator <| Just query_ ] [ text "Justus's homepage v3.0" ] ]
        ]



footerBlock : List Html -> Html
footerBlock inner =
  div [ class "footer-block" ]
    [ div [ class "inner" ] inner ]


pageTemplate : String -> Template
pageTemplate title' =
  headerImpl `T.andThen` \header' ->
  render <| \main ->
  div
    [ class "page-container" ]
    [ header'
    , header [] [ div [ class "center-block" ] [ h1 [] [ text title' ] ] ]
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


postTemplate : String -> Template
postTemplate title' =
  pageTemplate title' `nest` render (\main ->
    div []
      [ article []
        [ main ]
      ]
  )


indexTemplate : String -> String -> Template
indexTemplate basePath title' =
  acquire (sidebar basePath) `T.andThen` \sb ->
  pageTemplate title' `nest`
    render (\main ->
        div []
          [ section [ class "main-content" ] [ main ]
          , div [ style [ "float" := "left", "width" := "25%" ] ]
            [ div [ class "sidebar" ]
              (h3 [] [ text "\"News\"" ]
              :: singleton (withDefault (text "no sidebar") sb))
            ]
          , clearfix
          ])
