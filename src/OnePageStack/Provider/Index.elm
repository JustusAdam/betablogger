module OnePageStack.Provider.Index (indexProvider) where

import Task exposing (Task)
import Json.Decode as Decode exposing ((:=))
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Http
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Path.Url exposing ((</>))


type alias PostMeta = 
  { location : String
  , title : String
  , description : Maybe String 
  }


fetchIndex : String -> a -> Task String (List PostMeta)
fetchIndex basePath _ =
  basePath </> "index.json"
  |> Http.get (Decode.list postMetaDecoder)
  |> Task.mapError toString


renderIndex : Targeter -> (List PostMeta) -> Html
renderIndex chgr =
  ul [ style [("padding-left", "10px")] ]
    << List.map (\pm -> 
        li [ style [("list-style-type", "none"), ("padding", "0")]] 
          [ a [ onClick chgr (navigate "post" pm.location) ] 
              ([ h3 [] [text pm.title]]
              ++ case pm.description of
                   Nothing -> []
                   Just d -> [p [] [text d]] 
              )
          ])


indexProvider : String -> Handler
indexProvider basePath = mkProvider (fetchIndex basePath) renderIndex


postMetaDecoder : Decode.Decoder PostMeta
postMetaDecoder = 
  Decode.object3 
    PostMeta 
    ("location" := Decode.string) 
    ("title" := Decode.string)
    ("description" := Decode.maybe Decode.string)
