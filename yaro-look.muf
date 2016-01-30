@q
@program yaro-look.muf
1 999999 del
i
$include $lib/yaro
$include $cmd/status

: visible? ( d -- n )
    var ref

    ref !
    ref @ "D" flag? not
    loc @ "D" flag? not and
    loc @ "O" flag? or
    ref @ "O" flag? or
    ref @ me @ control? or
    loc @ me @ control? or
    ref @ exit? if
        ref @ getlink room? and
    then
;

: container? ( d -- n )
    var ref

    ref !
    ref @ player?
    ref @ room? or
    ref @ thing? or
;

: get_looktraps ( d -- s ... s' )
    var ref

    ref !
    ref @ "_details/" array_get_propvals dup if
        array_keys array_make foreach nip
            ";" split pop "^OPEN_TAG^" swap strcat
            "^CLOSE_TAG^" strcat
        repeat
    else pop then
;

: get_looktrap ( s -- )
    var trap

    trap !

    loc @ "_details/" array_get_propvals dup if
        array_keys array_make "" swap foreach
            dup trap @ instr not if pop pop
            else nip nip break then
        repeat
    else pop "" then
;

: look_looktrap ( s -- s )
    var trap
    var traplist

    trap ! trap @ get_looktrap dup if
        trap !
        me @ trap @ ";" split pop 80 boxTitle
        me @ loc @ loc @ "_details/" trap @ strcat getprop "(MUF)" 1 parsempi 80 boxContent
        "^BOX_COLOR^" me @ 80 line strcat tell
        " " tell
    else
        pop "^ERROR_COLOR^I don't see any " trap @ strcat " here." strcat tell
    then
;

: set_looktrap ( s s -- )
    var description
    var trap

    description !
    trap !
    trap @ get_looktrap dup if
        trap !
    else
        pop
    then
    loc @ "_details/" trap @ strcat description @ setprop

    description @ dup if
        "^SUCCESS_COLOR^Set looktrap " trap @ ";" split pop strcat "!" strcat tell
    else
        "^SUCCESS_COLOR^Cleared looktrap " trap @ ";" split pop strcat "!" strcat tell
    then
;

: looktrap_usage
    "^NOTE_COLOR^Usage: ^INFO_COLOR^" command @ strcat
    " #set-looktrap <TRAP_NAME>[;][ALIAS1][;][ALIAS2]=[DESCRIPTION]" strcat tell
    "^NOTE_COLOR^This creates a virtual object for viewing with look!" tell
    "^NOTE_COLOR^Example Use: look #set-looktrap Pile of Bugs;pile;bugs;bugpile=This"
    " is a big pile of bugs. Looks delicious!" strcat tell
    "^NOTE_COLOR^This will create an \"object\" called \"Pile of Bugs\" in the room"
    " and give it the description." strcat tell
    "^NOTE_COLOR^Issuing look #set-looktrap pile= with no description will clear"
    " the looktrap." strcat tell
;

: toggle_refs
    me @ "look/see_refs" getConfig if
        me @ "look/see_refs" 0 setConfig
        "^SUCCESS_COLOR^Now hiding controlled dbrefs." tell
    else
        me @ "look/see_refs" 1 setConfig
        "^SUCCESS_COLOR^Now showing controlled dbrefs." tell
    then
;

: toggle_sleepers
    me @ "look/hide_sleepers" getConfig if
        me @ "look/hide_sleepers" 0 setConfig
        "^SUCCESS_COLOR^Now showing sleeping players." tell
    else
        me @ "look/hide_sleepers" 1 setConfig
        "^SUCCESS_COLOR^Now hiding sleeping players." tell
    then
;

: show_help
    me @ trigger @ name ";" split pop " Help" strcat 80 boxTitle
    me @ { 
    { "^FIELD_COLOR^" trigger @ name ";" split pop strcat " [OBJECT]" strcat
    "^CONTENT_COLOR^Show description, contents, and exits for [OBJECT]." } array_make
    loc @ me @ control? if
        { "^FIELD_COLOR^" trigger @ name ";" split pop strcat " #set-looktrap" strcat
        "^CONTENT_COLOR^Set up looktraps in the current room." } array_make
    then
    { "^FIELD_COLOR^" trigger @ name ";" split pop strcat " #show-refs" strcat
    "^CONTENT_COLOR^Toggle if dbrefs are shown for objects you control." } array_make
    { "^FIELD_COLOR^" trigger @ name ";" split pop strcat " #hide-sleepers" strcat
    "^CONTENT_COLOR^Toggle if you see sleeping players or not." } array_make
    { "^FIELD_COLOR^" trigger @ name ";" split pop strcat " #help" strcat
    "^CONTENT_COLOR^Show this box" } array_make } array_make 80 boxInfo
    me @ flush_buffer
    "^BOX_COLOR^" me @ 80 line strcat tell
    " " tell
;

: main
    var look_ref
    var look_name
    var look_desc
    var see_refs
    var hide_sleepers

    "" look_name !
    strip
    dup "#" instr 1 = if
        dup "set-looktrap" paramTest if
            " " split swap pop dup if 
                dup "=" instr if
                    loc @ me @ control? if
                        "=" split set_looktrap
                    else
                        "^ERROR_COLOR^You do not have permissions to create a looktrap here." tell
                    then
                else
                    looktrap_usage
                then
            else 
                looktrap_usage
            then
            exit
        then
        dup "show-refs" paramTest if toggle_refs exit then
        dup "hide-sleepers" paramTest if toggle_sleepers exit then
        dup "help" paramTest if show_help exit then
    then
    me @ "look/see_refs" getConfig see_refs !
    me @ "look/hide_sleepers" getConfig hide_sleepers !
    case
        dup not if pop loc @ end
        dup match ok? when match end
        default pop pop look_looktrap exit end
    endcase
    look_ref !
    look_ref @ case
        player? when
            look_ref @ "cinfo/lnotify" getConfig if
                look_ref @ me @ name " has looked at you!" strcat "^NOTE_COLOR^" swap strcat
                otell
            then
            look_ref @ "~sex" getprop dup if
                tolower look_name !
            else pop then
            look_ref @ "~species" getprop dup if
                look_name @ dup if
                    " " strcat swap strcat
                else pop then
                tolower look_name !
            else pop then
            look_name @ dup if
                " named " strcat "A " swap strcat
                look_name !
            else pop then
            look_ref @ name look_name @ swap strcat look_name !
        end
        exit? when
            look_ref @ name ";" split pop look_name !
        end
        default pop look_ref @ name look_name ! end
    endcase
    look_ref @ me @ control? see_refs @ and if
        look_name @ " ^OPEN_TAG^" look_ref @ dtos strcat "^CLOSE_TAG^"
        strcat strcat me @ swap process_tags look_name !
    then
    me @ look_name @ 80 boxTitle
    look_ref @ "_/de" "(MUF)" 1 parseprop dup not if
        pop "You see nothing special about " look_name @ strcat "." strcat
    then
    look_desc !
    me @ look_desc @ 80 boxContent
    look_ref @ visible? look_ref @ container? and if
        look_ref @ exits_array { swap foreach nip
            dup visible? 
            look_ref @ player? not and
            look_ref @ "O" flag? or
            over "O" flag? or not if pop else
                { swap
                dup name ";" split ";" split pop dup if
                    toupper "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^" swap strcat
                    "^TAG_COLOR_2^^CLOSE_TAG^^CONTENT_COLOR^" strcat
                else pop "" swap then swap
                rot dup me @ control? see_refs @ and if
                    dtos " ^OPEN_TAG^" swap strcat "^CLOSE_TAG^" strcat strcat
                else pop then } array_make
            then 
        repeat } array_make dup if
            0 1 array_sort_indexed
            0 0 array_sort_indexed
            me @ "OBVIOUS EXITS" 80 boxTitle
            me @ swap 80 boxInfo
        else pop then
        look_ref @ getPlayers nip hide_sleepers @ not if swap array_merge else pop then { swap foreach nip 
            dup visible? not if pop else
                dup name over dup awake? if 
                    get_status pop 
                else pop "ZZZ" then
                "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^" swap strcat
                "^TAG_COLOR_2^^CLOSE_TAG^^CONTENT_COLOR^ " strcat swap strcat
                swap dup me @ control? see_refs @ and if
                    dtos " ^OPEN_TAG^" swap strcat "^CLOSE_TAG^" strcat strcat
                else pop then
            then
        repeat } array_make dup if
            0 array_sort
            me @ "VISIBLE PLAYERS" 80 boxTitle
            me @ swap 80 boxList
        else pop then
        look_ref @ contents_array { swap foreach nip
            dup player? not over visible? and not if pop else
                dup name
                swap dup me @ control? see_refs @ and if
                    dtos " ^OPEN_TAG^" swap strcat "^CLOSE_TAG^" strcat strcat
                else pop then
            then
        repeat look_ref @ room? if look_ref @ get_looktraps then } array_make dup if
            0 array_sort
            me @ "VISIBLE CONTENTS" 80 boxTitle
            me @ swap 80 boxList
        else pop then
    then
    me @ flush_buffer
    me @ 80 line "^BOX_COLOR^" swap strcat tell
    me @ " " tell
;
.
c
q

