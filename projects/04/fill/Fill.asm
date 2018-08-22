// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

@SCREEN
D=A
@scr
M=D

// Calculate the last address of the SCREEN
@8191
D=A
@SCREEN
D=D+A
@maxscr
M=D

(LOOP)
    @KBD
    D=M
    @FILL
    D;JEQ

    @KBD
    D=M
    @EMPTY
    D;JNE

    (FILL)
        @scr
        D=M
        A=D
        M=-1

        @scr
        D=M
        @maxscr
        D=D-M
        @LOOP
        D;JEQ

        // Increment the screen address
        @scr
        M=M+1
        @LOOP
        0;JMP
        
    (EMPTY)
        @scr
        D=M
        A=D
        M=0
        
        // check if value @scr == @SCREEN
        @scr
        D=M
        @SCREEN
        D=D-A
        @LOOP
        D;JEQ

        // Decrement the screen address
        @scr
        M=M-1
        @LOOP
        0;JMP
(END)
    @END
    0;JMP
