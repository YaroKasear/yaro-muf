@q
@program lib-yaro
1 99999 del
i

lvar cache

: make_cache_key ( d s -- s )
    swap dtos "_" strcat swap strcat
;

: cache_gen ( -- )
    cache @ array? not if
        { }dict cache !
    then
;

: cache_read ( s -- x )
    cache_gen
    cache @ swap array_getitem
;

: cache_write ( s x -- )
    cache_gen
    swap cache @ swap array_insertitem cache !
;

: cache_delete ( s -- )
    cache_gen
    dup cache @ swap array_getitem if
        cache @ swap array_delitem cache !
    else pop then
;

: clear_cache ( -- )
    0 cache ! cache_gen
;

: time_explode ( i -- i i i i i i )
    var time_value
    var moons
    var weeks
    var days
    var hours
    var minutes
    var seconds

    time_value ! time_value @ 2419200 / moons !
    time_value @ 604800 / 4 % weeks !
    time_value @ 86400 / 7 % days !
    time_value @ 3600 / 24 % hours !
    time_value @ 60 / 60 % minutes !
    time_value @ 60 % seconds !
    moons @ weeks @ days @ hours @ minutes @ seconds @
;

: time_format ( i -- s )
    var t

    var h
    var m
    var s

    t !

    t @ 3600 / h !
    t @ 60 / 60 % m !
    t @ 60 % s !

    h @ intostr ":" strcat
    m @ intostr dup strlen 1 = if "0" swap strcat then ":" strcat strcat
    s @ intostr dup strlen 1 = if "0" swap strcat then strcat
;

: cleanString ( s -- s )
    dup "^" instr if
        ( dup "^^" instr not if )
            "^RED^" dup 1 parse_ansi swap subst
            "^CRIMSON^" dup 1 parse_ansi swap subst
            "^CRED^" dup 1 parse_ansi swap subst
            "^BRED^" dup 1 parse_ansi swap subst
            "^GREEN^" dup 1 parse_ansi swap subst
            "^FOREST^" dup 1 parse_ansi swap subst
            "^CGREEN^" dup 1 parse_ansi swap subst
            "^BGREEN^" dup 1 parse_ansi swap subst
            "^YELLOW^" dup 1 parse_ansi swap subst
            "^BROWN^" dup 1 parse_ansi swap subst
            "^CYELLOW^" dup 1 parse_ansi swap subst
            "^BYELLOW^" dup 1 parse_ansi swap subst
            "^BLUE^" dup 1 parse_ansi swap subst
            "^NAVY^" dup 1 parse_ansi swap subst
            "^CBLUE^" dup 1 parse_ansi swap subst
            "^BBLUE^" dup 1 parse_ansi swap subst
            "^PURPLE^" dup 1 parse_ansi swap subst
            "^VIOLET^" dup 1 parse_ansi swap subst
            "^CPURPLE^" dup 1 parse_ansi swap subst
            "^BPURPLE^" dup 1 parse_ansi swap subst
            "^CYAN^" dup 1 parse_ansi swap subst
            "^AQUA^" dup 1 parse_ansi swap subst
            "^CCYAN^" dup 1 parse_ansi swap subst
            "^BCYAN^" dup 1 parse_ansi swap subst
            "^WHITE^" dup 1 parse_ansi swap subst
            "^GRAY^" dup 1 parse_ansi swap subst
            "^CWHITE^" dup 1 parse_ansi swap subst
            "^BWHITE^" dup 1 parse_ansi swap subst
            "^BLACK^" dup 1 parse_ansi swap subst
            "^GLOOM^" dup 1 parse_ansi swap subst
            "^CBLACK^" dup 1 parse_ansi swap subst
            "^BBLACK^" dup 1 parse_ansi swap subst
            "^CFAIL^" dup 1 parse_ansi swap subst
            "^CSUCC^" dup 1 parse_ansi swap subst
            "^CINFO^" dup 1 parse_ansi swap subst
            "^CNOTE^" dup 1 parse_ansi swap subst
            "^CMOVE^" dup 1 parse_ansi swap subst
            "^" "^ESCAPE^" subst
        ( then )
    then
;

: readConf ( d s -- x )
    var key
    var ref

    key !
    ref !

    ref @ key @ "#" strcat propdir? if
        ref @ key @ "#" strcat array_get_proplist dup if
            exit
        else
            pop
        then
    else ref @ key @ propdir? if
        ref @ key @ array_get_propvals dup if
            exit
        else
            pop
        then
    else
        ref @ key @ getprop dup if
            exit
        else
            pop
        then
    then then
    0
;

: getConfig ( x s -- x )
    var ref
    var key
    var myValue
    var myKey
    var myProgKey
    var cache_key

    key !
    dup array? not if
        { swap } array_make
    then
    foreach nip
        ref !

        ref @ key @ make_cache_key cache_key !

        cache_key @ cache_read dup if exit else pop then

        key @ "_config/" swap strcat myKey !
        command @ match ok? if
            "_config/" command @ match name ";" split pop strcat "/" strcat key @ strcat myProgKey !
        else
            myKey @ myProgKey !
        then

        ref @ myProgKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
        ref @ myKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
    repeat
    loc @ begin dup while
        dup myProgKey @ readConf dup if dup cache_key @ swap cache_write nip exit else pop then
        dup myKey @ readConf dup if dup cache_key @ swap cache_write nip exit else pop then
        location
    repeat pop
    trigger @ ok? if
        trigger @ myProgKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
        trigger @ myKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
    then
    prog myProgKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
    prog myKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
    0
;

