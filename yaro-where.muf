@q
@program yaro-where.muf
1 9999 del
i
$include $lib/yaro

: get_info ( d n -- s s s s s s )
    var ref
    var c

    c !
    ref !

    ref @ name
    ref @ "~sex" getprop dup not if pop "U" then 1 strcut pop
    toupper dup case
        "M" stringcmp not when "^CYAN^" swap strcat end
        "F" stringcmp not when "^PURPLE^" swap strcat end
        default pop "^WHITE^" swap strcat end
    endcase cleanString "^CONTENT_COLOR^" strcat me @ swap process_tags
    ref @ "~species" getprop dup not if pop "Unknown" then
    ref @ awake? if
        ref @ "~status" getConfig dup not if
            pop "???"
        then
    else
        "ZZZ"
    then toupper
    c @ dup -1 = not if conidle time_format else pop "N/A" then
    ref @ location name
;

: do_ws 
    var ref

    ref !

    ref @ name 
    ref @ "~sex" getprop dup not if pop "U" then 1 strcut pop
    toupper dup case
        "M" stringcmp not when "^CYAN^" swap strcat end
        "F" stringcmp not when "^PURPLE^" swap strcat end
        default pop "^WHITE^" swap strcat end
    endcase cleanString "^CONTENT_COLOR^" strcat me @ swap process_tags
    ref @ "~species" getprop dup not if pop "Unknown" then
    ref @ awake? if
        ref @ "~status" getConfig dup not if
            pop "???"
        then
    else
        "ZZZ"
    then toupper
    ref @ awake? if
        ref @ descrleastidle descrcon conidle time_format
    else
        "N/A"
    then
;

: main
    var ref
    var p

    command @ tolower case
        dup "where" swap instr swap "find" swap instr or when
            dup if 
                pmatch dup ok? over player? and if
                    { } array_make over array_append
                else
                    0 array_make 
                then 
            else
                pop #0 online array_make 
            then
            p !
        
            me @ "Player Locations" 80 boxtitle
            me @ { "Name" "Sex" "Species" "Status" "Idle" "Room" } array_make
            { p @ array_dedup foreach swap pop ref ! 
                ref @ descriptors array_make dup array_count 0 > if 
                    foreach swap pop
                        { swap ref @ swap descrcon get_info } array_make
                    repeat 
                else
                    pop { ref @ -1 get_info } array_make
                then
            repeat } array_make
            SORTTYPE_CASE_ASCEND 0 array_sort_indexed SORTTYPE_CASE_ASCEND 5 array_sort_indexed 80 boxtable
            #-1 = if
                me @ "unable to find a player with that name." 80 boxcontent
            then
            me @ concount intostr " players online" strcat 80 boxtitle
            " " tell
        end
        dup "whospecies" swap instr swap "ws" swap instr or when
            me @ "Players in " loc @ name strcat 50 boxTitle
            me @ { "Name" "Sex" "Species" "Status" "Idle" } array_make 
            loc @ getplayers swap pop swap { swap array_dedup foreach swap pop
                { swap do_ws } array_make
            repeat 
            } array_make 
            me @ "where/show_sleepers" getConfig if
                swap { swap foreach swap pop
                    { swap do_ws } array_make
                repeat } array_make array_union
            else swap pop then
            SORTTYPE_CASE_ASCEND 4 array_sort_indexed 50 boxTable
            me @ me @ 50 line box_color tell
        end 
        default
            me @ "please tell " prog owner name strcat " that the illegal command "
            strcat " has been linked to " prog name strcat "." strcat error_color tell
        end
    endcase
;
.
c
q

