lui $1, 1           # for sub 1
lui $2, 1           # a
lui $3, 1           # b
lui $4, 1           # c
lui $5, 33          # i
lui $6, 2
sub $5,$5,$6         
loop:
add $3,$0,$2        # b=a
add $2,$0,$4        # a=c
add $4,$2,$3        # c=a+b
sto $4, 5000
sub $5,$5,$1        # $i--
jpz end
jmp loop
end:
hlt
