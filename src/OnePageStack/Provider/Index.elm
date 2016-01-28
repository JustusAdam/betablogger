module OnePageStack.Provider.Index (indexProvider) where

import Task exposing (Task)
import Json.Decode as Decode exposing ((:=))
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Http
import Html exposing (..)
import Html.Events exposing (onClick)
import Path.Url exposing ((</>))

fetchIndex : String -> a -> Task String (List PostMeta)
fetchIndex basePath _ = Task.mapError toString <| Http.get (Decode.list postMetaDecoder) <| basePath </> "index.json"

renderIndex : Targeter -> (List PostMeta) -> Html
renderIndex chgr l =
  ul []
    <| List.map (\pm -> li [] [a [ onClick chgr (navigate "post" pm.location) ] [ text pm.title ]])
        l

indexProvider : String -> ProviderFunc
indexProvider basePath = mkProvider (fetchIndex basePath) renderIndex

postMetaDecoder : Decode.Decoder PostMeta
postMetaDecoder = Decode.object2 PostMeta ("location" := Decode.string) ("title" := Decode.string)
