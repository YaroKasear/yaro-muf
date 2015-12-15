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
            ( "^^" "^" subst )
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
        dup myProgKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
        dup myKey @ readConf dup if dup cache_key @ swap cache_write exit else pop then
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
    over "color/error_color" make_cache_key cache_key !
    over "color/error_color" getConfig dup if
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
    over "color/success_color" make_cache_key cache_key !
    over "color/success_color" getConfig dup if
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
    over "color/info_color" make_cache_key cache_key !
    over "color/info_color" getConfig dup if
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
    over "color/note_color" make_cache_key cache_key !
    over "color/note_color" getConfig dup if
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
    over "color/tag1" make_cache_key cache_key !
    over "color/tag1" getConfig dup if
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
    over "color/tag2" make_cache_key cache_key !
    over "color/tag2" getConfig dup if
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
    over "color/ooc1" make_cache_key cache_key !
    over "color/ooc1" getConfig dup if
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
    over "color/ooc2" make_cache_key cache_key !
    over "color/ooc2" getConfig dup if
        swap strcat
    else
        pop "^GRAY^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;
 
: ic_color_1 ( d s -- s )
    var cache_key 
    over "color/ic1" make_cache_key cache_key !
    over "color/ic1" getConfig dup if
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
    over "color/ic2" make_cache_key cache_key !
    over "color/ic2" getConfig dup if
        swap strcat
    else
        pop "^WHITE^" 1 parse_ansi dup cache_key @ swap cache_write
        swap strcat
    then
    swap pop
    "\[[0m" swap strcat
;

: title_color ( d s -- s )
    var cache_key 
    over "color/title" make_cache_key cache_key !
    over "color/title" getConfig dup if
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
    over "color/opt1" make_cache_key cache_key !
    over "color/opt1" getConfig dup if
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
    over "color/opt2" make_cache_key cache_key !
    over "color/opt2" getConfig dup if
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
    over "color/box" make_cache_key cache_key !
    over "color/box" getConfig dup if
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
    over "color/content" make_cache_key cache_key !
    over "color/content" getConfig dup if
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
    over "color/field" make_cache_key cache_key !
    over "color/field" getConfig dup if
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

    over "line" make_cache_key cache_key !

    swap "line" getConfig dup not if
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
    dup "open_tag" make_cache_key cache_key !
    "open_tag" getConfig dup not if
        pop "[" dup cache_key @ swap cache_write
    then
;
 
: close_tag ( d -- s )
    var cache_key
    dup "close_tag" make_cache_key cache_key !
    "close_tag" getConfig dup not if
        pop "]" dup cache_key @ swap cache_write
    then
;
 
: option_tag ( -- s )
    var cache_key
    dup "option_tag" make_cache_key cache_key !
    "option_tag" getConfig dup not if
        pop ")" dup cache_key @ swap cache_write
    then
;
 
: vline ( -- s )
    var cache_key
    dup "vline" make_cache_key cache_key !
    "vline" getConfig dup not if
        pop "|" dup cache_key @ swap cache_write
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
            dup toupper "^OPTION_COLOR_1^" instr if ref @ "" option_color_1 "^OPTION_COLOR_1^" subst then
            dup toupper "^OPTION_COLOR_2^" instr if ref @ "" option_color_2 "^OPTION_COLOR_2^" subst then
            dup toupper "^IC_COLOR_1^" instr if ref @ "" ic_color_1       "^IC_COLOR_1^" subst then
            dup toupper "^IC_COLOR_2^" instr if ref @ "" ic_color_2       "^IC_COLOR_2^" subst then
            dup toupper "^TITLE_COLOR^" instr if ref @ "" title_color    "^TITLE_COLOR^" subst then
            dup toupper "^FIELD_COLOR^" instr if ref @ "" field_color    "^FIELD_COLOR^" subst then
            dup toupper "^BOX_COLOR^" instr if ref @ "" box_color      "^BOX_COLOR^" subst then
            dup toupper "^CONTENT_COLOR^" instr if ref @ "" content_color  "^CONTENT_COLOR^" subst then
            dup toupper "^OPEN_TAG^" instr if ref @ open_tag  "^OPEN_TAG^" subst then
            dup toupper "^CLOSE_TAG^" instr if ref @ close_tag  "^CLOSE_TAG^" subst then
            dup toupper "^UNDERLINE^" instr if "\[[4m" "^UNDERLINE^" subst then
            dup toupper "^BOLD^" instr if "\[[1m" "^BOLD^" subst then
            dup toupper "^DARK^" instr if "\[[2m" "^DARK^" subst then
            dup toupper "^UNDERLINE^" instr if "\[[4m" "^UNDERLINE^" subst then
            dup toupper "^FLASH^" instr if "\[[5m" "^FLASH^" subst then
            dup toupper "^INVERT^" instr if "\[[7m" "^INVERT^" subst then
            dup toupper "^RESET^" instr if "\[[0m" "^RESET^" subst then
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
 
