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

: main
    var look_ref
    var look_name
    var look_desc
    var see_refs

    "" look_name !
    me @ "look/see_refs" getConfig see_refs !
    case
        dup not if pop loc @ end
        dup match ok? when match end
        default pop "^ERROR_COLOR^I do not see anything called " swap strcat "." strcat tell exit end
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
                dup name ";" split ";" split pop
                toupper "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^" swap strcat
                "^TAG_COLOR_2^^CLOSE_TAG^ " strcat swap strcat
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
        repeat } array_make dup if
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

