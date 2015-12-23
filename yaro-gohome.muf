@q
@program yaro-gohome.muf
1 9999 del
i
$include $lib/yaro

: show_help
    var command_name

    trigger @ name ";" split pop command_name !
    me @ command_name @ " Help" strcat 80 boxTitle
    me @ "^FIELD_COLOR^" command_name @ strcat 
    "^CONTENT_COLOR^Send yourself home WITH inventory." 80 boxInfo
    me @ "^FIELD_COLOR^" command_name @ strcat " #set-message" strcat 
    "^CONTENT_COLOR^Set the message you see when you go home." 80 boxInfo
    me @ "^FIELD_COLOR^" command_name @ strcat " #set-omessage" strcat 
    "^CONTENT_COLOR^Set the message others see when you go home." 80 boxInfo
    "^BOX_COLOR^" me @ 80 line strcat tell
    " " tell
;

: main 
    strip dup "#" instr 1 = if
        dup case
            "set-message" paramTest when
                " " split nip dup if
                    "^SUCCESS_COLOR^Set your personal home message" tell
                else
                    "^SUCCESS_COLOR^Cleared personal home message." tell
                then
                me @ swap "prefs/home_message" swap setConfig
            end
            "set-omessage" paramTest when
                " " split nip dup if
                    "^SUCCESS_COLOR^Set your public home message" tell
                else
                    "^SUCCESS_COLOR^Cleared public home message." tell
                then
                me @ swap "prefs/ohome_message" swap setConfig
            end
            "help" paramTest show_help when
            end
            default 
            end
        endcase
        exit
    then
    me @ getlink loc @ != if
        me @ "prefs/home_message" getConfig dup not if
            pop "There's no place like home."
        then
        dup "^SUCCESS_COLOR^" swap strcat tell 1 sleep 
        dup "^INFO_COLOR^" swap strcat tell 1 sleep 
        "^NOTE_COLOR^" swap strcat tell 1 sleep 
        me @ "prefs/ohome_message" getConfig dup not if
            pop "goes home."
        then
        me @ name " " strcat swap strcat "^INFO_COLOR^" swap strcat
        loc @ getPlayers pop pop dup me @ array_findval 0 array_getitem 
        array_extract pop foreach nip
            over otell
        repeat pop
        me @ me @ getlink moveto
    else
        "^ERROR_COLOR^You are already home!" tell
    then
;
.
c
q

