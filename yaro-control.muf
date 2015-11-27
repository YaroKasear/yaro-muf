@q
@edit yaro-control.muf
1 9999 del
i
$include $lib/yaro

: main ( s -- )
    " " explode pop match swap match swap over over control? if
        name " does control " strcat swap name strcat "!" strcat me @ swap success_color tell
    else
        name " does not control " strcat swap name strcat "!" strcat  me @ swap error_color tell
    then
;
.
c
q

