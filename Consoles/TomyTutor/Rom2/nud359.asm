********************************************************************************
       AORG >9C84                                                         *TOMY*
       TITL 'NUD359'
 
LEXP   CB   @FAC2,@CBH63      Must have a numeric
       JH   ERRSNM            Don't, so error
       BL   @PSHPRS           Push 1st and parse 2nd
       BYTE EXPON$,0          Up to another wxpon or less
       BL   @STKCHK           Make sure room on stack
       LI   R2,PWR$$          Address of power routine
       JMP  COMM05            Jump into common routine
* ABS
NABS   CI   R8,LPAR$*256      Must have a left parenthesis
       JNE  SYNERR            If not, error
       BL   @PARSE            Parse the argument
       BYTE ABS$              Up to another ABS
CBH63  BYTE >63               Use the wasted byte
       CB   @FAC2,@CBH63      Must have numeric arg
       JH   ERRSNM            If not, error
       ABS  @FAC              Take the absolute value
BCONT  B    @CONT             And continue
* ATN
NATN   LI   R2,ATN$$          Load up arctan address
       JMP  COMMON            Jump into common rountine
* COS
NCOS   LI   R2,COS$$          Load up cosine address
       JMP  COMMON            Jump into common routine
* EXP
NEXP   LI   R2,EXP$$          Load up exponential address
       JMP  COMMON            Jump into common routine
* INT
NINT   LI   R2,GRINT          Load up greatest integer address
       JMP  COMMON            Jump into common routine
* LOG
NLOG   LI   R2,LOG$$          Load up logarithm code
       JMP  COMMON            Jump to common routine
* SGN
NSGN   CI   R8,LPAR$*256      Must have left parenthesis
       JNE  SYNERR            If not, error
       BL   @PARSE            Parse the argument
       BYTE SGN$,0            Up to another SGN
       CB   @FAC2,@CBH63      Must have a numeric arg
       JH   ERRSNM            If not, error
       LI   R4,>4001          Floating point one
       MOV  @FAC,R0           Check status
       JEQ  BCONT             If 0, return 0
       JGT  BLTST9            If positive, return +1
       B    @LTRUE            If negative, return -1
BLTST9 B    @LTST90           Sets up the FAC w/R4 and 0s
ERRSNM B    @ERRT             STRING-NUMBER MISMATCH
SYNERR B    @ERRONE           SYNTAX ERROR
* SIN
NSIN   LI   R2,SIN$$          Load up sine address
       JMP  COMMON            Jump into common routine
* SQR
NSQR   LI   R2,SQR$$          Load up square-root address
       JMP  COMMON            Jump into common routine
* TAN
*NTAN  LI   R2,TAN$$          Load up tangent address                     *TOMY*
COMMON BL   @STKCHK           Make sure room on stacks
       CI   R8,LPAR$*256      Must have left parenthesis
       JNE  SYNERR            If not, error
       INCT R9                Get space on subroutine stack
       MOV  R2,*R9            Put address of routine on stack
       BL   @PARSE            Parse the argument
       BYTE >FF,0             To end of the arg
       MOV  *R9,R2            Get address of function back
       DECT  R9               Decrement subroutine stack
COMM05 CB   @FAC2,@CBH63      Must have a numeric arg
       JH   ERRSNM            If not, error
       CLR  @FAC10            Assume no error or warning
       BL   @SAVREG           Save Basic registers
       MOV  R2,@PAGE2         Select page 2
       BL   *R2               Evaluate the function
       MOV  R2,@PAGE1         Reselect Page 1
       BL   @SETREG           Set registers up again
       MOVB @FAC10,R0         Check for error or warning
       JEQ  BCONT             If not error, continue
       SRL  R0,9              Check for warning
       JEQ  PWARN             Warning, issue it
       LI   R0,>0803          BAD ARGUMENT code
       B    @ERR
PWARN  B    @WARN$$           Issue the warning message
STKCHK CI   R9,STND12         Enough room on the subr stack?
       JH   BSO               No, memory full error
       MOV  @VSPTR,R0         Get the value stack pointer
       AI   R0,48             Buffer-zone of 48 bytes
       C    R0,@STREND        Room between stack & strings
       JL   STKRTN            Yes, return
       INCT R9                Get space on subr stack
       MOV  R11,*R9+          Save return address
       MOV  R2,*R9+           Save COMMON function code
       MOV  R0,*R9            Save v-stack pointer+48
       BL   @COMPCT           Do a garbage collection
       C    *R9,@STREND       Enough space now?
       JHE  BMF               No, MEMORY FULL error
       DECT R9                Decrement stack pointer
       MOV  *R9,R2            Restore COMMON function code
       DECT R9                Decrement stack pointer
