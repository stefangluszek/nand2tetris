// push local|argument|this|that
// push [segment] [index]
// push local 4
@4
D=A
@LCL
A=M+D
D=M
@SP
AM=M+1
A=A-1
M=D

// pop local 4
@LCL
D=M
@4
D=D+A
@R13
M=D

@SP
AM=M-1
D=M

@R13
A=M
M=D

// push temp 3
@3
D=A
@R5
D=A+D
D=M
@SP
AM=M+1
A=A-1
M=D

// pop temp 4
@R5
D=M
@4
D=D+A
@R13
M=D

@SP
AM=M-1
D=M

@R13
A=M
M=D

// pop pointer 1 (that)
@SP
AM=M-1
D=M

@THIS
M=D

// push pointer 0 (this)
@THAT
D=M
@SP
AM=M+1
M=D
