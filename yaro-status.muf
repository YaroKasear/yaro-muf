@q
@program yaro-status.muf
1 99999 del
i
$include $lib/yaro

: get_status_string ( d s -- )
    var status
    var ref
    toupper status !
    ref !

    "status" match "statuses" getConfig dup dictionary? if
        status @ array_getitem
    then
    dup not if
        pop ref @ "~stype" getConfig dup not if
            pop "?"
        then
    then
    case
        "I" stringcmp not when "^IC_COLOR_1^" status @ strcat end
        "O" stringcmp not when "^OOC_COLOR_1^" status @ strcat end
        "A" stringcmp not when "^OOC_COLOR_2^" status @ strcat end
        "D" stringcmp not when "^SUCCESS_COLOR^" status @ strcat end
        "F" stringcmp not when "^ERROR_COLOR^" status @ strcat end
        default pop status @ end
    endcase
;

: get_status ( d -- s s )
    var ref
    var status

    ref !

    ref @ "~status" getConfig dup if
        toupper status ! 
    else
        pop "???" status !
    then
    "status" match "statuses" getConfig dup dictionary? if
        status @ array_getitem dup not if
            pop "?"
        then
    else
        pop "?"
    then
    ref @ status @ get_status_string swap
;

: show_help
    me @ trigger @ name ";" split pop " Usage Help" strcat 80 boxTitle
    me @ me @ "status" field_color 
    me @ "Pick from a menu of statuses." content_color 80 boxInfo
    me @ me @ "status <STATUS>" field_color 
    me @ "Change to STATUS." content_color 80 boxInfo
    me @ me @ "go<STATUS>" field_color 
    me @ "Change to STATUS." content_color 80 boxInfo
    me @ me @ "status #add-ic" field_color
    me @ "W" flag? if
        me @ "Add an IC status." content_color 80 boxInfo
        me @ me @ "status #add-ooc" field_color
        me @ "Add an OOC status." content_color 80 boxInfo
        me @ me @ "status #add-away" field_color
        me @ "Add an AWAY status." content_color 80 boxInfo
        me @ me @ "status #add-onduty" field_color
        me @ "Add an ON-DUTY status." content_color 80 boxInfo
        me @ me @ "status #add-offduty" field_color
        me @ "Add an OFF-DUTY status." content_color 80 boxInfo
        me @ me @ "status #remove" field_color 
        me @ "Remove a status." content_color 80 boxInfo
        me @ me @ "status #set-custom <STATUS> [PLAYER]" field_color
        me @ "Set a custom status STATUS on yourself or PLAYER." content_color 80 boxInfo
    then
    me @ me @ "status #help" field_color
    me @ "Show this dialog." content_color 80 boxInfo
    me @ me @ 80 line box_color tell
;

: add_status ( s s -- )
    var type
    var status
    var statuses

    me @ "W" flag? not if
        me @ "You are not authorized to add statuses." error_color tell
        exit
    then
    dup if
        trigger @ "statuses" getConfig dup dictionary? not if
            pop { }dict
        then
        statuses !
        type !
        dup if 
            toupper status !
            statuses @ status @ array_getitem if
                "^ERROR_COLOR^That status already exists." tell exit
            then
            status @ tolower ";go" swap strcat dup
            trigger @ swap trigger @ name swap "" swap subst rot strcat setname
            trigger @ "_config/statuses" remove_prop
            trigger @ "statuses" type @ statuses @ status @ array_insertitem setConfig
            "^SUCCESS_COLOR^Added the status " me @ status @ get_status_string strcat "^SUCCESS_COLOR^ successfully!" 
            strcat tell
        else
            pop "^ERROR_COLOR^I need a status to add!" tell
        then
    else
        pop "^ERROR_COLOR^There is no type for this status! This should not happen! Tell " prog owner name strcat "!" strcat tell
    then
;

: remove_status ( s -- )
    var status
    var status_string
    var statuses

    toupper status !
    
    trigger @ "statuses" getConfig dup dictionary? not if
        pop "^ERROR_COLOR^No such status exists." tell exit 
    then
    dup status @ array_getitem not if
        pop "^ERROR_COLOR^No such status exists." tell exit
    then
    status @ array_delitem statuses !
    me @ status @ get_status_string status_string !
    trigger @ "_config/statuses/" remove_prop
    
    trigger @ "statuses" statuses @ setConfig
    trigger @ trigger @ name status @ tolower ";go" swap strcat "" swap subst setname
    "^SUCCESS_COLOR^Removed the status " status_string @ strcat "." strcat tell
;

