module Tuple.Extra exposing (mapTrio)


mapTrio : (a -> x) -> (b -> y) -> (c -> z) -> ( a, b, c ) -> ( x, y, z )
mapTrio fn1 fn2 fn3 ( a, b, c ) =
    ( fn1 a, fn2 b, fn3 c )