: error_color ( d s -- s )
    var cache_key
    over "prefs/color/error_color" make_cache_key cache_key !
    over "prefs/color/error_color" getConfig dup if
        swap strcat
    else
        pop "^CFAIL^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: success_color ( d s -- s )
    var cache_key
    over "prefs/color/success_color" make_cache_key cache_key !
    over "prefs/color/success_color" getConfig dup if
        swap strcat
    else
        pop "^CSUCC^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: info_color ( d s -- s )
    var cache_key
    over "prefs/color/info_color" make_cache_key cache_key !
    over "prefs/color/info_color" getConfig dup if
        swap strcat
    else
        pop "^CINFO^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: note_color ( d s -- s )
    var cache_key
    over "prefs/color/note_color" make_cache_key cache_key !
    over "prefs/color/note_color" getConfig dup if
        swap strcat
    else
        pop "^CNOTE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: tag_color_1 ( d s -- s )
    var cache_key
    over "prefs/color/tag1" make_cache_key cache_key !
    over "prefs/color/tag1" getConfig dup if
        swap strcat
    else
        pop "^WHITE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: tag_color_2 ( d s -- s )
    var cache_key
    over "prefs/color/tag2" make_cache_key cache_key !
    over "prefs/color/tag2" getConfig dup if
        swap strcat
    else
        pop "^FOREST^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: ooc_color_1 ( d s -- s )
    var cache_key
    over "prefs/color/ooc1" make_cache_key cache_key !
    over "prefs/color/ooc1" getConfig dup if
        swap strcat
    else
        pop "^AQUA^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: ooc_color_2 ( d s -- s )
    var cache_key
    over "prefs/color/ooc2" make_cache_key cache_key !
    over "prefs/color/ooc2" getConfig dup if
        swap strcat
    else
        pop "^GRAY^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: ooc_name_color ( d s -- s )
    var cache_key
    over "prefs/color/oocn" make_cache_key cache_key !
    over "prefs/color/oocn" getConfig dup if
        swap strcat
    else
        pop "^OOC_COLOR_1^" dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: ic_color_1 ( d s -- s )
    var cache_key
    over "prefs/color/ic1" make_cache_key cache_key !
    over "prefs/color/ic1" getConfig dup if
        swap strcat
    else
        pop "^WHITE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: ic_color_2 ( d s -- s )
    var cache_key
    over "prefs/color/ic2" make_cache_key cache_key !
    over "prefs/color/ic2" getConfig dup if
        swap strcat
    else
        pop "^WHITE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: ic_name_color ( d s -- s )
    var cache_key
    over "prefs/color/icn" make_cache_key cache_key !
    over "prefs/color/icn" getConfig dup if
        swap strcat
    else
        pop "^IC_COLOR_1^" dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: title_color ( d s -- s )
    var cache_key
    over "prefs/color/title" make_cache_key cache_key !
    over "prefs/color/title" getConfig dup if
        swap strcat
    else
        pop "^WHITE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: option_color_1 ( d s -- s )
    var cache_key
    over "prefs/color/opt1" make_cache_key cache_key !
    over "prefs/color/opt1" getConfig dup if
        swap strcat
    else
        pop "^GREEN^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: option_color_2 ( d s -- s )
    var cache_key
    over "prefs/color/opt2" make_cache_key cache_key !
    over "prefs/color/opt2" getConfig dup if
        swap strcat
    else
        pop "^GRAY^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: box_color ( d s -- s )
    var cache_key
    over "prefs/color/box" make_cache_key cache_key !
    over "prefs/color/box" getConfig dup if
        swap strcat
    else
        pop "^AQUA^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: content_color ( d s -- s )
    var cache_key
    over "prefs/color/content" make_cache_key cache_key !
    over "prefs/color/content" getConfig dup if
        swap strcat
    else
        pop "^GRAY^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: field_color ( d s -- s )
    var cache_key
    over "prefs/color/field" make_cache_key cache_key !
    over "prefs/color/field" getConfig dup if
        swap strcat
    else
        pop "^WHITE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: line ( d n -- )
    var myLine
    var outputLine
    var length
    var cache_key

    over "prefs/line" make_cache_key cache_key !

    swap "prefs/line" getConfig dup not if
        pop "-------------------------------------------------------------------" dup cache_key @ swap cache_write
    then
    myLine !
    dup 0 < if
        pop 0
    then
    length !

    myLine @ cleanString outputLine !

    begin outputLine @ ansi_strlen length @ = not while
        outputLine @ ansi_strlen length @ > if
            outputLine @ length @ ansi_strcut pop outputLine !
        else
            outputLine @ outputLine @ strcat outputLine !
        then
    repeat
    outputLine @
;

: space ( n -- )
    var length
    var outputLine

    dup 0 < if
        pop 0
    then
    length !

    "                                                                           "
    outputLine !

    begin outputLine @ ansi_strlen length @ = not while
        outputLine @ ansi_strlen length @ > if
            outputLine @ length @ ansi_strcut pop outputLine !
        else
            outputLine @ outputLine @ strcat outputLine !
        then
    repeat
    outputLine @
;

: open_tag ( d -- s )
    var cache_key
    dup "prefs/open_tag" make_cache_key cache_key !
    "prefs/open_tag" getConfig dup not if
        pop "[" dup cache_key @ swap cache_write
    then
;

: close_tag ( d -- s )
    var cache_key
    dup "prefs/close_tag" make_cache_key cache_key !
    "prefs/close_tag" getConfig dup not if
        pop "]" dup cache_key @ swap cache_write
    then
;

: option_tag ( -- s )
    var cache_key
    dup "prefs/option_tag" make_cache_key cache_key !
    "prefs/option_tag" getConfig dup not if
        pop ")" dup cache_key @ swap cache_write
    then
;

: vline ( -- s )
    var cache_key
    dup "prefs/vline" make_cache_key cache_key !
    "prefs/vline" getConfig dup not if
        pop "|" dup cache_key @ swap cache_write
    then
;

: say ( d -- s )
    "prefs/say" getConfig dup not if
        pop "say"
    then
;

: says ( d -- s )
    "prefs/says" getConfig dup not if
        pop "says"
    then
;

