********************************************************************************
       AORG >A5C4                                                         *TOMY*
       TITL 'SCANS'
 
RETUR$ EQU  >88
DEF$   EQU  >89
DIM$   EQU  >8A
END$   EQU  >8B
FOR$   EQU  >8C
INPUT$ EQU  >92
DATA$  EQU  >93
REM$   EQU  >9A
ON$    EQU  >9B
CALL$  EQU  >9D
OPTIO$ EQU  >9E
IMAGE$ EQU  >A3
SUBXT$ EQU  >A7
SUBND$ EQU  >A8
LINPU$ EQU  >AA
STEP$  EQU  >B2
NUM$   EQU  >C7
*-----------------------------------------------------------*
* Added for "NOPSCAN" feature 6/8/81                        *
P1     EQU  >40               @
P2     EQU  >50               P
P3     EQU  >2B               +
P4     EQU  >2D               -
P5     EQU  >70               p
PSCFG  EQU  >03B7             VDP temporary: PSCAN flag
*                                            >00 : no pscan *
*                                            >FF : pscan    *
*-----------------------------------------------------------*
 
*-----------------------------------------------------------*
* SCAN routine is changed for implementing "NOPSCAN"        *
* feature,                    6/8/81                        *
* "!@P+" or "!@p+"            is RESUME PSCAN               *
* "!@P-" or "!@p-"            is NO PSCAN                   *
*-----------------------------------------------------------*
*                                                           *
*************************************************************
* SCAN is the main looping structure of the prescan routine.*
* Takes care of scanning each statement in a line. Goes     *
* back to GPL to scan the special cases (DEF, OPTION, DIM,  *
* SUB, CALL, SUBEND, SUBEXIT) and also goes to GPL to enter *
* variables into the symbol table. All statements which are *
* not allowed to be imperative are checked directly without *
* goting to GPL. The NOCARE label is where a non-special    *
* statement is scanned, looking for variables to enter them *
* into the symbol table.                                    *
*************************************************************
*PSCAN MOVB *R13,R0           Read Scan code                              *TOMY*
PSCAN  MOV  R11,R12                                                       *TOMY*
       MOV  *R13+,R0                                                      *TOMY*
       BL   @PUTSTK           Save GROM address
       BL   @SETREG           Set up R8/R9 with CHAT/SUBSTK
* First decode the type of XML being executed
* Types are: >00 - initial call with program
*            >01 - resume within a statement after call to
*                  GPL for some reason
*            >02 - initial call for imperative statement
       SRL  R0,8              Set condition
       JEQ  SCAN05            If calling scan routine w/pgm
       DEC  R0                Returning from call to GPL?
       JEQ  JNCARE            Yes, continue w/in line
       MOV  *R9,@RTNADD
       JMP  SCAN10
SCAN05 A    @C4,*R9           Skip following XML and select               *TOMY*
       MOV  *R9,@RTNADD       Set up rtn to common GPL loc
       CLR  @DATA             Assume out of data
SCAN5A C    @LINUM,@EXTRAM    End of program yet?
       JNE  SCAN07            No, get next line
SCAN5B MOVB @FORNET,R0        Check fornext counter
       JNE  FNERR             For/Next error
*      MOVB @XFLAG,R0         Check subprogram bits                       *TOMY*
*CBH40 EQU  $+1                                                           *TOMY*
*      SLA  R0,4              Subprogram encountered?                     *TOMY*
*      JLT  SCAN6A            Yes, check subend                           *TOMY*
SCAN06 LI   R0,>A000          Initialize data stack
       MOVB R0,@STACK
       CLR  R3                                                            *TOMY*
*      BL   @RESOLV           Resolve any subprogram refs                 *TOMY*
*      B    @GPL05            Return                                      *TOMY*
*SCAN6A SLA  R0,4             Subend encountered?                         *TOMY*
*      JNC  ERRMS             No, text ended w/out subend                 *TOMY*
*      LI   R3,TABSAV         Get main symbol table's ptr                 *TOMY*
*      BL   @GET1             Get it                                      *TOMY*
*      MOV  R1,@SYMTAB                                                    *TOMY*
*      JMP  SCAN06            Merge back in                               *TOMY*
*ERRMS LI   R3,>18            * MISSING SUBEND                            *TOMY*
       JMP  GPL05L
SCAN07 S    @C4,@EXTRAM       Go to next line in program
*      MOVB @RAMTOP,R0        ERAM program?                               *TOMY*
*      JNE  SCAN08            Yes, handle  ERAM                           *TOMY*
       BL   @GET              No, het new line pointer in VDP
       DATA EXTRAM
