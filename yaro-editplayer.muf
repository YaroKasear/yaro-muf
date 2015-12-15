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
    prname @ isme @ or if
        me @ me @ "Real Name:" field_color
        isme @ if prname @ me @ swap checkbox " " strcat swap strcat then
        me @ rname @ content_color 80 boxInfo
    then
    prsex @ isme @ or if
        me @ me @ "Gender:" field_color
        isme @ if prsex @ me @ swap checkbox " " strcat swap strcat then
        me @ rsex @ content_color 80 boxInfo
    then
    prbdate @ isme @ or if
        me @ me @ "Birthdate:" field_color
        isme @ if prbdate @ me @ swap checkbox " " strcat swap strcat then
        me @ rbdate @ content_color 80 boxInfo
    then
    prloc @ isme @ or if
        me @ me @ "Location:" field_color
        isme @ if prloc @ me @ swap checkbox " " strcat swap strcat then
        me @ rloc @ content_color 80 boxInfo
    then
    prutc @ isme @ or if
        me @ me @ "UTC Offset (Time Zone):" field_color
        isme @ if prutc @ me @ swap checkbox " " strcat swap strcat then
        me @ rutc @ content_color 80 boxInfo
    then
    premail @ isme @ or if
        me @ me @ "E-Mail Address:" field_color
        isme @ if premail @ me @ swap checkbox " " strcat swap strcat then
        me @ remail @ content_color 80 boxInfo
    then
;

: doPInfo ( d n -- )
    var ref
    ref !

    ref @ loadPInfo

    begin
        ref @ 1 showPInfo
        me @ "Options"
        1 "Set Real Name"
        2 "Toggle Real Name"
        3 "Set Gender"
        4 "Toggle Gender"
        5 "Set Birthdate"
        6 "Toggle Birthdate"
        7 "Set Location"
        8 "Toggle Location"
        9 "Set Time Offset"
        10 "Toggle Time Offset"
        11 "Set E-Mail Address"
        12 "Toggle E-Mail Address"
        88 "Save"
        99 "Quit"
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

    authorized_editor !
    dup ref !
    me @ = me @ "W" flag? or authorized_editor @ or isme !

    me @ ref @ name "'s Character Information" strcat 80 boxTitle
    isme @ if
        me @ "An 'X' denotes that look-notify is enabled." 80 boxContent
        me @ "" 80 boxContent
    then
    me @ me @ "Name:" field_color me @ ref @ name content_color 80 boxInfo
    me @ me @ "Gender:" field_color me @ sex @ content_color 80 boxInfo
    me @ me @ "Species:" field_color me @ species @ content_color 80 boxInfo
    me @ me @ "Birth Date:" field_color me @ bdate @ content_color 80 boxInfo
    me @ me @ "Job:" field_color me @ job @ content_color 80 boxInfo
    me @ me @ "Family:" field_color me @ family @ content_color 80 boxInfo
    me @ me @ "Cutie Mark:" field_color me @ special @ content_color 80 boxInfo
    me @ me @ "Description:" field_color
    isme @ if me @ look_notify @ checkbox " " strcat swap strcat then
    me @ cdesc @ content_color 80 boxInfo
    me @ me @ "Personality:" field_color me @ personality @ content_color 80 boxInfo
;

