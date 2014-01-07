loa $1, 200
jmc print
loa $1, 201
jmc print
loa $1, 202
jmc print
loa $1, 203
jmc print
loa $1, 204
jmc print
lui $1, 512
jmc printAscii
hlt
print:
add $20, $1, $0
printLoop:
sto $20, 65521
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
jpz endPrint
jmp printLoop
endPrint:
ret
printAscii:
add $20, $1, $0
asciloop:
and $21, $20, 15
or  $21, $21, 48
sub $22, $21, 10
jpc smaller
add $21, $21, 7
smaller:
sto $21, 65521
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
jpz asciloop:
ret
