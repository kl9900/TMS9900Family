********************************************************************************
       AORG >7502
       TITL 'SUBPROGS'
 
CONTAD DATA >A000             Address of a continue stmt
GPLIST EQU  >A026             GPL subprogram linked list
 
UNQST$ EQU  >C8               Unquoted string token
 
INUSE  DATA >8000             In-use flag
FNCFLG DATA >4000             User-defined function flag
SHRFLG DATA >2000             Shared-value flag
*
* ERROR CODES
*
ERRSND EQU  >1203             * SUBEND NOT IN SUBPROGRAM
ERRREC EQU  >0F03             * RECURSIVE SUBPROGRAM CALL
ERRIAL EQU  >0E03             * INCORRECT ARGUMENT LIST
ERROLP EQU  >1103             * ONLY LEGAL IN A PROGRAM
 
*************************************************************
* CALL - STATEMENT EXECUTION                                *
* Finds the subprogram specified in the subprogram table,   *
* evaluates and assigns any arguments to the formal         *
* parameters, builds the stack block, and transfers control *
* into the subprogram.                                      *
*  General register usage:                                  *
*     R0 - R6 Temporaries                                   *
*     R7      Pointer into formals in subprogram name entry *
*     R8      Character returned by PGMCHR                  *
*     R9      Subroutine stack                              *
*     R10     Temporary                                     *
*     R11     Return link                                   *
*     R12     Temporary                                     *
*     R13     GROM read-data address                        *
*     R14     Interpreter flags                             *
*     R15     VDP write-address address                     *
*************************************************************
CALL   BL   @PGMCHR           Skip UNQST$ & get name length
       MOVB R8,@FAC15         Save lengthfor FBS
       MOVB R8,R4             For the copies to be made
       SRL  R4,8               below
       MOV  @PGMPTR,R0        Get pointer to name
       MOVB @RAMFLG,R1        ERAM or VDP?
       JEQ  CALL04            VDP
* ERAM, must copy into VDP
       MOV  R0,R5             Pointer to string in ERAM
       LI   R0,CRNBUF         Destination in VDP
       MOV  R4,R3             Length for this move
       MOVB @R0LB,*R15        Load out the VDP write address
       ORI  R0,WRVDP          Enable the VDP write
       MOVB R0,*R15           Second byte of VDP write
CALL02 MOVB *R5+,@XVDPWD      Move a byte
       DEC  R3                One less byte to move
       JNE  CALL02            Loop if not done
CALL04 A    R4,@PGMPTR        Skip over the name
       LI   R1,FAC            Destination in CPU
       MOVB @R0LB,*R15        Load out VDP read address
       ANDI R0,>3FFF          Kill VDP write-enable
       MOVB R0,*R15           Both bytes
       NOP                    Don't go to fast for it
CALL06 MOVB @XVDPRD,*R1+      Move a byte
       DEC  R4                One less bye to move
       JNE  CALL06            Loop if not done
       MOV  @SUBTAB,R4        Get beginning of subpgm table
       JEQ  SCAL89            If table empty, search in GPL
       BL   @FBS001           Search subprogram table
       DATA SCAL89            If not found, search in GPL
* Pointer to table entry returned in both R4 and FAC
       BL   @PGMCHR           Get next token
       MOV  R4,R3             Duplicate pointer for GETV
       BL   @GETV1            Get flag byte
       JLT  SCAL90            If attempted recursive call
       SLA  R1,1              Check for BASIC/GPL program
       JLT  GPLSU             GPL subprogram
       MOVB @PRGFLG,R11       Imperative call to BASIC sub?
       JNE  SCAL01            No, OK-handle BASIC subprogram
       LI   R0,ERROLP         Can't call a BASIC sub
       JMP  SCAL91              imperatively
*
* Handle a GPL subprogram
*
GPLSU  INCT R9
       MOV  @CONTAD,*R9+      Put address of a cont on stack
       MOV  R13,*R9           Save address for real BASIC
       AI   R3,6              Now set up new environment
       BL   @GET1             Get access address of GPL subpgm
       MOVB R1,@GRMWAX(R13)    Load out the address into GROM
       SWPB R1                Need to kill time here
       MOVB R1,@GRMWAX(R13)    Next byte also
       BL   @SAVREG           Restore registers to GPL
       B    @RESET            And enter the routine