: tell_array ( a s -- )
    cleanString
    swap foreach
        swap pop over over swap process_tags ansi_notify
    repeat
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
    { swap foreach swap 1 + swap repeat } 2 /
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
    space length @ text @ ansi_strlen - 2 / strcut
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
            buffer @ width @ strcut swap
            dup " " rinstr dup if
                strcut rot strcat buffer !
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
 
: boxInfo ( ref string1 string2 width -- )
    var ref
    var string1
    var string2
    var width
 
    var t
    
    width !
    rot ref !
    ref @ swap process_tags cleanString string2 !
    ref @ swap process_tags cleanString string1 !
 
    { string2 @ string1 @ ansi_strlen 1 + width @ 4 - swap - format_wrap dup array_count t ! foreach swap pop
        string1 @ ansi_strlen 1 + width @ 4 - swap - t @ 1 > if 
            format_left
        else
            format_right
        then
    repeat } array_make 
    0 array_extract string1 @ " " strcat swap strcat
    ref @ swap content_color
    ref @ ref @ vline " " strcat box_color swap strcat
    ref @ ref @ vline " " swap strcat box_color strcat
    ref @ swap otell
    foreach swap pop
        string1 @ ansi_strlen 1 + space swap strcat
        ref @ swap content_color
        ref @ ref @ vline " " strcat box_color swap strcat
        ref @ ref @ vline " " swap strcat box_color strcat
        ref @ swap otell
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
 
