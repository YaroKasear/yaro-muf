@q
@program yaro-editplayer
1 99999 del
i

$include $lib/yaro
$include $lib/editor

lvar rname
lvar rsex
lvar rbdate
lvar rloc
lvar rutc
lvar remail
lvar prname
lvar prsex
lvar prbdate
lvar prloc
lvar prutc
lvar premail
lvar sex
lvar bdate
lvar species
lvar job
lvar family
lvar cdesc
lvar look_notify
lvar personality
lvar special
lvar desc_array
lvar pers_array
lvar submitted

: loadPInfo ( d -- )
    var ref

    ref !

    ref @ "pinfo/rname" getConfig dup not if pop "NOT SET" then rname !
    ref @ "pinfo/rsex" getConfig dup not if pop "NOT SET" then rsex !
    ref @ "pinfo/rbdate" getConfig dup not if pop "NOT SET" then rbdate !
    ref @ "pinfo/rloc" getConfig dup not if pop "NOT SET" then rloc !
    ref @ "pinfo/rutc" getConfig dup not if pop "0" then rutc !
    ref @ "pinfo/remail" getConfig dup not if pop "NOT SET" then remail !
    ref @ "pinfo/prname" getConfig dup not if pop 0 then prname !
    ref @ "pinfo/prsex" getConfig dup not if pop 0 then prsex !
    ref @ "pinfo/prbdate" getConfig dup not if pop 0 then prbdate !
    ref @ "pinfo/prloc" getConfig dup not if pop 0 then prloc !
    ref @ "pinfo/prutc" getConfig dup not if pop 0 then prutc !
    ref @ "pinfo/premail" getConfig dup not if pop 0 then premail !
;

: showPInfo ( d n -- )
    var ref
    var isme
    var authorized_editor

    authorized_editor !
    dup ref !
    me @ = me @ "W" flag? or authorized_editor @ or isme !

    me @ ref @ name "'s Player Information" strcat 80 boxTitle
    prname @ prsex @ or prbdate @ or prloc @ or prutc @ or isme @ or not if
        me @ ref @ ref @ name " is not making %o player information public at this time." strcat
        pronoun_sub 80 boxContent
    then
    isme @ if
        me @ "An 'X' denotes information that is shared publically." 80 boxContent
        me @ "" 80 boxContent
    then
    me @ {
    prname @ isme @ or if
        { me @ "Real Name:" field_color
        isme @ if prname @ me @ swap checkbox " " strcat swap strcat then
        me @ rname @ content_color } array_make
    then
    prsex @ isme @ or if
        { me @ "Gender:" field_color
        isme @ if prsex @ me @ swap checkbox " " strcat swap strcat then
        me @ rsex @ content_color } array_make
    then
    prbdate @ isme @ or if
        { me @ "Birthdate:" field_color
        isme @ if prbdate @ me @ swap checkbox " " strcat swap strcat then
        me @ rbdate @ content_color } array_make
    then
    prloc @ isme @ or if
        { me @ "Location:" field_color
        isme @ if prloc @ me @ swap checkbox " " strcat swap strcat then
        me @ rloc @ content_color } array_make
    then
    prutc @ isme @ or if
        { me @ "UTC Offset (Time Zone):" field_color
        isme @ if prutc @ me @ swap checkbox " " strcat swap strcat then
        me @ rutc @ content_color } array_make
    then
    premail @ isme @ or if
        { me @ "E-Mail Address:" field_color
        isme @ if premail @ me @ swap checkbox " " strcat swap strcat then
        me @ remail @ content_color } array_make
    then } array_make 80 boxInfo
;

