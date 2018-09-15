// equal

// pop to D
@SP
AM=M-1
D=M
A=A-1
D=M-D

@EQ
D;JEQ

@SP
A=M-1
M=0

@END
0;JMP

(EQ)
    @SP
    A=M-1
    M=-1

(END)
