module Template where


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
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Index exposing (PostMeta)
import OnePageStack.Provider.Util exposing (navigate)
import OnePageStack.Provider.Projects exposing (Project)
import Date


type alias PageInformation =
  { interface : AppInterface
  , title : Maybe String
  , content : Html
  }


clearfix = div [class "clearfix"] []


renderIndex : String -> AppInterface -> (List PostMeta) -> Task.Task String Html
renderIndex basePath i postData =
  let
    {navigator} = i
    content =
      postData
      |> List.sortBy (Date.toTime << .date)
      |> List.reverse
      |> List.map (\pm ->
              li [ class "element" ]
                [ a [ onClick navigator (navigate <| "post/" ++ pm.location)]
                    ([ h3 [] [text pm.title]]
                    ++ case pm.description of
                        Nothing -> []
                        Just d -> [p [ class "description" ] [text d]]
                    )
                ])
        -- >> List.intersperse (li [class "separator"] [])
      |> ul [ class "post-list" ]
  in
    flip Task.map (sidebar basePath) <| \sb ->
      indexTemplate
        { sidebar = sb
        , pageInformation =
          { title = Just "Welcome to my blog"
          , interface = i
          , content = content
          }
        }


renderProjects : AppInterface -> List Project -> Task.Task String Html
renderProjects i projects =
  let
    renderProject project =
      [ h3 [] [ text project.name ]
      , p [] [ text project.description ]
      ]
    c = projects
      |> List.map renderProject
      |> List.map (li [ class "project" ])
      |> ul [ class "project-list" ]
  in
    Task.succeed <|
      postTemplate { interface = i, title = Just "My Projects", content = c }


renderPost : AppInterface -> Html -> Task.Task String Html
renderPost i c = Task.succeed <|
  postTemplate { content = c, interface = i, title = Nothing }


sidebar : String -> Task.Task String Html
sidebar basePath =
  Http.get (Decode.list Decode.string) (basePath </> "sidebar.json")
  |> Task.map
      (List.map (
        Markdown.toHtml
        >> singleton
        >> li []
        )
      >> ul [])
  |> Task.mapError toString


headerImpl : AppInterface -> Html
headerImpl {navigator, currentUrl} =
  div [ class "top-bar" ]
    [ div [ class "wrapper" ]
        [ a [ onClick navigator <| Just "/" ] [ text "Justus's homepage v3.0" ] ]
    ]



footerBlock : List Html -> Html
footerBlock inner =
  div [ class "footer-block" ]
    [ div [ class "inner" ] inner ]


pageTemplate : PageInformation -> Html
pageTemplate { interface, title, content } =
  div
    [ class "page-container" ]
    <| headerImpl interface
    :: (case title of
          Just t -> [header [] [ div [ class "center-block" ] [ h1 [] [ text t ] ] ]]
          Nothing -> [])
    ++
    [ div [ class "center-block" ]
      [ content ]
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


postTemplate : PageInformation -> Html
postTemplate pi =
  let
    { content } = pi
    newContent =
      div []
        [ article []
          [ content ]
        ]
  in
    pageTemplate { pi | content = newContent }


type alias IndexTemplateData =
  { sidebar : Html
  , pageInformation : PageInformation
  }


indexTemplate : IndexTemplateData -> Html
indexTemplate { sidebar, pageInformation } =
  let
    newContent =
      div []
        [ section [ class "main-content" ] [ pageInformation.content ]
        , div [ class "sidebar-container" ]
          [ div [ class "sidebar" ]
            [ h3 [] [ text "\"News\"" ]
            , sidebar
            ]
          ]
        , clearfix
        ]
  in
    pageTemplate { pageInformation | content = newContent}