: doPInfo ( d n -- )
    var ref
    ref !

    ref @ loadPInfo

    begin
        ref @ 1 showPInfo
        me @ "Options"
        1 "Set Real Name" 1
        2 "Toggle Real Name" 2
        3 "Set Gender" 3
        4 "Toggle Gender" 4
        5 "Set Birthdate" 5
        6 "Toggle Birthdate" 6 
        7 "Set Location" 7
        8 "Toggle Location" 8
        9 "Set Time Offset" 9
        10 "Toggle Time Offset" 10
        11 "Set E-Mail Address" 11
        12 "Toggle E-Mail Address" 12
        88 "Save" 88
        99 "Quit" 99
        14 80 doMenu dup 99 = not while
            case
            1 = when me @ "Please input your real name." note_color tell read dup not if "NOT SET" then rname ! end
            2 = when prname @ if 0 prname ! else 1 prname ! then end
            3 = when me @ "Please input your gender." note_color tell read dup not if "NOT SET" then rsex ! end
            4 = when prsex @ if 0 prsex ! else 1 prsex ! then end
            5 = when me @ "Please input your birthdate." note_color tell read dup not if "NOT SET" then rbdate ! end
            6 = when prbdate @ if 0 prbdate ! else 1 prbdate ! then end
            7 = when me @ "Please input your location." note_color tell read dup not if "NOT SET" then rloc ! end
            8 = when prloc @ if 0 prloc ! else 1 prloc ! then end
            9 = when
                1 begin while
                    me @ "Please input a number ranging from -12 to 12 to denote your offset from UTC" note_color tell
                    read dup number? if
                        dup atoi abs 12 > if
                            me @ "Number out of range. It must be -12 to 12." error_color tell 1
                        else
                            rutc ! 0
                        then
                    else
                        me @ "Please input a number." error_color tell 1
                    then
                repeat
            end
            10 = when prutc @ if 0 prutc ! else 1 prutc ! then end
            11 = when me @ "Please input your E-Mail Address." note_color tell read dup not if "NOT SET" then remail ! end
            12 = when premail @ if 0 premail ! else 1 premail ! then end
            88 = when
                ref @ "pinfo/rname" rname @ setConfig
                ref @ "pinfo/prname" prname @ setConfig
                ref @ "pinfo/rsex" rsex @ setConfig
                ref @ "pinfo/prsex" prsex @ setConfig
                ref @ "pinfo/rbdate" rbdate @ setConfig
                ref @ "pinfo/prbdate" prbdate @ setConfig
                ref @ "pinfo/rloc" rloc @ setConfig
                ref @ "pinfo/prloc" prloc @ setConfig
                ref @ "pinfo/rutc" rutc @ setConfig
                ref @ "pinfo/prutc" prutc @ setConfig
                ref @ "pinfo/remail" remail @ setConfig
                ref @ "pinfo/premail" premail @ setConfig
            end
        endcase
        repeat

;

: showCInfo ( d n -- )
    var ref
    var isme
    var authorized_editor

    var special_name

    trigger @ "special_name" getConfig dup not if pop "Special" then special_name !

    authorized_editor !
    dup ref !
    me @ = me @ "W" flag? or authorized_editor @ or isme !

    me @ ref @ name "'s Character Information" strcat 80 boxTitle
    isme @ if
        me @ "An 'X' denotes that look-notify is enabled." 80 boxContent
        me @ "" 80 boxContent
    then
    me @ { { me @ "Name:" field_color me @ ref @ name content_color } array_make
    { me @ "Gender:" field_color me @ sex @ content_color } array_make
    { me @ "Species:" field_color me @ species @ content_color } array_make
    { me @ "Birth Date:" field_color me @ bdate @ content_color } array_make
    { me @ "Job:" field_color me @ job @ content_color } array_make
    { me @ "Family:" field_color me @ family @ content_color } array_make
    { me @ special_name @ ":" strcat field_color me @ special @ content_color } array_make
    { me @ "Description:" field_color
    isme @ if me @ look_notify @ checkbox " " strcat swap strcat then
    me @ cdesc @ content_color } array_make
    { me @ "Personality:" field_color me @ personality @ content_color } array_make } array_make 80 boxInfo
;