: process_tags ( d s -- s )
    var s
    var ref

    s !
    ref !

    s @ "^" instr if
        ( s @ dup "^^" instr not if )
            s @
            dup toupper "^ERROR_COLOR^" instr if ref @ "" error_color    "^ERROR_COLOR^" subst then
            dup toupper "^SUCCESS_COLOR^" instr if ref @ "" success_color  "^SUCCESS_COLOR^" subst then
            dup toupper "^INFO_COLOR^" instr if ref @ "" info_color     "^INFO_COLOR^" subst then
            dup toupper "^NOTE_COLOR^" instr if ref @ "" note_color     "^NOTE_COLOR^" subst then
            dup toupper "^TAG_COLOR_1^" instr if ref @ "" tag_color_1    "^TAG_COLOR_1^" subst then
            dup toupper "^TAG_COLOR_2^" instr if ref @ "" tag_color_2    "^TAG_COLOR_2^" subst then
            dup toupper "^OOC_COLOR_1^" instr if ref @ "" ooc_color_1    "^OOC_COLOR_1^" subst then
            dup toupper "^OOC_COLOR_2^" instr if ref @ "" ooc_color_2    "^OOC_COLOR_2^" subst then
            dup toupper "^OOC_NAME_COLOR^" instr if ref @ "" ooc_name_color "^OOC_NAME_COLOR^" subst then
            dup toupper "^OPTION_COLOR_1^" instr if ref @ "" option_color_1 "^OPTION_COLOR_1^" subst then
            dup toupper "^OPTION_COLOR_2^" instr if ref @ "" option_color_2 "^OPTION_COLOR_2^" subst then
            dup toupper "^IC_COLOR_1^" instr if ref @ "" ic_color_1       "^IC_COLOR_1^" subst then
            dup toupper "^IC_COLOR_2^" instr if ref @ "" ic_color_2       "^IC_COLOR_2^" subst then
            dup toupper "^IC_NAME_COLOR^" instr if ref @ "" ic_name_color "^IC_NAME_COLOR^" subst then
            dup toupper "^TITLE_COLOR^" instr if ref @ "" title_color    "^TITLE_COLOR^" subst then
            dup toupper "^FIELD_COLOR^" instr if ref @ "" field_color    "^FIELD_COLOR^" subst then
            dup toupper "^BOX_COLOR^" instr if ref @ "" box_color      "^BOX_COLOR^" subst then
            dup toupper "^CONTENT_COLOR^" instr if ref @ "" content_color  "^CONTENT_COLOR^" subst then
            dup toupper "^OPEN_TAG^" instr if ref @ open_tag  "^OPEN_TAG^" subst then
            dup toupper "^CLOSE_TAG^" instr if ref @ close_tag  "^CLOSE_TAG^" subst then
            dup toupper "^VLINE^" instr if ref @ vline  "^VLINE^" subst then
            dup toupper "^UNDERLINE^" instr if "\[[4m" "^UNDERLINE^" subst then
            dup toupper "^BOLD^" instr if "\[[1m" "^BOLD^" subst then
            dup toupper "^DARK^" instr if "\[[2m" "^DARK^" subst then
            dup toupper "^UNDERLINE^" instr if "\[[4m" "^UNDERLINE^" subst then
            dup toupper "^FLASH^" instr if "\[[5m" "^FLASH^" subst then
            dup toupper "^INVERT^" instr if "\[[7m" "^INVERT^" subst then
            dup toupper "^RESET^" instr if "\[[0m" "^RESET^" subst then
            dup toupper "^FRANDOM^" instr if
                "\[[0;3" random 8 % intostr strcat
                ";" strcat random 6 % case
                    0 = when "0" end
                    1 = when "1" end
                    2 = when "2" end
                    3 = when "4" end
                    4 = when "5" end
                    5 = when "7" end
                endcase
                strcat "m" strcat
            "^FRANDOM^" subst then
            dup toupper "^BRANDOM^" instr if
                "\[[4" random 8 % intostr strcat
                ";" strcat random 6 % case
                    0 = when "0" end
                    1 = when "1" end
                    2 = when "2" end
                    3 = when "4" end
                    4 = when "5" end
                    5 = when "7" end
                endcase
                strcat "m" strcat
            "^BRANDOM^" subst then
            "\\^(\\d+)\\^" "\[[38;5;\\1m" REG_ALL REGSUB
            cleanString
        ( then )
    else s @ then
;

: tell ( s -- )
    me @ swap process_tags cleanString
    me @ swap notify
;

: otell ( d s -- )
    over swap process_tags cleanString
    notify
;

: array_append ( a x -- a )
    swap dup array_count array_insertitem
;

: array_extract ( a n -- a x )
    var arr
    var n

    n !
    arr !

    arr @ n @ array_getitem
    arr @ n @ array_delitem swap
;

: array_dedup ( a -- a )
    dup foreach
        swap pop 1 array_make array_union
    repeat
;

: array_merge ( a a -- a )
    var arr1
    var arr2

    arr1 !
    arr2 !

    arr1 @ arr1 @ array_count arr2 @ array_insertrange
;

: array_to_menu ( a -- @ s ... @' s' n )
    { swap foreach swap 1 + swap over repeat } 3 /
;

: format_left ( s n -- s )
    var length
    var text

    length !
    cleanString text !

    length @ text @ ansi_strlen -
    space text @ swap strcat
;

: format_center ( s n -- s )
    var length
    var text

    length !
    cleanString text !

    length @ text @ ansi_strlen -
    space length @ text @ ansi_strlen - 2 / ansi_strcut
    text @ swap strcat strcat
;

: format_right ( s n -- s )
    var length
    var text

    length !
    cleanString text !

    length @ text @ ansi_strlen - space text @ strcat
;

: columns ( strings number width -- a )
    var width
    var number
    var strings

    var full_rows
    var rows
    var extra_entries
    var per_row

    var current_row
    var row_buffer
    var row_strings

    "" row_buffer !
    { } array_make row_strings !

    width !
    number !
    { swap foreach swap pop
        cleanString
    repeat } array_make strings !
    number @ strings @ array_count > if strings @ array_count number ! then
    strings @ array_count number @ / dup full_rows !
    strings @ array_count number @ % dup if extra_entries ! 1 + else pop then rows !
    strings @ array_count full_rows @ / per_row !
    {
    begin strings @ array_count full_rows @ >= while
        strings @ full_rows @ extra_entries @ if
            1 + extra_entries @ 1 - extra_entries !
        then
        array_cut strings !
    repeat
    } array_make foreach swap pop
        dup array_count rows @ < if
            dup array_count rows @ swap - 1 swap 1 for pop
                " " array_append
            repeat
        then
    repeat
    0 rows @ 1 - 1 for current_row !
        1 number @ 1 for pop
            number @ rotate 0 array_extract
            width @ number @ / format_left
            row_buffer @ swap strcat row_buffer !
        repeat
        row_strings @ row_buffer @ array_append row_strings !
        "" row_buffer !
    repeat number @ popn row_strings @