: doMenu ( ref title option_number' option' ... number_of_options width -- selection )
    var options
    var title
    var ref
 
    var strings
    var longest
    var width
    var cols
    var numbers
 
    var temp_width
 
    temp_width !
    array_make_dict options !
    swap ref !
    ref @ swap process_tags cleanString title !
 
    { options @ foreach
        swap intostr 
        ref @ option_tag strcat " " strcat
        ref @ swap option_color_1 swap
        ref @ swap option_color_2 strcat
        cleanString dup ansi_strlen longest @ > if
            dup ansi_strlen longest !
        then
    repeat } array_make strings !
    longest @ 1 + longest !
    options @ array_keys array_make numbers !
    title @ ansi_strlen longest @ > if
        title @ ansi_strlen 10 + 
        dup longest @ / cols !
        dup longest @ 2 * - dup 4 <= if + else pop then         
    else
        longest @ 4 +
        1 cols !
    then
    width !
    temp_width @ width @ > if 
        temp_width @ width ! 
        width @ longest @ 1 + / cols !
    then
    ref @ title @ width @ boxTitle
    strings @ cols @ width @ 4 - columns foreach swap pop
        dup ansi_strlen width @ 4 - swap - space strcat
        ref @ swap content_color
        ref @ vline " " strcat
        ref @ swap box_color swap strcat
        ref @ vline " " swap strcat
        ref @ swap box_color strcat
        ref @ swap otell
    repeat
    ref @ width @ line
    ref @ swap box_color
    ref @ swap otell
    ref @ " " otell
    ref @ ref @ "Please select an option." note_color otell
    -999 begin -999 = while
        read dup number? if
            atoi dup numbers @ swap array_findval not if
                ref @ ref @ "I do not know that option." error_color otell pop -999
            else dup then
        else
            ref @ ref @ "Please input a numerical response." error_color otell pop -999
        then
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
        "" swap foreach swap
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
    1 "^RED^RED" ref @ "" content_color strcat
    2 "^CRIMSON^CRIMSON" ref @ "" content_color strcat
    3 "^CRED^CRED" ref @ "" content_color strcat
    4 "^BRED^BRED" ref @ "" content_color strcat
    5 "^GREEN^GREEN" ref @ "" content_color strcat
    6 "^FOREST^FOREST" ref @ "" content_color strcat
    7 "^CGREEN^CGREEN" ref @ "" content_color strcat
    8 "^BGREEN^BGREEN" ref @ "" content_color strcat
    9 "^YELLOW^YELLOW" ref @ "" content_color strcat
    10 "^BROWN^BROWN" ref @ "" content_color strcat
    11 "^CYELLOW^CYELLOW" ref @ "" content_color strcat
    12 "^BYELLOW^BYELLOW" ref @ "" content_color strcat
    13 "^BLUE^BLUE" ref @ "" content_color strcat
    14 "^NAVY^NAVY" ref @ "" content_color strcat
    15 "^CBLUE^CBLUE" ref @ "" content_color strcat
    16 "^BBLUE^BBLUE" ref @ "" content_color strcat
    17 "^PURPLE^PURPLE" ref @ "" content_color strcat
    18 "^VIOLET^VIOLET" ref @ "" content_color strcat
    19 "^CPURPLE^CPURPLE" ref @ "" content_color strcat
    20 "^BPURPLE^BPURPLE" ref @ "" content_color strcat
    21 "^CYAN^CYAN" ref @ "" content_color strcat
    22 "^AQUA^AQUA" ref @ "" content_color strcat
    23 "^CCYAN^CCYAN" ref @ "" content_color strcat
    24 "^BCYAN^BCYAN" ref @ "" content_color strcat
    25 "^WHITE^WHITE" ref @ "" content_color strcat
    26 "^GRAY^GRAY" ref @ "" content_color strcat
    27 "^CWHITE^CWHITE" ref @ "" content_color strcat
    28 "^BWHITE^BWHITE" ref @ "" content_color strcat
    29 "^BLACK^BLACK" ref @ "" content_color strcat
    30 "^GLOOM^GLOOM" ref @ "" content_color strcat
    31 "^CBLACK^CBLACK" ref @ "" content_color strcat
    32 "^BBLACK^BBLACK" ref @ "" content_color strcat
    33 "^CFAIL^CFAIL" ref @ "" content_color strcat
    34 "^CSUCC^CSUCC" ref @ "" content_color strcat
    35 "^CINFO^CINFO" ref @ "" content_color strcat
    36 "^CNOTE^CNOTE" ref @ "" content_color strcat
    37 "^CMOVE^CMOVE" ref @ "" content_color strcat
    99 "Cancel"
    38 0 doMenu case
        1 = when "^RED^" 1 parse_ansi end
        2 = when "^CRIMSON^" 1 parse_ansi end
        3 = when "^CRED^" 1 parse_ansi end
        4 = when "^BRED^" 1 parse_ansi end
        5 = when "^GREEN^" 1 parse_ansi end
        6 = when "^FOREST^" 1 parse_ansi end
        7 = when "^CGREEN^" 1 parse_ansi end
        8 = when "^BGREEN^" 1 parse_ansi end
        9 = when "^YELLOW^" 1 parse_ansi end
        10 = when "^BROWN^" 1 parse_ansi end
        11 = when "^CYELLOW^" 1 parse_ansi end
        12 = when "^BYELLOW^" 1 parse_ansi end
        13 = when "^BLUE^" 1 parse_ansi end
        14 = when "^NAVY^" 1 parse_ansi end
        15 = when "^CBLUE^" 1 parse_ansi end
        16 = when "^BBLUE^" 1 parse_ansi end
        17 = when "^PURPLE^" 1 parse_ansi end
        18 = when "^VIOLET^" 1 parse_ansi end
        19 = when "^CPURPLE^" 1 parse_ansi end
        20 = when "^BPURPLE^" 1 parse_ansi end
        21 = when "^CYAN^" 1 parse_ansi end
        22 = when "^AQUA^" 1 parse_ansi end
        23 = when "^CCYAN^" 1 parse_ansi end
        24 = when "^BCYAN^" 1 parse_ansi end
        25 = when "^WHITE^" 1 parse_ansi end
        26 = when "^GRAY^" 1 parse_ansi end
        27 = when "^CWHITE^" 1 parse_ansi end
        28 = when "^BWHITE^" 1 parse_ansi end
        29 = when "^BLACK^" 1 parse_ansi end
        30 = when "^GLOOM^" 1 parse_ansi end
        31 = when "^CBLACK^" 1 parse_ansi end
        32 = when "^BBLACK^" 1 parse_ansi end
        33 = when "^CFAIL^" 1 parse_ansi end
        34 = when "^CSUCC^" 1 parse_ansi end
        35 = when "^CINFO^" 1 parse_ansi end
        36 = when "^CNOTE^" 1 parse_ansi end
        37 = when "^CMOVE^" 1 parse_ansi end
        99 = when "" end
    endcase
;
 
: make_temp ( -- d )
    me @ dup name "_temp" strcat "_" strcat systime intostr strcat newobject
;
 
: command_color_menu ( -- s )
    color_menu
;

: paramTest ( s1 s2 -- n )
    swap " " split pop
    dup "#" instr 1 = if
        "#" split swap pop
        stringcmp not
    else
        pop pop 0 exit
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
public tell_array
public paramTest
public error_color
public success_color
public info_color
public note_color
public tag_color_1
public tag_color_2
public ooc_color_1
public ooc_color_2
public option_color_1
public option_color_2
public ic_color_1
public ic_color_2
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
public process_tags
public color_quotes
public array_to_menu
public clear_cache
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
@set lib-yaro=_defs/option_color_1:"$lib/yaro" match "option_color_1" call
@set lib-yaro=_defs/option_color_2:"$lib/yaro" match "option_color_2" call
@set lib-yaro=_defs/ic_color_1:"$lib/yaro" match "ic_color_1" call
@set lib-yaro=_defs/ic_color_2:"$lib/yaro" match "ic_color_2" call
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
@set lib-yaro=_defs/process_tags:"$lib/yaro" match "process_tags" call
@set lib-yaro=_defs/color_quotes:"$lib/yaro" match "color_quotes" call
@set lib-yaro=_defs/clear_cache:"$lib/yaro" match "clear_cache" call

