@q
@program yaro-say.muf
1 9999 del
i
$include $lib/yaro
$include $cmd/status
$include $cmd/poseorder

: doPose ( s -- )
    strip loc @ getPlayers pop pop foreach swap pop
        over "^IC_NAME_COLOR^" me @ name strcat 
        "^IC_COLOR_1^ " strcat swap strcat "^IC_COLOR_1^" "^IC_COLOR_2^" 
        color_quotes over swap process_tags otell
    repeat pop
    update_po
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
    update_po
;

: doSay ( s -- )
    strip dup "^IC_NAME_COLOR^You^IC_COLOR_1^ " me @ say strcat ", \"" strcat swap strcat "\"" strcat 
    "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
    me @ swap process_tags tell
    loc @ getPlayers pop pop me @ 1 array_make swap array_diff 
    foreach swap pop
        over "^IC_NAME_COLOR^" me @ name strcat "^IC_COLOR_1^ " strcat me @ says strcat ", \"" strcat
        swap strcat "\"" strcat 
        "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes
        over swap process_tags otell 
    repeat pop
    update_po
;

: doOsay ( s -- )
    strip dup "^OOC_NAME_COLOR^You^OOC_COLOR_1^ " me @ say strcat ", \"" strcat swap strcat "\"" strcat 
    "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
    "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^OOC^TAG_COLOR_2^^CLOSE_TAG^ " 
    swap strcat me @ swap process_tags tell
    loc @ getPlayers pop pop me @ 1 array_make swap array_diff 
    foreach swap pop
        over "^OOC_NAME_COLOR^" me @ name strcat "^OOC_COLOR_1^ " strcat me @ says strcat ", \"" strcat
        swap strcat "\"" strcat 
        "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
        "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^OOC^TAG_COLOR_2^^CLOSE_TAG^ " 
        swap strcat over swap process_tags otell 
    repeat pop
;

: doOpose ( s -- )
    dup ":" instr 1 = if 
        ":" split swap pop
    then strip
    loc @ getPlayers pop pop foreach swap pop
        over "^OOC_NAME_COLOR^" me @ name strcat "^OOC_COLOR_1^ " strcat swap strcat
        "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
        "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^OOC^TAG_COLOR_2^^CLOSE_TAG^ " 
        swap strcat over swap process_tags otell    
    repeat pop
;

: doOspoof ( s -- )
    strip loc @ getPlayers pop pop foreach swap pop
        over dup me @ name instr if
            "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
            "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^OOC^TAG_COLOR_2^^CLOSE_TAG^ " 
            swap strcat over swap process_tags otell
        else
            "( " swap strcat " )" strcat 
            "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes
            over "W" flag? if
                " " strcat
                over dup open_tag tag_color_2 strcat
                over me @ name tag_color_1 strcat
                over dup close_tag tag_color_2 strcat 
            then
            "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^OOC^TAG_COLOR_2^^CLOSE_TAG^ " 
            swap strcat over swap process_tags otell
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

