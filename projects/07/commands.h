final constant push_segment_template =
#"@%d
D=A
@%s
A=M+D
D=M
@SP
AM=M+1
A=A-1
M=D
";

final constant push_constant_template =
#"@%d
D=A
@SP
AM=M+1
A=A-1
M=D
";

final constant arithmetic_2_template =
#"@SP
AM=M-1
D=M
A=A-1
M=M%sD
";

final constant arithmetic_1_template =
#"@SP
A=M-1
M=%sM
";

final constant comp_template =
#"@SP
AM=M-1
D=M
A=A-1
D=M-D

@EQ.%d
D;%s

@SP
A=M-1
M=0

@L.%d
0;JMP

(EQ.%d)
    @SP
    A=M-1
    M=-1

(L.%d)
";

final constant pop_segment_template =
#"@%s
D=M
@%d
D=D+A
@R13
M=D

@SP
AM=M-1
D=M

@R13
A=M
M=D
";

final constant push_temp_template =
#"@%d
D=A
@R5
A=A+D
D=M
@SP
AM=M+1
A=A-1
M=D
";

final constant pop_temp_template =
#"@R5
D=A
@%d
D=D+A
@R13
M=D

@SP
AM=M-1
D=M

@R13
A=M
M=D
";

final constant push_pointer_template =
#"@%s
D=M
@SP
AM=M+1
A=A-1
M=D
";

final constant  pop_pointer_template =
#"@SP
AM=M-1
D=M

@%s
M=D
";
