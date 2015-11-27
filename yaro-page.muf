@program yaro-page.muf
1 9999999 del
i
$include $lib/yaro
$include $lib/jmail
 
: doPage ( s s -- )
    var asleepNames
    var invalidNames
    var validNames
    var asleepList
    var invalidList
    var validList

    { } array_make
    dup asleepNames !
    dup invalidNames !
    validNames !

    "" 
    dup asleepList !
    dup invalidList !
    validList !

    swap getPlayers dup if 
        dup array_count 1 = if
            0 array_getitem name
            me @ swap " is currently asleep. Please use " command @ strcat " #mail to leave them a message." 
            strcat strcat info_color tell
        else
            foreach swap pop
                name asleepNames @ swap array_append asleepNames !
            repeat
            asleepNames @ foreach
                swap 0 = if
                    "and " swap strcat 
                    asleepList @ swap strcat asleepList !
                else
                    ", " strcat
                    asleepList @ strcat asleepList !
                then
            repeat
            asleepList @ " are currently asleep. Please use " command @ strcat " #mail to leave them a message."
            strcat strcat me @ swap info_color tell
        then
    else
        pop
    then
    dup if
        dup array_count 1 = if
            0 array_getitem
            me @ swap " is not a valid player." strcat error_color tell
        else
            foreach swap pop
                invalidNames @ swap array_append invalidNames !
            repeat
            invalidNames @ foreach
                swap 0 = if
                    "and " swap strcat 
                    invalidList @ swap strcat invalidList !
                else
                    ", " strcat
                    invalidList @ strcat invalidList !
                then
            repeat
            invalidList @ " are not valid players!" strcat me @ swap error_color tell
        then
    else
        pop
    then
    dup if
        dup dup array_count 1 = if
            0 array_getitem
            me @ swap name "\" to " swap strcat ooc_color_1 
            3 pick dup ":" instr 1 = if
                ":" split swap pop
                me @ "You page-pose, \"" ooc_color_1
                swap me @ name " " strcat swap strcat me @ swap ooc_color_2 strcat
                swap strcat tell
                0 array_getitem swap
                ":" split swap pop
                "In a page-pose to you, " me @ name strcat " " strcat swap strcat
                over swap ooc_color_1 over swap otell 
                1 array_make 
            else
                me @ swap ooc_color_2 swap strcat 
                me @ "You page, \"" ooc_color_1 swap strcat tell
                0 array_getitem dup 
                me @ name " pages, \"" strcat ooc_color_1
                rot 3 pick swap ooc_color_2 strcat
                over "\" to you." ooc_color_1 strcat over swap otell 
                1 array_make
            then
        else
            foreach swap pop
                name validNames @ swap array_append validNames !
            repeat
            over dup ":" instr 1 = if
                ":" split swap pop
                validNames @ foreach
                    swap 0 = if
                        "and " swap strcat 
                        validList @ swap strcat validList !
                    else
                        ", " strcat
                        validList @ strcat validList !
                    then
                repeat
                me @ "You page-pose, \"" ooc_color_1
                swap me @ swap me @ name " " strcat swap strcat ooc_color_2 strcat
                me @ "\" to " validList @ strcat ooc_color_1 strcat
                tell

                over ":" split swap pop over foreach swap pop
                    { } array_make
                    validNames !
    
                    "" 
                    validList !

                    3 pick foreach swap pop
                        over over = if
                            pop "you"
                        else
                            name
                        then
                        validNames @ swap array_append validNames !
                    repeat
                    validNames @ foreach
                        swap 0 = if
                            "and " swap strcat 
                            validList @ swap strcat validList !
                        else
                            ", " strcat
                            validList @ strcat validList !
                        then
                    repeat
                    dup "In a page-pose to " validList @ strcat ", " strcat 
                    me @ name strcat " " strcat
                    4 pick strcat ooc_color_1 otell
                repeat
            else
                validNames @ foreach
                    swap 0 = if
                        "and " swap strcat 
                        validList @ swap strcat validList !
                    else
                        ", " strcat
                        validList @ strcat validList !
                    then
                repeat
                me @ "You page, \"" ooc_color_1
                swap me @ swap ooc_color_2 strcat
                me @ "\" to " validList @ strcat ooc_color_1 strcat
                tell

                over over foreach swap pop
                    { } array_make
                    validNames !
    
                    "" 
                    validList !

                    3 pick foreach swap pop
                        over over = if
                            pop "you"
                        else
                            name
                        then
                        validNames @ swap array_append validNames !
                    repeat
                    validNames @ foreach
                        swap 0 = if
                            "and " swap strcat 
                            validList @ swap strcat validList !
                        else
                            ", " strcat
                            validList @ strcat validList !
                        then
                    repeat
                    dup me @ name " pages, \"" strcat ooc_color_1
                    3 pick 3 pick swap ooc_color_2 strcat
                    over validList @ "\" to " swap strcat "." strcat ooc_color_1
                    strcat otell
                repeat
                pop swap pop
            then
        then
        me @ swap "page/last-paged" swap setConfig
    else
        pop
    then