;

: format_wrap ( string width -- formatted_output )
    var content
    var width

    var strings
    var output

    var buffer

    width !
    cleanString content !

    content @ "\r" explode array_make array_reverse strings !

    { } array_make output !

    strings @ foreach swap pop buffer !
        begin buffer @ ansi_strlen width @ > while
            buffer @ width @ ansi_strcut swap
            dup " " rinstr if
                " " rsplit rot strcat buffer !
            else
                pop swap buffer !
            then
            output @ swap strip array_append output !
        repeat
        output @ buffer @ strip array_append output !
    repeat
    output @
;

: getPlayers ( x -- a a a )
    var validRefs
    var invalidRefs
    var asleepRefs

    { } array_make
    dup validRefs !
    dup invalidRefs !
    asleepRefs !

    dup case
        string? when
            " " explode array_make foreach swap pop
                dup if dup pmatch dup player? over ok? and if
                    swap pop dup awake? if
                        validRefs @ swap array_append validRefs !
                    else
                        asleepRefs @ swap array_append asleepRefs !
                    then
                else
                    pop invalidRefs @ swap array_append invalidRefs !
                then else pop then
            repeat
        end
        dbref? when
            contents begin dup while
                dup player? if
                    dup awake? if
                        validRefs @ over array_append validRefs !
                    else
                        asleepRefs @ over array_append asleepRefs !
                    then
                else
                then
                next
            repeat pop
        end
    endcase

    validRefs @
    invalidRefs @
    asleepRefs @
;

: getThings ( d -- a )
    var thingRefs
    { } array_make thingRefs !

    contents begin dup ok? while
        dup thing? over program? or if
            dup thingRefs @ swap array_append thingRefs !
        then
        next
    repeat
    pop thingRefs @
;

: getExits ( d -- a )
    var exitRefs
    { } array_make exitRefs !

    exits begin dup ok? while
        dup exitRefs @ swap array_append exitRefs !
        next
    repeat
    pop exitRefs @
;

: showPreview
    me @ open_tag me @ swap tag_color_2 me @ "OOC" tag_color_1 strcat
    me @ close_tag " " strcat me @ swap tag_color_2 strcat
    me @ me @ name " says, \"" strcat ooc_color_1 strcat me @ "Test." ooc_color_2 strcat
    me @ "\"" ooc_color_1 strcat tell
;

: doTest
    me @ "This is what your current configuration looks like." info_color tell " " tell
    me @ "SUCCESS COLOR" success_color tell
    me @ "ERROR COLOR" error_color tell
    me @ "INFORMATION COLOR" info_color tell
    me @ "NOTE COLOR" note_color tell
    me @ "TAG COLOR 1" tag_color_1 tell
    me @ "TAG COLOR 2" tag_color_2 tell
    me @ "OOC COLOR 1" ooc_color_1 tell
    me @ "OOC COLOR 2" ooc_color_2 tell
    " " tell
    me @ "Preview of visual configuration." info_color tell " " tell showPreview
;

: setConfigCommand ( d s s s -- )
    match name ";" split pop
    "_config/" swap strcat "/" strcat
    rot strcat swap setprop
;

: setConfig ( d s x -- )
    var val
    var key
    var ref

    val !
    key !
    ref !

    ref @ key @ make_cache_key cache_delete

    ref @ "_config/" key @ strcat val @ dup array? if
        dup dictionary? if
            array_put_propvals
        else
            array_put_proplist
        then
    else
        setprop
    then
;

: control? ( d d -- )
    dup player? if
        dup rot owner = swap "W" flag? or
    else
        pop pop 0
    then
;

: boxInfo ( d a n -- )
    var width
    var content
    var ref

    var right_longest
    var left_longest
    var wrap_point

    width !
    content !
    ref !

    content @ foreach nip
        array_vals pop
        ref @ swap process_tags ansi_strlen dup
        right_longest @ > if right_longest ! else pop then
        ref @ swap process_tags ansi_strlen dup
        left_longest @ > if left_longest ! else pop then
    repeat
    ( width @ 4 - right_longest @ - wrap_point !
    left_longest @ wrap_point @ > if left_longest @ ++ wrap_point ! then )
    left_longest @ right_longest @ > if
        left_longest @ ++ wrap_point !
        wrap_point @ width @ 4 - right_longest @ - > if
            width @ 4 - right_longest @ - wrap_point !
        then
    else left_longest @ right_longest @ < if
        width @ 4 - right_longest @ - wrap_point !
        wrap_point @ left_longest @ ++ < if
            left_longest @ ++ wrap_point !
        then
    else
        width @ 4 - 2 / wrap_point !
    then then
    content @ foreach nip
        array_vals pop ref @ swap process_tags width @ 4 - wrap_point @ - format_wrap
        swap ref @ swap process_tags wrap_point @ format_wrap swap
        over over array_count swap array_count swap over over > if
            - 1 swap 1 for pop
                "" swap array_appenditem
            repeat
        else over over < if
            swap - rot rot swap rot 1 swap 1 for pop
                "" swap array_appenditem
            repeat
            swap
        else pop pop then then
        dup array_count 1 swap 1 for pop
            0 array_extract dup ansi_strlen
            width @ 4 - wrap_point @ - swap - space strcat
            rot 0 array_extract dup ansi_strlen
            wrap_point @ swap - space strcat
            rot strcat "^BOX_COLOR^^VLINE^^RESET^ " swap strcat
            " ^BOX_COLOR^^VLINE^" strcat ref @ swap otell swap
        repeat 2 popn
    repeat
;

