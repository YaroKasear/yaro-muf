@q
@program yaro-guest.muf
1 99999 del
i
$include $lib/yaro
$include $lib/editor

$def template_player #87
$def guest_room #88

: main
    var n
    var p

    case
        "Connect" stringcmp not when 
            begin
            prog "guest/firstnames#" getConfig array_vals array_make 
            SORTTYPE_SHUFFLE array_sort 0 array_getitem
            prog "guest/lastnames#" getConfig  array_vals array_make 
            SORTTYPE_SHUFFLE array_sort 0 array_getitem
            strcat "G_" swap strcat dup pmatch ok? over strlen 15 > or while repeat
            dup n !
            template_player swap prog owner name dup dup strcat strcat
            dup p !
            copyplayer dup guest_room moveto
            me @ descr n @ pmatch p @ descr_setuser
        end
        "Disconnect" stringcmp not when
            me @ #1 me @ toadplayer recycle
        end
        ( default
            case
                "edit-firstnames" paramTest when
                    0 EDITOR 
                end
                "edit-lastnames" paramTest when
                end
            endcase
        end )
    endcase
;
.
c
q

