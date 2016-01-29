module OnePageStack.Template where

import Dict
import Task exposing (Task)
import Html exposing (Html)
import OnePageStack.Types exposing (..)
import Erl


type alias Component = Maybe Html
type alias AcquireComponent = Erl.Url -> Task String Component
type alias Components = Dict.Dict String AcquireComponent
type alias TemplateBuilder a = Components -> AppInterface -> Html -> Task String a
type alias Template = AppInterface -> Html -> Task String Html


withComponents : Components -> TemplateBuilder Html -> Template
withComponents c tb = tb c


getComponent : String -> TemplateBuilder Component
getComponent selector components {currentUrl} _ =
  case Dict.get selector components of
    Just acq -> acq currentUrl
    Nothing -> Task.succeed Nothing


getInterface : TemplateBuilder AppInterface
getInterface _ i _ = Task.succeed i


getUrl : TemplateBuilder Erl.Url
getUrl = map .currentUrl getInterface


getNavigator : TemplateBuilder Targeter
getNavigator = map .navigator getInterface


getCanvas : TemplateBuilder ContentHook
getCanvas = map .canvas getInterface


map : (a -> b) -> TemplateBuilder a -> TemplateBuilder b
map f tb comp i h = Task.map f <| tb comp i h


andThen : TemplateBuilder a -> (a -> TemplateBuilder b) -> TemplateBuilder b
andThen ta f comp i html = ta comp i html `Task.andThen` \a -> f a comp i html


render : (Html -> a) -> TemplateBuilder a
render a _ _ h = Task.succeed (a h)


return : a -> TemplateBuilder a
return a _ _ _ = Task.succeed a


acquired : Html -> AcquireComponent
acquired html _ = Task.mapError toString <| Task.succeed <| Just html


withTemplate : Template -> ProviderFunc -> ProviderFunc
withTemplate t f i = f i `Task.andThen` t i
