********************************************************************************
       AORG >7000
       TITL 'FORNEXTS'
 
*************************************************************
* FOR statement                                             *
* Builds up a stack entry for the FOR statement. Checks the *
* syntax of a FOR statement and also checks to see if the   *
* loop is executed at all. The loop is not executed if the  *
* limit of the FOR is > then initial value and the step is  *
* positive of the limit of the FOR is < then initial value  *
* and the step is negative.                                 *
*                                                           *
* A stack entry for a 'FOR' statement looks like:           *
*                                                           *
* +-------------------------------------------------------+ *
* | PTR TO S.T. | >67 |     | Value Space  | BUFLEV       | *
* |   ENTRY     |     |     |  Pointer     |              | *
* | ------------------------------------------------------| *
* | FOR line #  | FOR line  |                             | *
* | table ptr   |  pointer  |                             | *
* |-------------------------------------------------------| *
* |                    Increment Value                    | *
* |-------------------------------------------------------| *
* |                        Limit                          | *
* +-------------------------------------------------------+ *
*************************************************************
NFOR   MOVB R8,R8             EOL?
       JGT  NFOR1             If symbol name, ok
       JMP  ERRCDT            If EOL or Token, error
NFOR1  BL   @SYM              Get pointer to s.t. entry
       BL   @GETV             Get 1st byte of symbol
       DATA FAC                 entry
*
       ANDI R1,>C700          Check string, function & array
       JNE  BERMUW            If andy of the above, error
       CI   R8,EQ$*256        Must have '='
       JNE  ERRCDT            If not, error
       BL   @SMB              Get index's value space
       CLR  @FAC2             Dummy entry ID on the stack
       MOV  @BUFLEV,@FAC6     Save buffer level
*
* Search stack for another FOR entry with the same loop
*  variable. If one is found, remove it.
*
       MOV  @VSPTR,R3         Copy stack pointer
*
* See if end of stack
NFOR1A C    R3,@STVSPT        Check stack underflow
       JLE  NFOR1E            Finished with stack scan
* See if FOR entry
       BL   @GET1             Get pointer to s.t. entry
       MOV  R1,R0             Move it to use later
       MOVB @XVDPRD,R1        Read stack ID
       CB   R1,@CBH67         Is stack entry a FOR?
       JNE  NFOR1B            No, 8 byte regular entry
* Compare loop variables
       C    R0,@FAC           Loop variables match?
       JEQ  NFOR1C            Yes
       AI   R3,-32            Skip this FOR entry
       JMP  NFOR1A            Loop
NFOR1B CB   R1,@CCBH6A        Hit a subprogram entry?
       JEQ  NFOR1E            Yes, don't scan anymore
       AI   R3,-8             Skip 8 byte stack entry
       JMP  NFOR1A            Loop
* Found matching loop variable, move stack down 32 bytes
NFOR1C MOV  @VSPTR,R2         Copy stack pointer
       S    R3,R2             Calculate # of bytes to move
       JEQ  NFOR1D            0 bytes, skip move
       MOV  R3,R4             Destination pointer
       AI   R4,-24            Place to move to
C8     EQU  $+2
       AI   R3,8              Point at entry above FOR entry
NFOR1F BL   @GETV1            Get the byte
       BL   @PUTV1            Put the byte
       INC  R3                Inc From pointer
       INC  R4                Inc To pointer
       DEC  R2                Decrement counter
       JNE  NFOR1F            Loop if not done
NFOR1D S    @C32,@VSPTR       Adjust top of stack
* Now put new FOR entry on stack
NFOR1E BL   @VPUSH            Reserve space for limit
       BL   @VPUSH               increment,
       BL   @VPUSH                and 2nd info entry
       MOVB @CBH67,@FAC2      FOR ID on stack
       BL   @PGMCHR           Get next character
       BL   @PSHPRS           Push symbol I.D. entry
       BYTE TO$               Parse the initial value
CCBH63 BYTE >63               Wasted byte (CBH63)
       CI   R8,TO$*256        TO?
       JNE  ERRCDT            No, error
       BL   @PGMCHR
       BL   @PSHPRS           Push initial and get limit
       BYTE STEP$