*      JMP  SCAN09                                                        *TOMY*
*SCAN08 BL   @GETG            Get new line pointer from GRAM              *TOMY*
*      DATA EXTRAM                                                        *TOMY*
SCAN09 MOV  R1,@PGMPTR        Put new line pointer into perm
       SZCB @TLAB3,@XFLAG     Reset IFFLAG only on new line               *TOMY*
*-----------------------------------------------------------*
* Following is changed for adding "nopscan" feature         *
* SCAN9A @PGMCHR                Get 1st token on line       *
SCAN9A BL   @PGMCHR           Get 1st token on line         *
*      LI   R3,PSCFG          Check the flag to see which   *             *TOMY*
*                  mode is in: NOPSCAN (>00) or PSCAN (>FF) *
*      BL   @GETV1            Get the flag from VDP         *             *TOMY*
*      JEQ  NPSCAN            NOPSCAN mode                  *             *TOMY*
*-----------------------------------------------------------*
       SZCB @CBH94,@XFLAG     Reset ENTER, STRFLG, and FNCFLG
*      MOVB @XFLAG,R0         Get flag bits                               *TOMY*
*      SLA  R0,8              Shift to check REMODE                       *TOMY*
*      JNC  SCAN10            If not in REMODE                            *TOMY*
*      MOVB R8,R8             Check if token                              *TOMY*
*      JLT  SCAN11            If token, look further                      *TOMY*
*ERRIBS LI   R3,>1E           * ILLEGAL BETWEEN SUBPROGRAMS               *TOMY*
*      JMP  GPL05L            Goto error return                           *TOMY*
*SCAN11 SETO R6               Set up index into table                     *TOMY*
*SCAN12 INC  R6               Increment to 1st/next element               *TOMY*
*      CB   R8,@IBSTAB(R6)    legal stmt between subprogdams?             *TOMY*
*      JH   SCAN12            Not able to tell, check further             *TOMY*
*      JL   ERRIBS            Illegal statement here                      *TOMY*
SCAN10 CLR  R6                Offset into special stmt table
SCAN15 MOV  @SCNTAB(R6),R3    Read entry from special table
       CB   R3,R8             Match this token?
       JEQ  SCAN20            Yes, handle special case
       JH   NOCARE            Didn't match but passed in tab
       INCT R6                Increment offset into table
       CI   R6,TABLEN         Reach end of table?
       JNE  SCAN15            No, check further
JNCARE JMP  NOCARE            End of table, not special case
SCAN20 SLA  R3,8              Look at special case byte
*      JLT  SCGPL1            If MSB set, goto GPL                        *TOMY*
       JLT  SCNGPL                                                        *TOMY*
       SWPB R3                MSB reset, offset into 9900
       B    @OFFSET(R3)       Branch to 9900 special handler
