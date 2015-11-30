@q
@edit yaro-poseorder.muf
1 999999 del
i
$include $lib/yaro

var timeout

: displayPo ( -- )
    var names
    var n
    "" names !
    "" n !

    loc @ "poseorder/order" getConfig dup if
        dup array_vals array_make
        SORTTYPE_CASE_ASCEND array_sort foreach swap pop
            dup systime swap - timeout @ -1 = swap timeout @ < or if
                over swap array_findval 0 array_getitem
                dup pmatch awake? over pmatch location loc @ = and 
                over pmatch "~status" getConfig dup not if pop "???" then "status" match swap "statuses/" swap strcat getConfig dup not if pop "?" then "I" stringcmp not and if
                    " " strcat names @ swap strcat names !
                else
                    pop
                then
            else
                pop
            then
        repeat
        names @ " " swap strcat dup " " stringcmp not if
            me @ "There is no established pose order!" info_color tell
        else
            names @ dup " " instr strcut pop strip match me @ = if
                me @ "poseorder/notify" getConfig if
                    me @ " <-- " tag_color_2 me @ "It is currently your pose." note_color strcat n !
                then
            then
            me @ swap tag_color_1
            me @ open_tag me @ swap tag_color_2 swap strcat
            me @ close_tag me @ swap tag_color_2 strcat 
            n @ strcat tell pop
        then
    else
        me @ "There is no established pose order!" info_color tell
    then
;

: doSkip ( -- )
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
    loc @ getPlayers pop pop foreach swap pop
        dup me @ name " is skipping their turn." strcat info_color otell
    repeat
    dup array_vals array_make SORTTYPE_CASE_ASCEND array_sort 0 array_getitem
    array_findval 0 array_getitem dup match swap
    loc @ getPlayers pop pop over { swap match } array_make swap array_diff 
    foreach swap pop
        dup "poseorder/notify" getConfig if
            over "It is now " swap strcat "'s pose." strcat over swap info_color otell
        else pop then
    repeat pop
    dup "poseorder/notify" getConfig if
        dup "It is now your pose!" info_color otell
    else pop then
;

: rmPlayer ( d -- )
    name "_config/poseorder/order/" swap strcat loc @ swap remove_prop
;

: main ( s -- )
    loc @ "poseorder/timeout" getConfig atoi dup not if 
        pop 1800
    then
    timeout !
    dup "skip" paramTest if pop doSkip exit then
    dup "drop" paramTest if 
        pop me @ rmPlayer 
        loc @ getPlayers pop pop foreach swap pop
            dup me @ name " has dropped from the pose order!" strcat info_color otell
        repeat exit 
    then
    dup "kick" paramTest if " " split swap pop dup if
        pmatch dup player? if 
            dup rmPlayer 
            loc @ getPlayers pop pop foreach swap pop
                dup 3 pick me @ name " has kicked " strcat
                swap name strcat " out of the pose order!" strcat info_color otell
            repeat
        else
            me @ "I do not recognize who you want me to #kick." error_color tell
        then
        exit
    else
        pop me @ "Please tell me what player to #kick." error_color tell exit
    then then
    dup "notify" paramTest if
        me @ "poseorder/notify" getConfig if
            me @ "poseorder/notify" 0 setConfig
            me @ "You will no longer be notified on current pose." note_color tell
        else
            me @ "poseorder/notify" 1 setConfig
            me @ "You will now be notified on current pose." note_color tell
        then
        exit
    then
    dup "nuke" paramTest if
        loc @ "_config/poseorder/order" remove_prop
        loc @ getPlayers pop pop foreach swap pop
            dup me @ name " has dropped a bomb on the pose order and blown it to smithereens!" strcat info_color otell
        repeat
        exit
    then
    displayPo
;
.
c
q

