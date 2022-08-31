@program yaro-setdbrefprop.muf
1 9999 del
i
$include $lib/yaro

: main
    ( "#0=_prop:#123" )
    dup "=" instr over ":" instr over over and not rot rot > or 
    if
        "^ERROR_COLOR^Invalid setting string." tell
        exit
    then
    "=" split ":" split match dup not if
        "^ERROR_COLOR^I am not sure what you're trying to set." tell
        exit
    then
    rot match dup not if
        "^ERROR_COLOR^I am not sure where this prop is being set." tell
        exit
    then
    rot rot setprop
    "^SUCCESS_COLOR^Property set." tell
;
.
c
q