: loadCInfo ( d -- )
    var ref

    ref !

    clear_cache

    ref @ "~sex" getprop dup not if pop "NOT SET [TALK TO WIZARD]" then sex !
    ref @ "~species" getprop dup not if pop "NOT SET [TALK TO WIZARD]" then species !
    ref @ "cinfo/bdate" getConfig dup not if pop "NOT SET" then bdate !
    ref @ "cinfo/job" getConfig dup not if pop "NOT SET" then job !
    ref @ "cinfo/family" getConfig dup not if pop "NOT SET" then family !
    ref @ "{list:_config/cinfo/cdesc," ref @ dtos strcat "}" strcat "" 1 parsempi dup not if pop "NOT SET" then cdesc !
    ref @ "cinfo/cdesc#" getConfig dup if desc_array ! else pop { } array_make desc_array ! then
    ref @ "cinfo/lnotify" getConfig dup not if pop 0 then look_notify !
    ref @ "{list:_config/cinfo/personality," ref @ dtos strcat "}" strcat "" 1 parsempi dup not if pop "NOT SET" then personality !
    ref @ "cinfo/personality#" getConfig dup if pers_array ! else pop { } array_make pers_array ! then
    ref @ "cinfo/special" getConfig dup not if pop "NOT SET" then special !
;

: doCInfo ( d -- )
    var ref
    ref !

    var special_name

    ref @ loadCInfo

    trigger @ "special_name" getConfig dup not if pop "Special" then special_name !

    begin
        ref @ 1 showCInfo
        me @ "Options"
        1 "Set Birthdate" 1
        2 "Set Job" 2
        3 "Set Family" 3
        4 "Set " special_name @ strcat 4
        5 "Set Description" 5
        6 "Toggle Look-Notify" 6
        7 "Set Personality" 7
        88 "Save" 88
        99 "Quit" 99
    9 80 doMenu dup 99 = not while
            case
                1 = when me @ "Please input your character's birthdate." note_color tell read dup not if "NOT SET" then bdate ! end
                2 = when me @ "Please input your character's job." note_color tell read dup not if "NOT SET" then job ! end
                3 = when me @ "Please input your character's family." note_color tell read dup not if "NOT SET" then family ! end
                4 = when me @ "Please input your character's cutie mark." note_color tell read dup not if "NOT SET" then special ! end
                5 = when
                    desc_array @ dup array? if array_vals else pop 0 then EDITOR "abort" stringcmp not if
                        popn cdesc @
                    else
                        array_make dup desc_array ! foreach
                            swap 0 = not if "\r" swap strcat strcat then
                        repeat
                    then
                    cdesc !
                end
                6 = when look_notify @ if 0 look_notify ! else 1 look_notify ! then end
                7 = when
                    pers_array @ dup array? if array_vals else pop 0 then EDITOR "abort" stringcmp not if
                        popn personality @
                    else
                        array_make dup pers_array ! foreach
                            swap 0 = not if "\r" swap strcat strcat then
                        repeat
                    then
                    personality !
                end
                88 = when
                    ref @ "cinfo/bdate" bdate @ setConfig
                    ref @ "cinfo/job" job @ setConfig
                    ref @ "cinfo/family" family @ setConfig
                    ref @ "cinfo/special" special @ setConfig
                    ref @ "cinfo/lnotify" look_notify @ setConfig
                    ref @ "_config/cinfo/cdesc" desc_array @ dup array? if array_vals else pop 0 then array_make array_put_proplist
                    ref @ "_config/cinfo/personality" pers_array @ dup array? if array_vals else pop 0 then array_make array_put_proplist
                    "{list:_config/cinfo/cdesc," ref @ dtos strcat "}" strcat ref @ swap setdesc
                end
            endcase
    repeat
;

: doPrefs
    me @ "Player Preferences" "This is the tool for setting player-specific preferences."
    set_look_feel
;

: doBasics ( d -- )
    var ref

    ref !

    begin
        me @ ref @ name "'s Basic Information" strcat
        40 boxTitle
        me @ { { me @ "Gender:" field_color me @ sex @ dup not if pop "NOT SET" then content_color } array_make
        { me @ "Species:" field_color me @ species @ dup not if pop "NOT SET" then content_color } array_make } array_make 40 boxInfo
        me @ "Options"
        1 "Set Gender" 1
        2 "Set Species" 2
        8 "Save" 8
        9 "Quit" 9
        4 40 doMenu dup 9 = not while
            case
                1 = when
                    me @ "Please enter the character's gender." info_color tell read
                    dup not if
                        pop "NOT SET"
                    then
                    sex !
                end
                2 = when
                    me @ "Please enter the character's species." info_color tell read
                    dup not if
                        pop "NOT SET"
                    then
                    species !
                end
                8 = when
                    ref @ "~sex" sex @ setprop
                    ref @ "~species" species @ setprop
                end
            endcase
        repeat
