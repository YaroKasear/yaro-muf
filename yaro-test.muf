@q
@program yaro-test.muf
1 99999 del
i
$include $lib/yaro

: main
    me @ { me @ 24 line  me @ 18 line dup } array_make 80 boxList
;
.
c
q