*SCGPL1 B    @SCNGPL                                                      *TOMY*
*FNERR B    @FNNERR                                                       *TOMY*
*-----------------------------------------------------------*
* These are added for "nopscan" feature 6/8/81              *
SCAN25 EQU  $                                                             *TOMY*
OFFSET EQU  $                                                             *TOMY*
SCAN26 MOVB @PRGFLG,R0        In program mode?              *
*      JEQ  SCAN5B            No, check for/next subs&rtn   *             *TOMY*
*SCAN28 BL   @PGMCHR          Yes, check "!@P+" or "!@P-"   *             *TOMY*
*      CI   R8,P1*256         "@" following "!"?            *             *TOMY*
*      JNE  SCAN5A            No, goto the next line        *             *TOMY*
*      BL   @PGMCHR           Yes, check for "P"            *             *TOMY*
*      CI   R8,P2*256                                       *             *TOMY*
*      JEQ  SCAN40            Yes, check for "+" or "-"     *             *TOMY*
*      CI   R8,P5*256         No, try "p"                   *             *TOMY*
*      JNE  SCAN5A            No, goto the next line        *             *TOMY*
*SCAN40 BL   @PGMCHR          Yes, check for "+" or "-"     *             *TOMY*
*      CI   R8,P3*256                                       *             *TOMY*
*      JEQ  SCAN35            "!@P+" is found at the        *             *TOMY*
*                               beginnning of the line      *             *TOMY*
*      CI   R8,P4*256                                       *             *TOMY*
*      JNE  SCAN5A            Didn't file what we want,     *             *TOMY*
*                              goto the next line           *             *TOMY*
*      LI   R1,0              "!@P-" is found, set flag to  *             *TOMY*
*                              0 NO PSCAN                   *             *TOMY*
*SCAN30 LI   R4,PSCFG         Address register for PUTV1    *             *TOMY*
*      BL   @PUTV1            Set the flag PSCFG in VDP tem.*             *TOMY*
*      JMP  SCAN5A            Goto the next line            *             *TOMY*
*SCAN35 LI   R1,>FF00         "!@P+", set flag to be >FF so *             *TOMY*
*                              RESUME PSCAN                 *             *TOMY*
*      JMP  SCAN30            Use common code to set flag   *             *TOMY*
*-----------------------------------------------------------*
*-----------------------------------------------------------*
* In NOPSCAN mode, only looking for "!@P+", "!@P-" at the   *
* beginning of each line      6/8/81                        *
*NPSCAN CI   R8,TREM$*256     First token on line           *             *TOMY*
*                              is it "!"                    *
*      JEQ  SCAN28            Yes, check "!@P+" or "!@P-"   *             *TOMY*
*      B    @SCAN5A           No, ignore the whole line,    *             *TOMY*
*                              just goto the next line      *
*-----------------------------------------------------------*
*OFFSET                                                                   *TOMY*
*SCN26A JMP  SCAN26                                                       *TOMY*
*SCAN25 MOVB @PRGFLG,R0       In imperative mode?                         *TOMY*
*      JEQ  SCAN5C            Yes, check for/next sub & rtn               *TOMY*
*      B    @SCAN5A           No, check next line                         *TOMY*
*SCAN5C B    @SCAN5B                                                      *TOMY*
       JNE  SCAN5A                                                        *TOMY*
       JMP  SCAN5B                                                        *TOMY*
FNERR  JMP  FNNERR                                                        *TOMY*
* 9900 code special handlers
IFIF   SOCB @TLAB3,@XFLAG     Indicate scan of "IF" stmt                  *TOMY*
* Special handler for program-only statements
IMPER  MOVB @PRGFLG,R0        Executing in a program?
       JNE  NXTCHR            Yes, proceed in don't char mode
ERRIMP LI   R3,>12            Illegal imperative return code
GPL05L JMP  GPL05             Return to GPL with error
* Special handler for data-statements
DATA1  MOVB @DATA,R0          Data already encountered?
       JNE  IMAGE             Yes, don't set pointer
       MOV  @EXTRAM,@LNBUF    Save line buffer pointer
       MOV  @PGMPTR,@DATA     Set line buffer pointer
* Special handler for image-statements
IMAGE  MOVB @PRGFLG,R0        In program mode?
*      B    @SCAN5A           Yes, no need to scan line                   *TOMY*
       JNE  SCAN5A                                                        *TOMY*
       JMP  ERRIMP            No, illegal imperative
* Special handler for for-statements
FOR    INC  @XFLAG            Increment the nesting counter
       MOVB @XFLAG,R0         Fetch the IFFLAG
       ANDI R0,>4000          Inside an if-statement?
       JEQ  NXTCHR            No, continue in don't care mode
SNTXER LI   R3,>1A            * SYNTAX ERROR
       JMP  GPL05
* Special handler for next-statements
SNEXT  MOV  @XFLAG,R0         Get flag and for-next counter
       ANDI R0,>40FF          Get rid of flag bits except IF
       MOVB R0,R0             IFFLAG set?
       JNE  SNTXER            Yes, syntax error
       DEC  R0                Decrement counter by one
       MOVB @R0LB,@FORNET     Move back to the real conter
       JEQ  NXTCHR            Returning to top level, ok
       JGT  NXTCHR            Still at a secndary level, ok
       LI   R3,>0E            For/next nesting return code                *TOMY*
       JMP  GPL05             Return to GPL with error
ELSE   MOVB @XFLAG,R0         Get flag byte
       ANDI R0,>4000          Inside an if?
       JEQ  SNTXER            No, error
