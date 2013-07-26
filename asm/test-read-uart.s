start:
loa $1, 65520
jmc print
jmc wait
jmp start
print:
add $20, $1, $0
sto $20, 65521
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
sto $20, 65521
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
sto $20, 65521
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
shr $20, $20, $0
sto $20, 65521
ret
wait:
lui $10, 600
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
shl $10, $10, $0
lui $11, 1
loop:
sub $10, $10, $11
jpz endloop
jmp loop
endloop:
ret
