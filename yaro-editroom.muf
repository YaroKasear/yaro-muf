@q
@program yaro-editroom.muf
1 9999 del
i
$include $lib/yaro
$include $lib/editor

: set_description
    var description
    
    me @ "Room Description" 80 boxTitle
    loc @ "_/de" "(MUF)" 1 parseprop dup if 
        dup me @ swap 80 boxContent
        "\r" explode array_make array_reverse description !
        description @ array_vals 
    else
        me @ "This room does not have a description." 80 boxContent
        pop 0 
    then
    "^BOX_COLOR^" me @ 80 line strcat tell
    " " tell
    EDITOR "abort" stringcmp not if
        popn
    else
        array_make loc @ swap "desc" swap setConfig
        loc @ "{list:_config/desc," loc @ dtos strcat "}" strcat setdesc
    then
;

: edit_menu
    begin
        me @ "Room Editor"
        1 "Set Description" 'set_description
        2 "Look And Feel" 2
        9 "Quit" 0
        3 30 doMenu while 2 = if 
            begin me @ "Room Preferences" 80 boxTitle
            me @ "This is the tool for setting room-wide preferences. "
            "PROTIP: Running this in a parent room can apply preferences across the environment."
            loc @ set_look_feel 
        then repeat
    "^NOTE_COLOR^Thank you for using the Room Editor!" tell
;

: main
    strip dup "#" instr 1 = if
    else pop then
    loc @ me @ control? if
        edit_menu
    else
        "^ERROR_COLOR^You do not control this room and cannot edit it." tell
    then
;
.
c
q

