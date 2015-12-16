@q
@program yaro-chat
1 999999 d
i
$include $lib/yaro

: get_channel_name ( s -- s )
    trigger @ name swap instr dup if
        1 - trigger @ name swap strcut swap pop 
        ";" split pop    
    else pop "" then
;

: get_channel_alias ( s -- s )
    var channel_name

    get_channel_name channel_name !
    command @ match channel_name @ "/alias" strcat getConfig dup not if
        pop channel_name @
    then
;

: get_nickname ( d s - s )
    var channel_name 
    
    get_channel_name channel_name !
    dup channel_name @ "/nick" strcat getConfig dup if
        swap pop
    else
        pop name
    then
;

: on_channel? ( d s -- n )
    var channel_name
    var ref

    get_channel_name channel_name !
    ref !
    command @ match channel_name @ "/members" strcat getConfig dup array? if
        ref @ array_findval if
            1
        else
            0
        then
    else
        pop 0
    then
;

: is_gagged? ( d d s -- n )
    var channel_name
    var gagger_ref
    var gaggee_ref

    get_channel_name channel_name !
    gagger_ref !
    gaggee_ref !

    gagger_ref @ channel_name @ "/gagged" strcat getConfig dup array? if
        gaggee_ref @ array_findval if
            1
        else
            0
        then
    else
        pop 0
    then
;

: is_banned? ( d s -- n )
    var channel_name
    var ref

    get_channel_name channel_name !
    ref !
    command @ match channel_name @ "/banlist" strcat getConfig dup array? if
        ref @ array_findval if
            1
        else
            0
        then
    else
        pop 0
    then
;

: command_match ( s - )
    var channel_list

    command @ match "channels" getConfig channel_list !
    channel_list @ command @ get_channel_name array_findval if
        command @ get_channel_name command !
    else
        channel_list @ foreach swap pop
            dup command @ match swap "/commands" strcat getConfig dup array? if
                command @ array_findval if
                    command ! exit
                else pop then
            else pop pop then
        repeat
    then
;
 
: createChannel ( s -- )
    var chan_list
    var break_string
    me @ "W" flag? if
        dup
        { } array_make chan_list !
        "" break_string !
    
        dup if
            command @ match "channels" getConfig dup array? if
                dup chan_list !
                over over swap array_findval 
                3 pick trigger @ name swap instr or
                if 
                    pop pop pop me @ "That channel already exists!" error_color tell exit
                else pop then
            else pop then
            chan_list @ over array_append command @ match swap "channels" swap setConfig
            begin dup while
                break_string @ ";" strcat over strcat break_string !
                dup strlen 1 - strcut pop
            repeat pop
            trigger @ trigger @ name break_string @ strcat setname
            "Channel " swap strcat " has been created." strcat me @ swap success_color tell
        else
            pop me @ "I need a channel name to create." error_color tell
        then
    else
        pop me @ "You are not authorized to create channels!" error_color tell
    then
;
 
: deleteChannel ( s -- )
    var chan_list
    var break_string
    var channel_name

    me @ "W" flag? if
        dup if
            { } array_make chan_list !
            get_channel_name dup if channel_name ! else pop me @ "That channel does not exist." error_color tell exit then
            "" break_string !
            channel_name @
            begin dup while
                    break_string @ ";" strcat over strcat break_string !
                    dup strlen 1 - strcut pop
            repeat pop
            command @ match "channels" getConfig dup array? if
                chan_list ! chan_list @ channel_name @ array_findval if
                    trigger @ trigger @ name "" break_string @ subst setname
                    trigger @ "_config/channels#" remove_prop
                    chan_list @ chan_list @ channel_name @ array_findval 0 array_getitem
                    array_delitem command @ match swap "channels" swap setConfig
                    command @ match "_config/" channel_name @ strcat remove_prop
                    me @ "Channel " channel_name @ strcat " has been deleted." strcat success_color tell
                else
                    me @ "That channel does not exist." error_color tell
                then
            else
                pop me @ "That channel does not exist." error_color tell
            then
        else
            pop me @ "I need the name of a channel to delete." error_color tell
        then
    else
        pop me @ "You are not authorized to delete channels!" error_color tell
    then
