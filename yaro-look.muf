@q
@program yaro-look.muf
1 999999 del
i
$include $lib/yaro
$include $cmd/status

: cansee? ( d -- n )
    dup "D" flag? over me @ control? and swap "D" flag? not or
;

: parseDesc ( d -- s )
     dup desc "(@desc)" 0 parsempi
;

: testBox ( -- )
    me @ "Title" 25 boxTitle
    me @ "Content" 25 boxContent
    me @ "Title" 25 boxTitle
    me @ open_tag 
    me @ swap tag_color_2 
    me @ "TAG" tag_color_1 strcat 
    me @ close_tag 
    me @ swap tag_color_2 strcat
    me @ " Listing" content_color strcat 
    me @ swap 25 boxContent
    me @ 25 line me @ swap box_color tell
    " " tell
;

: getChar ( -- s )
    me @ "Please type in a single character." note_color tell read
    1 strcut pop
;

: doInterfaceCfg ( -- )
    me @ "open_tag" getConfig me @ swap "orig/open_tag" swap setConfig
    me @ "close_tag" getConfig me @ swap "orig/close_tag" swap setConfig
    me @ "line" getConfig me @ swap "orig/line" swap setConfig
    me @ "vline" getConfig me @ swap "orig/vline" swap setConfig
    me @ "open_tag" getConfig me @ swap "temp/open_tag" swap setConfig
    me @ "close_tag" getConfig me @ swap "temp/close_tag" swap setConfig
    me @ "line" getConfig me @ swap "temp/line" swap setConfig
    me @ "vline" getConfig me @ swap "temp/vline" swap setConfig
    begin
        me @ "temp/open_tag" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "open_tag" strcat swap setConfig
        me @ "temp/close_tag" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "close_tag" strcat swap setConfig
        me @ "temp/line" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "line" strcat swap setConfig
        me @ "temp/vline" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "vline" strcat swap setConfig

        testBox

        me @ "orig/open_tag" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "open_tag" strcat swap setConfig
        me @ "orig/close_tag" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "close_tag" strcat swap setConfig
        me @ "orig/line" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "line" strcat swap setConfig
        me @ "orig/vline" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "vline" strcat swap setConfig

        me @ "Interface Configuration"
        1 "Open Tag"
        2 "Close Tag"
        3 "Horizontal Line"
        4 "Vertical Line"
        8 "Save"
        9 "Quit"
        6 0 doMenu dup 9 = not 
    while
        case
            1 = when getChar dup if me @ swap "temp/open_tag" swap setConfig else pop then end
            2 = when getChar dup if me @ swap "temp/close_tag" swap setConfig else pop then end
            3 = when getChar dup if me @ swap "temp/line" swap setConfig else pop then end
            4 = when getChar dup if me @ swap "temp/vline" swap setConfig else pop then end
            8 = when 
                me @ "temp/open_tag" getConfig me @ swap "orig/open_tag" swap setConfig
                me @ "temp/close_tag" getConfig me @ swap "orig/close_tag" swap setConfig
                me @ "temp/line" getConfig me @ swap "orig/line" swap setConfig       
                me @ "temp/vline" getConfig me @ swap "orig/vline" swap setConfig       
            end
        endcase
    repeat pop
    me @ "_config/orig" remove_prop
    me @ "_config/temp" remove_prop
;

: doColorCfg ( -- )
    me @ "color/title" getConfig me @ swap "orig/color/title" swap setConfig
    me @ "color/box" getConfig me @ swap "orig/color/box" swap setConfig
    me @ "color/content" getConfig me @ swap "orig/color/content" swap setConfig
    me @ "color/tag2" getConfig me @ swap "orig/color/tag2" swap setConfig
    me @ "color/tag1" getConfig me @ swap "orig/color/tag1" swap setConfig
    me @ "color/title" getConfig me @ swap "temp/color/title" swap setConfig
    me @ "color/box" getConfig me @ swap "temp/color/box" swap setConfig
    me @ "color/content" getConfig me @ swap "temp/color/content" swap setConfig
    me @ "color/tag2" getConfig me @ swap "temp/color/tag2" swap setConfig
    me @ "color/tag1" getConfig me @ swap "temp/color/tag1" swap setConfig
    begin 
        me @ "temp/color/title" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/title" strcat swap setConfig
        me @ "temp/color/box" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/box" strcat swap setConfig
        me @ "temp/color/content" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/content" strcat swap setConfig
        me @ "temp/color/tag2" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/tag2" strcat swap setConfig
        me @ "temp/color/tag1" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/tag1" strcat swap setConfig

        testBox

        me @ "orig/color/title" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/title" strcat swap setConfig
        me @ "orig/color/box" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/box" strcat swap setConfig
        me @ "orig/color/content" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/content" strcat swap setConfig
        me @ "orig/color/tag2" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/tag2" strcat swap setConfig
        me @ "orig/color/tag1" getConfig me @ swap 
        command @ match name ";" split pop "/" strcat "color/tag1" strcat swap setConfig

        me @ "Color Configuration"
        1 "Title Color"
        2 "Box Color"
        3 "Content Color"
        4 "Outside Tag Color"
        5 "Inside Tag Color"
        8 "Save"
        9 "Quit" 
        7 0 doMenu dup 9 = not while case
            1 = when me @ color_menu dup if me @ swap "temp/color/title" swap setConfig else pop then end
            2 = when me @ color_menu dup if me @ swap "temp/color/box" swap setConfig else pop then end
            3 = when me @ color_menu dup if me @ swap "temp/color/content" swap setConfig else pop then end
            4 = when me @ color_menu dup if me @ swap "temp/color/tag2" swap setConfig else pop then end
            5 = when me @ color_menu dup if me @ swap "temp/color/tag1" swap setConfig else pop then end
            8 = when 
                me @ "temp/color/title" getConfig me @ swap "orig/color/title" swap setConfig
                me @ "temp/color/box" getConfig me @ swap "orig/color/box" swap setConfig
                me @ "temp/color/content" getConfig me @ swap "orig/color/content" swap setConfig       
                me @ "temp/color/tag2" getConfig me @ swap "orig/color/tag2" swap setConfig       
                me @ "temp/color/tag1" getConfig me @ swap "orig/color/tag1" swap setConfig       
            end
        endcase
    repeat pop
    me @ "_config/orig" remove_prop
    me @ "_config/temp" remove_prop
