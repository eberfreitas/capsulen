module List.Extra exposing (indexedFilter)


indexedFilter : (Int -> a -> Bool) -> List a -> List a
indexedFilter f list =
    list
        |> List.indexedMap Tuple.pair
        |> List.filter (\( i, item ) -> f i item)
        |> List.map Tuple.second
