// pop local 2
@LCL
D=M
@2
D=D+A
@R13
M=D

@SP
AM=M-1
D=M

@R13
A=M
M=D
