********************************************************************************
       AORG >6464
       TITL 'PARSES'
 
*      BASIC PARSE CODE
* REGISTER USAGE
*    RESERVED FOR GPL INTERPRETER  R13, R14, R15
*          R13 contains the read address for GROM
*          R14 is used in BASSUP/10 for the VDPRAM pointer
*    RESERVED IN BASIC SUPPORT
*          R8 MSB current character (like CHAT in GPL)
*          R8 LSB zero
*          R10 read data port address for program data
*   ALL EXITS TO GPL MUST GO THROUGH "NUDG05"
*
 
*                         ~~~TOKENS~~~
ELSE$  EQU  >81               ELSE
SSEP$  EQU  >82               STATEMENT SEPERATOR
TREM$  EQU  >83               TAIL REMARK
IF$    EQU  >84               IF
GO$    EQU  >85               GO
GOTO$  EQU  >86               GOTO
GOSUB$ EQU  >87               GOSUB
BREAK$ EQU  >8E               BREAK
NEXT$  EQU  >96               NEXT
SUB$   EQU  >A1               SUB
ERROR$ EQU  >A5               ERROR
WARN$  EQU  >A6               WARNING
THEN$  EQU  >B0               THEN
TO$    EQU  >B1               TO
COMMA$ EQU  >B3               COMMA
RPAR$  EQU  >B6               RIGHT PARENTHESIS )
LPAR$  EQU  >B7               LEFT PARENTHESIS (
OR$    EQU  >BA               OR
AND$   EQU  >BB               AND
XOR$   EQU  >BC               XOR
NOT$   EQU  >BD               NOT
EQ$    EQU  >BE               EQUAL (=)
GT$    EQU  >C0               GREATER THEN (>)
PLUS$  EQU  >C1               PLUS (+)
MINUS$ EQU  >C2               MINUS (-)
DIVI$  EQU  >C4               DIVIDE (/)
EXPON$ EQU  >C5               EXPONENT
STRIN$ EQU  >C7               STRING
LN$    EQU  >C9               LINE NUMBER
ABS$   EQU  >CB               ABSOLUTE
SGN$   EQU  >D1               SIGN
*
C24    DATA 24                CONSTANT 24
EXRTNA DATA EXRTN             RETURN FOR EXEC
*
ERRSO  LI   R0,>0703          Issue STACK OVERFLOW message
       B    @ERR
*
* GRAPHICS LANGUAGE ENTRY TO PARSE
*
PARSEG BL   @SETREG           Set up registers for Basic
       MOVB @GRMRAX(R13),R11   Get GROM address
       MOVB @GRMRAX(R13),@R11LB
       DEC  R11
*
* 9900 ENTRY TO PARSE
*
PARSE  INCT R9                Get room for return address
       CI   R9,STKEND         Stack full?
       JH   ERRSO             Yes, too many levels deep
       MOV  R11,*R9           Save the return address
P05    MOVB R8,R7             Test for token beginning
       JLT  P10               If token, then look it up
       B    @PSYM             If not token is a symbol
P10    BL   @PGMCHR           Get next character
       SRL  R7,7              Change last character to offset
       AI   R7,->B7*2         Check for legal NUD
       CI   R7,NTABLN         Within the legal NUD address?
       JH   CONT15            No, check for legal LED
       MOV  @NTAB(R7),R7      Get NUD address
       JGT  B9900             If 9900 code
P17    EQU  $                 R7 contains offset into nudtab
       ANDI R7,>7FFF          If GPL code, get rid of MSB
       A    @NUDTAB,R7        Add in table address
NUDG05 BL   @SAVREG           Restore GPL pointers
       MOVB R7,@GRMWAX(R13)    Write out new GROM address
       SWPB R7                Bare the LSB
       MOVB R7,@GRMWAX(R13)    Put it out too
       B    @RESET            Go back to GPL interpreter
P17L   JMP  P17
*
* CONTINUE ROUTINE FOR PARSE
*
CONTG  BL   @SETREG           GPL entry-set Basic registers
CONT   MOV  *R9,R6            Get last address from stack
       JGT  CONT10            9900 code if not negative
       MOVB R6,@GRMWAX(R13)    Write out new GROM address
       SWPB R6                Bare the second byte
       MOVB R6,@GRMWAX(R13)    Put it out too
       MOV  R13,R6            Set up to test precedence
CONT10 CB   *R6,R8            Test precedence
       JHE  NUDNDL            Have parsed far enough->return
       SRL  R8,7              Make into table offset
       AI   R8,->B8*2         Minimum token for a LED (*2)
       CI   R8,LTBLEN         Maximum token for a LED (*2)
CONT15 JH   NOLEDL            If outside legal LED range-err
       MOV  @LTAB(R8),R7      Pick up address of LED handler
       CLR  R8                Clear 'CHAT' for getting new
       BL   @PGMCHR           Get next character
B9900  B    *R7               Go to the LED handler
NUDE10 DECT R9                Back up subroutine stack
       INC  R7                Skip over precedence
       JMP  NUDG05            Goto code to return to GPL
NOLEDL B    @NOLED
NUDNDL JMP  NUDND1
* Execute one or more lines of Basic
EXECG  EQU  $                 GPL entry point for execution
       BL   @SETREG           Set up registers
       CLR  @ERRCOD           Clear the return code
       MOVB @PRGFLG,R0        Imperative statement?
       JEQ  EXEC15            Yes, handle it as such
* Loop for each statement in the program
EXEC10 EQU  $
       MOVB @FLAG,R0          Now test for trace mode
       SLA  R0,3              Check the trace bit in FLAG
       JLT  TRACL             If set->display line number
EXEC11 MOV  @EXTRAM,@PGMPTR   Get text pointer
       DECT @PGMPTR           Back to the line # to check
*                              break point
       BL   @PGMCHR           Get the first byte of line #
       STST R0                Save status for breakpnt check
       INC  @PGMPTR           Get text pointer again
       BL   @PGMCHR           Go get the text pointer
       SWPB R8                Save 1st byte of text pointer
       BL   @PGMCHR           Get 2nd byte of text pointer
       SWPB R8                Put text pointer in order
       MOV  R8,@PGMPTR        Set new text pointer
       CLR  R8                Clean up the mess
       SLA  R0,2              Check breakpoint status
       JLT  EXEC15            If no breakpoint set - count
       JNC  BRKPNT            If breakpoint set-handle it
EXEC15 EQU  $                                                  <****************
C3     EQU  $+2               Constant data 3                  <
CB3    EQU  $+3               Constant byte 3                  <
       LIMI 3                 Let interrupts loose             <
C0     EQU  $+2               Constant data 0                  <
       LIMI 0                 Shut down interrupts             <
       CLR  @>83D6            Reset VDP timeout                < CRU
       LI   R12,>24           Load console KBD address in CRU  < KEY
       LDCR @C0,3             Select keyboard section          < SCAN
       LI   R12,6             Read address                     < SECTION
       STCR R0,8              SCAN the keyboard                < MUST
       CZC  @C1000,R0         Shift-key depressed?             < BE
       JNE  EXEC16            No, execute the Basic statement  < PATCHED
       LI   R12,>24           Test column 3 of keyboard        < TO
       LDCR @CB3,3            Select keyboard section          < WORK
       LI   R12,6             Read address                     < ON
       STCR R0,8              SCAN the keyboard                < A
       CZC  @C1000,R0         Shift-C depressed?               < GENEVE
       JEQ  BRKP1L            Yes, so take Basic breakpoint    < COMPUTER
EXEC16 MOV  @PGMPTR,@SMTSRT   Save start of statement
       INCT R9                Get subroutine stack space
       MOV  @EXRTNA,*R9       Save the GPL return address
       BL   @PGMCHR           Now get 1st character of stmt
       JEQ  EXRTN3            If EOL after EOS
EXEC17 JLT  EXEC20            If top bit set->keyword
       B    @NLET             If not->fake a 'LET' stmt
EXEC20 MOV  R8,R7             Save 1st token so can get 2nd
       INC  @PGMPTR           Increment the perm pointer
       MOVB *R10,R8           Read the character
       SRL  R7,7              Convert 1st to table offset
       AI   R7,->AA*2         Check for legal stmt token
       JGT  ERRONE            Not in range -> error
       MOV  @STMTTB(R7),R7    Get address of stmt handler
       JLT  P17L              If top bit set -> GROM code
       B    *R7               If 9900 code, goto it!
EXRTN  BYTE >83               Unused bytes for data constant
CBH65  BYTE >65                since NUDEND skips precedences
       CI   R8,SSEP$*256      EOS only?
       JEQ  EXEC15            Yes, continue on this line
EXRTN2 MOVB @PRGFLG,R0        Did we execute an imperative
       JEQ  EXEC50            Yes, so return to top-level
       S    @C4,@EXTRAM       No, so goto the next line
       C    @EXTRAM,@STLN     Check to see if end of program
       JHE  EXEC10            No, so loop for the next line
       JMP  EXEC50            Yes, so return to top-level
*
* STMT handler for ::
*
SMTSEP MOVB R8,R8             EOL?
       JNE  EXEC17            NO, there is another stmt
EXRTN3 DECT R9                YES
       JMP  EXRTN2            Jump back into it
* Continue after a breakpoint
CONTIN BL   @SETREG           Set up Basic registers
EXC15L JMP  EXEC15            Continue execution
BRKP1L JMP  BRKPN1
TRACL  JMP  TRACE
* Test for required End-Of-Statement
EOL    MOVB R8,R8             EOL reached?
       JEQ  NUDND1            Yes
       CI   R8,TREM$*256      Higher then tail remark token?
       JH   ERRONE            Yes, its an error
       CI   R8,ELSE$*256      Tail, ssep or else?
       JL   ERRONE            No, error
*
* Return from call to PARSE
* (entered from CONT)
*
NUDND1 MOV  *R9,R7            Get the return address
       JLT  NUDE10            If negative - return to GPL
       DECT R9                Back up the subroutine stack
       B    @2(R7)            And return to caller
*      (Skip the precedence word)
NUDEND MOVB R8,R8             Check for EOL
       JEQ  NUDND1            If EOL
NUDND2 CI   R8,STRIN$*256     Lower than a string?
       JL   NUDND4            Yes
       CI   R8,LN$*256        Higher than a line #?
       JEQ  SKPLN             Skip line numbers
       JL   SKPSTR            Skip string or numeric
NUDND3 BL   @PGMCHR           Read next character
       JEQ  NUDND1            If EOL
       JMP  NUDND2            Continue scan of line
NUDND4 CI   R8,TREM$*256      Higher than a tail remark?
       JH   NUDND3            Yes
       CI   R8,SSEP$*256      Lower then stmt sep(else)?
       JL   NUDND3            Yes
       JMP  NUDND1            TREM or SSEP
SKPSTR BL   @PGMCHR
       SWPB R8                Prepare to add
       A    R8,@PGMPTR        Skip it
       CLR  R8                Clear lower byte
SKPS01 BL   @PGMCHR           Get next token
       JMP  NUDEND            Go on
SKPLN  INCT @PGMPTR           Skip line number
       JMP  SKPS01            Go on
*
* Return from "CALL" to GPL
RTNG   BL   @SETREG           Set up registers again
       JMP  NUDND1            And jump back into it!
*************************************************************
* Handle Breakpoints
BRKPNT MOVB @FLAG,R0          Check flag bits
       SLA  R0,1              Check bit 6 for breakpoint
       JLT  EXC15L            If set then ignore breakpoint
BRKPN2 LI   R0,BRKFL
       JMP  EXIT              Return to top-level
BRKPN1 MOVB @FLAG,R0          Move flag bits
       SLA  R0,1              Check bit 6 for breakpoint
       JLT  EXEC16            If set then ignore breakpoint
       JMP  BRKPN2            Bit not set
*
* Error handling from 9900 code
*
ERRSYN EQU  $                 These all issue same message
ERRONE EQU  $
NONUD  EQU  $
NOLED  EQU  $
       LI   R0,ERRSN          *SYNTAX ERROR return code
EXIT   EQU  $
ERR    MOV  R0,@ERRCOD        Load up return code for GPL
* General return to GPL portion of Basic
EXEC50 MOV  @RTNADD,R7        Get return address
       B    @NUDG05           Use commond code to link back
* Handle STOP and END statements
STOP
END    DECT R9                Pop last call to PARSE
       JMP  EXEC50            Jump to return to top-level
* Error codes for return to GPL
ERRSN  EQU  >0003             ERROR SYNTAX
ERROM  EQU  >0103             ERROR OUT OF MEMORY
ERRIOR EQU  >0203             ERROR INDEX OUT OF RANGE
ERRLNF EQU  >0303             ERROR LINE NOT FOUND
ERREX  EQU  >0403             ERROR EXECUTION
* >0004 WARNING NUMERIC OVERFLOW
BRKFL  EQU  >0001             BREAKPOINT RETURN VECTOR
ERROR  EQU  >0005             ON ERROR
UDF    EQU  >0006             FUNCTION REFERENCE
BREAK  EQU  >0007             ON BREAK
CONCAT EQU  >0008             CONCATENATE (&) STRINGS
WARN   EQU  >0009             ON WARNING
* Warning routine (only OVERFLOW)
WARN$$ MOV  @C4,@ERRCOD       Load warning code for GPL
       LI   R11,CONT-2        To optimize for return
* Return to GPL as a CALL
CALGPL INCT R9                Get space on subroutine stack
       MOV  R11,*R9           Save return address
       JMP  EXEC50            And go to GPL
* Trace a line (Call GPL routine)
TRACE  MOV  @C2,@ERRCOD       Load return vector
       LI   R11,EXEC11-2      Set up for return to execute
       JMP  CALGPL            Call GPL to display line #
* Special code to handle concatenate (&)
CONC   LI   R0,CONCAT         Go to GPL to handle it
       JMP  EXIT              Exit to GPL interpeter
*************************************************************
*              NUD routine for a numeric constant           *
* NUMCON first puts pointer to the numeric string into      *
* FAC12 for CSN, clears the error byte (FAC10) and then     *
* converts from a string to a floating point number. Issues *
* warning if necessary. Leaves value in FAC                 *
*************************************************************
NUMCON MOV  @PGMPTR,@FAC12    Set pointer for CSN
       SWPB R8                Swap to get length into LSB
       A    R8,@PGMPTR        Add to pointer to check end
       CLR  @FAC10            Assume no error
       BL   @SAVRE2           Save registers
       LI   R3,GETCH          Adjustment for ERAM in order
       MOVB @RAMFLG,R4         to call CSN
       JEQ  NUMC49
       LI   R3,GETCGR
NUMC49 BL   @CSN01            Convert String to Number
       BL   @SETREG           Restore registers
       C    @FAC12,@PGMPTR    Check to see if all converted
       JNE  ERRONE            If not - error
       BL   @PGMCHR           Now get next char from program
       MOVB @FAC10,R0         Get an overflow on conversion?
       JNE  WARN$$            Yes, have GPL issue warning
       B    @CONT             Continue the PARSE
*
* ON ERROR, ON WARNING and ON BREAK
ONERR  LI   R0,ERROR          ON ERROR code
       JMP  EXIT              Return to GPL code
ONWARN LI   R0,WARN           ON WARNING code
       JMP  EXIT              Return to GPL code
ONBRK  LI   R0,BREAK          ON BREAK code
       JMP  EXIT              Return to GPL code
*
* NUD routine for "GO"
*
GO     CLR  R3                Dummy "ON" index for common
       JMP  ON30              Merge into "ON" code
*
* NUD ROUTINE FOR "ON"
*
ON     CI   R8,WARN$*256      On warning?
       JEQ  ONWARN            Yes, goto ONWARN
       CI   R8,ERROR$*256     On error?
       JEQ  ONERR             Yes, got ONERR
       CI   R8,BREAK$*256     On break?
       JEQ  ONBRK             Yes, goto ONBRK
*
* Normal "ON" statement
*
       BL   @PARSE            PARSE the index value
       BYTE COMMA$            Stop on a comma or less
CBH66  BYTE >66               Unused byte for constant
       BL   @NUMCHK           Ensure index is a number
       CLR  @FAC10            Assume no error in CFI
       BL   @CFI              Convert Floating to Integer
       MOVB @FAC10,R0         Test error code
       JNE  GOTO90            If overflow, BAD VALUE
       MOV  @FAC,R3           Get the index
       JGT  ON20              Must be positive
GOTO90 LI   R0,ERRIOR         Negative, BAD VALUE
GOTO95 JMP  ERR               Jump to error handler
ON20   EQU  $                 Now check GO TO/SUB
       CI   R8,GO$*256        Bare "GO" token?
       JNE  ON40              No, check other possibilities
       BL   @PGMCHR           Yes, get next token
ON30   CI   R8,TO$*256        "GO TO" ?
       JEQ  GOTO50            Yes, handle GO TO like GOTO
       CI   R8,SUB$*256       "GO SUB" ?
       JMP  ON50              Merge to common code to test
ON40   CI   R8,GOTO$*256      "GOTO" ?
       JEQ  GOTO50            Yes, go handle it
       CI   R8,GOSUB$*256     "GOSUB" ?
ON50   JNE  ERRONE            No, so is an error
       BL   @PGMCHR           Get next token
       JMP  GOSUB2            Goto gosub code
ERR1B  JMP  ERRONE            Issue error message
* NUD routine for "GOSUB"
GOSUB  CLR  R3                Dummy index for "ON" code
* Common GOSUB code
GOSUB2 EQU  $                 Now build a FAC entry
       LI   R1,FAC            Optimize to save bytes
       MOV  R3,*R1+           Save the "ON" index
*                              in case of garbage collection
       MOVB @CBH66,*R1+       Indicate GOSUB entry on stack
       INC  R1                Skip FAC3
       MOV  @PGMPTR,*R1       Save current ptr w/in line
       INCT *R1+              Skip line # to correct place
       MOV  @EXTRAM,*R1       Save current line # pointer
       BL   @VPUSH            Save the stack entry
       MOV  @FAC,R3           Restore the "ON" index
       JMP  GOTO20            Jump to code to find the line
* NUD routine for "GOTO"
GOTO   CLR  R3                Dummy index for "ON" code
* Common (ON) GOTO/GOSUB THEN/ELSE code to fine line
*
* Get line number from program
GOTO20 CI   R8,LN$*256        Must have line number token
       JNE  ERR1B             Don't, so error
GETL10 BL   @PGMCHR           Get MSB of the line number
       MOVB R8,R0             Save it
       BL   @PGMCHR           Read the character
       DEC  R3                Decrement the "ON" index
       JGT  GOTO40            Loop if not there yet
*
* Find the program line
*
       MOV  @STLN,R1          Get into line # table
       MOVB @RAMFLG,R2        Check ERAM flag to see where?
       JEQ  GOTO31            From VDP, go handle it
       MOV  R1,R2             Copy address
GOT32  C    R1,@ENLN          Finished w/line # table?
       JHE  GOTO34            Yes, so line doesn't exist
       MOVB *R2+,R3           2nd byte match?
       ANDI R3,>7FFF          Reset possible breakpoint
       CB   R3,R0             Compare 1st byte of #, Match?
       JNE  GOT35             Not a match, so move on
       CB   *R2+,R8           2nd byte match?
       JEQ  GOTO36            Yes, line is found!
GOT33  INCT R2                Skip line pointer
       MOV  R2,R1             Advance to next line in table
       JMP  GOT32             Go back for more
GOT35  MOVB *R2+,R3           Skip 2nd byte of line #
       JMP  GOT33             And jump back in
GOTO31 MOVB @R1LB,*R15        Get the data from the VDP
       LI   R2,XVDPRD         Load up to read data
       MOVB R1,*R15           Write out MSB of address
GOTO32 C    R1,@ENLN          Finished w/line # table
       JHE  GOTO34            Yes, so line doesn't exist
       MOVB *R2,R3            Save in temporary place for
*                              breakpoint checking
       ANDI R3,>7FFF          Reset possible breakpoint
       CB   R3,R0             Compare 1st byte of #, Match?
       JNE  GOTO35            Not a match, so move on
       CB   *R2,R8            2nd byte match?
       JEQ  GOTO36            Yes, line is found!
GOTO33 MOVB *R2,R3            Skip 1st byte of line pointer
       AI   R1,4              Advance to next line in table
       MOVB *R2,R3            Skip 1nd byte of line pointer
       JMP  GOTO32            Go back for more
GOTO35 MOVB *R2,R3            Skip 2nd byte of line #
       JMP  GOTO33            And jump back in
GOTO34 LI   R0,ERRLNF         LINE NOT FOUND error vector
       JMP  GOTO95            Jump for error exit
GOTO36 INCT R1                Adjust to line pointer
       MOV  R1,@EXTRAM        Save for execution of the line
       DECT R9                Pop saved link to goto
       B    @EXEC10           Reenter EXEC code directly
GOTO40 BL   @PGMCHR           Get next token
       BL   @EOSTMT           Premature end of statement?
       JEQ  GOTO90            Yes =>BAD VALUE for index
       CI   R8,COMMA$*256     Comma next ?
       JNE  ERR1C             No, error
GOTO50 BL   @PGMCHR           Yes, get next character
       JMP  GOTO20            And check this index value
ERR1C  JMP  ERR1B             Linking becuase long-distance
ERR51  LI   R0,>0903          RETURN WITHOUT GOSUB
       JMP  GOTO95            Exit to GPL
* NUD entry for "RETURN"
RETURN C    @VSPTR,@STVSPT    Check bottom of stack
       JLE  ERR51             Error -> RETURN WITHOUT GOSUB
       BL   @VPOP             Pop entry
       CB   @CBH66,@FAC2      Check ID for a GOSUB entry
       JNE  RETU30            Check for ERROR ENTRY
*
* Have a GOSUB entry
*
       BL   @EOSTMT           Must have EOS after return
       JNE  RETURN            Not EOS, then error return?
       MOV  @FAC4,@PGMPTR     Get return ptr w/in line
       MOV  @FAC6,@EXTRAM     Get return line pointer
       B    @SKPS01           Go adjust it and get back
* Check ERROR entry
RETU30 CB   @CBH69,@FAC2      ERROR ENTRY?
       JEQ  RETU40            Yes, take care of error entry
       CB   @CBH6A,@FAC2      Subprogram entry?
       JNE  RETURN            No, look some more
       BL   @VPUSH            Push it back. Keep information
       JMP  ERR51             RETURN WITHOUT GOSUB error
*
* Have an ERROR entry
* RETURN, RETURN line #, RETURN or RETURN NEXT follows.
*
RETU40 CLR  R3                In case of a line number
       CI   R8,LN$*256        Check for a line number
       JEQ  GETL10            Yes, treat like GOTO
       MOV  @FAC4,@PGMPTR     Get return ptr w/in line
       MOV  @FAC6,@EXTRAM     Get return line pointer
       BL   @EOSTMT           EOL now?
       JEQ  BEXC15            Yes, treat like GOSUB rtn.
       CI   R8,NEXT$*256      NEXT now?
       JNE  ERR1C             No, so its an error
       B    @SKPS01           Yes, so execute next statement
BEXC15 B    @EXEC15           Execute next line
CBH6A  BYTE >6A               Subprogram call stack ID
       EVEN
*************************************************************
*         EOSTMT - Check for End-Of-STateMenT               *
*         Returns with condition '=' if EOS                 *
*           else condition '<>' if not EOS                  *
*************************************************************
EOSTMT MOVB R8,R8             EOL or non-token?
       JEQ  EOSTM1            EOL-return condition '='
       JGT  EOSTM1            Non-token return condition '<>'
       CI   R8,TREM$*256      In the EOS range (>81 to >83)?
       JH   EOSTM1            No, return condition '<>'
       C    R8,R8             Yes, force condition to '='
EOSTM1 RT
*************************************************************
*         EOLINE - Tests for End-Of-LINE; either a >00 or a *
*                  '!'                                      *
*         Returns with condition '=' if EOL else condition  *
*                  '<>' if not EOL                          *
*************************************************************
EOLINE MOVB R8,R8             EOL?
       JEQ  EOLNE1            Yes, return with '=' set
       CI   R8,TREM$*256      Set condition on a tall remark
EOLNE1 RT                     And return
SYMB20 LI   R0,UDF            Long distance
       B    @GOTO95
* NUD for a symbol (variable)
PSYM   BL   @SYM              Get symbol table entry
       BL   @GETV             Get 1st byte of entry
       DATA FAC               SYM left pointer in FAC
*
       SLA  R1,1              UDF reference?
       JLT  SYMB20            Yes, special code for it
       BL   @SMB              No, get value space pointer
       CB   @FAC2,@CBH65      String reference?
       JEQ  SYMB10            Yes, special code for it
       BL   @MOVFAC           No, numeric ->copy into FAC
SYMB10 B    @CONT             And continue the PARSE
* Statement entry for IF statement
IF     BL   @PARSE            Evaluate the expression
       BYTE COMMA$            Stop on a comma
CBH67  BYTE >67               Unused byte for a constant
       BL   @NUMCHK           Ensure the value is a number
       CLR  R3                Create a dummy "ON" index
       CI   R8,THEN$*256      Have a "THEN" token
       JNE  ERR1C             No, error
       NEG  @FAC              Test if condition true i.e. <>0
       JNE  IF$10             True - branch to the special #
       BL   @PGMCHR           Advance to line number token
       CI   R8,LN$*256        Have the line # token?
       JNE  IF$20             No, must look harder for ELSE
       INCT @PGMPTR           Skip the line number
       BL   @PGMCHR           Get next token
IF$5   CI   R8,ELSE$*256      Test if token is ELSE
       JEQ  IF$10             We do! So branch to the line #
       B    @EOL              We don't, so better be EOL
GETL1$ B    @GETL10           Get 1st token of clause
IF$10  BL   @PGMCHR           Get 1st token of clause
       CI   R8,LN$*256        Line # token?
       JEQ  GETL1$            Yes, go there
       BL   @EOSTMT           EOS?
JEQ1C  JEQ  ERR1C             Yes, its an error
       LI   R8,SSEP$*256      Cheat to do a continue
       DEC  @PGMPTR           Back up to get 1st character
       B    @CONT             Continue on
*
* LOOK FOR AN ELSE CLAUSE SINCE THE CONDITION WAS FALSE
*
IF$20  LI   R3,1              IF/ELSE pair counter
       BL   @EOLINE           Trap out EOS following THEN/ELSE
       JEQ  JEQ1C             error
IF$25  CI   R8,ELSE$*256      ELSE?
       JNE  IF$27             If not
       DEC  R3                Matching ELSE?
       JEQ  IF$10             Yes, do it
       JMP  IF$35             No, go on
IF$27  CI   R8,IF$*256        Check for it
       JNE  IF$28             Not an IF
       INC  R3                Increment nesting level
       JMP  IF$35              And go on
IF$28  CI   R8,STRIN$*256     Lower than string?
       JL   IF$30             Yes
       CI   R8,LN$*256        Higher or = to a line #
       JEQ  IF$40             = line #
       JL   IF$50             Skip strings and numerics
IF$30  BL   @EOLINE           EOL?
       JEQ  IF$5              Yes, done scanning
IF$35  BL   @PGMCHR           Get next character
       JMP  IF$25               And go on
*
* SKIP LINE #'s
*
IF$40  INCT @PGMPTR           Skip the line #
       JMP  IF$35             Go on
*
* SKIP STRINGS AND NUMERICS
*
IF$50  BL   @PGMCHR           Get # of bytes to skip
       SWPB R8                Swap for add
       A    R8,@PGMPTR        Skip it
       CLR  R8                Clear LSB of R8
       JMP  IF$35
********************************************************************************
 