: loadCInfo ( d -- )
    var ref

    ref !

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

    ref @ loadCInfo

    begin
        ref @ 1 showCInfo
        me @ "Options"
        1 "Set Birthdate"
        2 "Set Job"
        3 "Set Family"
        4 "Set Cutie Mark"
        5 "Set Description"
        6 "Toggle Look-Notify"
        7 "Set Personality"
        88 "Save"
        99 "Quit"
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
    var width

    var l
    var vl
    var error
    var success
    var info
    var note
    var tag1
    var tag2
    var ooc1
    var ooc2
    var option1
    var option2
    var ic1
    var ic2
    var title
    var field
    var box
    var content
    var open
    var close
    var set_defaults
    var save_defaults

    0 set_defaults !
    0 save_defaults !

    me @ 1 line l !
    me @ vline vl !
    me @ "" error_color error !
    me @ "" success_color success !
    me @ "" info_color info !
    me @ "" note_color note !
    me @ "" tag_color_1 tag1 !
    me @ "" tag_color_2 tag2 !
    me @ "" ooc_color_1 ooc1 !
    me @ "" ooc_color_2 ooc2 !
    me @ "" option_color_1 option1 !
    me @ "" option_color_2 option2 !
    me @ "" ic_color_1 ic1 !
    me @ "" ic_color_2 ic2 !
    me @ "" title_color title !
    me @ "" field_color field !
    me @ "" box_color box !
    me @ "" content_color content !
    me @ open_tag open !
    me @ close_tag close !

    me @ "orig/line" l @ setConfig
    me @ "orig/vline" vl @ setConfig
    me @ "orig/open_tag" open @ setConfig
    me @ "orig/close_tag" close @ setConfig
    me @ "orig/color/error_color" error @ setConfig
    me @ "orig/color/success_color" success @ setConfig
    me @ "orig/color/info_color" info @ setConfig
    me @ "orig/color/note_color" note @ setConfig
    me @ "orig/color/tag1" tag1 @ setConfig
    me @ "orig/color/tag2" tag2 @ setConfig
    me @ "orig/color/ooc1" ooc1 @ setConfig
    me @ "orig/color/ooc2" ooc2 @ setConfig
    me @ "orig/color/opt1" option1 @ setConfig
    me @ "orig/color/opt2" option2 @ setConfig
    me @ "orig/color/ic1" ic1 @ setConfig
    me @ "orig/color/ic2" ic2 @ setConfig
    me @ "orig/color/title" title @ setConfig
    me @ "orig/color/field" field @ setConfig
    me @ "orig/color/box" box @ setConfig
    me @ "orig/color/content" content @ setConfig
    begin
        me @ 1 line l !
        me @ vline vl !
        me @ "" error_color error !
        me @ "" success_color success !
        me @ "" info_color info !
        me @ "" note_color note !
        me @ "" tag_color_1 tag1 !
        me @ "" tag_color_2 tag2 !
        me @ "" ooc_color_1 ooc1 !
        me @ "" ooc_color_2 ooc2 !
        me @ "" option_color_1 option1 !
        me @ "" option_color_2 option2 !
        me @ "" ic_color_1 ic1 !
        me @ "" ic_color_2 ic2 !
        me @ "" title_color title !
        me @ "" field_color field !
        me @ "" box_color box !
        me @ "" content_color content !
        me @ open_tag open !
        me @ close_tag close !
        me @ "Preferences" 80 dup width ! boxTitle
        me @ "This is the lib-yaro preferences dialog. In this box you will "
             "be exposed to the various settings lib-yaro allows you to change "
             "global preferences not specific to any given command. For that you "
             "should see if the command has a #config parameter."
        strcat strcat strcat width @ boxContent
        me @ "" width @ boxContent
        me @ "Select the options below to change colors and visual look of "
             "interface elements." strcat
        width @ boxContent
        me @ "" width @ boxContent
        me @ me @ "Sample Field:" field_color me @ "Sample Content" content_color 80 boxInfo
        me @ me @ me @ open_tag tag_color_2
        me @ "TAG" tag_color_1 strcat
        me @ me @ close_tag tag_color_2 strcat " " strcat
        me @ "OOC says, \"" ooc_color_1
        me @ "This is a test message." ooc_color_2
        me @ "\"" ooc_color_1 strcat strcat strcat
        80 boxContent
        me @ me @ "IC poses and says, \"Who is a superhero?!\"" "^IC_COLOR_1^" "^IC_COLOR_2^" 
        color_quotes process_tags 80 boxContent 
        me @ me @ "You have looked at this message successfully!" success_color 80 boxContent
        me @ me @ "Somewhere an error has probably occured!" error_color 80 boxContent
        me @ me @ "Here is some information!" info_color 80 boxContent
        me @ me @ "Here is a note!" note_color 80 boxContent
        me @ me @ "1) " option_color_1
        me @ "Option Text" option_color_2 strcat 80 boxContent
        me @ "Options"
        1 "Horizontal Line Character (" me @ 1 line strcat ")" strcat
        2 "Vertical Line Character (" me @ vline strcat ")" strcat
        3 "Open Tag Character (" me @ open_tag strcat ")" strcat
        4 "Close Tag Character (" me @ close_tag strcat ")" strcat
        5 me @ "Error Color" error_color me @ "" content_color strcat
        6 me @ "Success Color" success_color me @ "" content_color strcat
        7 me @ "Information Color" info_color me @ "" content_color strcat
        8 me @ "Note Color" note_color me @ "" content_color strcat
        9 me @ "Inner Tag Color" tag_color_1 me @ "" content_color strcat
        10 me @ "Outer Tag Color" tag_color_2 me @ "" content_color strcat
        11 me @ "OOC Description Color" ooc_color_1 me @ "" content_color strcat
        12 me @ "OOC Message Color" ooc_color_2 me @ "" content_color strcat
        13 me @ "IC Description Color" ic_color_1 me @ "" content_color strcat
        14 me @ "IC Message Color" ic_color_2 me @ "" content_color strcat
        15 me @ "Option Number Color" option_color_1 me @ "" content_color strcat
        16 me @ "Option Text Color" option_color_2 me @ "" content_color strcat
        17 me @ "Title Color" title_color me @ "" content_color strcat
        18 me @ "Field Color" field_color me @ "" content_color strcat
        19 me @ "Box Color" box_color me @ "" content_color strcat
        20 me @ "Content Color" content_color me @ "" content_color strcat
        77 "Reset to Defaults"
        88 "Save"
        99 "Quit"
    23 width @ doMenu dup 99 = not while
        case
            1 = when
                me @ "Please enter a single character. Any extra will be truncated."
                note_color tell read cleanString 1 ansi_strcut pop
                dup l ! me @ swap "line" swap setConfig
                0 set_defaults !
            end
            2 = when
                me @ "Please enter a single character. Any extra will be truncated."
                note_color tell read cleanString 1 ansi_strcut pop
                dup vl ! me @ swap "vline" swap setConfig
                0 set_defaults !
            end
            3 = when
                me @ "Please enter a single character. Any extra will be truncated."
                note_color tell read cleanString 1 ansi_strcut pop
                dup open ! me @ swap "open_tag" swap setConfig
                0 set_defaults !
            end
            4 = when
                me @ "Please enter a single character. Any extra will be truncated."
                note_color tell read cleanString 1 ansi_strcut pop
                dup close ! me @ swap "close_tag" swap setConfig
                0 set_defaults !
            end
            5 = when me @ color_menu dup if dup error ! me @ swap "color/error_color" swap setConfig 0 set_defaults ! else pop then end
            6 = when me @ color_menu dup if dup success ! me @ swap "color/success_color" swap setConfig 0 set_defaults ! else pop then end
            7 = when me @ color_menu dup if dup info ! me @ swap "color/info_color" swap setConfig 0 set_defaults ! else pop then end
            8 = when me @ color_menu dup if dup note ! me @ swap "color/note_color" swap setConfig 0 set_defaults ! else pop then end
            9 = when me @ color_menu dup if dup tag1 ! me @ swap "color/tag1" swap setConfig 0 set_defaults ! else pop then end
            10 = when me @ color_menu dup if dup tag2 ! me @ swap "color/tag2" swap setConfig 0 set_defaults ! else pop then end
            11 = when me @ color_menu dup if dup ooc1 ! me @ swap "color/ooc1" swap setConfig 0 set_defaults ! else pop then end
            12 = when me @ color_menu dup if dup ooc2 ! me @ swap "color/ooc2" swap setConfig 0 set_defaults ! else pop then end
            13 = when me @ color_menu dup if dup ic1 ! me @ swap "color/ic1" swap setConfig 0 set_defaults ! else pop then end
            14 = when me @ color_menu dup if dup ic2 ! me @ swap "color/ic2" swap setConfig 0 set_defaults ! else pop then end
            15 = when me @ color_menu dup if dup option1 ! me @ swap "color/opt1" swap setConfig 0 set_defaults ! else pop then end
            16 = when me @ color_menu dup if dup option2 ! me @ swap "color/opt2" swap setConfig 0 set_defaults ! else pop then end
            17 = when me @ color_menu dup if dup title ! me @ swap "color/title" swap setConfig 0 set_defaults ! else pop then end
            18 = when me @ color_menu dup if dup field ! me @ swap "color/field" swap setConfig 0 set_defaults ! else pop then end
            19 = when me @ color_menu dup if dup box ! me @ swap "color/box" swap setConfig 0 set_defaults ! else pop then end
            20 = when me @ color_menu dup if dup content ! me @ swap "color/content" swap setConfig 0 set_defaults ! else pop then end
            77 = when
                me @ "line" 0 setConfig
                me @ "vline" 0 setConfig
                me @ "open_tag" 0 setConfig
                me @ "close_tag" 0 setConfig
                me @ "color/error_color" 0 setConfig
                me @ "color/success_color" 0 setConfig
                me @ "color/info_color" 0 setConfig
                me @ "color/note_color" 0 setConfig
                me @ "color/tag1" 0 setConfig
                me @ "color/tag2" 0 setConfig
                me @ "color/ooc1" 0 setConfig
                me @ "color/ooc2" 0 setConfig
                me @ "color/opt1" 0 setConfig
                me @ "color/opt2" 0 setConfig
                me @ "color/ic1" 0 setConfig
                me @ "color/ic2" 0 setConfig
                me @ "color/title" 0 setConfig
                me @ "color/field" 0 setConfig
                me @ "color/box" 0 setConfig
                me @ "color/content" 0 setConfig
                1 set_defaults !
            end
            88 = when
                me @ "orig/line" l @ setConfig
                me @ "orig/vline" vl @ setConfig
                me @ "orig/open_tag" open @ setConfig
                me @ "orig/close_tag" close @ setConfig
                me @ "orig/color/error_color" error @ setConfig
                me @ "orig/color/success_color" success @ setConfig
                me @ "orig/color/info_color" info @ setConfig
                me @ "orig/color/note_color" note @ setConfig
                me @ "orig/color/tag1" tag1 @ setConfig
                me @ "orig/color/tag2" tag2 @ setConfig
                me @ "orig/color/ooc1" ooc1 @ setConfig
                me @ "orig/color/ooc2" ooc2 @ setConfig
                me @ "orig/color/opt1" option1 @ setConfig
                me @ "orig/color/opt2" option2 @ setConfig
                me @ "orig/color/ic1" ic1 @ setConfig
                me @ "orig/color/ic2" ic2 @ setConfig
                me @ "orig/color/title" title @ setConfig
                me @ "orig/color/field" field @ setConfig
                me @ "orig/color/box" box @ setConfig
                me @ "orig/color/content" content @ setConfig
                set_defaults @ if
                    1 save_defaults !
                else
                    0 save_defaults !
                then
            end
        endcase
    repeat
    me @ me @ "orig/line" getConfig "line" swap setConfig
    me @ me @ "orig/vline" getConfig "vline" swap setConfig
    me @ me @ "orig/open_tag" getConfig "open_tag" swap setConfig
    me @ me @ "orig/close_tag" getConfig "close_tag" swap setConfig
    me @ me @ "orig/color/error_color" getConfig "color/error_color" swap setConfig
    me @ me @ "orig/color/success_color" getConfig "color/success_color" swap setConfig
    me @ me @ "orig/color/info_color" getConfig "color/info_color" swap setConfig
    me @ me @ "orig/color/note_color" getConfig "color/note_color" swap setConfig
    me @ me @ "orig/color/tag1" getConfig "color/tag1" swap setConfig
    me @ me @ "orig/color/tag2" getConfig "color/tag2" swap setConfig
    me @ me @ "orig/color/ooc1" getConfig "color/ooc1" swap setConfig
    me @ me @ "orig/color/ooc2" getConfig "color/ooc2" swap setConfig
    me @ me @ "orig/color/opt1" getConfig "color/opt1" swap setConfig
    me @ me @ "orig/color/opt2" getConfig "color/opt2" swap setConfig
    me @ me @ "orig/color/ic1" getConfig "color/ic1" swap setConfig
    me @ me @ "orig/color/ic2" getConfig "color/ic2" swap setConfig
    me @ me @ "orig/color/title" getConfig "color/title" swap setConfig
    me @ me @ "orig/color/field" getConfig "color/field" swap setConfig
    me @ me @ "orig/color/box" getConfig "color/box" swap setConfig
    me @ me @ "orig/color/content" getConfig "color/content" swap setConfig
    me @ "_config/orig" remove_prop
    save_defaults @ if
        me @ "line" 0 setConfig
        me @ "vline" 0 setConfig
        me @ "open_tag" 0 setConfig
        me @ "close_tag" 0 setConfig
        me @ "color/error_color" 0 setConfig
        me @ "color/success_color" 0 setConfig
        me @ "color/info_color" 0 setConfig
        me @ "color/note_color" 0 setConfig
        me @ "color/tag1" 0 setConfig
        me @ "color/tag2" 0 setConfig
        me @ "color/ooc1" 0 setConfig
        me @ "color/ooc2" 0 setConfig
        me @ "color/opt1" 0 setConfig
        me @ "color/opt2" 0 setConfig
        me @ "color/ic" 0 setConfig
        me @ "color/title" 0 setConfig
        me @ "color/field" 0 setConfig
        me @ "color/box" 0 setConfig
        me @ "color/content" 0 setConfig
    then