: boxTitle ( d s n -- )
    var ref
    var length
    var target

    dup target !
    rot ref !

    swap ref @ swap process_tags cleanString swap
    over ansi_strlen swap 2 /
    swap 2 / - 2 -
    dup length !
    ref @ swap line
    ref @ open_tag strcat
    ref @ swap " " strcat box_color swap
    ref @ swap title_color strcat
    ref @ close_tag " " swap strcat
    ref @ length @ line strcat
    ref @ swap box_color strcat
    ref @ swap process_tags cleanString dup ansi_strlen
    target @ > if
        target @ ansi_strcut pop
    then
    ref @ swap otell
;

: boxContent ( d s n -- )
    var ref
    var content
    var width

    width !
    content !
    ref !

    content @ width @ 4 - format_wrap foreach swap pop
        ref @ vline " " strcat
        ref @ swap box_color swap
        ref @ swap content_color strcat
        ref @ swap process_tags cleanString dup ansi_strlen width @ 1 - swap - space strcat
        ref @ vline
        ref @ swap box_color strcat
        ref @ swap otell
    repeat
;

: boxList ( d a n -- )
    var width
    var strings
    var ref

    var column_width

    width !
    swap ref !
    { swap foreach swap pop
        ref @ swap process_tags cleanString ref @ swap content_color dup ansi_strlen column_width @ > if dup ansi_strlen column_width ! then
    repeat } array_make strings !
    column_width @ 1 + column_width !

    strings @ width @ 4 - column_width @ / width @ 4 - columns foreach swap pop
        dup ansi_strlen width @ 4 - swap - space strcat
        ref @ swap content_color
        ref @ ref @ vline " " strcat box_color swap strcat
        ref @ ref @ vline " " swap strcat box_color strcat
        ref @ swap otell
    repeat
;

: boxTable ( d a a n -- )
    var width
    var content
    var header
    var ref

    var num_columns
    var num_rows
    var longest
    var column_buffer
    var cols
    var col_widths

    width !
    content !
    header !
    ref !

    { } array_make cols !
    { } array_make column_buffer !

    header @ array_count num_columns !
    content @ array_count num_rows !

    header @ content @ array_vals pop 1 num_columns @ 1 for pop
        1 num_rows @ ++ 1 for pop
            num_rows @ ++ rotate 0 array_extract
            column_buffer @ swap array_append column_buffer !
        repeat
        cols @ column_buffer @ array_append cols !
        { } array_make column_buffer !
    repeat

    { cols @ foreach swap pop
        0 longest !
        foreach swap pop
            ref @ swap process_tags cleanString ansi_strlen dup longest @ > if
                longest !
            else pop then
        repeat
        longest @ ++
    repeat } array_make col_widths !
    col_widths @ array_sum width @ 4 - > if
        col_widths @ dup array_count 1 - array_getitem
        col_widths @ array_sum  width @ 4 - - -
        col_widths @ array_count 1 - col_widths @ swap array_delitem
        swap array_append col_widths !
    then
    num_rows @ ++ popn
    "" header @ foreach swap
        col_widths @ swap array_getitem
        format_left strcat
    repeat

    ref @ swap field_color

    ref @ swap width @ boxContent

    ref @ ref @ ref @ width @ line box_color otell

    content @ foreach swap pop
        "" swap foreach ref @ swap process_tags swap
            col_widths @ swap array_getitem
            over ansi_strlen over > if
                swap over 4 - ansi_strcut pop
                " ..." strcat swap
            then
            format_left strcat
        repeat
        ref @ swap width @ boxContent
    repeat
;

: doMenu ( ref title option_number' option' ... number_of_options width -- selection )
    var n_options
    var title
    var ref
    var options
    var addresses
    var width

    width !
    n_options !
    { }dict dup options ! addresses !

    1 n_options @ 1 for pop
        3 pick addresses @ swap array_insertitem addresses !
        swap options @ swap array_insertitem options !
    repeat

    title !
    ref !
    ref @ ref @ title @ process_tags cleanString width @ boxTitle
    ref @ { options @ foreach
        swap intostr ") " strcat "^OPTION_COLOR_1^"
        swap strcat swap "^OPTION_COLOR_2^" swap strcat
        strcat ref @ swap process_tags cleanString
    repeat } array_make width @ boxList
    ref @ "^BOX_COLOR^" ref @ width @ line strcat otell
    ref @ "Select option." width @ boxContent
    ref @ "^BOX_COLOR^" ref @ width @ line strcat otell
    ref @ " " otell
    begin read dup number? if atoi dup else dup then over options @ swap array_getitem and not while
        pop ref @ "^ERROR_COLOR^That is not a valid option!" otell
    repeat
    dup addresses @ swap array_getitem dup address? if
        over swap execute
    else nip then
;

: checkbox ( ref value -- box )
    var ref

    var ot
    var ct
    var tag1
    var tag2

    swap
    dup open_tag ot !
    dup close_tag ct !
    dup "" tag_color_1 tag1 !
    "" tag_color_2 tag2 !

    tag2 @ ot @ strcat
    swap if "X" else " " then
    tag1 @ swap strcat strcat
    tag2 @ ct @ strcat strcat
;