;

: doAUP
    var ref
    ref !

    me @ "Authorized Use Policy" 80 boxTitle
    prog "_config/aup" array_get_proplist foreach swap pop
        me @ swap 80 boxContent
    repeat
    me @ "Do you accept this policy?"
    1 "Yes" 1
    2 "No" 2
    2 80 doMenu
    ref @ swap "aup_accepted" swap setConfig
;

: doSubmit
    var ref
    ref !

    me @ "Are you sure you wish to submit your application?"
    1 "Yes" 1
    2 "No" 2
    2 80 doMenu case
        1 = when
            ref @ "aup_accepted" getConfig 1 = not if
                me @ "Please note you have not accepted the Authorized Use Policy! That is grounds for immediate rejection of your application." error_color tell
            then
            "$lib/yaro" match "c_apps/" ref @ name strcat ref @ setConfig
            me @ "Your application has been submitted! Good luck!" success_color tell
            1 submitted !
            online array_make foreach swap pop
                dup "W" flag? if
                    dup "The character " ref @ name strcat " has been requested." strcat
                    " Use @request #process " ref @ name strcat " to review the application."
                    strcat strcat info_color otell
                else pop then
            repeat
            1
        end
        2 = when 0 end
    endcase
;

: doProcess ( d -- )
    var ref
    ref !

    ref @ loadPInfo
    ref @ loadCInfo

    me @ ref @ name "'s Character Application" strcat
    80 boxTitle
    ref @ "aup_accepted" getConfig 1 = if
        me @ me @ "THE AUTHORIZED USE POLICY HAS BEEN ACCEPTED" success_color
        80 boxContent
    else
        me @ me @ "THE AUTHORIZED USE POLICY HAS NOT BEEN ACCEPTED" error_color
        80 boxContent
        me @ me @ "IT IS RECOMMENDED THAT THIS APPLICATION IS REJECTED" error_color
        80 boxContent
    then
    ref @ 0 showPInfo
    ref @ 0 showCInfo
    me @ "Application Outcome"
    1 "Accept" 1
    2 "Reject" 2
    3 "Defer" 3
    3 80 doMenu case
        1 = when 
            ref @ "!G" set
            ref @ "B" set
            "$lib/yaro" match "c_apps/" ref @ name strcat 0 setConfig
            ref @ ref @ "You have been approved! Congratulations!" success_color otell
            me @ "Character " ref @ name strcat " approved." strcat note_color tell
            online array_make foreach swap pop
                dup "W" flag? if
                    dup me @ name " has approved the character " strcat
                    ref @ name strcat "!" strcat info_color otell
                else pop then
            repeat
        end
        2 = when 
            me @ "Rejected " ref @ name strcat " and toaded." strcat note_color tell
            online array_make foreach swap pop
                dup me @ name " has rejected the character " strcat ref @ name strcat
                " and the character has been toaded." strcat info_color otell
            repeat
            "$lib/yaro" match "c_apps/" ref @ name strcat 0 setConfig
            #2 ref @ toadplayer
            ref @ recycle
        end
        3 = when
            me @ "Deferring to another wizard." note_color tell
            online array_make foreach swap pop
                dup "W" flag? if
                    dup me @ name " has deferred on " strcat 
                    ref @ name strcat  "'s application. " strcat
                    " Use @request #process " ref @ name strcat " to review the application."
                    strcat strcat info_color otell
                else pop then
            repeat
        end
    endcase
;

: new_morph ( d s -- s )
    var ref
    var current_name

    current_name !
    ref !

    ref @ "_config/morph/" current_name @ strcat remove_prop
    ref @ "_config/cinfo" ref @ "_config/morph/" current_name @ strcat 1 copyprops pop
    "" begin dup not while
        "^NOTE_COLOR^Please type a name for the new morph without a space." tell
        read dup " " instr if
            pop "" "^ERROR_COLOR^Please do not use a space." tell
        then
    repeat
    "^SUCCESS_COLOR^Copied current morph into new morph named " over strcat "!" strcat tell
    "^SUCCESS_COLOR^You will be put in the character editor now." tell
    ref @ loadCInfo
    ref @ doCInfo pop
    dup ref @ swap "_config/cinfo" swap 
    ref @ swap "_config/morph/" swap strcat 1 copyprops pop
    dup ref @ swap "cinfo/morph_name" swap setConfig
