@q
@program yaro-wizcenter.muf
1 99999 del
i
$include $lib/yaro
$include $cmd/status

: get_details ( d - s s s )
    var ref

    ref !

    ref @ name 
    me @ ref @ get_status pop "^CONTENT_COLOR^" strcat process_tags
    ref @ "role" getConfig dup not if
        pop "Who knows?"
    then
;

: getAlerts
    me @ "muckname" sysparm " Wizard Center" strcat 80 boxTitle
    "$lib/yaro" match "c_apps" getConfig dup array? if
        array_keys array_make
        dup array_count me @ swap "There are " swap intostr strcat
        " character applications awaiting review." strcat 
        me @ swap info_color 80 boxContent
        me @ me @ "Please issue the command @request #process <NAME> to review." 
        info_color 80 boxContent
        me @ "" 80 boxContent
        me @ swap 80 boxList
    else
        me @ "There are no alerts to bring to your attention!" 80 boxContent
    then
;

: list_wizards
    me @ "muckname" sysparm " Online Wizard Staff" strcat 80 boxTitle
    me @ { "Name" "Status" "Role" } array_make 
    { 
        online array_make array_dedup foreach swap pop 
            dup mlevel 4 > over "hidden_wizard" getConfig not and if
                { swap get_details } array_make
            else pop then
        repeat
    } array_make 80 boxTable
    me @ me @ 80 line box_color tell
;

: show_help
    me @ command @ " Help Listing " strcat 80 boxTitle
    me @ me @ "wizzes" field_color me @ "Shows the online wizard staff and their information." content_color 80 boxInfo
    me @ me @ "wizzes #set-role [WIZARDS ONLY]" field_color me @ "Set your role." content_color 80 boxInfo
    me @ me @ "wcenter [WIZARDS ONLY]" field_color me @ "Show outstanding staff notifications." content_color 80 boxInfo
    me @ me @ 80 line box_color tell
;

: get_sysinfo
    me @ "System Information" 80 boxTitle
    me @ "^FIELD_COLOR^Server Time:" "^CONTENT_COLOR^%C %r" systime timefmt 80 boxInfo
    me @ "^FIELD_COLOR^Connected Players:" "^CONTENT_COLOR^" concount intostr strcat 80 boxInfo
;

: main
    dup "help" paramTest if show_help exit then
    command @ case
        "wizzes" stringcmp not when 
            dup "set-role" paramTest if
                me @ "W" flag? if
                    " " split swap pop
                    dup me @ swap "role" swap setConfig
                    me @ swap "Set role to \"" swap strcat "." strcat success_color tell
                    exit 
                else
                    me @ "You are not authorized to set a role on yourself." error_color tell
                then
            then
            list_wizards 
        end
        "wcenter" stringcmp not rot "Connect" stringcmp not or when 
            me @ "W" flag? if 
                getAlerts 
                get_sysinfo
                me @ "" 80 boxContent
                me @ "Please post bug reports and feature requests for Yaro's programs to "
                "https://github.com/YaroKasear/yaro-muf/issues" strcat 80 boxContent
                me @ version 80 boxTitle
            then 
        end
        default 
            me @ "Please tell " prog owner name strcat 
            " that the incorrect command " strcat command @ strcat 
            " is linked to " strcat prog name strcat "." strcat
            error_color tell
        end
    endcase
;
.
c
q

