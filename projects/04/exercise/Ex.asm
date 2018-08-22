@101
D = A - 1
AD = A + 1  // set A and D to A + 1

@19         // Set D to 19
D = A

AD = A + D

@5034
M = D - 1

@171
D=A
@53
M=D

@7
D = M + 1

@sum
M = 0

@j
M = M + 1

@sum
D = M
@12
D = D + A
@j
D = D - M
@q
M = D

// goto 50
@50
0;JMP

// if D == 0 goto 112
@112
D;JEQ

// if D < 9 goto 50
@9
D = D - A
@50
D;JLT

// if RAM[12] > 0 goto 50
@12
D = M
@50
D;JGT

// if sum > 0 goto END
@sum
D = M
@END
D;JGT