: color_menu ( d -- s )
    var ref

    dup ref ! "Please select a color."
    1 "^RED^RED^RESET^"              "^RED^" 1 parse_ansi
    2 "^CRIMSON^CRIMSON^RESET^"      "^CRIMSON^" 1 parse_ansi
    3 "^CRED^CRED^RESET^"            "^CRED^" 1 parse_ansi
    4 "^BRED^BRED^RESET^"            "^BRED^" 1 parse_ansi
    5 "^GREEN^GREEN^RESET^"          "^GREEN^" 1 parse_ansi
    6 "^FOREST^FOREST^RESET^"        "^FOREST^" 1 parse_ansi
    7 "^CGREEN^CGREEN^RESET^"        "^CGREEN^" 1 parse_ansi
    8 "^BGREEN^BGREEN^RESET^"        "^BGREEN^" 1 parse_ansi
    9 "^YELLOW^YELLOW^RESET^"        "^YELLOW^" 1 parse_ansi
    10 "^BROWN^BROWN^RESET^"          "^BROWN^" 1 parse_ansi
    11 "^CYELLOW^CYELLOW^RESET^"      "^CYELLOW^" 1 parse_ansi
    12 "^BYELLOW^BYELLOW^RESET^"      "^BYELLOW^" 1 parse_ansi
    13 "^BLUE^BLUE^RESET^"            "^BLUE^" 1 parse_ansi
    14 "^NAVY^NAVY^RESET^"            "^NAVY^" 1 parse_ansi
    15 "^CBLUE^CBLUE^RESET^"          "^CBLUE^" 1 parse_ansi
    16 "^BBLUE^BBLUE^RESET^"          "^BBLUE^" 1 parse_ansi
    17 "^PURPLE^PURPLE^RESET^"        "^PURPLE^" 1 parse_ansi
    18 "^VIOLET^VIOLET^RESET^"        "^VIOLET^" 1 parse_ansi
    19 "^CPURPLE^CPURPLE^RESET^"      "^CPURPLE^" 1 parse_ansi
    20 "^BPURPLE^BPURPLE^RESET^"      "^BPURPLE^" 1 parse_ansi
    21 "^CYAN^CYAN^RESET^"            "^CYAN^" 1 parse_ansi
    22 "^AQUA^AQUA^RESET^"            "^AQUA^" 1 parse_ansi
    23 "^CCYAN^CCYAN^RESET^"          "^CCYAN^" 1 parse_ansi
    24 "^BCYAN^BCYAN^RESET^"          "^BCYAN^" 1 parse_ansi
    25 "^WHITE^WHITE^RESET^"          "^WHITE^" 1 parse_ansi
    26 "^GRAY^GRAY^RESET^"            "^GRAY^" 1 parse_ansi
    27 "^CWHITE^CWHITE^RESET^"        "^CWHITE^" 1 parse_ansi
    28 "^BWHITE^BWHITE^RESET^"        "^BWHITE^" 1 parse_ansi
    29 "^BLACK^BLACK^RESET^"          "^BLACK^" 1 parse_ansi
    30 "^GLOOM^GLOOM^RESET^"          "^GLOOM^" 1 parse_ansi
    31 "^CBLACK^CBLACK^RESET^"        "^CBLACK^" 1 parse_ansi
    32 "^BBLACK^BBLACK^RESET^"        "^BBLACK^" 1 parse_ansi
    33 "^CFAIL^CFAIL^RESET^"          "^CFAIL^" 1 parse_ansi
    34 "^CSUCC^CSUCC^RESET^"          "^CSUCC^" 1 parse_ansi
    35 "^CINFO^CINFO^RESET^"          "^CINFO^" 1 parse_ansi
    36 "^CNOTE^CNOTE^RESET^"          "^CNOTE^" 1 parse_ansi
    37 "^CMOVE^CMOVE^RESET^"          "^CMOVE^" 1 parse_ansi
    99 "Cancel"                                              ""
    38 80 doMenu
;

: make_temp ( -- d )
    me @ dup name "_temp" strcat "_" strcat systime intostr strcat newobject
;

: command_color_menu ( -- s )
    color_menu
;

: paramTest ( s1 s2 -- n )
    var arg
    var parm

    "#" swap strcat parm !
    " " split pop strip arg !
    arg @ if
        parm @ arg @ instr 1 =
    else
        ""
    then
;

: color_quotes ( s s s -- s )
    var outside_color
    var inside_color
    var s

    inside_color !
    outside_color !
    cleanString s !

    outside_color @ s @ strcat s !
    begin s @ "\"" instr while
        s @ "\"" split "\"" split
        swap "^QUOTE^" inside_color @ strcat swap strcat "^QUOTE^"
        outside_color @ swap strcat strcat swap strcat strcat s !
    repeat
    s @ "\"" "^QUOTE^" subst
;

: set_color
    case
        1 = when me @ color_menu dup if "prefs/color/error_color" swap else pop then end
        2 = when me @ color_menu dup if "prefs/color/success_color" swap else pop then end
        3 = when me @ color_menu dup if "prefs/color/info_color" swap else pop then end
        4 = when me @ color_menu dup if "prefs/color/note_color" swap else pop then end
        5 = when me @ color_menu dup if "prefs/color/field" swap else pop then end
        6 = when me @ color_menu dup if "prefs/color/content" swap else pop then end
        7 = when me @ color_menu dup if "prefs/color/tag1" swap else pop then end
        8 = when me @ color_menu dup if "prefs/color/tag2" swap else pop then end
        9 = when me @ color_menu dup if "prefs/color/ooc1" swap else pop then end
        10 = when me @ color_menu dup if "prefs/color/ooc2" swap else pop then end
        11 = when me @ color_menu dup if "prefs/color/oocn" swap else pop then end
        12 = when me @ color_menu dup if "prefs/color/ic1" swap else pop then end
        13 = when me @ color_menu dup if "prefs/color/ic2" swap else pop then end
        14 = when me @ color_menu dup if "prefs/color/icn" swap else pop then end
        15 = when me @ color_menu dup if "prefs/color/opt1" swap else pop then end
        16 = when me @ color_menu dup if "prefs/color/opt2" swap else pop then end
        17 = when me @ color_menu dup if "prefs/color/title" swap else pop then end
        18 = when me @ color_menu dup if "prefs/color/box" swap else pop then end
    endcase
;

: set_character
    case
        19 = when
            "^NOTE_COLOR^Please enter a single character." tell read 1 strcut pop "prefs/open_tag" swap
        end
        20 = when
            "^NOTE_COLOR^Please enter a single character." tell read 1 strcut pop "prefs/close_tag" swap
        end
        22 = when
            "^NOTE_COLOR^Please enter a single character." tell read 1 strcut pop "prefs/vline" swap
        end
    endcase
;

: set_line
    case
        21 = when
            "^NOTE_COLOR^Please enter a string of characters." tell read "prefs/line" swap
        end
        23 = when
            "^NOTE_COLOR^Please enter a string of characters." tell read "prefs/say" swap
        end
        24 = when
            "^NOTE_COLOR^Please enter a string of characters." tell read "prefs/says" swap
        end
    endcase
;