;

: doMail ( s s -- )
    var invalidNames
    var validNames
    var invalidList
    var validList
    var myName

    me @ myName !

    { } array_make
    dup invalidNames !
    validNames !

    "" 
    dup invalidList !
    validList !

    swap getPlayers
    swap dup if
        dup array_count 1 = if
            0 array_getitem
            me @ swap " is not a valid player." strcat error_color tell
        else
            foreach swap pop
                invalidNames @ swap array_append invalidNames !
            repeat
            invalidNames @ foreach
                swap 0 = if
                    "and " swap strcat 
                    invalidList @ swap strcat invalidList !
                else
                    ", " strcat
                    invalidList @ strcat invalidList !
                then
            repeat
            invalidList @ " are not valid players!" strcat me @ swap error_color tell
        then
    else
        pop
    then 
    array_union dup if
        dup array_count 1 = if
            0 array_getitem
            me @ over name "\" to " swap strcat ooc_color_1 
            me @ "You page-mail, \"" ooc_color_1 
            4 pick me @ swap ooc_color_2 strcat swap strcat tell 
            swap "You have a page-mail from " me @ name strcat "!" strcat 
            swap jmail-player
        else
            dup foreach swap pop
                name validNames @ swap array_append validNames !
            repeat   
            validNames @ foreach
                swap 0 = if
                    "and " swap strcat 
                    validList @ swap strcat validList !
                else
                    ", " strcat
                    validList @ strcat validList !
                then
            repeat
            me @ "You page-mail, \"" ooc_color_1 
            3 pick me @ swap ooc_color_2 strcat
            me @ "\" to " validList @ strcat ooc_color_1 strcat tell
            me @ "temp/mail-list" rot setConfig
            me @ "_config/temp/mail-list" "You have a page-mail from " me @ name strcat "!" strcat
            4 rotate jmail-list
        then
    else
        pop
    then
;
 
: doUsage ( -- )
    me @ "Usage: " info_color me @ command @ "[#mail] [RECIPIENT]=[:]<MESSAGE>" 
    strcat note_color strcat tell
;
 
: main ( s -- )
    strip
    dup if
        dup "mail" paramTest if
            " " split swap pop dup if
                dup "=" instr if
                    "=" split doMail exit
                else
                    doUsage exit
                then
            else
                doUsage exit
            then
        then
        dup "=" instr if
            dup "=" instr 1 = if
                me @ "last-paged" getConfig dup if 
                    swap "=" split swap pop doPage
                else
                    pop me @ "Page who?" error_color tell exit
                then
            else
                "=" split doPage
            then
        else
            doUsage
        then
    else
        doUsage
    then
;
.
c
q