;
 
 
: who ( -- )
    var channel_name
    var listeners

    command @ get_channel_name channel_name !
    me @ "Listeners on " channel_name @ get_channel_alias strcat 50 boxTitle
    command @ match channel_name @ "/members" strcat getConfig
    dup array? if
        listeners ! 
        me @ { listeners @ foreach swap pop
            dup awake? if
                dup name me @ swap content_color
                swap channel_name @ "/nick" strcat getConfig dup if
                    me @ swap tag_color_1
                    " " me @ me @ open_tag tag_color_2 strcat swap strcat 
                    me @ me @ close_tag tag_color_2 strcat strcat
                else pop then
            else pop then
        repeat } array_make 50 boxList
    else
        pop me @ "There are no listeners on " channel_name @ get_channel_alias strcat "." strcat 50 boxContent
    then
    me @ me @ 50 line box_color tell
;

: channel_decorate ( d s s -- s )
    var ref
    var channel_name
    var message

    var tc1
    var tc2
    var o1
    var o2
    var ot
    var ct

    message !
    channel_name !
    ref !

    ref @ channel_name @ "/color/tag1" strcat getConfig tc1 !
    ref @ channel_name @ "/color/tag2" strcat getConfig tc2 !
    ref @ channel_name @ "/color/ooc1" strcat getConfig o1 ! 
    ref @ channel_name @ "/color/ooc2" strcat getConfig o2 ! 
    ref @ channel_name @ "/open_tag" strcat getConfig ot ! 
    ref @ channel_name @ "/close_tag" strcat getConfig ct ! 

    tc1 @ not if ref @ "" tag_color_1 tc1 ! then
    tc2 @ not if ref @ "" tag_color_2 tc2 ! then
    o1 @ not if ref @ "" ooc_color_1 o1 ! then
    o2 @ not if ref @ "" ooc_color_2 o2 ! then
    ot @ not if ref @ open_tag ot ! then
    ct @ not if ref @ close_tag ct ! then

    channel_name @ get_channel_alias toupper tc1 @ swap strcat
    ot @ tc2 @ swap strcat " " strcat swap strcat
    "^RESET^ " ct @ tc2 @ swap strcat strcat strcat
    ref @ message @ o1 @ "^REPLACE_ME^" subst 
    o1 @ o2 @ color_quotes process_tags " " swap strcat strcat
;

: alert_members ( s s -- )
    var message
    var channel_name

    message !
    channel_name !
    command @ match channel_name @ "/members" strcat 
    getConfig foreach swap pop
        dup me @ channel_name @ is_gagged? over me @ swap channel_name @ is_gagged? or not if
            dup channel_name @ "/alert" strcat getConfig if
                dup channel_name @ message @ channel_decorate otell
            else pop then
        else pop then
    repeat
;
 
: doSay ( s -- )
    var channel_name
    var message

    strip message !
    command @ get_channel_name channel_name !
    me @ channel_name @ on_channel? if
        "You " me @ say strcat ", \"" strcat message @ strcat "\"" strcat 
        me @ swap channel_name @ swap channel_decorate tell
        command @ match channel_name @ "/members" strcat getConfig foreach swap pop
            dup me @ = if pop
            else
                dup me @ channel_name @ is_gagged? over me @ swap channel_name @ is_gagged? or not if
                    dup me @ channel_name @ get_nickname "^REPLACE_ME^" strcat " " strcat 
                    me @ says strcat ", \"" strcat message @ strcat "\"" strcat
                    channel_name @ swap channel_decorate otell
                else pop then
            then
        repeat 
    else
        me @ "You are not on " channel_name @ get_channel_alias strcat "!" strcat
        error_color tell
    then
;
 
: doPose ( s -- )    
    var channel_name
    var message

    strip message !
    command @ get_channel_name channel_name !
    me @ channel_name @ on_channel? if
        command @ match channel_name @ "/members" strcat getConfig foreach swap pop
            dup me @ channel_name @ is_gagged? over me @ swap channel_name @ is_gagged? or not if
                dup me @ channel_name @ get_nickname "^REPLACE_ME^" strcat 
                message @ case
                    ":" instr 1 = when "" end
                    "," instr 1 = when "" end
                    default pop " " end
                endcase
                strcat message @ strcat channel_name @ swap channel_decorate otell
            else pop then
        repeat 
    else
        me @ "You are not on " channel_name @ get_channel_alias strcat "!" strcat
        error_color tell
    then
;
 
