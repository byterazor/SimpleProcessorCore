start:
lui $0, 0
lui $1, 35
lui $2, 36
jmc print
sto $1, 65521
jmc print
jmp end
print:
add $30, $31, $0
sto $30, 65521
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
sto $30, 65521
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
sto $30, 65521
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
shr $30, $30, $0
sto $30, 65521
sto $1, 65521
ret
sto $2, 65521
end:
hlt
