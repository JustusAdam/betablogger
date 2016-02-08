module Template where


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Dict exposing (Dict)
import Maybe exposing (withDefault)
import Maybe.Extra exposing (or)
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
  , subtitle : Maybe String
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
          { title = Just "Hi, how are you?"
          , interface = i
          , content = content
          , subtitle = Nothing
          }
        }


renderProjects : AppInterface -> List Project -> Task.Task String Html
renderProjects i projects =
  let
    renderProject project =
      let
        language =
          case project.language of
            Just l -> [ span [ class "language" ] [ text l ] ]
            _ -> []
      in
        [ div [] <|
          language ++
          [ span [ class "stats" ]
            [ a [ class "stars", href project.starsUrl ]
              [ span [ class "name" ] [ text "Stars" ]
              , span [ class "count" ]  [ text <| toString project.stars ]
              ]
            , a [ class "watchers", href project.watchUrl ]
              [ span [ class "name" ] [ text "Watchers" ]
              , span [ class "count" ]  [ text <| toString project.watchers ]
              ]
            , a [ class "forks", href project.forksUrl ]
              [ span [ class "name" ] [ text "Forks" ]
              , span [ class "count" ]  [ text <| toString project.forks ]
              ]
            ]
          , clearfix
          ]
        , h3 [ class "heading"]
          [ a [ href project.htmlUrl ]
            [ text <| project.name ++ if project.isFork then " (fork)" else "" ] ]
        , p [] [ text project.description ]
        ]
    projectList = projects
      |> List.sortWith (\projA projB ->
        case compare projA.stars projB.stars of
          EQ -> compare (Date.toTime projA.createdAt) (Date.toTime projB.createdAt)
          o -> o)
      |> List.reverse
      |> List.map renderProject
      |> List.map (div [ class "project" ] << singleton << div [ class "wrapper" ])
      |> bisectList
      |> List.map toRow
      |> div [ class "project-list" ]
    toRow e = div [ class "row" ] (e ++ [clearfix])
    content =
      article []
        [ projectList
        , clearfix
        ]
    bisectList l =
      case l of
        [] -> []
        [x] -> [[x]]
        (x::x'::xs) -> [x,x']::bisectList xs
  in
    Task.succeed <|
      pageTemplate
        { interface = i
        , title = Just "Projects"
        , content = content
        , subtitle = Just "What I am/was/will be working on"
        }


renderPost : AppInterface -> (Html, Maybe String, Maybe String) -> Task.Task String Html
renderPost i (c, title, desc) = Task.succeed <|
  postTemplate { content = c, interface = i, title = title, subtitle = desc }


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
      [ ul [ class "page-menu" ]
        [ li [ class "home" ]
          [ a [ onClick navigator <| Just "/" ] [ text "Justus's homepage v3.0" ] ]
        , li [] [ a [ onClick navigator <| Just "projects" ] [ text "Projects" ]]
        ]
      ]
    ]



footerBlock : List Html -> Html
footerBlock inner =
  div [ class "footer-block" ]
    [ div [ class "inner" ] inner ]


pageTemplate : PageInformation -> Html
pageTemplate { interface, title, subtitle, content } =
  div
    [ class "page-container" ]
    <| headerImpl interface
    :: (case title `or` subtitle of
          Nothing -> []
          Just _ ->
            let
              titleH = Maybe.map (\t -> [ h1 [] [ text t ] ]) title
                       |> withDefault []
              subtitleH = Maybe.map (\st ->
                            [ div [ class "subtitle"] [ text st ] ]) subtitle
                          |> withDefault []
            in
              [ header []
                [ div [ class "center-block" ] <| titleH ++ subtitleH ]
              ])
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
    pageTemplate { pageInformation | content = newContent }