: onChannel ( -- )
    var channel_name
    var listeners

    { } array_make listeners !
    command @ get_channel_name channel_name !
    command @ match channel_name @ "/restricted" strcat getConfig not me @ "W" flag? or if
        me @ channel_name @ is_banned? not if
            command @ match channel_name @ "/members" strcat getConfig dup array? if
                listeners ! listeners @ me @ array_findval if
                    me @ "You are already on this channel." error_color tell
                    exit
                then
            else
                pop
            then
            listeners @ me @ array_append listeners !
            command @ match channel_name @ "/members" strcat listeners @ setConfig
            channel_name @ me @ name " has joined " channel_name @ get_channel_alias strcat "." strcat strcat
            alert_members
            me @ "You have joined " channel_name @ get_channel_alias strcat " successfully." strcat success_color tell
        else
            me @ "You have been banned from " channel_name @ get_channel_alias strcat " and therefore cannot join it." strcat
            error_color tell
        then
    else
        me @ "You are not authorized to join " channel_name @ get_channel_alias strcat "!" strcat error_color tell
    then
;
 
: offChannel ( -- )
    var channel_name
    var listeners

    { } array_make listeners !
    command @ get_channel_name channel_name !
    command @ match channel_name @ "/members" strcat getConfig dup array? if
        listeners ! listeners @ me @ array_findval dup if
            channel_name @ me @ name " has left " strcat channel_name @ get_channel_alias strcat "." strcat
            alert_members
            0 array_getitem listeners @ swap array_delitem listeners !
            trigger @ "_config/" channel_name @ strcat "/members#" strcat remove_prop
            command @ match channel_name @ "/members" strcat listeners @ setConfig
            me @ "You have left " channel_name @ get_channel_alias strcat " successfully." strcat success_color tell
        else
            me @ "You are not on this channel!" error_color tell
        then
    else
        me @ "You are not on this channel!" error_color tell
    then
;
 
: doAlias ( s -- )
    var channel_name

    me @ "W" flag? if
        command @ get_channel_name channel_name !
        dup if
            command @ match swap channel_name @ "/alias" strcat swap setConfig
            me @ "You have given " channel_name @ strcat 
            " the alias " strcat channel_name @ get_channel_alias strcat "!" strcat
            success_color tell
        else
            command @ match channel_name @ "/alias" strcat 0 setConfig
            me @ "Alias for channel " channel_name @ strcat " cleared." strcat success_color tell
        then
    else
        me @ "You are not authorized to alias channels." error_color tell
    then
;
 
: doNick ( s -- )
    var channel_name

    command @ get_channel_name channel_name !
    dup if
        dup me @ swap channel_name @ "/nick" strcat swap setConfig
        me @ swap "Nickname for " channel_name @ strcat " set to " strcat
        swap strcat "." strcat success_color tell
    else
        pop me @ channel_name @ "/nick" strcat 0 setConfig
        me @ "Cleared nickname for " channel_name @ strcat "." strcat success_color tell
    then
;
 
: doRestrict ( -- )
    var channel_name
    var listeners

    { } array_make listeners !
    command @ get_channel_name channel_name !
    command @ match channel_name @ "/restricted" strcat getConfig if
        command @ match channel_name @ "/restricted" strcat 0 setConfig
        me @ "The channel " channel_name @ strcat " has been unrestricted. All players may join." strcat success_color tell
    else
        command @ match channel_name @ "/restricted" strcat 1 setConfig
        me @ "The channel " channel_name @ strcat " has been restricted. Only wizards may join." strcat success_color tell
    then
;
 
: gag ( s -- )
    var channel_name

    command @ get_channel_name channel_name !
    dup if
        pmatch dup ok? over player? and if
            me @ channel_name @ on_channel? if
                dup me @ = not if
                    dup channel_name @ on_channel? if
                        dup me @ channel_name @ is_gagged? if
                            me @ channel_name @ "/gagged" strcat getConfig over over swap array_findval
                            0 array_getitem array_delitem
                            me @ "_config/" channel_name @ strcat "/gagged#" strcat remove_prop
                            me @ swap channel_name @ "/gagged" strcat swap setConfig
                            "You are no longer gagging " swap name strcat " on " channel_name @ get_channel_alias strcat
                            "." strcat strcat me @ swap success_color tell
                        else
                            me @ channel_name @ "/gagged" strcat getConfig dup array? not if
                                pop { } array_make
                            then
                            over array_append me @ swap channel_name @ "/gagged" strcat swap
                            setConfig
                            "You have gagged " swap name strcat " on " channel_name @ get_channel_alias strcat
                            "." strcat strcat me @ swap success_color tell
                        then
                    else
                        name " is is not on this channel!" strcat me @ swap
                        error_color tell
                    then
                else
                    me @ "You cannot gag yourself." error_color tell
                then
            else
                me @ "You are not on " channel_name @ get_channel_alias strcat "!" strcat
                error_color tell
            then
        else
            pop me @ "I do not recognize this user." error_color tell
        then
    else
        pop me @ "Who do you want to gag on " channel_name @ get_channel_alias "?" strcat strcat
        error_color tell
    then
