@
@program yaro-status.muf
1 99999 del
i
$include $lib/yaro

: doAdd ( a -- )
    var newStatuses

    { } array_make newStatuses !

    foreach swap pop
        dup "statuses/" swap strcat
        command @ tolower match swap getConfig if
        else
            newStatuses @ swap array_append newStatuses !
        then
    repeat
    newStatuses @ foreach swap pop
        dup command @ tolower match swap "statuses/" swap strcat "P" setConfig
        command @ tolower match name over ";go" swap strcat split strcat 
        over ";go" swap strcat strcat command @ tolower match swap setname
        me @ swap "Successfully added new status " swap toupper strcat "!" strcat
        success_color tell
    repeat
;

: doAddSpecial ( a -- )
    var newStatuses

    { } array_make newStatuses !

    foreach swap pop
        dup "statuses/" swap strcat
        command @ tolower match swap getConfig if
        else
            newStatuses @ swap array_append newStatuses !
        then
    repeat
    newStatuses @ foreach swap pop
        dup command @ tolower match swap "statuses/" swap strcat "W" setConfig
        command @ tolower match name over ";go" swap strcat split strcat 
        over ";go" swap strcat strcat command @ tolower match swap setname
        me @ swap "Successfully added new special status " swap toupper strcat "!" strcat
        success_color tell
    repeat
;

: doAddIC ( a -- )
    var newStatuses

    { } array_make newStatuses !

    foreach swap pop
        dup "statuses/" swap strcat
        command @ tolower match swap getConfig if
        else
            newStatuses @ swap array_append newStatuses !
        then
    repeat
    newStatuses @ foreach swap pop
        dup command @ tolower match swap "statuses/" swap strcat "I" setConfig
        command @ tolower match name over ";go" swap strcat split strcat 
        over ";go" swap strcat strcat command @ tolower match swap setname
        me @ swap "Successfully added new special status " swap toupper strcat "!" strcat
        success_color tell
    repeat
;

: doRemove ( a -- )
    foreach swap pop
        dup "_config/statuses/" swap strcat
        command @ tolower match swap remove_prop
        command @ tolower match name over ";go" swap strcat split strcat 
        command @ tolower match swap setname
    repeat
    me @ swap "Successfully removed status " swap toupper strcat "!" strcat
    success_color tell
;

: setStatus ( s -- )
    dup command @ tolower match "statuses" getConfig dup if
        swap array_getitem dup if
            dup "P" stringcmp not over "I" stringcmp not or swap "W" stringcmp not me @ "W" flag? and or if
                dup me @ swap "status" swap setConfig
                toupper dup "You have gone " swap strcat "!" strcat me @ swap success_color tell
                loc @ getPlayers pop pop me @ 1 array_make swap array_diff 
                foreach swap pop
                    dup me @ name " has gone " strcat 4 pick strcat "!" strcat info_color otell
                repeat pop
            else
                me @ "You are not allowed to go " rot toupper strcat "!" strcat error_color tell
            then
        else
            pop me @ "I do not know the \"" rot toupper strcat "\" status!" strcat error_color tell
        then
    else
        me @ "I do not have any statuses configured!" error_color tell
    then
;

: main ( s -- )
    tolower
    dup "add-status" paramTest if
        me @ "W" flag? if
            " " explode swap pop 1 - array_make doAdd
        else
            me @ "You are not authorized to add statuses!" error_color tell
        then
        exit
    then
    dup "add-special" paramTest if
        me @ "W" flag? if
            " " explode swap pop 1 - array_make doAddSpecial
        else
            me @ "You are not authorized to add special statuses!" error_color tell
        then
        exit
    then
    dup "add-ic" paramTest if
        me @ "W" flag? if
            " " explode swap pop 1 - array_make doAddIC
        else
            me @ "You are not authorized to add in-character statuses!" error_color tell
        then
        exit
    then
    dup "remove" paramTest if
        me @ "W" flag? if
            " " explode swap pop 1 - array_make doRemove
        else
            me @ "You are not authorized to remove statuses!" error_color tell
        then
        exit
    then
    command @ tolower "status" stringcmp not if
        " " split pop dup if 
            setStatus exit
        else
            command @ tolower match "statuses" getConfig dup if
                var statlist
                { } array_make statlist !

                foreach 
                    dup "P" stringcmp not over "I" stringcmp not or swap "W" stringcmp not me @ "W" flag? and or if
                        toupper statlist @ swap array_append statlist !
                    else pop then
                repeat
                statlist @ me @ "SELECT STATUS" statlist @ foreach
                    swap 1 + swap
                repeat 
                over 1 + 999 swap "Cancel" swap
                0 doMenu dup 999 = if exit then
                1 - array_getitem tolower setStatus exit
            else
                pop me @ "I do not have any statuses configured!" error_color tell
            then
        then
    then
    command @ tolower "go" split swap pop dup if setStatus then
;
.
c
q