;

: delete_morph ( a -- a )
    var morphs

    morphs !
    me @ "Morph Deletion" morphs @ array_to_menu ++ dup "Cancel" swap 50 doMenu
    dup morphs @ array_count > not if
        -- morphs @ swap array_extract dup me @ "cinfo/morph_name" getConfig stringcmp if
            swap morphs !
            me @ swap "_config/morph/" swap strcat remove_prop
            me @ "_config/morphs#" remove_prop
            me @ "morphs" morphs @ setConfig
        else
            pop "^ERROR_COLOR^You can't delete your current morph." tell
        then
    then
    morphs @
;

: set_morph ( s -- )
    var morph_name

    morph_name !
    me @ "morphs" getConfig dup array? if
        morph_name @ array_findval if
            me @ "_config/cinfo" remove_prop
            me @ "_config/morph/" morph_name @ strcat me @ "_config/cinfo" 1 copyprops pop
            me @ loadCInfo
            "^SUCCESS_COLOR^Morphed into " morph_name @ strcat "!" strcat tell
        else
            "^ERROR_COLOR^That is not a valid morph." tell
        then
    else
        "^ERROR_COLOR^That is not a valid morph." tell
    then
;

: doMorphs ( d -- )
    var ref
    var current_name
    var morphs

    dup ref ! 
    "cinfo/morph_name" getConfig dup not if
        "^INFO_COLOR^You do not have a name for your current default morph state!" tell
        "^NOTE_COLOR^Please type a name for this morph." tell
        pop "" begin read dup " " instr while
            pop "^ERROR_COLOR^No spaces are allowed in morph names." tell
        repeat
        dup ref @ swap "cinfo/morph_name" swap setConfig
        dup { swap } array_make ref @ swap "morphs" swap setConfig
        dup ref @ swap "_config/cinfo" swap 
        ref @ swap "_config/morph/" swap strcat 1 copyprops pop
    then
    current_name !

    ref @ "morphs" getConfig dup array? not if
        pop { current_name @ } array_make
    then
    morphs ! begin me @ "Morph Editor" morphs @ array_to_menu ++
    "New Morph" over dup ++ 
    "Delete Morph" over dup ++ 
    "Quit" over dup
    50 doMenu dup morphs @ array_count 3 + = not while
        case 
            morphs @ array_count ++ = when
                ref @ current_name @ new_morph
                morphs @ swap array_append morphs !
                ref @ "_config/morphs#" remove_prop
                ref @ "morphs" morphs @ setConfig
            end
            morphs @ array_count 2 + = when
                morphs @ delete_morph morphs !
            end
            default
                -- morphs @ swap array_getitem
                set_morph exit
            end
        endcase
    repeat
;

: set_special
    strip dup if
        dup trigger @ swap "special_name" swap setConfig
        "^SUCCESS_COLOR^Special character field name set to " swap strcat "." strcat tell
    else
        pop trigger @ "special_name" 0 setConfig
        "^SUCCESS_COLOR^Special character field name cleared." tell
    then
;

: show_help
    me @ command @ " Command Help" strcat 80 boxTitle
    me @ "editplayer - Change player information, character information, and preferences." 80 boxContent
    me @ "@request <NAME> - Request character NAME for approval." 80 boxContent
    me @ "@request #process - WIZARDS ONLY: Process a character application." 80 boxContent
    me @ "pinfo <NAME> - View NAME's player information." 80 boxContent
    me @ "cinfo <NAME> - View NAME's character information." 80 boxContent
    me @ "W" flag? if
        me @ command @ " #set-special - Set the special character field name." strcat 80 boxContent
    then
    me @ me @ 80 line box_color tell 
;

