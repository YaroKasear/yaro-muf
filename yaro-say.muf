@q
@program yaro-say.muf
1 9999 del
i
$include $lib/yaro
$include $cmd/status

var timeout

: updatePo ( -- )
    var current_turn

    loc @ "poseorder/order" getConfig dup if
        var newPO
        { }dict newPO ! foreach
            dup systime swap - timeout @ -1 = swap timeout @ < or if
                swap me @ name over stringcmp not if
                    pop pop
                else
                    swap newPO @ rot array_insertitem newPO !
                then
            else
                pop pop
            then
        repeat
        systime newPO @ me @ name array_insertitem
    else
        pop { me @ name systime }dict
    then
    dup loc @ swap "poseorder/order" swap setconfig
    foreach
        systime swap - timeout @ > not if
            pmatch dup get_status swap pop "I" stringcmp not over awake? and if
                current_turn ! break
            else pop then
        else pop then
    repeat
    current_turn @ if
        loc @ getPlayers pop pop foreach swap pop
            dup "poseorder/notify" getConfig if
                dup current_turn @ = if
                    dup "It is now currently your pose." info_color otell
                else
                    dup "It is now currently " current_turn @ name "'s pose." strcat strcat
                    info_color otell
                then
            else pop then
        repeat
    then
;

: makeOOC ( d -- s )
    dup open_tag over swap tag_color_2
    over "OOC" tag_color_1 strcat
    swap dup close_tag tag_color_2 strcat
;

: doPose ( s -- )
    strip loc @ getPlayers pop pop foreach swap pop
        over me @ name " " strcat swap strcat
        "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
        over swap process_tags otell
    repeat pop
    updatePo
;

: doSpoof ( s -- )
    strip loc @ getPlayers pop pop foreach swap pop
        over dup me @ name instr if
            "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
            over swap process_tags otell
        else
            "( " swap strcat " )" strcat
            over "W" flag? if
                " " strcat
                over dup open_tag tag_color_2 strcat
                over me @ name tag_color_1 strcat
                over dup close_tag tag_color_2 strcat
            then
            "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
            over swap process_tags otell
        then
    repeat pop
    updatePo
;

: doSay ( s -- )
    strip dup "You " me @ say strcat ", \"" strcat swap strcat "\"" strcat 
    "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
    me @ swap process_tags tell
    loc @ getPlayers pop pop me @ 1 array_make swap array_diff 
    foreach swap pop
        over me @ name " " strcat me @ says strcat ", \"" strcat
        swap strcat "\"" strcat 
        "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
        over swap process_tags otell 
    repeat pop
    updatePo
;

: doOsay ( s -- )
    strip dup "You " me @ say strcat ", \"" strcat swap strcat "\"" strcat 
    "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
    me @ makeOOC " " strcat swap strcat me @ swap process_tags tell
    loc @ getPlayers pop pop me @ 1 array_make swap array_diff 
    foreach swap pop
        over me @ name " " strcat me @ says strcat ", \"" strcat
        swap strcat "\"" strcat 
        "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
        over makeOOC " " strcat swap strcat over swap process_tags otell 
    repeat pop
;

: doOpose ( s -- )
    dup ":" instr 1 = if 
        ":" split swap pop
    then strip
    loc @ getPlayers pop pop foreach swap pop
        over me @ name " " strcat swap strcat
        "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
        over makeOOC " " strcat swap strcat 
        over swap process_tags otell
    repeat pop
;

: doOspoof ( s -- )
    strip loc @ getPlayers pop pop foreach swap pop
        over dup me @ name instr if
            "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
            over makeOOC " " strcat swap strcat over swap process_tags otell
        else
            "( " swap strcat " )" strcat 
            "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
            over "W" flag? if
                " " strcat
                over dup open_tag tag_color_2 strcat
                over me @ name tag_color_1 strcat
                over dup close_tag tag_color_2 strcat 
            then
            over makeOOC " " strcat swap strcat 
            over swap process_tags otell
        then
    repeat pop
;

: doOchoose ( s -- )
    dup ":" instr 1 = if
        doOpose
    else
        doOsay
    then
;

: main ( s -- )
    loc @ "poseorder/timeout" getConfig atoi dup not if 
        pop 1800
    then
    timeout !
    strip
    command @ tolower case
        "say" swap instr 1 = when doSay end
        "\"" swap instr 1 = when doSay end
        "pose" swap instr 1 = when doPose end
        "@emit" swap instr 1 = when doPose end
        ":" swap instr 1 = when doPose end
        "spoof" swap instr 1 = when doSpoof end
        "osay" swap instr 1 = when doOchoose end
        "ooc" swap instr 1 = when doOchoose end
        "opose" swap instr 1 = when doOpose end
        "ospoof" swap instr 1 = when doOspoof end
        ">" swap instr 1 = when doOchoose end
        default end
    endcase
;
.
c
q