: set_status ( s -- )
    var status
    var type

    toupper status !
    trigger @ "statuses" getConfig dup dictionary? not if
        pop "^ERROR_COLOR^I do not know the status " status @ strcat "." strcat tell exit
    then
    status @ array_getitem dup not if
        pop "^ERROR_COLOR^I do not know the status " status @ strcat "." strcat tell exit
    then
    type !
    type @ "D" stringcmp not type @ "F" stringcmp not or if
        me @ "W" flag? not if
            "^ERROR_COLOR^You are not authorized to use the " 
            me @ status @ get_status_string strcat "^ERROR_COLOR^ status." strcat
            tell exit
        then
    then
    me @ "~status" status @ setConfig
    me @ "~stype" type @ setConfig
    "^NOTE_COLOR^" me @ name strcat " has gone " strcat me @ status @ get_status_string strcat 
    "^NOTE_COLOR^!" strcat 
    loc @ getPlayers pop pop foreach swap pop
        over otell
    repeat
;

: status_menu
    var statuses
    var list

    trigger @ "statuses" getConfig dup dictionary? not if
        pop "^ERROR_COLOR^I do not have any statuses configured." tell exit
    then statuses !
    me @ "Select Status"
    statuses @ array_keys array_make dup list ! { swap foreach 
        swap 1 + swap me @ swap get_status_string me @ swap process_tags 
    repeat } 
    2 / 1 + "Cancel" over 50 doMenu
    1 - list @ swap array_getitem dup if
        set_status
    else
        pop "^NOTE_COLOR^Canceled status selection." tell
    then
;

: set_custom ( d s -- )
    var status
    var ref

    me @ "W" flag? not if
        "^ERROR_COLOR^You are not authorized to set custom statuses." tell exit
    then
    dup if 
        toupper status !
        dup ok? over player? and if
            ref !
        else
            pop "^ERROR_COLOR^I do not know that player." tell
        then
    else
        "^ERROR_COLOR^I need a status to set!" tell
    then
    me @ "Select Status Type"
    1 "IC"
    2 "OOC"
    3 "AWAY"
    4 "ON-DUTY"
    5 "OFF-DUTY"
    6 "Cancel"
    6 50 doMenu case
        1 = when ref @ "~stype" "I" setConfig end
        2 = when ref @ "~stype" "O" setConfig end
        3 = when ref @ "~stype" "A" setConfig end
        4 = when ref @ "W" flag? if 
                ref @ "~stype" "D" setConfig 
            else
                me @ ref @ name " is not a wizard." strcat error_color tell exit
            then
        end
        5 = when ref @ "W" flag? if 
                ref @ "~stype" "F" setConfig 
            else
                me @ ref @ name " is not a wizard." strcat error_color tell exit
            then end
        6 = when exit end
    endcase
    ref @ "~status" status @ setConfig
    "^SUCCESS_COLOR^You set " ref @ name strcat "'s status to " strcat
    ref @ status @ get_status_string strcat "." strcat tell
    me @ ref @ = not if
        ref @ "^NOTE_COLOR^" me @ name strcat " has set your status to " strcat 
        ref @ status @ get_status_string strcat "^NOTE_COLOR^!" strcat otell
    then
;

: main ( s -- )
    strip tolower dup
    case
        "add-ic" paramTest when
            "#add-ic" split swap pop strip
            "I" add_status
        end
        "add-ooc" paramTest when
            "#add-ooc" split swap pop strip
            "O" add_status
        end
        "add-away" paramTest when
            "#add-away" split swap pop strip
            "A" add_status
        end
        "add-onduty" paramTest when
            "#add-onduty" split swap pop strip
            "D" add_status
        end
        "add-offduty" paramTest when
            "#add-offduty" split swap pop strip
            "F" add_status
        end
        "remove" paramTest when
            "#remove" split swap pop strip
            remove_status
        end
        "set-custom" paramTest when
            "#set-custom" split swap pop strip
            " " split " " split pop dup not if
                pop me @ name
            then
            pmatch swap
            set_custom
        end
        "idle" stringcmp not when
            command @ match "idle_status" getConfig dup if
                me @ "idle/~status" me @ get_status pop setConfig
                me @ "idle/~stype" me @ get_status swap pop setConfig
                set_status
            else pop then
        end
        "unidle" stringcmp not when
            command @ match "idle_status" getConfig dup if
                me @ "idle/~status" getConfig
                me @ swap "~status" swap setConfig
                me @ "idle/~stype" getConfig
                me @ swap "~stype" swap setConfig
                me @ "idle/~status" 0 setConfig
                me @ "idle/~stype" 0 setConfig
                "^NOTE_COLOR^" me @ name strcat " has gone " strcat me @ get_status pop strcat 
                "^NOTE_COLOR^!" strcat 
                loc @ getPlayers pop pop foreach swap pop
                    over otell
                repeat
            else pop then
        end
        "help" paramTest when show_help exit end
        command @ "go" instr 1 = when
            command @ "go" split swap pop strip set_status
        end
        command @ "status" stringcmp not when
            dup if
                set_status
            else
                status_menu
            then
        end
        default show_help exit end
    endcase
;

public get_status
.
c
q
@reg yaro-status=cmd/status
@set yaro-status=_defs/get_status:"$cmd/status" match "get_status" call