;

: doBasics ( d -- )
    var ref

    ref !

    begin
        me @ ref @ name "'s Basic Information" strcat
        40 boxTitle
        me @ me @ "Gender:" field_color me @ sex @ dup not if pop "NOT SET" then content_color 40 boxInfo
        me @ me @ "Species:" field_color me @ species @ dup not if pop "NOT SET" then content_color 40 boxInfo
        me @ "Options"
        1 "Set Gender"
        2 "Set Species"
        8 "Save"
        9 "Quit"
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
    1 "Yes"
    2 "No"
    2 80 doMenu
    ref @ swap "aup_accepted" swap setConfig
;

: doSubmit
    var ref
    ref !

    me @ "Are you sure you wish to submit your application?"
    1 "Yes"
    2 "No"
    2 0 doMenu case
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
    1 "Accept"
    2 "Reject"
    3 "Defer"
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

: show_help
    me @ command @ " Command Help" strcat 80 boxTitle
    me @ "editplayer - Change player information, character information, and preferences." 80 boxContent
    me @ "@request <NAME> - Request character NAME for approval." 80 boxContent
    me @ "@request #process - WIZARDS ONLY: Process a character application." 80 boxContent
    me @ "pinfo <NAME> - View NAME's player information." 80 boxContent
    me @ "cinfo <NAME> - View NAME's character information." 80 boxContent
    me @ me @ 80 line box_color tell 
;

: main
    var newPRef
    dup "help" paramTest if show_help exit then
    command @ tolower case
        "editplayer" stringcmp not when pop
            begin
                me @ "Player Editor"
                1 "Player Information"
                2 "Character Information"
                3 "Preferences"
                9 "Quit"
            4 0 doMenu dup 9 = not while
                case
                    1 = when me @ doPInfo end
                    2 = when me @ doCInfo end
                    3 = when doPrefs end
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
                        1 "Basics"
                        2 "Player Information"
                        3 "Character Information"
                        4 "Read AUP - " me @ "EXTREMELY IMPORTANT" error_color strcat
                        8 "Submit"
                        9 "Quit"
                    6 0 doMenu dup 9 = not while
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
    endcase
;
.
c
q