CCBH6A BYTE >6A               Wasted byte (CBA6A)
       CB   @CCBH63,@FAC2     If a string value
       JL   BERR6             Its an error
       S    @C40,@VSPTR
       BL   @VPUSH            Push the limit
       BL   @EOSTMT           At the end of statement?
       JEQ  NFOR2             Yes, default incr to 1
       CI   R8,STEP$*256      STEP?
       JNE  ERRCDT            No, Its an error
       A    @C32,@VSPTR       Corrrect stack pointer
       BL   @PGMCHR
       BL   @PARSE            Get the increment
       BYTE TREM$,0
       S    @C32,@VSPTR       Get stack to needed place
       MOV  @FAC,R0           Can't have zero increment
       JEQ  ERRBV2            If 0, its an error
       CB   @CCBH63,@FAC2     Can't have zero increment
       JHE  NFOR3             If numeric, ok
BERR6  B    @ERRT             * STRING NUMBER MISMATCH
BERMUW B    @ERRMUV           * MULTIPLY USED VARIABLE
ERRBV2 B    @GOTO90
ERRCDT B    @ERRSYN
NFOR2  LI   R0,FAC
       MOV  @FLTONE,*R0+      Put a floating one in
       CLR  *R0+
       CLR  *R0+
       CLR  *R0
NFOR3  BL   @VPUSH            Push the step
       LI   R1,FAC            Optimize to save bytes
       MOV  @EXTRAM,*R1+      Save line # pointer
       MOV  @PGMPTR,*R1       Save ptr w/in the line
       DEC  *R1               Back up so get last character
       BL   @VPUSH            Push it too!
       A    @H16,@VSPTR       Point to initial value
       BL   @VPOP             Get initial value
       BL   @ASSG             Assign it
       A    @C8,@VSPTR        Restore to top of entry
* Check to see if execute loop at all
       BL   @VPOP             Get ptr to value
       BL   @MOVFAC           Get value
       S    @H16,@VSPTR       Point at limit
       BL   @SCOMPB           Compare them
* VSPTR is now below the FOR entry
       STST R4                Save the status
       JEQ  NFOR03            IF =
       MOV  @VSPTR,R3
H16    EQU  $+2
       AI   R3,16
       BL   @GETV1            Check negative step
       JLT  NFOR05            If a decrement
       SLA  R4,1              Check out of limit
       JGT  NFOR07            Out of limit
NFOR03 A    @C32,@VSPTR       Leave the entry on
       B    @CONT     <<<<<<< Result is w/in limit
NFOR05 SLA  R4,1              Check out of limit
       JGT  NFOR03            Result is w/in limit
* Initial value is not within the limit. Therefore, the loop
* is not executed at all. Must skip the code in the body of
* the loop
NFOR07 LI   R3,1              FOR/NEXT pair counter
NFOR09 BL   @EOLINE           Check end of line
       JEQ  NFOR13            Is end of line
       BL   @PGMCHR           Get 1st token on line
NFOR10 CI   R8,NEXT$*256      If NEXT
       JNE  NFOR11            If not
       DEC  R3                Decrement counter
       JNE  NFOR12            If NOT matching next
       BL   @PGMCHR           Get 1st char of loop variable
* Check is added in SYM       5/26/81
*      JLT  ERRCDT            If token
       BL   @SYM              Get s.t. pointer to check match
       MOV  @VSPTR,R3         Correct to top of entry
C32    EQU  $+2
       AI   R3,32
       BL   @GET1             Get pointer
       C    R1,@FAC           Match?
       JNE  ERRFNN            No match
       B    @CONT             Continue  <<<<<<<< THE WAY
ERRFN  A    @C4,@EXTRAM
ERRFNN LI   R0,>0B03          FOR NEXT NESTING
       B    @ERR
NFOR11 CI   R8,SUB$*256       Hit a SUB?
       JEQ  ERRFNN            Yes, can't find matching next
       CI   R8,FOR$*256       FOR?
       JNE  NFOR20            No, Check some more
       INC  R3                Increment depth
NFOR20 CI   R8,LN$*256        Line number token?
       JNE  NFOR30            No, Check some more
       INCT @PGMPTR           Skip the line number
NFOR30 CI   R8,STRIN$*256     String?
       JNE  NFOR12            No, Check end of statement
       BL   @PGMCHR           Yes, get string length
       SWPB R8                Put the length in R8
       A    R8,@PGMPTR        Skip that many length
       CLR  R8                Clear next crunched code