;

: kick ( s -- )
    var channel_name
    var listeners

    command @ get_channel_name channel_name !
    me @ "W" flag? if
        dup if
            pmatch dup ok? over player? and if
                dup channel_name @ on_channel? if
                    dup "W" flag? not if
                        command @ match channel_name @ "/members" strcat getConfig listeners !
                        command @ match "_config/" channel_name @ strcat "/members#" strcat remove_prop
                        listeners @ over over swap array_findval 0 array_getitem array_delitem
                        command @ match swap channel_name @ "/members" strcat swap setConfig
                        dup dup "You have been kicked off of " channel_name @ get_channel_alias strcat "." strcat
                        info_color otell
                        command @ match channel_name @ "/members" strcat getConfig foreach swap pop
                            dup "W" flag? if
                                over me @ name " has kicked " strcat swap name strcat " from " strcat
                                channel_name @ get_channel_alias strcat over swap info_color otell
                            else pop then
                        repeat
                    else
                        me @ "You cannot kick wizards off of " channel_name @ get_channel_alias strcat "." strcat 
                        error_color tell
                    then
                else
                    me @ "That user is not on " channel_name @ get_channel_alias strcat "." strcat
                    error_color tell
                then
            else
                me @ "I don't know who that is." error_color tell
            then
        else
            me @ "Who are you kicking off " channel_name @ get_channel_alias strcat "?" strcat
            error_color tell
        then
    else
        me @ "You are not authorized to kick users off of " channel_name @ get_channel_alias strcat "." strcat
        error_color tell
    then
;

: ban ( s -- )
    var channel_name
    var listeners
    var banlist

    command @ get_channel_name channel_name !
    me @ "W" flag? if
        dup if
            pmatch dup ok? over player? and if
                dup channel_name @ is_banned? not if
                    dup channel_name @ on_channel? if
                        dup "W" flag? not if
                            command @ match channel_name @ "/members" strcat getConfig listeners !
                            command @ match "_config/" channel_name @ strcat "/members#" strcat remove_prop
                            listeners @ over over swap array_findval 0 array_getitem array_delitem
                            command @ match swap channel_name @ "/members" strcat swap setConfig
                            command @ match channel_name @ "/banlist" strcat getConfig dup array? not if
                                pop { } array_make
                            then
                            over array_append command @ match swap channel_name @ "/banlist" strcat swap setConfig
                            dup dup "You have been kicked off of " channel_name @ get_channel_alias strcat " and banned." strcat
                            info_color otell
                            command @ match channel_name @ "/members" strcat getConfig foreach swap pop
                                dup "W" flag? if
                                    over me @ name " has kicked and banned " strcat swap name strcat " from " strcat
                                    channel_name @ get_channel_alias strcat over swap info_color otell
                                else pop then
                            repeat
                        else
                            me @ "You cannot ban wizards from " channel_name @ get_channel_alias strcat "." strcat 
                            error_color tell
                        then
                    else
                        me @ "That user is not on " channel_name @ get_channel_alias strcat "." strcat
                        error_color tell
                    then
                else
                    command @ match channel_name @ "/banlist" strcat getConfig banlist ! banlist @
                    command @ match "_config/" channel_name @ strcat "/banlist" strcat remove_prop
                    over over swap array_findval 0 array_getitem array_delitem
                    command @ match swap channel_name @ "/banlist" strcat swap setConfig
                    dup dup "The ban placed on you for " channel_name @ get_channel_alias strcat " has been lifted." strcat
                    info_color otell
                    command @ match channel_name @ "/members" strcat getConfig foreach swap pop
                        dup "W" flag? if
                            over me @ name " has lifted the ban off " strcat swap name strcat " for " strcat
                            channel_name @ get_channel_alias strcat "." strcat over swap info_color otell
                        else pop then
                    repeat
                then
            else
                me @ "I don't know who that is." error_color tell
            then
        else
            me @ "Who are you banning " channel_name @ get_channel_alias strcat "?" strcat
            error_color tell
        then
    else
        me @ "You are not authorized to ban users from " channel_name @ get_channel_alias strcat "." strcat
        error_color tell
    then
;

