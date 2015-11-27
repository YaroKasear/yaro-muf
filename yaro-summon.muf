@q
@program yaro-summon.muf
1 99999 del
i
$include $lib/yaro

: doSummon ( s -- )
    dup if
        dup pmatch dup case
            ok? not when "I don't recognize a player named \"" rot strcat "!\"" strcat me @ swap error_color tell end
            player? not when "I don't recognize a player named \"" rot strcat "!\"" strcat me @ swap error_color tell end
            awake? not when swap pop name " is not awake." strcat me @ swap error_color tell end
            me @ = when me @ "Summoning yourself?" error_color tell end
            default 
                pop swap pop me @ "summon/join_req" getConfig dup if
                    dup "_" rinstr strcut swap dup strlen 1 - strcut pop swap
                    atoi systime swap - 600 > not over pmatch 4 pick = and if
                        pop dup loc @ moveto
                        "_config/summon" remove_prop
                        me @ "_config/summon" remove_prop
                        me @ "Summoned." note_color tell
                        exit
                    else
                    pop dup "summon/summon_req" me @ name "_" strcat systime intostr strcat setConfig
                    dup dup me @ name " has just sent you a summon request. Type 'mjoin " strcat me @ name strcat "' to accept." strcat
                    info_color otell
                    name "You have sent a summon request to " swap strcat me @ swap note_color tell
                    then
                else
                    pop dup "summon/summon_req" me @ name "_" strcat systime intostr strcat setConfig
                    dup dup me @ name " has just sent you a summon request. Type 'mjoin " strcat me @ name strcat "' to accept." strcat
                    info_color otell
                    name "You have sent a summon request to " swap strcat me @ swap note_color tell
                then
            end
        endcase
    else
        pop me @ "Who do you wish to summon?" error_color tell
    then
;

: doJoin ( s -- )
    dup if
        dup pmatch dup case
            ok? not when "I don't recognize a player named \"" rot strcat "!\"" strcat me @ swap error_color tell end
            player? not when "I don't recognize a player named \"" rot strcat "!\"" strcat me @ swap error_color tell end
            awake? not when swap pop name " is not awake." strcat me @ swap error_color tell end
            me @ = when me @ "Joining yourself?" error_color tell end
            default 
                pop swap pop me @ "summon/summon_req" getConfig dup if
                    dup "_" rinstr strcut swap dup strlen 1 - strcut pop swap
                    atoi systime swap - 600 > not over pmatch 4 pick = and if
                        pop dup location me @ swap moveto
                        "_config/summon" remove_prop
                        me @ "_config/summon" remove_prop
                        me @ "Joined." note_color tell
                        exit
                    else
                        pop dup "summon/join_req" me @ name "_" strcat systime intostr strcat setConfig
                        dup dup me @ name " has just sent you a join request. Type 'msummon " strcat me @ name strcat "' to accept." strcat
                        info_color otell
                        name "You have sent a join request to " swap strcat me @ swap note_color tell
                    then
                else
                    pop dup "summon/join_req" me @ name "_" strcat systime intostr strcat setConfig
                    dup dup me @ name " has just sent you a join request. Type 'msummon " strcat me @ name strcat "' to accept." strcat
                    info_color otell
                    name "You have sent a join request to " swap strcat me @ swap note_color tell
                then
            end
        endcase
    else
        pop me @ "Who do you wish to summon?" error_color tell
    then
;

: main ( s -- )
    command @ case
        "msummon" stringcmp not when doSummon exit end
        "mjoin" stringcmp not when doJoin exit end
        default 
            me @ "Please tell " 
            trigger @ owner name strcat 
            " that there is a bad command linked to the program " strcat
            prog name strcat " called " strcat command @ strcat "." strcat
            error_color tell
        end
    endcase
;
.
c
q