* Special handler for statement seperator
SEPSMT B    @SCAN9A           Skip the '::' and check next
* General don't care scan. Simply looks for variables to
*  enter into symbol table; stops on end of statement
NOCARE CI   R8,SSEP$*256      At a statement separator
       JEQ  SEPSMT            Skip and scan next statement
       CI   R8,TREM$*256      At a tail remark?
       JEQ  SCAN25            Yes, check mode
       MOVB R8,R8             At an end-of-line or symbol?
       JEQ  SCAN25            EOL, checK mode
       JGT  ENTER             Symbol, ENTER in symbol table
       CI   R8,LN$*256        Special line number token?
       JEQ  SKIPLN            Yes, need to skip it
       CI   R8,UNQST$*256     Special numeric token?                      *TOMY*
       JEQ  STRSKP            Yes, need to skip it
       CI   R8,NUM$*256       Special string token?                       *TOMY*
       JEQ  STRSKP            Yes, need to skip it
       CI   R8,THEN$*256      Hit a then-clause?
       JEQ  ELSE              Yes, treat like a stmt-sep
       CI   R8,ELSE$*256      Hit a else-clause?
       JEQ  ELSE              Yes, t[eat liek a stmt-sep
NXTCHR BL   @PGMCHR           Get next token
       JMP  NOCARE            And continue loop
SKIPLN INCT @PGMPTR           Skip line number
       JMP  NXTCHR            And get next token
STRSKP BL   @PGMCHR           Get length of string/number
       SWPB R8                Swap for add
       A    R8,@PGMPTR        Skip the string of number
       CLR  R8                Clear LSB of character
       JMP  NXTCHR            And get next token
* Code to return to GPL to handle special case or an
*  end-of-line return
FNNERR LI   R3,>16            FOR/NEXT NESTING
       JMP  GPL05
ENTER  LI   R3,>10            Load return code for ENTER
       JMP  GPL05             Goto GPL
SCNGPL ANDI R3,>7F00          Throw away GPL flag
       SRL  R3,8              Shift to use as index for rtn
GPL05  MOV  @RTNADD,*R9       Make sure right GROM address
       A    R3,*R9            Add offset to old GROM address
       BL   @SAVREG           Save R8/R9 in CHAT/SUBSTK
       BL   @GETSTK           Restore old GROM address
*      B    @RESET            Goto GPL w/condition reset                  *TOMY*
       B    *R12                                                          *TOMY*
*************************************************************
* Table of specially scanned statements                     *
* 2 bytes / special token                                   *
* Byte 1 - token value                                      *
* Byte 2 - "address" of special handler                     *
*        If MSB set then GPL and rest is offset from        *
*         the XML that got us here                          *
*        If MSB reset then 9900 code and is offset from     *
*         label OFFSET in this assembly of the special      *
*         case handler                                      *
*************************************************************
SCNTAB BYTE ELSE$,ELSE-OFFSET
       BYTE SSEP$,SEPSMT-OFFSET
*-----------------------------------------------------------*
* Change the following line for searching for !@P- at the   *
*  beginning of line                                        *
       BYTE TREM$,SCAN25-OFFSET                             *             *TOMY*
*      BYTE TREM$,SCN26A-OFFSET                                           *TOMY*
*-----------------------------------------------------------*
       BYTE IF$,IFIF-OFFSET
       BYTE GO$,IMPER-OFFSET
       BYTE GOTO$,IMPER-OFFSET
       BYTE GOSUB$,IMPER-OFFSET
       BYTE RETUR$,IMPER-OFFSET
       BYTE DEF$,>82
       BYTE DIM$,>84
       BYTE FOR$,FOR-OFFSET
       BYTE INPUT$,IMPER-OFFSET
       BYTE DATA$,DATA1-OFFSET
       BYTE NEXT$,SNEXT-OFFSET
       BYTE REM$,SCAN25-OFFSET
       BYTE ON$,IMPER-OFFSET
*      BYTE CALL$,>86                                                     *TOMY*
*      BYTE OPTIO$,>88                                                    *TOMY*
*      BYTE SUB$,>8A                                                      *TOMY*
*      BYTE IMAGE$,IMAGE-OFFSET                                           *TOMY*
*      BYTE SUBXT$,>8C                                                    *TOMY*
*      BYTE SUBND$,>8E                                                    *TOMY*
*      BYTE LINPU$,IMPER-OFFSET                                           *TOMY*
       BYTE THEN$,ELSE-OFFSET
TABLEN EQU  $-SCNTAB
*IBSTAB BYTE SSEP$                                                        *TOMY*
*      BYTE TREM$                                                         *TOMY*
*      BYTE END$                                                          *TOMY*
*      BYTE REM$                                                          *TOMY*
*      BYTE SUB$                                                          *TOMY*
*      BYTE >FF                                                           *TOMY*
********************************************************************************
 
