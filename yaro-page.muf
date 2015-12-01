@q
@program yaro-page.muf
1 9999999 del
i
$include $lib/yaro
$include $lib/jmail
$include $cmd/status

: listify_ref ( d a -- s )
    dup array_count 1 > if
        "" swap
        foreach swap pop
            name strcat ", " strcat
        repeat
        "," rsplit pop
        "," rsplit ", and" swap strcat strcat
        swap name "you" swap subst
    else
        0 array_getitem name
        swap name "you" swap subst
    then
;

: listify_string ( a -- s )
    dup array_count 1 > if
        "" swap
        foreach swap pop
            strcat ", " strcat
        repeat
        "," rsplit pop
        "," rsplit ", and" swap strcat strcat
    else
        0 array_getitem
    then
;

: get_idle ( a -- a )
    { swap foreach swap pop
        dup descrleastidle descrcon conidle 900 > 
        over get_status swap pop "A" stringcmp not or not if pop then
    repeat } array_make
;

: do_summon ( s -- )
    getPlayers array_dedup dup if
        dup array_count 1 > if
            me @ swap listify_ref
            me @ swap " are currently asleep and cannot recieve your summons." strcat 
        else
            me @ swap listify_ref
            me @ swap " is currently asleep and cannot recieve your summons." strcat 
        then
        error_color tell
    else pop then
    array_dedup dup if
        listify_string
        me @ swap "I do not recognize " swap strcat ". They will not be summoned." strcat 
        error_color tell
    else pop then
    array_dedup dup if
        dup get_idle dup if dup array_count 1 > if
            me @ swap listify_ref "^INFO_COLOR^" swap strcat 
            " are currently idle or away from their keyboard and might not get back to you soon." strcat tell
        else
            me @ swap listify_ref "^INFO_COLOR^" swap strcat me @ name "you" subst 
            " is currently idle or away from their keyboard and might not get back to you soon." strcat tell
        then else pop then
        dup foreach swap pop
            over over swap listify_ref 
            "You sense that " me @ name strcat " is looking for " strcat swap strcat " in " strcat
            loc @ name strcat "." strcat over swap info_color otell
        repeat
        me @ over listify_ref "You have sent your summons to " swap strcat "." strcat me @ swap
        note_color tell
        me @ "_config/page/last_paged#/" remove_prop
        me @ swap "page/last_paged" swap setConfig
    then
;

: do_pose ( a s -- )
    var message
    var players

    strip message !
    array_dedup players !
    "You page-pose, '" me @ name strcat " " strcat message @ strcat "' to " strcat me @ players @ listify_ref strcat "." strcat
    "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes tell
    players @ foreach swap pop
        "In a page-pose to " over players @ listify_ref strcat ", " strcat 
        me @ name strcat " " strcat message @ strcat "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes otell
    repeat
    me @ "_config/page/last_paged#/" remove_prop
    me @ "page/last_paged" players @ setConfig
;

: do_say ( a s -- )
    var message
    var players

    strip message !
    array_dedup players !
    "You page, \"" message @ strcat "\" to " strcat me @ players @ listify_ref strcat "." strcat
    "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes tell
    players @ foreach swap pop
        me @ name " pages, \"" strcat message @ strcat "\" to " strcat over players @ listify_ref
        strcat "." strcat "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes otell
    repeat
    me @ "_config/page/last_paged#/" remove_prop
    me @ "page/last_paged" players @ setConfig
;

: do_mail ( a s -- )
    var message
    var players
    var whoami

    message !
    players !
    me @ whoami !

    me @ "_config/page/mail-list" players @ array_put_reflist
    me @ "_config/page/mail-list" "You have a page-mail from " me @ name strcat "." strcat message @ jmail-list if    
        whoami @ "You page-mail, \"" message @ strcat "\" to " strcat me @ players @ listify_ref strcat "." strcat
        "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes otell
    else
        whoami @ "Something went wrong when sending your mail to " players @ listify_ref strcat "." strcat
        error_color otell
    then
;

: show_help
    me @ trigger @ name ";" split pop " Command Usage" strcat 80 boxTitle
    me @ me @ command @ " [players]=<message>" strcat field_color 
    me @ "Send a private message to players." content_color 80 boxInfo
    me @ me @ command @ " players" strcat field_color 
    me @ "Send a summon message to players" content_color 80 boxInfo
    me @ me @ command @ " #mail [players]=<message>" strcat field_color 
    me @ "Send a private mail to players." content_color 80 boxInfo
    me @ me @ command @ " #help" strcat field_color 
    me @ "Show this dialog." content_color 80 boxInfo
    me @ me @ 80 line box_color tell
; 

: main
    var asleep

    { } array_make asleep !
    strip
    dup case
        "help" paramTest when show_help exit end
        "mail" paramTest when 
            "#mail" split swap pop strip
            dup if
                dup "=" instr if
                    "=" split swap getPlayers swap array_dedup dup if
                        listify_string
                        me @ swap "I do not recognize " swap strcat ". They will not be mailed." strcat 
                        error_color tell
                    else pop then
                    array_union swap do_mail
                else
                    me @ "I need a message to send." error_color tell
                then
            else
                me @ "Who are you page-mailing?" error_color tell
            then
        exit end
        default
            pop dup "=" instr if
                "=" split strip swap dup if
                    getPlayers array_dedup dup if
                        dup array_count 1 > if
                            me @ swap listify_ref
                            me @ swap " are currently asleep and cannot recieve your page. Use page #mail to leave them a message." strcat 
                        else
                            me @ swap listify_ref
                            me @ swap dup pmatch " is currently asleep and cannot recieve your page. Use page #mail to leave %o a message." pronoun_sub strcat 
                        then
                        error_color tell
                    else pop then
                    array_dedup dup if
                        listify_string
                        me @ swap "I do not recognize " swap strcat ". They will not be paged." strcat 
                        error_color tell
                    else pop then
                else
                    pop me @ "page/last_paged" getConfig { swap foreach swap pop
                        dup ok? not if pop else
                            dup awake? not if
                                asleep @ swap array_append asleep !
                            then
                        then
                    repeat } array_make
                then
                asleep @ array_dedup dup if
                    dup array_count 1 > if
                        me @ swap listify_ref
                        me @ swap " are currently asleep and cannot recieve your page. Use page #mail to leave them a message." strcat 
                    else
                        me @ swap listify_ref
                        me @ swap dup pmatch " is currently asleep and cannot recieve your page. Use page #mail to leave %o a message." pronoun_sub strcat 
                    then
                    error_color tell
                else pop then
                dup get_idle dup if dup array_count 1 > if
                    me @ swap listify_ref "^INFO_COLOR^" swap strcat 
                    " are currently idle or away from their keyboard and might not get back to you soon." strcat tell
                else
                    me @ swap listify_ref "^INFO_COLOR^" swap strcat me @ name "you" subst 
                    " is currently idle or away from their keyboard and might not get back to you soon." strcat tell
                then else pop then
                dup if
                    swap dup ":" instr 1 = if
                        ":" split swap pop do_pose
                    else
                        do_say
                    then
                else
                    pop me @ "No one to page." error_color tell
                then
            else do_summon then
        end
    endcase
;

.
c
q

