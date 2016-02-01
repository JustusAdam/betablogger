module OnePageStack.Template where

import Dict
import Task exposing (Task)
import Html exposing (Html)
import OnePageStack.Types exposing (..)
import Erl


type alias Component = Maybe Html
type alias AcquireComponent = Erl.Url -> Task String Component
type alias Components = Dict.Dict String AcquireComponent
type alias TemplateBuilder a = AppInterface -> Html -> Task String a
type alias Template = TemplateBuilder Html


nest : Template -> Template -> Template
nest outer inner interface content =
    inner interface content `Task.andThen` outer interface


getInterface : TemplateBuilder AppInterface
getInterface i _ = Task.succeed i


acquire : AcquireComponent -> TemplateBuilder Component
acquire component = getUrl `andThen` \url _ _ -> component url 


getUrl : TemplateBuilder Erl.Url
getUrl = map .currentUrl getInterface


getNavigator : TemplateBuilder Targeter
getNavigator = map .navigator getInterface


getCanvas : TemplateBuilder ContentHook
getCanvas = map .canvas getInterface


map : (a -> b) -> TemplateBuilder a -> TemplateBuilder b
map f tb i h = Task.map f <| tb i h


andThen : TemplateBuilder a -> (a -> TemplateBuilder b) -> TemplateBuilder b
andThen ta f i html = ta i html `Task.andThen` \a -> f a i html


render : (Html -> a) -> TemplateBuilder a
render a _ h = Task.succeed (a h)


return : a -> TemplateBuilder a
return a _ _ = Task.succeed a


acquired : Html -> AcquireComponent
acquired html _ = Task.mapError toString <| Task.succeed <| Just html


withTemplate : Template -> Handler -> Handler
withTemplate t f i = f i `Task.andThen` t i