: show_look_feel ( d -- )
    var ref

    ref !
    me @ {
        { ref @ "^ERROR_COLOR^ERROR COLOR" process_tags 
          ref @ "^SUCCESS_COLOR^SUCCESS COLOR" process_tags } array_make
        { ref @ "^INFO_COLOR^INFO COLOR" process_tags 
          ref @ "^NOTE_COLOR^NOTE COLOR" process_tags } array_make
        { ref @ "^FIELD_COLOR^FIELD COLOR" process_tags
          ref @ "^CONTENT_COLOR^CONTENT_COLOR" process_tags } array_make
        { ref @ "^TAG_COLOR_2^^OPEN_TAG^^TAG_COLOR_1^TAG^TAG_COLOR_2^^CLOSE_TAG^" process_tags
          ref @ "^CONTENT_COLOR^CONTENT COLOR" process_tags } array_make
        { ref @ ref @ "^OOC_NAME_COLOR^(You/" me @ name strcat
        ")^OOC_COLOR_1^ (" ref @ says strcat "/" ref @ say strcat
        ") \"Hello\" in an OOC manner." strcat strcat strcat process_tags
        "^OOC_COLOR_1^" "^OOC_COLOR_2^" color_quotes process_tags "" } array_make
        { ref @ ref @ "^IC_NAME_COLOR^(You/" me @ name strcat
        ")^IC_COLOR_1^ (" ref @ says strcat "/" ref @ say strcat
        ") \"Hello\" in an IC manner." strcat strcat strcat process_tags
        "^IC_COLOR_1^" "^IC_COLOR_2^" color_quotes process_tags "" } array_make
        { ref @ "^OPTION_COLOR_1^1) ^OPTION_COLOR_2^FAKE OPTION 1" process_tags
          ref @ "^OPTION_COLOR_1^2) ^OPTION_COLOR_2^FAKE OPTION 2" process_tags } array_make
    } array_make 80 boxInfo
;

: set_look_feel ( d s s -- )
    var ref
    var title
    var message

    message !
    title !
    ref !

    { ref @ "_config/orig" remove_prop
    ref @ "_config/prefs" ref @ "_config/orig/prefs" 1 copyprops pop
    begin me @ title @ 80 boxTitle
    me @ message @ 80 boxContent me @ "" 80 boxContent
    ref @ show_look_feel
    me @ "Options" {
    1 "^ERROR_COLOR^Error Color^RESET^" 'set_color
    2 "^SUCCESS_COLOR^Success Color^RESET^" 'set_color
    3 "^INFO_COLOR^Info Color^RESET^" 'set_color
    4 "^NOTE_COLOR^Note Color^RESET^" 'set_color
    5 "^FIELD_COLOR^Field Color^RESET^" 'set_color
    6 "^CONTENT_COLOR^Content Color^RESET^" 'set_color
    7 "^TAG_COLOR_1^Inner Tag Color^RESET^" 'set_color
    8 "^TAG_COLOR_2^Outer Tag Color^RESET^" 'set_color
    9 "^OOC_COLOR_1^OOC Message Descriptor Color^RESET^" 'set_color
    10 "^OOC_COLOR_2^OOC Message Color^RESET^" 'set_color
    11 "^OOC_NAME_COLOR^OOC Name Color^RESET^" 'set_color
    12 "^IC_COLOR_1^IC Message Descriptor Color^RESET^" 'set_color
    13 "^IC_COLOR_2^IC Message Color^RESET^" 'set_color
    14 "^IC_NAME_COLOR^IC Name Color^RESET^" 'set_color
    15 "^OPTION_COLOR_1^Option Number Color^RESET^" 'set_color
    16 "^OPTION_COLOR_2^Option Text Color^RESET^" 'set_color
    17 "^TITLE_COLOR^Title Color^RESET^" 'set_color
    18 "^BOX_COLOR^Box Color^RESET^" 'set_color
    19 "Opening Tag (^OPEN_TAG^)" 'set_character
    20 "Closing Tag (^CLOSE_TAG^)" 'set_character
    21 "Line (" me @ 3 line strcat ")" strcat 'set_line
    22 "Vertical Line (^VLINE^)" 'set_character
    23 "Second Person Say Verb (" me @ say strcat ")" strcat 'set_line
    24 "Third Person Say Verb (" me @ says strcat ")" strcat 'set_line
    77 "Default Settings" 77
    88 "Save" 88
    99 "Quit" 0
    } 3 / 80 doMenu dup while
            dup string? if
                ref @ rot rot setConfig clear_cache
            else
                dup case
                    77 = when 
                        ref @ "_config/prefs" remove_prop clear_cache
                    end
                    88 = when 
                        ref @ "_config/orig" remove_prop
                        ref @ "_config/prefs" ref @ "_config/orig/prefs" 1 copyprops pop
                    end
                endcase
            then pop
    repeat
    ref @ "_config/prefs" remove_prop
    ref @ "_config/orig/prefs" ref @ "_config/prefs" 1 copyprops pop
    ref @ "_config/orig" remove_prop clear_cache } popn
;

: main ( s -- )
    command @ "yaroconf" strcmp not if
        dup "test" paramTest if pop doTest exit then
        dup "getconfig" paramTest if " " split swap pop me @ swap getConfig me @ swap intostr notify exit then
        dup "setconfig" paramTest if " " explode dup 5 = if
            pop pop match swap rot 4 rotate 4 pick me @ control? if
                setConfigCommand
            else
                me @ "You do not have permissions to that object!" error_color tell
            then exit
        else
            4 = if
                pop match rot rot swap 3 pick me @ control? if
                    setConfig
                else
                    me @ "You do not have permissions to that object!" error_color tell
                then exit
            else
                me @ "Usage: " info_color
                me @ command @ " #setconfig <TARGET> <KEY> <VALUE> [COMMAND]" strcat note_color
                strcat tell
            then
        then then
    else
        me @ "This is Yaro's configuration and support library. Please run \"yaroconf\" instead of "
        command @ strcat "." strcat error_color tell
    then
;

