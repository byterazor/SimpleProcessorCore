lui $1, 5
lui $2, 6
lui $3, 0
lui $4, 1
add $5, $0, $2
loop:
add $3, $3, $1
sub $5, $5, $4
jpz end
jmp loop
end:
sto $3, 5000
hlt