: show_help
    me @ command @ get_channel_name get_channel_alias " Command Help" strcat 80 boxTitle
    me @ "W" flag? command @ match command @ get_channel_name "/restricted" strcat getConfig not or if
        me @ "W" flag? if
            me @ me @ command @ " #create <NAME>" strcat field_color 
            me @ "Create a new channel <NAME>" content_color 80 boxInfo
            me @ me @ command @ " #delete <NAME>" strcat field_color 
            me @ "Delete channel <NAME>" content_color 80 boxInfo
            me @ me @ command @ " #restrict" strcat field_color 
            me @ "Toggle if " command @ strcat " is accessible only to wizards" strcat content_color 80 boxInfo
            me @ me @ command @ " #alias" strcat field_color 
            me @ "Set an alias for " command @ strcat ". Leave alias out to clear." strcat content_color 80 boxInfo
            me @ me @ command @ " #kick" strcat field_color 
            me @ "Throw a user out of " command @ strcat "." strcat content_color 80 boxInfo
            me @ me @ command @ " #ban" strcat field_color 
            me @ "Toggle a user ban on " command @ strcat "." strcat content_color 80 boxInfo
            me @ me @ command @ " #add-command <COMMAND>" strcat field_color 
            me @ "Add a new command to use " command @ strcat "." strcat content_color 80 boxInfo
        then
        me @ me @ command @ " #on" strcat field_color 
        me @ "Join the " command @ strcat " channel" strcat content_color 80 boxInfo
        me @ me @ command @ " #off" strcat field_color 
        me @ "Leave the " command @ strcat " channel" strcat content_color 80 boxInfo
        me @ me @ command @ " #who" strcat field_color 
        me @ "Get a list of users listening on " command @ strcat content_color 80 boxInfo
        me @ me @ command @ " #nick" strcat field_color 
        me @ "Give yourself a nickname on " command @ strcat ". Leave nickname blank to clear." strcat content_color 80 boxInfo
        me @ me @ command @ " #gag" strcat field_color 
        me @ "Stop a user from sending or recieving messages from you on " command @ strcat content_color 80 boxInfo
        me @ me @ command @ " #help" strcat field_color 
        me @ "Display this message." content_color 80 boxInfo
    else
        me @ me @ "This channel is accessible only to wizards!" error_color 80 boxContent
    then
    me @ me @ 80 line box_color tell
;

: add_command ( s -- )
    var channel_name

    command @ get_channel_name channel_name !

    me @ "W" flag? if
        dup if
            command @ match channel_name @ "/commands" strcat getConfig dup not if
                pop { } array_make 
            then
            over over swap array_findval not if
                over array_append command @ match swap channel_name @ "/commands" strcat swap setConfig
                dup ";" swap strcat trigger @ name swap strcat trigger @ swap setname
                me @ "Successfully set the command " rot strcat " for " strcat channel_name @ get_channel_alias
                strcat "." strcat success_color tell
            else
                me @ "I already have that command set for " channel_name @ get_channel_alias strcat "." strcat
                error_color tell
            then
        else
            me @ "No command given!" error_color tell
        then
    else
        me @ "You are not authorized to add alternate commands to " channel_name @ get_channel_alias strcat "." strcat
        error_color tell
    then
;

: clear_bad ( s -- )
    var channel_name
    var listeners

    command @ get_channel_name channel_name !
    command @ match channel_name @ "/members" strcat getConfig dup array? if
        listeners ! listeners @ foreach swap pop
            dup ok? not if
                listeners @ swap over swap array_findval 0 array_getitem array_delitem listeners !
            else pop then
        repeat
        command @ match "_config/" channel_name @ strcat "/members#" strcat remove_prop
        command @ match channel_name @ "/members" strcat listeners @ setConfig
    else pop exit then
;
 
: main ( s -- )
    command_match clear_bad
    dup "create" paramTest if " " split swap pop createChannel exit then
    dup "delete" paramTest if " " split swap pop deleteChannel exit then
    dup "on" paramTest if " " split swap pop onChannel exit then
    dup "off" paramTest if " " split swap pop offChannel exit then
    dup "who" paramTest if " " split swap pop who exit then
    dup "alias" paramTest if " " split swap pop doAlias exit then    
    dup "nick" paramTest if " " split swap pop doNick exit then    
    dup "restrict" paramTest if " " split swap pop doRestrict exit then    
    dup "gag" paramTest if " " split swap pop gag exit then    
    dup "kick" paramTest if " " split swap pop kick exit then    
    dup "ban" paramTest if " " split swap pop ban exit then    
    dup "add-command" paramTest if " " split swap pop add_command exit then    
    dup "help" paramTest if pop show_help exit then    
    dup ":" instr 1 = if ":" split swap pop doPose exit then
    doSay
;
.
c
q


