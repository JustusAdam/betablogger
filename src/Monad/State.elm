module Monad.State where


import Util exposing (const)


type alias State s v = s -> (v, s)


return : a -> State s a
return = (,)


andThen : State s v -> (v -> State s v') -> State s v'
andThen st f v =
  let
    (v', s') = st v
  in
    f v' s'


thenDo : State s v -> State s v' -> State s v'
thenDo s s2 = s `andThen` const s2


get : State s s
get s = (s, s)


put : s -> State s ()
put s _ = ((), s)


modify : (s -> s) -> State s ()
modify f s = ((), f s)


map : (a -> b) -> State s a -> State s b
map f s = s `andThen` (return << f)