RETRN  MOV *R9,R11            Restore return address
       DECT R9                Decrement stack pointer
STKRTN RT
BMF    B    @VPSH23           * MEMORY FULL
BSO    B    @ERRSO            * STACK OVERFLOW
*************************************************************
* LED routine for AND, OR, NOT, and XOR                     *
*************************************************************
O0AND  BL   @PSHPRS           Push L.H. and PARSE R.H.
       BYTE AND$,0            Stop on AND or less
       BL   @CONVRT           Convert both to integers
       INV  @FAC              Complement L.H.
       SZC  @FAC,@ARG         Perform the AND
O0AND1 MOV  @ARG,@FAC         Put back in FAC
O0AND2 BL   @CIF              Convert back to floating
       B    @CONT             Continue
O0OR   BL   @PSHPRS           Push L.H. and PARSE R.H.
       BYTE OR$,0             Stop on OR or less
       BL   @CONVRT           Convert both to integers
       SOC  @FAC,@ARG         Perform the OR
       JMP  O0AND1            Convert to floating and done
O0NOT  BL   @PARSE            Parse the arg
       BYTE NOT$,0            Stop on NOT or less
       CB   @FAC2,@CBH63      Get a numeric back?
       JH   ERRSN1            No, error
       CLR  @FAC10            Clear for CFI
       BL   @CFI              Convert to Integer
       MOVB @FAC10,R0         Check for an error
       JNE  SYNERR            Error
       INV  @FAC              Perform the NOT
       JMP  O0AND2            Convert to floating and done
O0XOR  BL   @PSHPRS           Push L.H. and PARSE R.H.
       BYTE XOR$,0            Stop on XOR or less
       BL   @CONVRT           Convert both to integer
       MOV  @ARG,R0           Get R.H. into register
       XOR  @FAC,R0           Do the XOR
       MOV  R0,@FAC           Put result back in FAC
       JMP  O0AND2            Convert and continue
*************************************************************
* NUD for left parenthesis                                  *
*************************************************************
NLPR   CI   R8,RPAR$*256      Have a right paren already?
       JEQ  ERRSY1            If so, syntax error
       BL   @PARSE            Parse inside the parenthesises
       BYTE LPAR$,0           Up to left parenthesis or less
       CI   R8,RPAR$*256      Have a right parenthesis now?
       JNE  ERRSY1            No, so error
       BL   @PGMCHR           Get next token
BCON1  B    @CONT             And continue
*************************************************************
* NUD for unary minus                                       *
*************************************************************
NMINUS BL   @PARSE            Parse the expression
       BYTE MINUS$,0          Up to another minus
       NEG  @FAC              Make it negative
NMIN10 CB   @FAC2,@CBH63      Must have a numeric
       JH   ERRSN1            If not, error
       JMP  BCON1             Continue
*************************************************************
* NUD for unary plus                                        *
*************************************************************
NPLUS  BL   @PARSE            Parse the expression
       BYTE PLUS$,0
       JMP  NMIN10            Use common code
*************************************************************
* CONVRT - Takes two arguments, 1 form FAC and 1 from the   *
*          top of the stack and converts them to integer    *
*          from floating point, issuing appropriate errors  *
*************************************************************
CONVRT INCT R9
       MOV  R11,*R9           SAVE RTN ADDRESS
       BL   @ARGTST           ARGS MUST BE SAME TYPE
       JEQ  ERRSN1            AND NON-STRING
       CLR  @FAC10            FOR CFI ERROR CODE
       BL   @CFI              CONVERT R.H. ARG
       MOVB @FAC10,R0         ANY ERROR OR WARNING?
       JNE  ERRBV             YES
       MOV  @FAC,@ARG         MOVE TO GET L.H. ARG
       BL   @VPOP             GET L.H. BACK
       BL   @CFI              CONVERT L.H.
       MOVB @FAC10,R0         ANY ERROR OR WARNING?
       JEQ  RETRN             No, get rtn off stack and rtn
*                             Yes, issue error
ERRBV  B    @GOTO90           BAD VALUE
ERRSN1 B    @ERRT             STRING NUMBER MISMATCH
ERRSY1 B    @ERRONE           SYNTAX ERROR
********************************************************************************
 
