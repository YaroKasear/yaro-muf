@q
@edit yaro-poseorder.muf
1 999999 del
i
$include $lib/yaro
$include $cmd/status

lvar timeout

: get_order ( -- a )
    var order

    loc @ "poseorder/order" getConfig dup array? if
        dup order !
        array_vals array_make { swap foreach nip
            dup systime swap - timeout @ >= timeout @ -1 != and if pop then
        repeat
        } array_make SORTTYPE_CASE_ASCEND array_sort { swap foreach nip
            order @ swap array_findval 0 array_getitem 
            dup pmatch dup ok? over get_status nip "I" 
            stringcmp not and swap location loc @ = and 
            not if pop then
        repeat } array_make
    else
        0 array_make
    then
;

: get_turn ( -- d )
    get_order dup if
        0 array_getitem pmatch dup ok? not if pop #-1 then
    else #-1 then
;

: update_po ( -- )
    var order

    loc @ "poseorder/timeout" getConfig dup not over int? not or if pop 1800 then timeout !
    loc @ "poseorder/order" getConfig dup array? not if
        pop { }dict
    then
    order !
    loc @ "_config/poseorder/order" remove_prop
    order @ me @ name array_delitem systime swap
    me @ name array_insertitem loc @ swap "poseorder/order"
    swap setConfig 
    get_turn dup if dup "poseorder/notify" getConfig if
        "^INFO_COLOR^It is now your pose." otell
    else pop then else pop then
;

: show_order ( -- )
    "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^ " "" get_order dup if foreach nip
        ", " strcat strcat
    repeat strcat "," rsplit pop " ^TAG_COLOR_2^^CLOSE_TAG^" strcat 
    me @ "poseorder/notify" getConfig if
        get_turn me @ = if
            " ^INFO_COLOR^<-- It is currently your pose." strcat
        then
    then tell
    else
        pop pop pop "^INFO_COLOR^There is no established pose order." tell
    then
;

: remove_player ( d -- )
    var order
    
    loc @ "poseorder/order" getConfig dup array? not if
        pop { }dict
    then
    order !

    loc @ "_config/poseorder/order" remove_prop
    order @ swap name array_delitem loc @ swap "poseorder/order" swap setConfig
;

: toggle_notify ( -- )
    me @ "poseorder/notify" getConfig if
        me @ "poseorder/notify" 0 setConfig
        "^SUCCESS_COLOR^No longer being notified when it is your pose." tell
    else
        me @ "poseorder/notify" 1 setConfig
        "^SUCCESS_COLOR^Now being notified when it is your pose." tell
    then
;

: do_nuke ( -- )
    loc @ "_config/poseorder/order" remove_prop
    loc @ getPlayers pop pop foreach nip
        "^INFO_COLOR^" me @ name strcat " has nuked the pose order!" strcat otell
    repeat
;

: show_help ( -- )
    var command_name
    trigger @ name ";" split pop command_name !
    me @ command_name @ " Help" strcat 80 boxTitle
    me @ { { "^FIELD_COLOR^" command_name @ strcat 
    "^CONTENT_COLOR^Get current pose order." } array_make
    { "^FIELD_COLOR^" command_name @ strcat " #skip" strcat
    "^CONTENT_COLOR^Put yourself on the end of the pose order." } array_make
    { "^FIELD_COLOR^" command_name @ strcat " #drop" strcat
    "^CONTENT_COLOR^Take yourself out of the pose order." } array_make
    { "^FIELD_COLOR^" command_name @ strcat " #kick <PLAYER>" strcat
    "^CONTENT_COLOR^Kick PLAYER out of the pose order." } array_make
    { "^FIELD_COLOR^" command_name @ strcat " #notify" strcat
    "^CONTENT_COLOR^Toggle whether to be told when it's your pose." } array_make
    { "^FIELD_COLOR^" command_name @ strcat " #nuke" strcat
    "^CONTENT_COLOR^Completely destroy the pose order." } array_make
    loc @ me @ control? if
        { "^FIELD_COLOR^" command_name @ strcat " #set-timeout <N>" strcat
        "^CONTENT_COLOR^Set how long a player stays in pose order." 
        " -1 disables timeout. 0 resets to default." strcat } array_make
    then
    { "^FIELD_COLOR^" command_name @ strcat " #help" strcat
    "^CONTENT_COLOR^Show this box." } array_make } array_make 80 boxinfo 
    "^BOX_COLOR^" me @ 80 line strcat tell
    " " tell
;

: main ( s -- )
    strip loc @ "poseorder/timeout" getConfig dup not over int? not or if pop 1800 then timeout !
    dup "#" instr 1 = if
        dup case
            "skip" paramTest when 
                pop update_po loc @ getPlayers pop pop foreach nip
                    pop "^INFO_COLOR^" me @ name strcat me @ " has skipped %p pose." pronoun_sub
                    strcat otell
                repeat
                exit 
            end
            "drop" paramTest when " " split nip pop me @ remove_player 
                loc @ getPlayers pop pop foreach nip
                    "^INFO_COLOR^" me @ name strcat " has dropped from the pose order." strcat otell
                repeat
            exit end
            "kick" paramTest when " " split nip dup if pmatch dup if remove_player else
                pop "^ERROR_COLOR^I can't tell who you want to kick." tell
            then else
                pop "^ERROR_COLOR^Who do you want to kick?" tell
            then
            exit end
            "notify" paramTest when " " split nip pop toggle_notify exit end
            "nuke" paramTest when " " split nip pop do_nuke exit end
            "set-timeout" paramTest when
                loc @ me @ control? if
                    " " split nip dup not if 
                        loc @ "poseorder/timeout" 0 setConfig
                        "^SUCCESS_COLOR^Reset timeout to default (1800 seconds.)." tell
                    else
                        dup number? if
                            atoi dup -2 > if
                                dup case
                                    -1 = when
                                        "^SUCCESS_COLOR^Disabled timeout for this location." tell
                                    end
                                    0 = when
                                        "^SUCCESS_COLOR^Reset timeout to default (1800 seconds.)." tell
                                    end
                                    default
                                        intostr "^SUCCESS_COLOR^Set timeout to " swap strcat "." strcat tell
                                    end
                                endcase
                                loc @ swap "poseorder/timeout" swap setConfig
                            else
                                pop "^ERROR_COLOR^Invalid value for timeout time." tell
                            then
                        else
                            pop "^ERROR_COLOR^Invalid value for timeout time." tell
                        then
                    then
                else
                    "^ERROR_COLOR^You do not have authority to change timeout for this location." tell
                then
                exit
            end
            "help" paramTest when " " split nip pop show_help exit end
        endcase
    then
    pop show_order
;

public update_po
public get_turn
.
c
q
@reg yaro-poseorder=cmd/poseorder
@set yaro-poseorder=_defs/update_po:"$cmd/poseorder" match "update_po" call
@set yaro-poseorder=_defs/get_turn:"$cmd/poseorder" match "get_turn" call

