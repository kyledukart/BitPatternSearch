*-----------------------------------------------------------
* Title      :  422 HW4 #3
* Written by :  Kyle Dukart
* Date       :  11/8/19
* Description:  This program takes user input for Starting Address,
*   Ending Address, and Pattern to search as word-length values.  The pattern
*   input is a string of up to 16 chars containing only '0' and '1'. The
*   program iterates through the given address values word by word, checking
*   to see if the pattern is located in memory.  If the pattern is found, the
*   address of the pattern will be stored in A5.  If the pattern is not found,
*   $FFFFFFFF will be stored in A5.
*-----------------------------------------------------------
CR  EQU $0D         ; carraige return
LF  EQU $0A         ; line feed
word    EQU 2       ; advance by 1 word
exit    EQU $2700   ; simulator stop code
mask    EQU $00FF   ; masking 2 lower bytes

    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.B  #14,D0      ; set up TRAP
    LEA INTROMSG,A1     ; prepare intromsg
    TRAP #15            ; display intromsg
    
    MOVE.B  #4,D0       ; set up read TRAP
    TRAP #15            ; read input
    MOVEA   D1,A3     ; move input to A3
    TRAP #15            ; read input
    MOVEA   D1,A4     ; move input to A4
    MOVE.B #2,D0        ; set up ASCII read TRAP
    TRAP #15            ; read input
    
*   This function takes an ASCII number containing only 0 and 1 and
*   converts it to a binary number.
*
*   Input: ASCII number is pointed to in memory by (A1)
*           Length of this number is in D1
*
*   Output: Binary number stored in D3
Convert_ASCII_to_BIN:
    CLR D0
    CLR D3
Convert_Loop:
    MOVE.B (A1)+,D0     ; move first ASCII byte to D0
    AND.W   #mask,D0    ; mask the byte
    SUB.B   #$30,D0     ; subtract 30
    SUB.W   #1, D1      ; decrement D1
    JSR SHIFT_D0        ; shift D0 to proper place
    OR D0,D3            ; add bit in D0 to answer(D3)
    CMP #0, D1          ; check if D1 == 0
    BNE CONVERT_LOOP    ; loop if D1 != 0

    
TESTING:
    MOVEA #5000,A6      ; point A6 to mem loc 5000
    MOVE.W #%1001100110011001,(A6)   ; move binary test value to mem loc 5000
    
LOOP:
    CMP.W (A3),D3       ; compare value in D3 to value pointed by A3
    BEQ FOUND           ; values match
    ADDQ.W  #word,A3    ; increment pointer
    CMP A3,A4           ; check if still in loop
    BLE LOOP            ; loop
    
    MOVEA #$FFFFFFFF,A5 ; not found, fill A5
    STOP #exit
    
FOUND:
    MOVEA A3,A5         ; move found address to A5
    STOP #exit          ; end sim
    
* This function shifts the value of D0 left X times, where X is stored in D1
SHIFT_D0:
    MOVE D1, D6         ; store number of places to shift in d6
    CMP #0, D6          ; check if D6 == 0
    BEQ ENDSHIFTLOOP
SHIFTLOOP:
    ASL.W #1, D0        ; shift 1 bit
    SUB #1, D6          ; decrement d6
    CMP #0, D6          ; check if D6 is 0
    BGT SHIFTLOOP       ; loop of D6 > 0
ENDSHIFTLOOP:
    RTS
    
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

INTROMSG DC.B 'Enter starting address, ending address, and pattern',CR,LF,0 

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
