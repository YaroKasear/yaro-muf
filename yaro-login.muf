@program yaro-login.muf
1 9999 del
i
$include $lib/editor
$include $lib/yaro

: screenMenu
    var cancelOption
    var longestOption

    dup strlen 4 + longestOption !
    me @ swap
    #0 "loginScreens" getConfig array_keys array_make
    foreach
        "#" rsplit pop 
        dup strlen longestOption @ > if
            dup strlen longestOption !
        then
        swap 1 + swap over
    repeat
    dup intostr strlen "9" swap "%.*s" fmtstring atoi dup cancelOption !
    "Cancel" over 4 pick 1 + longestOption @ doMenu cancelOption @ swap
;

: addScreen
    var name
    var selection

    "" name !
    begin name @ not while
        "^INFO_COLOR^Please enter a name for this screen." tell read name !
        name @ "loginScreens/" swap strcat #0 swap getConfig not if
            0 EDITOR "abort" strcmp if
                array_make "loginScreens/" name @ strcat swap
                #0 rot rot setConfig 
                #0 "{list:_config/loginScreens/" name @ strcat ", #0}" strcat
                "(MUF)" 0 parsempi #0 swap process_tags
                descr swap ansi_notify_descriptor
                me @
                "Keep this screen?"
                1 "Yes" 1
                2 "No" 2
                2 21 doMenu case
                    1 = when
                        "^SUCCESS_COLOR^Login screen " name @ strcat " saved!" strcat tell
                    end
                    2 = when
                        #0 "_config/loginScreens/" name @ strcat "#" strcat remove_prop
                        "^ERROR_COLOR^Login screen " name @ strcat " tossed!" strcat tell
                    end
                endcase
            else
                pop "^INFO_COLOR^Aborting..." tell exit
            then
        else
            "^ERROR_COLOR^That name has been taken." tell
            "" name !
        then
    name @ until
;

: editScreen
    var screenKey
    var screenArray
    var cancelOption

    "Login Screen Editor" screenMenu swap cancelOption !
    dup cancelOption @ = if
        pop exit
    then
    1 - #0 "loginScreens" getConfig array_keys array_make swap
    array_getitem "loginScreens/" swap strcat dup screenKey !
    #0 swap getConfig dup array_count swap screenArray !
    1 swap 1 for
        intostr screenArray @ swap array_getitem
    repeat
    screenArray @ array_count EDITOR 
    case
        "abort" strcmp not when
            pop
            "^ERROR_COLOR^Changes dropped." tell exit
        end
        "end" strcmp not when
            array_make #0 swap screenKey @ "#" rsplit pop swap setConfig
            "^SUCCESS_COLOR^Changes saved." tell exit
        end
    endcase
;

: showScreens
    #0 "loginScreens" getConfig foreach
        pop "#" rsplit pop dup toupper me @ swap 80 boxTitle
         "{list:_config/loginScreens/" swap strcat
        ", #0}" strcat #0 swap "(MUF)" 1 parsempi #0 swap process_tags
        descr " " ansi_notify_descriptor
        descr swap ansi_notify_descriptor
        descr " " ansi_notify_descriptor
    repeat
;

: deleteScreen
    var screenKey

    "Delete Screen" screenMenu over over = if
    pop pop
        "^ERROR_COLOR^Delete canceled." tell exit
    then
    swap pop #0 "loginScreens" getConfig array_keys array_make
    swap 1 - array_getitem "#" rsplit pop 
    "_config/loginScreens/" swap strcat screenKey !
    #0 "{list:" screenKey @ strcat ", #0}" strcat "(MUF)" 0 parsempi
    #0 swap process_tags descr swap ansi_notify_descriptor
    me @ "Delete?" 1 "Yes" 1 2 "No" 2 2 11 doMenu
    case
        1 = when
            #0 screenKey @ "#" strcat remove_prop
            "^SUCCESS_COLOR^Screen deleted. Please ensure you have a backup if you plan to restore the screen in the future." tell
        end
        2 = when
            "^ERROR_COLOR^Delete canceled." tell
        end
    endcase
;

: main
    var numItems
    var selection

    0 selection !
    command @ "Queued event." strcmp not swap "Login" strcmp not and not
    if
        #0 me @ control? me @ "W3" flag? and if
            begin selection @ 9 != while
                me @
                "Login Screen Configuration"
                1 "Add Login Screen" 1
                #0 "loginScreens" getConfig if
                    2 "Edit Login Screen" 2
                    3 "Delete Login Screen" 3
                    4 "Show Login Screens" 4
                    5 numItems !
                else
                    2 numItems !
                then
                9 "Quit" 9
                numItems @ 32 doMenu selection !
                selection @ case
                    1 = when
                        addScreen
                    end
                    2 = when
                        editScreen
                    end
                    3 = when
                        deleteScreen
                    end
                    4 = when
                        showScreens
                    end
                endcase
            selection @ 9 = until
            "^INFO_COLOR^Thank you for using the Login Screen Configuration Utility!" tell
        else
            "^ERROR_COLOR^Permission denied." tell
            exit
        then
    else
        descr "DF_COLOR" descr_set
        descr "DF_256COLOR" descr_set
        #0 "loginScreens" getConfig array_keys array_make
        dup array_count random swap % array_getitem "#" rsplit pop
        "{list:_config/loginScreens/" swap strcat ", #0}" strcat 
        #0 swap "(MUF)" 0 parsempi #0 swap process_tags
        descr swap ansi_notify_descriptor
    then
;
.
c
q
@set yaro-login.muf=l
@setdbref #0=@login/yaro-login:yaro-login.muf