*
* Execute BASIC subprogram
*
SCAL01 EQU  $
*-----------------------------------------------------------*
* Fix "An error happened in a CALL statement keeps its      *
*      in-use flag set" bug.  5/12/81                       *
*  Move the following 3 lines after finishing processing    *
*  the parameter list, before entering the subprogram.      *
*        SRL  R1,1             Restore mode to original form*
*        SOCB @INUSE,R1        Set the in-use flag bit      *
*        BL   @PUTV1           Put the byte back            *
* Save the pointer to table entry for setting in-use flag   *
* later.                                                    *
* $$$$$$$ USE VDP(0374) 2 BYTES AS TEMPRORARY HERE          *
       LI   R4,>0374          R4: address register for PUT1 *
       MOV  R3,R1             R1: data register for PUT1    *
       BL   @PUT1             Save the pointer to table     *
*                              entry in VDP temporary       *
*-----------------------------------------------------------*
       MOV  R3,R12            Save subtable address
       CLR  @FAC2             Indicate non-special entry
       BL   @VPUSH            Push subprogram entry on stack
       MOV  R12,R4            Restore sub table address
       MOV  R4,R7
       AI   R7,6              Point to 1st argument in list
       MOV  R7,R3             Formals' pointer
       BL   @GET1             Check to see if any
       MOV  R1,R1             Any args?
       JEQ  SCAL32            None, jump forward
       CI   R8,LPAR$*256      Must see a left parenthesis
       JNE  SCAL34            If not, error
       JMP  SCAL08            Jump into argument loop
SCAL90 LI   R0,ERRREC         * RECURSIVE SUBPROGRAM CALL
       JMP  SCAL91
SCAL89 LI   R0,>000A          GPL check for DSR subprogram
SCAL91 B    @ERR
SCAL93 JMP  SCAL12            Going down!
SCAL05 BL   @POPSTK           Short stack pop routine
       MOV  @ARG4,R7          To quickly restore R7
       INCT R7                To account for SCAL80
SCAL06 CI   R8,RPAR$*256      Actual list ended?
       JEQ  SCAL30            Actuals all scanned
       CI   R8,COMMA$*256     Must see a comma then
       JNE  SCAL12            Didn't, so error
