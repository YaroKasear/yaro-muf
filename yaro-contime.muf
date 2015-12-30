@program yaro-contime.muf
1 9999 del
i
$include $lib/yaro

: get_oldest ( d -- i )
    var longest

    descriptors array_make foreach nip
        descrcon contime dup longest @ > if longest ! else pop then
    repeat
    longest @
;

: format_name ( i s -- s )
    var tvalue
    var tunit

    tunit !
    tvalue !

    tvalue @ if
        tvalue @ intostr " " strcat tunit @ strcat
        tvalue @ 1 > if
            "s" strcat
        then
        ", " strcat
    else
        ""
    then
;

: pretty_time ( i -- s )
    time_explode 6 reverse 
    "moon" format_name -6 rotate
    "week" format_name -6 rotate
    "day" format_name -6 rotate
    "hour" format_name -6 rotate
    "minute" format_name -6 rotate
    "second" format_name -6 rotate
    6 reverse strcat strcat strcat strcat strcat
    ", " rsplit pop
;

: main
    dup if
        pmatch dup ok? if
            dup get_oldest dup if
                pretty_time swap name "^INFO_COLOR^" swap strcat 
                " has been online for " strcat swap strcat "." strcat tell
            else
                pop "^INFO_COLOR^" swap name strcat " is not currently connected." strcat tell
            then
        else
            "^ERROR_COLOR^I do not know that player." tell
        then
    else
        pop me @ get_oldest pretty_time
        "^INFO_COLOR^You have been online for " swap strcat "." strcat tell
    then
;
.
c
q


