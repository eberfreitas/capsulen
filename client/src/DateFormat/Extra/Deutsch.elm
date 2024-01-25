module DateFormat.Extra.Deutsch exposing (deutsch)

import DateFormat.Languages exposing (Language)
import Time


toMonthName : Time.Month -> String
toMonthName month =
    case month of
        Time.Jan ->
            "Januar"

        Time.Feb ->
            "Februar"

        Time.Mar ->
            "März"

        Time.Apr ->
            "April"

        Time.May ->
            "Mai"

        Time.Jun ->
            "Juni"

        Time.Jul ->
            "Juli"

        Time.Aug ->
            "August"

        Time.Sep ->
            "September"

        Time.Oct ->
            "Oktober"

        Time.Nov ->
            "November"

        Time.Dec ->
            "Dezember"


toMonthNameShort : Time.Month -> String
toMonthNameShort month =
    case month of
        Time.Mar ->
            toMonthName month

        Time.May ->
            toMonthName month

        Time.Jun ->
            toMonthName month

        Time.Jul ->
            toMonthName month

        _ ->
            month |> toMonthName |> String.left 3


toWeekdayName : Time.Weekday -> String
toWeekdayName day =
    case day of
        Time.Mon ->
            "Montag"

        Time.Tue ->
            "Dienstag"

        Time.Wed ->
            "Mittwoch"

        Time.Thu ->
            "Donnerstag"

        Time.Fri ->
            "Freitag"

        Time.Sat ->
            "Samstag"

        Time.Sun ->
            "Sonntag"


toAmPm : Int -> String
toAmPm hour =
    if hour > 11 then
        "pm"

    else
        "am"


deutsch : Language
deutsch =
    Language
        toMonthName
        toMonthNameShort
        toWeekdayName
        (toWeekdayName >> String.left 2)
        toAmPm
        (always ".")