* Scan next actual. Check if it is just a name
SCAL08 MOV  @PGMPTR,@ERRCOD   Save text ptr in case of expr
       BL   @PGMCHR           Get next character
       JLT  SCAL40            No, so must be an expression
       MOV  R7,R12            Save formals pointer
       BL   @SYM              Read name & see if recognized
       BL   @GETV             Check function flag
       DATA FAC
       MOV  R12,R7            Restore formals pointer first
       CZC  @FNCFLG,R1        User-defined function?
       JNE  SCAL40            Yes, pass by value
       CI   R8,LPAR$*256      Complex type?
       JNE  SCAL15            No
       BL   @PGMCHR           Check if formal entry
       CI   R8,RPAR$*256      FOO() ?
       JEQ  SCAL14            Yes, handle it as such
       CI   R8,COMMA$*256     or FOO(,...) ?
       JNE  SCAL35            No, an array element FOO(I...
SCAL10 BL   @PGMCHR           Formal array, scan to end
       BL   @EOSTMT           Check if end-of-statement
       JEQ  SCAL12            Premature end of statement
       CI   R8,COMMA$*256     Another comma?
       JEQ  SCAL10            Yes, continue on to end
       CI   R8,RPAR$*256      End yet?
       JEQ  SCAL14            Yes, merge in below
SCAL12 B    @ERRONE           * SYNTAX ERROR
SCAL32 B    @SCAL62           Going down!
SCAL30 B    @SCAL60
SCAL34 B    @SCAL88
SCAL35 B    @SCAL50
SCAL37 JMP  SCAL06
*
* Here for Scalers/Arrays by Reference
SCAL14 BL   @PGMCHR           Pass the right parenthesis
SCAL15 CI   R8,COMMA$*256     Just a name?
       JEQ  SCAL16            Yes
       CI   R8,RPAR$*256      Start an expression?
       JNE  SCAL40            Yes, name starts an expression
SCAL16 BL   @GETV             Get mode of name
       DATA FAC               Ptr to s.t. entry left by SYM
       MOVB R1,R2             Save for check below
       BL   @SCAL80           And fetch next formal info
       MOVB R2,R1             Copy for this check
       ANDI R1,>C700            for the comparison
       MOV  R6,R0             Use a temporary rgister
       ANDI R0,>C700            for the comparison
       C    R1,R0             Must be exact match
       JNE  SCAL34            Else can't pass by reference
       SOC  @SHRFLG,R6        Set the shared symbol flag
       MOVB R6,R1             Load up for PUTV
       MOV  R5,R4             Address to put the flag
       BL   @PUTV1            Set the flag in the s.t. entry
       ANDI R4,>3FFF          Kill VDP write-enable bit
*
* The following section finds actual's value space address
*  and puts it in R1.
*  FAC contains the symbol table's address.
* If actual is NOT shared.......................
*  Symbol table's address+6 will point to the value space
*   except for numeric ERAM cae. In a numeric ERAM case
*   GET1 to get pointer to the ERAM value space.
* If actual is SHARED........................
*  GET1 to get the pointer in symbol table's address+6
*  In a numeric ERAM case, GETG to get the indirect point
*   to the actual's vlaue space pointer after GET1 is call
*
       MOV  @FAC,R1           Ptr to actual s.t. entry
       AI   R1,6              Ptr to actuals value space
       ANDI R6,>8700          Keep info on string or array
       ANDI R2,>2000          Is actual shared?
       JEQ  SCAL23            No, use it
       MOV  R1,R3             Else look further
       BL   @GET1             Get the true pointer
       MOVB R6,R6             Array or string?
       JNE  SCAL24            Yes, both are special cases
       MOVB @RAMTOP,R2        ERAM present?
       JEQ  SCAL24            No ERAM, so skip
* Numeric variable, shared, ERAM.
       MOV  R1,R3             Get ptr to original from ERAM
       BL   @GETG2            Get indirect pointer
       JMP  SCAL24
* Shared bit is NOT on.
SCAL23 MOVB R6,R6             Check for array or string
       JNE  SCAL24            Yes, take what's in there
       MOVB @RAMTOP,R2        ERAM exists?
       JEQ  SCAL24            No
       MOV  R1,R3             Numeric and ERAM case
       BL   @GET1             Get ERAM value space address
*                             R4 pointing to value space of
SCAL24 AI   R4,6               subprogram's symbol table
       MOVB R6,R6             Array or string case?
       JNE  SCAL26            Yes, so just put ptr in VDP
* Here check for ERAM program and if ERAM then copy the
* address of shared value space into corresponding value
* space in ERAM
       MOVB @RAMTOP,R6        Get the ERAM flag
       JEQ  SCAL26            If no ERAM, simple case
       MOV  R1,R6             Keep shared value space address
       MOV  R4,R3             Put ptr in value space in ERAM
       BL   @GET1             Get value space address in ERAM
       MOV  R1,R4             Copy address into R4 for PUTG2
       MOV  R6,R1             Get the value to put in ERAM
       BL   @PUTG2            Write it into ERAM
       JMP  SCAL37            Loop for next argument
SCAL26 BL   @PUT1             Set symbol indirect link
       JMP  SCAL37            And loop for next arg
*
* Here to pass an expression by value
*
SCAL40 MOV  @ERRCOD,@PGMPTR   Restore text pointer
       MOV  R7,@FAC4          Save formals pointer
       CLR  @FAC2             Don't let VPUSH mess up
SCAL42 BL   @PGMCHR           Set up for the parse
* Save formals ptr & SUBTAB ptr and evaluate the expression
       BL   @PSHPRS
       BYTE RPAR$             Stop on an rpar or comma
DCBH6A BYTE >6A               (CBH6A copy)
       BL   @POPSTK           Restore formals pointer
       A    @C16,@VSPTR       But keep it on stack
       BL   @VPUSH            Save parse result
       MOV  @ARG4,R7          Restore formals pointer
       BL   @SCAL80           And fetch next formal's info
       MOV  R5,@FAC           Set up for assignment
       BL   @SMB              Get value space
       S    @C16,@VSPTR       Get to s.t. info
       BL   @VPUSH            Set up for ASSG
       A    @C8,@VSPTR        Get back to parse result
       BL   @VPOP             Get parse result back
       BL   @ASSG             Assign the value to the formal
       B    @SCAL05           And go back for more
*
* Here for array elements
*
SCAL50 DEC  @PGMPTR           Restore text pointer to lpar
       LI   R11,FAC2          Optimize to save
       CLR  *R11+             Don't let VPUSH mess up (FAC2)
       MOV  R7,*R11+          Save formals pointer    (FAC4)
       MOV  @ERRCOD,*R11      For save on stack       (FAC6)
       BL   @VPUSH            Save the info
       LI   R8,LPAR$*256      Load up R8 with the lpar again
       MOV  @FAC,@PAD0        Save ptr to s.t. entry
       BL   @SMB              Check if name or expression
       CI   R8,COMMA$*256
       JEQ  SCAL54            Name if ended on a comma
       CI   R8,RPAR$*256
       JEQ  SCAL54             or rpar
       BL   @VPOP             Get saved info back
       MOV  @FAC6,@PGMPTR     Else expr, Restore test pointer
       JMP  SCAL42            And handle like an expression
*
* Passing array elements by reference
SCAL54 BL   @POPSTK           Restore symbol pointer
       MOV  @ARG4,R7
       BL   @SCAL80           Get next formal's info
       BL   @GETV             Check actualOs mode
       DATA PAD0              Get back header information
       ANDI R1,>C000          Throw away all but string & function
       CB   R6,R1             Check mode match (string/num)
       JNE  JNE88             Don't, so error
* Can set bit in R1 since MSB (R1)=MSB (R6)
       SOCB @SHRFLG,R1        Set the share flag
       MOV  R5,R4             Address for PUTV
       BL   @PUTV1            Put it in the s.t. entry
       ANDI R4,>3FFF          Kill VDP write, enable bit
       MOV  @FAC,R1           Assuming string, ref link=@FAC
       MOVB R6,R6             Check if it is a string
       JLT  SCAL24            If so, go set ref. link
       MOV  @FAC4,R1          Numeric, ref. link=@FAC4(v.s.)
       JMP  SCAL24            Now set the link and go on
*
* Here when done parsing actuals
*
SCAL60 BL   @PGMCHR           Pass the right parenthesis
SCAL62 BL   @EOSTMT           Must be at end of statement
JNE88  JNE  SCAL88            If not, error
       MOV  R7,R3             Formals must also have ended
       INCT R7
       MOV  R7,@FAC           Keep R7, POPSTK destorys R7
       BL   @GET1             Get the last arg address
       MOV  R1,R1             Formals end?
       JNE  SCAL88            Didn't, so error
*
* Now set up the stack entry
*
       BL   @VPUSH            Check if enough room for push
       S    @C8,@VSPTR        Get back right pointer
       BL   @POPSTK           Retrieve ptr to subprog s.t.
       LI   R12,FAC           For code optimization
       MOV  R12,R1            Store following data in FAC
       MOV  *R12,@ARG2        Save new environment pointer
*
* First push entry. PGMCHR, EXTRAM, SYMTAB and RAM(SYNBOL)
*
       LI   R0,PGMPTR         Optimize
       MOV  *R0+,*R1+         Text pointer         PGMPTR
       MOV  *R0+,*R1+         Line table pointer   EXTRAM
       MOV  @SYMTAB,*R1+      Symbol table pointer
       LI   R3,SYMBOL         Put address of SYMBOL
       BL   @GET1             Get RAM(SYMBOL) in REG1
       MOV  R1,@FAC6          Move to FAC area
       BL   @VPUSH            Save first entry
*
* Push second entry. Subprogram table pointer, >6A on warning
*  bits and @LSUBP in the second stack.
       MOV  R12,R4            Going to build entry in FAC
       MOV  @ARG,*R4+         Subprogram table entry pointer
       MOVB @DCBH6A,*R4+      >6A = Stack ID
       MOVB @FLAG,R2          Warning/break bits
       ANDI R2,>0600          Mask off other bits
       MOVB R2,*R4+           Put bits in stack entry
       MOV  @LSUBP,@FAC6      Last subprogram block on stack
       BL   @VPUSH            Push final entry
       MOV  @VSPTR,@LSUBP     Set bottom of stack for the sub
*
* Now build the new environment by modifying PGMCHR,
* EXTRAM and pointer to sub's symbol table.
       LI   R0,PGMPTR         Optimization
       MOVB @ARG3,*R15        2nd byte of address
       LI   R1,XVDPRD         Optimize to save bytes
       MOVB @ARG2,*R15        1st byte of address
       LI   R4,4              Need 4 bytes
SCAL70 MOVB *R1,*R0+          Read EXTRAM and PGMPTR
       DEC  R4
       JNE  SCAL70
       MOVB *R1,@SYMTAB       New SYMTAB
       LI   R4,SYMBOL
       MOVB *R1,@SYMTA1
       MOV  @SYMTAB,R1
       BL   @PUT1             New RAM(SYMBOL)
       CLR  @ERRCOD           Clean up our mess
       BL   @PGMCHR           Get the next token into R8
*-----------------------------------------------------------*
* Fix "A error happened in a CALL statement keeps it        *
*   "in-use flag set" bug,    5/23/81                       *
* Insert following lines:                                   *
       LI   R3,>0374          Restore the pointer to table  *
*  entry from VDP temporary, R3: address reg. for GET1      *
       BL   @GET1                                           *
       MOV  R1,R3             Get flag byte                 *
       BL   @GETV1                                          *
       SOCB @INUSE,R1         Set the in-use flag bit       *
       MOV  R3,R4             ??????????????????????????????????????????????????
       BL   @PUTV1            Put the byte back             *
*-----------------------------------------------------------*
       B    @NUDEND           Enter the subprogram
SCAL88 LI   R0,ERRIAL         * INCORRECT ARGUMENT LIST
       JMP  $+>C6             Jump to  B @ERR
*************************************************************
* Fetch next formal and prop for adjustment                 *
* Register modification                                     *
*    R5  Address of s.t. entry (formal's entry)             *
*    R6  Header byte of formal's entry                      *
*    R7  Updated formal's pointer                           *
* Destroys: R1, R2, R3, R4, R11, R12                        *
*************************************************************
SCAL80 MOV  R11,R12           Save return address
       MOV  R7,R3             Fetch symbol pointer
       INCT R7                Point to next formal
       BL   @GET1             Fetch s.t. pointer
       MOV  R1,R3             Set condition & put in place
       JEQ  SCAL88            If to many actuals
       MOV  R1,R4             Save for below
       MOV  R1,R5             Save for return
       BL   @GET1             Get header bytes
       COC  @SHRFLG,R1        Shared?
       JEQ  SCAL82            Yes, reset flag and old value
       MOV  R1,R6             Save for return & test string
       JLT  SCAL81            If it is a string, then SCAL81
       B    *R12              Return
SCAL81 AI   R3,6              Is string, point at value ptr
       BL   @GET1             Get the value pointer
       MOV  R1,R4             Null value?
       JEQ  SCAL86            Yes
       CLR  R1                No, must free current string
       AI   R4,-3             Point at the backpointer
       BL   @PUT1             Clear the backpointer
       MOV  R3,R4
SCAL84 CLR  R1                Needed for entry from below
       BL   @PUT1             Clear the forward pointer
       B    *R12              Just return
SCAL82 ANDI R1,>DFFF          Reset the share flag
       BL   @PUTV1            Put it there
       AI   R4,6              Point at ref pointer
       MOV  R1,R6             Set for return
       JLT  SCAL84            If string clear ref pointer
SCAL86 B    *R12              Return
*************************************************************
* Execute a SUBEXIT or SUBEND                               *
*************************************************************
SUBXIT MOV  @LSUBP,R5         Check for subprogram on stack
       JEQ  SCAL98            Not one, so error
       C    R5,@VSPTR         Extra check on stack pointer
       JH   SCAL98            Pointers are messed up, error
SBXT05 BL   @VPOP             Get stack entry
       CB   @FAC2,@DCBH6A     Reached the subprogram entry?
       JNE  SBXT05            Not yet
*
* Reached the subprogram stack entry. Get information FAC
*  area has subprograms table pointer, >6A, on warning bits
*  and LSUBP
       LI   R12,FAC           Optimize for the copies
       MOV  R12,R0            For this copy
       MOV  *R0+,R3           Subprogram pointer
       BL   @GETV1            Get header byte in subprogram
       SZCB @INUSE,R1         Reset the in-use bit
       MOV  R3,R4
       BL   @PUTV1            Put it back
       MOV  *R0+,R1           On warning bits
       MOVB @FLAG,R4          Get the current flag
       ANDI R4,>F900          Trash current warning bits
       SOCB @R1LB,R4          OR the old ones back in
       MOVB R4,@FLAG          And put flag back
       INCT R0                There is one word empty
       MOV  *R0+,@LSUBP       Last subprogram block on stack
*
* Second subprogram stack entry. Restore pointers. FAC area
*  has PGMPTR, EXTRAM, SYMTAB, RAM(SYMBOL)
       BL   @VPOP             Get second entry
       MOV  R12,R0            Put FAC in R0. (optimization)
       LI   R1,PGMPTR         For optimization
       MOV  *R0+,*R1          Restore text pointer    PGMPTR
       DEC  *R1+              Save code to decrement it
       MOV  *R0+,*R1+         Line table pointer EXTRAM
       MOV  *R0+,@SYMTAB      Restore symbol table pointer
       MOV  *R0+,R1           Restore permanent s.t. pointer
       LI   R4,SYMBOL         Place in VDP
       BL   @PUT1             Put it out there
       BL   @PGMCHR           Load R8 with EOS/EOL & go on
       B    @EOL
SCAL98 LI   R0,ERRSND         * SUBEND NOT IN SUBPROGRAM
       B    @ERR
********************************************************************************
 
