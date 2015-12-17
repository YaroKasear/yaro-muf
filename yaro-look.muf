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
        me @ loc @ "_details/" trap @ strcat getprop 80 boxContent
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

: main
    var look_ref
    var look_name
    var look_desc
    var see_refs

    "" look_name !
    dup "set-looktrap" paramTest if
        " " split swap pop dup if 
            dup "=" instr if
                "=" split set_looktrap
            else
                looktrap_usage
            then
        else 
            looktrap_usage
        then
        exit
    then
    me @ "look/see_refs" getConfig see_refs !
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
        strcat strcat look_name !
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
                dup name ";" split ";" split pop dup if
                    toupper "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^" swap strcat
                    "^TAG_COLOR_2^^CLOSE_TAG^ " strcat swap strcat
                else pop then
                swap dup me @ control? see_refs @ and if
                    dtos " ^OPEN_TAG^" swap strcat "^CLOSE_TAG^" strcat strcat
                else pop then
            then
        repeat } array_make dup if
            me @ "OBVIOUS EXITS" 80 boxTitle
            me @ swap 80 boxList
        else pop then
        look_ref @ getPlayers nip swap array_merge { swap foreach nip
            dup visible? not if pop else
                dup name over dup awake? if 
                    get_status pop 
                else pop "ZZZ" then
                "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^" swap strcat
                "^TAG_COLOR_2^^CLOSE_TAG^ " strcat swap strcat
                swap dup me @ control? see_refs @ and if
                    dtos " ^OPEN_TAG^" swap strcat "^CLOSE_TAG^" strcat strcat
                else pop then
            then
        repeat } array_make dup if
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
            me @ "VISIBLE CONTENTS" 80 boxTitle
            me @ swap 80 boxList
        else pop then
    then
    me @ 80 line "^BOX_COLOR^" swap strcat tell
    me @ " " tell
;
.
c
q