NFOR12 BL   @PGMCHR           Read next crunched code
       BL   @EOSTMT           Check EOS (includes EOL)
       JNE  NFOR20            Check for line # or string
       JMP  NFOR09            Is EOS or EOL
NFOR13 MOVB @PRGFLG,R0        If imperative w/out match
       JEQ  ERRFNN            Its an error
       S    @C4,@EXTRAM       Goto next line
       C    @EXTRAM,@STLN     Hit end of program?
       JL   ERRFN             Yes, can't match the next
       MOV  @EXTRAM,@PGMPTR   Set PGMPTR to get new PGMPTR
       BL   @PGMCHR           Get
       MOVB R8,@PGMPTR         new
       MOVB *R10,@PGMPT1        PGMPTR
       BL   @PGMCHR           Get next line
       BL   @EOSTMT           Check EOS or EOL
       JEQ  NFOR09            Is EOS or EOL
       JMP  NFOR10            Keep looping
* NEXT4 and NEXT2A were moved from in-line to here in an
* effort to make the "normal" path through the NEXT code as
* straight-line as possible.
NEXT4  S    @C24,@VSPTR       LOOP VARIABLES DON'T MATCH
       JMP  NEXT2
NEXT2B BL   @VPUSH            Keep stack information
NEXT2A LI   R0,>0C03            NEXT WITHOUT FOR
       B    @ERR
*************************************************************
* NEXT statement handler - find the matching FOR statement  *
* on the stack, add the increment to the current value of   *
* the index variable and check to see if execute the loop   *
* again. If loop-variable's value is still within bounds,   *
* goto the top of the loop, otherwise, flush the FOR entry  *
* off the stack and continue with the statement following   *
* the NEXT statement.                                       *
*************************************************************
NNEXT  BL   @SYM              GET S.T.   I.D.
*      MOV  @FAC,R4           SYM/FBSYMB leaves value in R4
NEXT2  C    @VSPTR,@STVSPT    CHECK FOR BOTTOM OF STACK
       JLE  NEXT2A            IF AT BOTTOM -> NEXT W/OUT FOR
       BL   @VPOP             GET 'FOR' ENTRY OFF STACK
       CB   @FAC2,@CBH67      CHECK FOR 'FOR' ENTRY
       JNE  NEXT2B            Is not a 'FOR' entry, error
       C    R4,@FAC           CHECK IF MATCHING 'FOR' ENTRY
       JNE  NEXT4             Is not a match, so check more
       MOV  @VSPTR,R3         Check BUFLEV for match
       AI   R3,14             Point at the BUFLEV in stack
       BL   @GET1             Read it
       C    R1,@BUFLEV        SAME LEVEL?
       JNE  ERRFNN            NO, ITS AN ERROR
       S    @C8,@VSPTR
       BL   @MOVFAC           GET INDEX VALUE
       BL   @SAVREG           SAVE BASIC REGISTERS
       BL   @SADD             ADD IN THE INCREMENT
       BL   @SETREG           RESTORE BASIC REGS
       A    @C24,@VSPTR
       BL   @ASSG             SAVE NEW INDEX VALUE
       S    @H16,@VSPTR       POINT TO THE LIMIT
       BL   @SCOMPB           TEST W/IN LIMIT
       STST R4                SAVE RESULT OF COMPARE
       JEQ  NEXT5             IF = DO LAST LOOP
       MOV  @VSPTR,R3         CHECK FOR A DECREMENT
       AI   R3,16             Point at increment/decrement
       BL   @GETV1            Get 1st byte and set condition
       JLT  NEXT6             If was a decrement
       SLA  R4,1              Check if out of limit
       JGT  NEXT8             Out of limit
NEXT5  A    @C32,@VSPTR       Point to 'FOR' I.D. entry
       MOV  @VSPTR,R3         GOTO TOP OF 'FOR' LOOP
       AI   R3,-8             Point to old EXTRAM
       BL   @GET1             Get new EXTRAM
       MOV  R1,@EXTRAM        Put it in
       INCT R3                POINT AT OLD PGMPTR
       BL   @GET1             Get old PGMPTR
       MOV  R1,@PGMPTR        Put it in
       BL   @PGMCHR           Get 1st token in line
NEXT8  B    @CONT             Continue on
* TEST LIMIT FOR DECREMENT
NEXT6  SLA  R4,1              Check if out of limit
       JGT  NEXT5             If within limit, continue
       JMP  NEXT8             Continue PARSE
********************************************************************************
 