;

: doConfig ( -- )
    begin testBox me @ "Look Configuration"
    1 "Interface"
    2 "Colors"
    9 "Quit"
    3 0 doMenu dup 9 = not while case
        1 = when doInterfaceCfg end
        2 = when doColorCfg end
    endcase repeat pop
    me @ "Please note that these changes only affect look!" info_color tell
;

: main ( s -- )
    dup "config" paramTest if doConfig exit then
    var description

    "" description !

    dup if
        dup match ok? if
            match dup player? if
                dup awake? if
                    dup "cinfo/lnotify" getConfig if
                        dup dup me @ name " has looked at you!" strcat note_color otell
                    then
                then
            then
        else
            "I don't see an object named \"" swap strcat "!\"" strcat
            me @ swap error_color tell exit
        then
    else
        pop loc @
    then
    dup parseDesc description !
    dup me @ swap dup dup exit? if 
        name ";" split pop
    else
        name 
    then
    me @ "look/see_refs" getConfig if
        swap me @ control? if
            " " strcat
            3 pick intostr
            "#" swap strcat
            me @ open_tag swap strcat
            me @ close_tag strcat strcat
        then
    else swap pop then

    80 boxTitle
    me @ description @ dup not if
        pop "You see absolutely positively nothing special about " 
        3 pick dup exit? if
            name ";" split pop strcat
        else
             name strcat 
        then
        "!" strcat
    then
    80 boxContent
    dup exit? not over program? not and if dup getPlayers swap pop swap array_merge dup if
        over cansee? if
            var playerList
            { } array_make playerList !
            me @ "PLAYERS" 80 boxTitle
            foreach swap pop
                dup name me @ swap content_color over get_status pop dup not if
                    pop "^CONTENT_COLOR^???"
                then 
                3 pick awake? not if
                    pop "^CONTENT_COLOR^ZZZ" 
                then 
                toupper me @ swap tag_color_1 me @ open_tag me @ swap tag_color_2 swap strcat
                me @ close_tag " " strcat me @ swap tag_color_2 strcat swap strcat
                me @ "look/see_refs" getConfig if
                    swap dup me @ control? if  
                        intostr "#" swap strcat
                        me @ open_tag " " swap strcat swap strcat
                        me @ close_tag strcat strcat
                    else
                        pop
                    then
                else swap pop then
                playerList @ swap array_append playerList !
            repeat
            me @ playerList @ 80 boxList
        else
            pop
        then
    else
        pop
    then then
    dup exit? not over program? not and if dup getThings dup if
        over cansee? if
            var playerList
            { } array_make playerList !
            me @ "CONTENTS" 80 boxTitle
            foreach swap pop
                dup name 
                me @ "look/see_refs" getConfig if
                    swap dup me @ control? if  
                        intostr "#" swap strcat
                        me @ open_tag " " swap strcat swap strcat
                        me @ close_tag strcat strcat
                    else
                        pop
                    then
                else swap pop then
                playerList @ swap array_append playerList !
            repeat
            me @ playerList @ 80 boxList
        else
            pop
        then
    else
        pop
    then then
    dup exit? not over program? not and over player? not and if dup exits_array dup if
        over cansee? if
            var playerList
            { } array_make playerList !
            me @ "OBVIOUS EXITS" 80 boxTitle
            foreach swap pop
                dup name ";" split ";" split pop dup if
                    toupper me @ swap tag_color_1 me @ open_tag swap strcat 
                    me @ swap tag_color_2 
                    me @ close_tag " " strcat me @ swap tag_color_2 strcat swap 
                    me @ swap content_color strcat
                else
                    pop
                then
                me @ "look/see_refs" getConfig if
                    swap dup me @ control? if  
                        intostr "#" swap strcat
                        me @ open_tag " " swap strcat swap strcat
                        me @ close_tag strcat me @ swap content_color strcat
                    else
                        pop
                    then
                else swap pop then
                playerList @ swap array_append playerList !
            repeat
            me @ playerList @ 80 boxList
        else
            pop
        then
    else
        pop
    then then
    me @ 80 line
    me @ swap box_color tell
    " " tell
;
.
c
q

