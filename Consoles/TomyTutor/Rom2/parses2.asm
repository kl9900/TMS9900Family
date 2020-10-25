********************************************************************************
 
       TITL 'PARSES2'
 
*************************************************************
*                   'LET' statement handler                 *
* Assignments are done bye putting an entry on the stack    *
* for the destination variable and getting the source value *
* into the FAC. Multiple assignments are handled by the     *
* stacking the variable entrys and then looping for the     *
* assignments. Numeric assignments pose no problems,        *
* strings are more complicated. String assignments are done *
* by assigning the source string to the last variable       *
* specified in the list and changing the FAC entry so that  *
* the string assigned to the next-to-the-last variable      *
* comes from the permanent string belonging to the variable *
* just assigned.                                            *
* e.g.    A$,B$,C$="HELLO"                                  *
*                                                           *
*         C$-------"HELLO" (source string)                  *
*                                                           *
*         B$-------"HELLO" (copy from C$'s string)          *
*                                                           *
*         A$-------"HELLO" (copy from B$'s string)          *
*************************************************************
NLET   CLR  @PAD0             Counter for multiple assign's
NLET05 BL   @SYM              Get symbol table address
*-----------------------------------------------------------*
* The following code has been taken out for checking is     *
* inserted in SMB             5/22/81                       *
       BL   @GETV             Get first byte of entry       *             *TOMY*
       DATA FAC               SYM left pointer in FAC       *             *TOMY*
       SLA  R1,1              Test if a UDF                 *             *TOMY*
       JLT  ERRMUV            Is a UDF - so error           *             *TOMY*
*-----------------------------------------------------------*
       BL   @SMB              Get value space pointer
       BL   @VPUSH            Push s.t. pointer on stack
       INC  @PAD0             Count the variable
       CI   R8,EQ$*256        Is the token an '='?
       JEQ  NLET10            Yes, go into assignment loop
       CI   R8,COMMA$*256     Must have a comma now
       JNE  ERR1C$            Didn't - so error
       BL   @PGMCHR           Get next token
       JGT  NLET05            If legal symbol character
       JMP  ERR1C$            If not - error
ERRMUV LI   R0,>0D03          MULTIPLY USED VARIABLE
       B    @ERR
NLET10 BL   @PGMCHR           Get next token
       BL   @PARSE            PARSE the value to assign
       BYTE TREM$             Parse to the end of statement
STCOD2 BYTE >65               Wasted byte (STCODE copy)
* Loop for assignments
NLET15 BL   @ASSG             Assign the value to the symbol
       DEC  @PAD0             One less to assign, done?
       JEQ  LETCON            Yes, branch out
       CB   @FAC2,@STCOD2     String or numeric?
       JNE  NLET15            Numeric, just loop for more
       MOV  R6,@FAC4          Get pointer to new string
       MOV  @ARG,@FAC         Get pointer to last s.t. entry
       JMP  NLET15            Now loop to assign more
LETCON B    @EOL              Yes, continue the PARSE
ERR1C$ B    @ERR1C            For long distance jump
       DATA NONUD             (SPARE)             >80
       DATA NONUD             ELSE                >81
       DATA SMTSEP            ::                  >82
       DATA NUDND1            !                   >83
       DATA IF                IF                  >84
       DATA GO                GO                  >85
       DATA GOTO              GOTO                >86
       DATA GOSUB             GOSUB               >87
       DATA RETURN            RETURN              >88
       DATA NUDEND            DEF                 >89
       DATA NUDEND            DIM                 >8A
       DATA END               END                 >8B
       DATA NFOR              FOR                 >8C
       DATA NLET              LET                 >8D
       DATA >F002             BREAK               >8E                     *TOMY*
       DATA >F004             UNBREAK             >8F                     *TOMY*
       DATA >F006             TRACE               >90                     *TOMY*
       DATA >F008             UNTRACE             >91                     *TOMY*
       DATA >F016             INPUT               >92                     *TOMY*
       DATA NUDND1            DATA                >93
       DATA >F012             RESTORE             >94                     *TOMY*
       DATA >F014             RANDOMIZE           >95                     *TOMY*
       DATA NNEXT             NEXT                >96
       DATA >F00A             READ                >97                     *TOMY*
       DATA STOP              STOP                >98
       DATA NONUD             DELETE              >99                     *TOMY*
       DATA NUDND1            REM                 >9A
       DATA ON                ON                  >9B
       DATA >F00C             PRINT               >9C                     *TOMY*
       DATA CALL              CALL                >9D
       DATA NONUD             OPTION              >9E                     *TOMY*
       DATA NONUD             OPEN                >9F                     *TOMY*
       DATA >F018             CLOSE               >A0                     *TOMY*
       DATA >F01C             SUB                 >A1                     *TOMY*
       DATA >F020             DISPLAY             >A2                     *TOMY*
       DATA >F024             IMAGE               >A3                     *TOMY*
       DATA >F03C             ACCEPT              >A4                     *TOMY*
       DATA >F040             ERROR               >A5                     *TOMY*
       DATA >F044             WARNING             >A6                     *TOMY*
       DATA SUBXIT            SUBEXIT             >A7
       DATA SUBXIT            SUBEND              >A8
       DATA >F00E             RUN                 >A9                     *TOMY*
STMTTB DATA >F048             LINPUT              >AA                     *TOMY*
NTAB   DATA NLPR              LEFT PARENTHISIS    >B7
       DATA NONUD             CONCATENATE         >B8
       DATA NONUD             SPARE               >B9
       DATA NONUD             AND                 >BA
       DATA NONUD             OR                  >BB
       DATA NONUD             XOR                 >BC
       DATA O0NOT             NOT                 >BD
       DATA NONUD             =                   >BE
       DATA NONUD             <                   >BF
       DATA NONUD             >                   >C0
       DATA NPLUS             +                   >C1
       DATA NMINUS            -                   >C2
       DATA NONUD             *                   >C3
       DATA NONUD             /                   >C4
       DATA NONUD             ^                   >C5
       DATA NONUD             SPARE               >C6
       DATA NSTRCN            QUOTED STRING       >C7
       DATA NUMCON        UNQUOTED STRING/NUMERIC >C8
       DATA NONUD             LINE NUMBER         >C9
       DATA NONUD             EOF                 >CA                     *TOMY*
       DATA NABS              ABS                 >CB
       DATA NATN              ATN                 >CC
       DATA NCOS              COS                 >CD
       DATA NEXP              EXP                 >CE
       DATA NINT              INT                 >CF
       DATA NLOG              LOG                 >D0
       DATA NSGN              SGN                 >D1
       DATA NSIN              SIN                 >D2
       DATA NSQR              SQR                 >D3
       DATA NONUD             TAN                 >D4                     *TOMY*
       DATA >F036             LEN                 >D5                     *TOMY*
       DATA >F038             CHR$                >D6                     *TOMY*
       DATA >F03A             RND                 >D7                     *TOMY*
       DATA >F030             SEG$                >D8                     *TOMY*
       DATA NONUD             POS                 >D9                     *TOMY*
       DATA >F02C             VAL                 >DA                     *TOMY*
       DATA >F02E             STR                 >DB                     *TOMY*
       DATA >F028             ASC                 >DC                     *TOMY*
       DATA NONUD             PI                  >DD                     *TOMY*
       DATA NONUD             REC                 >DE                     *TOMY*
       DATA NONUD             MAX                 >DF                     *TOMY*
       DATA NONUD             MIN                 >E0                     *TOMY*
       DATA NONUD             RPT$                >E1                     *TOMY*
NTABLN EQU  $-NTAB
LTAB   DATA CONC              &                   >B8
       DATA NOLED             SPARE               >B9
       DATA O0OR              OR                  >BA
       DATA O0AND             AND                 >BB
       DATA O0XOR             XOR                 >BC
       DATA NOLED             NOT                 >BD
       DATA EQUALS            =                   >BE
       DATA LESS              <                   >BF
       DATA GREATR            >                   >C0
       DATA PLUS              +                   >C1
       DATA MINUS             -                   >C2
       DATA TIMES             *                   >C3
       DATA DIVIDE            /                   >C4
       DATA LEXP              ^                   >C5
LTBLEN EQU  $-LTAB
*************************************************************
*                     Relational operators                  *
* Logical conparisons encode the type of comparison and use *
* common code to PARSE the expression and set the status    *
* bits.                                                     *
*                                                           *
* The types of legal comparisons are:                       *
*                             0 EQUAL                       *
*                             1 NOT EQUAL                   *
*                             2 LESS THAN                   *
*                             3 LESS OR EQUAL               *
*                             4 GREATER THAN                *
*                             5 GREATER THAN OR EQUAL       *
*                                                           *
* This code is saved on the subroutine stack                *
*************************************************************
LESS   LI   R2,2              LESS-THAN code for common rtn
       CI   R8,GT$*256        Test for '>' token
       JNE  LT10              Jump if not
       DECT R2                Therefore, NOT-EQUAL code
       JMP  LT15              Jump to common
C4     EQU  $+2               Constant 4
GREATR LI   R2,4              GREATER-THEN code for common
LT10   CI   R8,EQ$*256        Test for '=' token
       JNE  LTST01            Jump if '>='
LT15   BL   @PGMCHR           Must be plain old '>' or '<'
       JMP  LEDLE             Jump to test
EQUALS SETO R2                Equal bit for common routine
LEDLE  INC  R2                Sets to zero
LTST01 INCT R9                Get room on stack for code
       MOV  R2,*R9            Save status matching code
       BL   @PSHPRS           Push 1st arg and PARSE the 2nd
       BYTE GT$               Parse to a '>'
CBH69  BYTE >69               Used in RETURN routine
       MOV  *R9,R4            Get the type code from stack
       DECT R9                Reset subroutine stack pointer
       MOVB @LTSTAB(R4),R12   Get address bias to baranch to
       SRA  R12,8             Right justify
       BL   @ARGTST           Test for matching arguments
       JEQ  LTST20            Handle strings specially
       BL   @SCOMPB           Floating point comparison
LTST15 B    @LTSTXX(R12)      Interpret the status by code
LTSTXX EQU  $
LTSTGE JGT  LTRUE             Test if GREATER or EQUAL
LTSTEQ JEQ  LTRUE             Test if EQUAL
LFALSE CLR  R4                FALSE is a ZERO
       JMP  LTST90            Put it into FAC
LTSTNE JEQ  LFALSE            Test if NOT-EQUAL
LTRUE  LI   R4,>BFFF          TRUE is a minus-one
LTST90 LI   R3,FAC            Store result in FAC
       MOV  R4,*R3+           Exp & 1st byte of manitissa
       CLR  *R3+              ZERO the remaining digits
       CLR  *R3+              ZERO the remaining digits
       CLR  *R3+              ZERO the remaining digits
       JMP  LEDEND            Jump to end of LED routine
LTSTLE JEQ  LTRUE             Test LESS-THAN or EQUAL
LTSTLT JLT  LTRUE             Test LESS-THEN
       JMP  LFALSE            Jump to false
LTSTGT JGT  LTRUE             Test GREATER-THAN
       JMP  LFALSE            Jump to false
* Data table for offsets for types
LTSTAB BYTE LTSTEQ-LTSTXX     EQUAL               (0)
       BYTE LTSTNE-LTSTXX     NOT EQUAL           (1)
       BYTE LTSTLT-LTSTXX     LESS THEN           (2)
       BYTE LTSTLE-LTSTXX     LESS or EQUAL       (3)
       BYTE LTSTGT-LTSTXX     GREATER THEN        (4)
       BYTE LTSTGE-LTSTXX     GREATER or EQUAL    (5)
LTST20 MOV  @FAC4,R10         Pointer to string1
       MOVB @FAC7,R7          R7 = string2 length
       BL   @VPOP             Get LH arg back
       MOV  @FAC4,R4          Pointer to string2
       MOVB @FAC7,R6          R6 = string2 length
       MOVB R6,R5             R5 will contain shorter length
       CB   R6,R7             Compare the 2 lengths
       CB   R6,R7                                                         *TOMY*
       JLT  CSTR05            Jump if length2 < length1
       MOVB R7,R5             Swap if length1 > length2
CSTR05 SRL  R5,8              Shift for speed and test zero
       JEQ  CSTR20            If ZERO-set status with length
CSTR10 MOV  R10,R3            Current character location
       INC  R10               Increment pointer
       BL   @GETV1            Get from VDP
       MOVB R1,R0             And save for comparison
       MOV  R4,R3             Current char location in ARG
       INC  R4                Increment pointer
       BL   @GETV1            Get from VDP
       CB   R1,R0             Compare the characters
       JNE  LTST15            Return with status if <>
       DEC  R5                Otherwise, decrement counter
       JGT  CSTR10            And loop for each character
CSTR20 CB   R6,R7             Status set by length compare
       JMP  LTST15            Return to do test of status
* ARITHMETIC FUNCTIONS
PLUS   BL   @PSHPRS           Push left arg and PARSE right
       BYTE MINUS$,0          Stop on a minus!!!!!!!!!!!!!!!
       LI   R2,SADD           Address of add routine
LEDEX  CLR  @FAC10            Clear error code
       BL   @ARGTST           Make sure both numerics
       JEQ  ARGT05            If strings, error
       BL   @SAVREG           Save registers
       BL   *R2               Do the operation
       BL   @SETREG           Restore registers
       MOVB @FAC10,R2         Test for overflow
       JNE  LEDERR            If overflow ->error
LEDEND B    @CONT             Continue the PARSE
LEDERR B    @WARN$$           Overflow - issue warning
MINUS  BL   @PSHPRS           Push left arg and PARSE right
       BYTE MINUS$,0          Parse to a minus
       LI   R2,SSUB           Address of subtract routine
       JMP  LEDEX             Common code for the operation
TIMES  BL   @PSHPRS           Push left arg and PARSE right
       BYTE DIVI$,0           Parse to a divide!!!!!!!!!!!!!
       LI   R2,SMULT          Address of multiply routine
       JMP  LEDEX             Common code for the operation
DIVIDE BL   @PSHPRS           Push left arg and PARSE right
       BYTE DIVI$,0           Parse to a divide
       LI   R2,SDIV           Address of divide routine
       JMP  LEDEX             Common code for the operation
*************************************************************
* Test arguments on both the stack and in the FAC           *
*      Both must be of the same type                        *
*  CALL:                                                    *
*      BL   @ARGTST                                         *
*      JEQ                    If string                     *
*      JNE                    If numeric                    *
*************************************************************
*ARGTST MOV  @VSPTR,R6        Get stack pointer                           *TOMY*
*      INCT R6                                                            *TOMY*
*      MOVB @R6LB,*R15        Load 2nd byte of stack address              *TOMY*
*      NOP                    Kill some time                              *TOMY*
*      MOVB R6,*R15           Load 1st byte of stack address              *TOMY*
*      NOP                    Kill some time                              *TOMY*
*      CB   @XVDPRD,@CBH65    String in operand 1?                        *TOMY*
*      JNE  ARGT10            No, numeric                                 *TOMY*
ARGTST EQU  $                                                             *TOMY*
       CB   @FAC2,@CBH65      Yes, is other the same?
*      JEQ  ARGT20            Yes, do string comparison                   *TOMY*
*ARGT05 B    @ERRT            Data types don't match                      *TOMY*
*NUMCHK                                                                   *TOMY*
*ARGT10 CB   @FAC2,@CBH65     2nd operand can't be string                 *TOMY*
*      JEQ  ARGT05            If so, error                                *TOMY*
ARGT20 RT                     Ok, so return with status
ARGT05 B    @SUBXIT                                                       *TOMY*
* VPUSH followed by a PARSE
PSHPRS INCT R9                Get room on stack
       CI   R9,STKEND         Stack full?
       JH   VPSH27            Yes, error
       MOV  R11,*R9           Save return on stack
       LI   R11,P05           Optimize for the parse
* Stack VPUSH routine
VPUSH  LI   R0,8              Pushing 8 byte entries
       A    R0,@VSPTR         Update the pointer
       MOV  @VSPTR,R1         Now get the new pointer
       MOVB @R1LB,*R15        Write new address to VDP chip
       C    R14,R14                                                       *TOMY*
       ORI  R1,WRVDP          Enable the write
       MOVB R1,*R15           Write 1st byte of address
       LI   R1,FAC            Source is FAC
VPSH15 SWPB R14                                                           *TOMY*
       MOVB *R1+,@XVDPWD      Move a byte                                 *TOMY*
       DEC  R0                Decrement the count, done?
       JGT  VPSH15            No, more to move
       MOV  R11,R0            Save the return address
       CB   @FAC2,@CBH65      Pushing a string entry?
       JNE  VPSH20            No, so done
       MOV  @VSPTR,R6         Entry on stack
       AI   R6,4              Pointer to the string is here
       MOV  @FAC,R1           Get the string's owner
       CI   R1,>001C          Is it a tempory string?
       JNE  VPSH20            No, so done
VPSH19 MOV  @FAC4,R1          Get the address of the string
       JEQ  VPSH20            If null string, nothing to do
       BL   @STVDP3           Set the backpointer
VPSH20 MOV  @VSPTR,R1         Check for buffer-zone
C16    EQU  $+2
       AI   R1,16             Correct by 16
       C    R1,@STREND        At least 16 bytes between stack
*                              and string space?
       JLE  VPOP18            Yes, so ok
       INCT R9                No, save return address
       MOV  R0,*R9             on stack
       BL   @COMPCT           Do the garbage collection
       MOV  *R9,R0            Restore return address
       DECT R9                Fix subroutine stack pointer
       MOV  @VSPTR,R1         Get value stack pointer
       AI   R1,16             Buffer zone
       C    R1,@STREND        At least 16 bytes now?
       JLE  VPOP18            Yes, so ok
VPSH23 LI   R0,ERROM          No, so MEMORY FULL error
VPSH25 BL   @SETREG           In case of GPL call
       B    @ERR
VPSH27 B    @ERRSO            STACK OVERFLOW
* Stack VPOP routine
VPOP   LI   R2,FAC            Destination in FAC
       MOV  @VSPTR,R1         Get stack pointer
       C    R1,@STVSPT        Check for stack underflow
       JLE  VPOP20            Yes, error
       MOVB @R1LB,*R15        Write 2nd byte of address
       C    R14,R14                                                       *TOMY*
       LI   R0,8              Popping 8 bytes
       MOVB R1,*R15           Write 1st byte of address
       S    R0,@VSPTR         Adjust stack pointer
VPOP10 SWPB R14                                                           *TOMY*
       MOVB @XVDPRD,*R2+      Move a byte                                 *TOMY*
       DEC  R0                Decrement the counter, done?
       JGT  VPOP10            No, finish the work
       MOV  R11,R0            Save return address
       CB   @FAC2,@CBH65      Pop a string?
       JNE  VPOP18            No, so done
       CLR  R6                For backpointer clear
       MOV  @FAC,R3           Get string owner
       CI   R3,>001C          Pop a temporary?
       JEQ  VPSH19            Yes, must free it
       BL   @GET1             No, get new pointer from s.t.
       MOV  R1,@FAC4          Set new pointer to string
VPOP18 B    *R0               And return
VPOP20 LI   R0,ERREX          * SYNTAX ERROR
       JMP  VPSH25
* The returned status reflects the character
* RAMFLG = >00   | No ERAM or imperative statements
*          >FF   | With ERAM and a program is being run
*PGMCHR MOVB @RAMFLG,R8       Test ERAM flag                              *TOMY*
*      JNE  PGMC10            ERAM and a program is being run             *TOMY*
PGMCHR EQU  $                                                             *TOMY*
* Next label is for entry from SUBPROG.
PGMSUB MOVB @PGMPT1,*R15      Write 2nd byte of address
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       LI   R10,XVDPRD        Read data address
       MOVB @PGMPTR,*R15      Write 1st byte of address
       INC  @PGMPTR           Increment the perm pointer
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       MOVB *R10,R8           Read the character
       RT                     And return
*PGMC10 MOV  @PGMPTR,R10                                                  *TOMY*
*      INC  @PGMPTR                                                       *TOMY*
*      MOVB *R10+,R8          Write 2nd byte of a address                 *TOMY*
*      RT                                                                 *TOMY*
********************************************************************************
 