: main
    var newPRef
    dup "help" paramTest if show_help exit then
    dup "set-special" paramTest if " " split nip set_special exit then
    command @ tolower case
        "editplayer" stringcmp not when pop
            begin
                me @ "Player Editor"
                1 "Player Information" 1
                2 "Character Information" 2
                3 "Morphs" 3
                4 "Preferences" 4
                9 "Quit" 9
            5 30 doMenu dup 9 = not while
                case
                    1 = when me @ doPInfo end
                    2 = when me @ doCInfo end
                    3 = when me @ doMorphs end
                    4 = when doPrefs end
                endcase
            repeat
            pop me @ "Thank you for using the Player Editor!" note_color tell
        end
        "@request" stringcmp not when
            dup if
                dup "process" paramTest if
                    me @ "W" flag? if
                        " " explode 1 > if
                            pop pmatch dup ok? over player? and if
                                newPRef !
                                "$lib/yaro" match "c_apps/" newPRef @ name strcat
                                getConfig dup if
                                    doProcess
                                else
                                    me @ newPRef @ name " is not a requested character." strcat
                                    error_color tell
                                then
                            else
                                me @ "I don't know any such character." error_color tell
                            then
                        else
                            me @ "Who are you #processing?" error_color tell
                        then
                    else
                        me @ "You are not authorized to process applications." error_color tell
                    then
                    exit
                then
                dup pmatch ok? not if
                    "changeme" newplayer newPRef !
                    newPRef @ "G" set
                    me @ loadPInfo
                    newPRef @ "~status" "NEW" setConfig
                    newPRef @ "~stype" "O" setConfig
                    newPRef @ "pinfo/rname" rname @ setConfig
                    newPRef @ "pinfo/prname" prname @ setConfig
                    newPRef @ "pinfo/rsex" rsex @ setConfig
                    newPRef @ "pinfo/prsex" prsex @ setConfig
                    newPRef @ "pinfo/rbdate" rbdate @ setConfig
                    newPRef @ "pinfo/prbdate" prbdate @ setConfig
                    newPRef @ "pinfo/rloc" rloc @ setConfig
                    newPRef @ "pinfo/prloc" prloc @ setConfig
                    newPRef @ "pinfo/rutc" rutc @ setConfig
                    newPRef @ "pinfo/prutc" prutc @ setConfig
                    begin
                        me @ "Character Application"
                        1 "Basics" 1
                        2 "Player Information" 2
                        3 "Character Information" 3
                        4 "Read AUP - " me @ "EXTREMELY IMPORTANT" error_color strcat 4
                        8 "Submit" 8
                        9 "Quit" 9
                    6 50 doMenu dup 9 = not while
                        case
                            1 = when newPRef @ doBasics end
                            2 = when newPRef @ doPInfo end
                            3 = when newPRef @ doCInfo end
                            4 = when newPRef @ doAUP end
                            8 = when newPRef @ doSubmit if exit then end
                        endcase
                    repeat
                    pop me @ "Thank you for using the Character Request System!" note_color tell
                    submitted @ not if
                        newPRef @ name
                        #2 newPRef @ toadplayer
                        newPRef @ recycle
                        "As you did not submit your application, " swap strcat " has been toaded." strcat
                        me @ swap info_color tell
                    then
                else
                    pmatch name " already exists." strcat me @ swap error_color tell
                then
            else
                me @ "I need a character name to process a request on." error_color tell
            then
        end
        "pinfo" stringcmp not when
            dup if
                dup pmatch dup ok? over player? and if
                    swap pop dup loadPInfo 0 showPInfo
                    me @ 80 line me @ swap box_color tell
                else
                    pop "I do not know any player named \"" swap strcat "!" strcat
                    me @ swap error_color tell
                then
            else
                me @ "Get player information on who?" error_color tell
            then
        end
        "cinfo" stringcmp not when
            dup if
                dup pmatch dup ok? over player? and if
                    swap pop dup loadCInfo 0 showCInfo
                    me @ 80 line me @ swap box_color tell
                else
                    pop "I do not know any player named \"" swap strcat "!" strcat
                    me @ swap error_color tell
                then
            else
                me @ "Get character information on who?" error_color tell
            then
        end
        "morph" stringcmp not when
            strip " " split pop set_morph
        end
    endcase
;
.
c
q