public line
public vline
public tell
public otell
public paramTest
public error_color
public success_color
public info_color
public note_color
public tag_color_1
public tag_color_2
public ooc_color_1
public ooc_color_2
public ooc_name_color
public option_color_1
public option_color_2
public ic_color_1
public ic_color_2
public ic_name_color
public title_color
public field_color
public box_color
public content_color
public open_tag
public close_tag
public getConfig
public setConfig
public getPlayers
public getThings
public getExits
public array_append
public array_dedup
public array_merge
public array_extract
public control?
public doMenu
public boxTitle
public boxContent
public boxList
public boxInfo
public boxTable
public color_menu
public command_color_menu
public make_temp
public space
public format_left
public format_center
public format_right
public format_wrap
public columns
public checkbox
public cleanString
public time_format
public time_explode
public process_tags
public color_quotes
public array_to_menu
public clear_cache
public say
public says
public set_look_feel
.
c
q

@set lib-yaro=_defs/line:"$lib/yaro" match "line" call
@set lib-yaro=_defs/vline:"$lib/yaro" match "vline" call
@set lib-yaro=_defs/tell:"$lib/yaro" match "tell" call
@set lib-yaro=_defs/otell:"$lib/yaro" match "otell" call
@set lib-yaro=_defs/tell_array:"$lib/yaro" match "tell_array" call
@set lib-yaro=_defs/paramTest:"$lib/yaro" match "paramTest" call
@set lib-yaro=_defs/error_color:"$lib/yaro" match "error_color" call
@set lib-yaro=_defs/success_color:"$lib/yaro" match "success_color" call
@set lib-yaro=_defs/info_color:"$lib/yaro" match "info_color" call
@set lib-yaro=_defs/note_color:"$lib/yaro" match "note_color" call
@set lib-yaro=_defs/tag_color_1:"$lib/yaro" match "tag_color_1" call
@set lib-yaro=_defs/tag_color_2:"$lib/yaro" match "tag_color_2" call
@set lib-yaro=_defs/ooc_color_1:"$lib/yaro" match "ooc_color_1" call
@set lib-yaro=_defs/ooc_color_2:"$lib/yaro" match "ooc_color_2" call
@set lib-yaro=_defs/ooc_name_color:"$lib/yaro" match "ooc_name_color" call
@set lib-yaro=_defs/option_color_1:"$lib/yaro" match "option_color_1" call
@set lib-yaro=_defs/option_color_2:"$lib/yaro" match "option_color_2" call
@set lib-yaro=_defs/ic_color_1:"$lib/yaro" match "ic_color_1" call
@set lib-yaro=_defs/ic_color_2:"$lib/yaro" match "ic_color_2" call
@set lib-yaro=_defs/ic_name_color:"$lib/yaro" match "ic_name_color" call
@set lib-yaro=_defs/title_color:"$lib/yaro" match "title_color" call
@set lib-yaro=_defs/box_color:"$lib/yaro" match "box_color" call
@set lib-yaro=_defs/field_color:"$lib/yaro" match "field_color" call
@set lib-yaro=_defs/content_color:"$lib/yaro" match "content_color" call
@set lib-yaro=_defs/open_tag:"$lib/yaro" match "open_tag" call
@set lib-yaro=_defs/close_tag:"$lib/yaro" match "close_tag" call
@set lib-yaro=_defs/option_tag:"$lib/yaro" match "option_tag" call
@set lib-yaro=_defs/getConfig:"$lib/yaro" match "getConfig" call
@set lib-yaro=_defs/setConfig:"$lib/yaro" match "setConfig" call
@set lib-yaro=_defs/getPlayers:"$lib/yaro" match "getPlayers" call
@set lib-yaro=_defs/getThings:"$lib/yaro" match "getThings" call
@set lib-yaro=_defs/getExits:"$lib/yaro" match "getExits" call
@set lib-yaro=_defs/array_append:"$lib/yaro" match "array_append" call
@set lib-yaro=_defs/array_dedup:"$lib/yaro" match "array_dedup" call
@set lib-yaro=_defs/array_extract:"$lib/yaro" match "array_extract" call
@set lib-yaro=_defs/array_merge:"$lib/yaro" match "array_merge" call
@set lib-yaro=_defs/array_to_menu:"$lib/yaro" match "array_to_menu" call
@set lib-yaro=_defs/control?:"$lib/yaro" match "control?" call
@set lib-yaro=_defs/doMenu:"$lib/yaro" match "doMenu" call
@set lib-yaro=_defs/boxTitle:"$lib/yaro" match "boxTitle" call
@set lib-yaro=_defs/boxContent:"$lib/yaro" match "boxContent" call
@set lib-yaro=_defs/boxList:"$lib/yaro" match "boxList" call
@set lib-yaro=_defs/boxInfo:"$lib/yaro" match "boxInfo" call
@set lib-yaro=_defs/boxTable:"$lib/yaro" match "boxTable" call
@set lib-yaro=_defs/color_menu:"$lib/yaro" match "color_menu" call
@set lib-yaro=_defs/make_temp:"$lib/yaro" match "make_temp" call
@set lib-yaro=_defs/space:"$lib/yaro" match "space" call
@set lib-yaro=_defs/format_left:"$lib/yaro" match "format_left" call
@set lib-yaro=_defs/format_center:"$lib/yaro" match "format_center" call
@set lib-yaro=_defs/format_right:"$lib/yaro" match "format_right" call
@set lib-yaro=_defs/format_wrap:"$lib/yaro" match "format_wrap" call
@set lib-yaro=_defs/columns:"$lib/yaro" match "columns" call
@set lib-yaro=_defs/checkbox:"$lib/yaro" match "checkbox" call
@set lib-yaro=_defs/cleanString:"$lib/yaro" match "cleanString" call
@set lib-yaro=_defs/time_format:"$lib/yaro" match "time_format" call
@set lib-yaro=_defs/time_explode:"$lib/yaro" match "time_explode" call
@set lib-yaro=_defs/process_tags:"$lib/yaro" match "process_tags" call
@set lib-yaro=_defs/color_quotes:"$lib/yaro" match "color_quotes" call
@set lib-yaro=_defs/clear_cache:"$lib/yaro" match "clear_cache" call
@set lib-yaro=_defs/say:"$lib/yaro" match "say" call
@set lib-yaro=_defs/says:"$lib/yaro" match "says" call
@set lib-yaro=_defs/set_look_feel:"$lib/yaro" match "set_look_feel" call

