********************************************************************************
       AORG >7B88
       TITL 'CRUNCHS'
 
QUOTE  EQU  >22
COMMA  EQU  >2C
 
LIST$  EQU  >02
OLD$   EQU  >05
SAVE$  EQU  >07
MERGE$ EQU  >08
RETUR$ EQU  >88
UNBRK$ EQU  >8F
DATA$  EQU  >93
RESTO$ EQU  >94
REM$   EQU  >9A
CALL$  EQU  >9D
IMAGE$ EQU  >A3
RUN$   EQU  >A9
COLON$ EQU  >B5
QUOTE$ EQU  >C7
UNQST$ EQU  >C8
USING$ EQU  >ED
 
MAXKEY EQU  10
*
* CRUNCH copies a line (normally in LINBUF) to CRNBUF in the
* process, it turns the line number (if any) binary, and
* converts all reserved words to tokens. CALL is a GPL XML
* followed by a single byte which indicates the type of
* crunch to be done. Possible types include:
*              >00 - Normal crunch
*              >01 - crunch as a data statement (input stmt)
*        REGISGERS:
*      R0 - R1   Scratch
*      R2 - R3   Scratch
*      R4        Points to R8LB
*      R5        Points to length byte of string/numeric
*      R6        Indicates numeric copy mode (numeric/line #)
*      R7        Mode of copy (strings, names, REMs, etc)
*      R8        Character buffer
*      R9        Points to name during keyword scan
*      R11 - R12 Links
*      R13       GROM read data pointer
*      R15       VDP write address pointer
*
CRUNCH MOV  R11,R12           Save return link
       MOVB *R13,R3           Read call code
       BL   @PUTSTK           Save GROM address
       CLR  @FAC              Assume no line number
       LI   R4,R8LB           Set up W/S low-byte pointer
       CLR  R8                Initialize character buffer
       BL   @GETNB            Scan line for 1st good char
       MOVB R1,*R4            Save character
       JEQ  CRU28             If empty line, return
* Now check crunch call mode, normal or input statement
       SRL  R3,8              Normal curnch call?
       JEQ  CRU01             Yes, crunch the statement
* Initialize for input statement crunch
       LI   R2,CRU84          No, must be crunch input stmt
       LI   R10,CRU83           so set up move indicators
       LI   R7,CRU80
       JMP  CRU10             And jump into it
* Initialize for normal line crunch
CRU01  INC  @BUFLEV           Indicate CRNBUF is destroyed
       CLR  @ARG4             Assume no symbol
       MOVB R8,@PRGFLG        Clear program flag
       BL   @GETINT           Try to read a line number
       MOV  R0,@FAC           Put line number into final
       JEQ  CRU02             If no line number
       BL   @GETNB            Skip all leading spaces
       MOVB R1,*R4            Save character in R8LB
       JEQ  CRU28             If nothing left in line
CRU02  LI   R7,CRU16          Set normal scan move
       LI   R6,CRU96          Set normal numeric scan mode
       JMP  CRU10             Merge into normal scan code
* Main loop of the input copy routine. Sets R8LB to next
* character, R0 to its character property byte
* R7 indicates dispatch mode.
CRU04  LI   R6,CRU96          Set normal numeric mode
CRU05  LI   R7,CRU16          Set normal scan mode
CRU06  BL   @PUTCHR           Copy into crunch buffer
CRU08  BL   @GETCHR           Get next input character
       CLR  R0                Assume nil property
       MOVB R1,*R4            Copy to crunch buffer
       JEQ  CRU12             Finish up if we reach a null
*-----------------------------------------------------------*
* Replace following line for adding lowercase character     *
* set to 99/4A                5/12/81                       *                  *
*  CRU10 MOVB @CPTBL(R8),R0     Fetch char's prop table vec *
CRU10  CB   *R4,@ENDPRO       Higher then "z"               *
       JHE  CRU09             Yes, give CPNIL property      *
       MOVB @CPTBL(R8),R0     Fetch char's prop table value *
       B    *R7               Dispatch to appropriate code  *
CRU09  MOVB CPNIL,R0          Don't go to CPT, just take    *
*                              CPNIL prop                   *
*-----------------------------------------------------------*
CRU12  B    *R7               Dispatch to appropriate code
CRU14  MOV  R8,R8             End of line?
       JNE  CRU06             Not yet
CRU15  MOV  @RAMPTR,R3        Now check for trailing spaces
       DEC  R3                Backup to read last character
       BL   @GETV1            Go read it
       CB   R1,@CBH20         Last character a space?
       JNE  CRU28             No, so end of line, exit
       DEC  @RAMPTR           Yes, backup pointer to delete
       JMP  CRU15             And test new last character
*-----------------------------------------------------------*
* The following two lines are added for adding lowercase    *
* character set for 99/4A     5/13/81                       *
ENDPRO BYTE >7B               ASCII code for char after "z" *
       EVEN                                                 *
*-----------------------------------------------------------*
*
* Normal scan mode -- figures out what to do with this char
CRU16 MOVB  *R4,*R4           At end of line?
       JEQ  CRU28             Yes, clean up and return
       MOVB R0,R0             Set condition on char prop
       JLT  CRU08             Ignore separators (spaces)
       MOV  @RAMPTR,R9        Save crunch pointer
       SLA  R0,2              Scan property bits 1 and 2
       JOC  CRU32             Break chars are 1 char tokens
       JLT  CRU18             Alpha, prepare to pack name
       SLA  R0,2              Scan property bits 3 and 4
       JNC  CRU20             Jump if not multi-char oper
       BL   @GETCHR           Check next char to see if we
       SRL  R1,8               have a 2 char operator
       JEQ  CRU32             If read end of line-single oper
       BL   @BACKUP           Backup read pointer
       CB   @CPTBL(R1),@LBCPMO  Next char also a multi-oper?
       JNE  CRU32             No, want single-char oper
       BL   @PUTCHR           Copy in first char to oper
       JMP  CRU36             And scan keyword table
* Set name copy mode
CRU18  LI   R7,CRU76          Alphabetic: set name copy mode
*-----------------------------------------------------------*
* Insert following 2 lines for adding lowercase character   *
* set in 99/4A                5/12/81                       *
       SRL  R0,2              Adjust R0 for LOWUP routine   *
       BL   @LOWUP            Translate lowercase to upper  *
*                              if necessary                 *
*-----------------------------------------------------------*
       JMP  CRU06             And resume copy
* Handle single character operators
CRU20  JLT  CRU32             Bit 4: single character oper
       SLA  R0,2              Scan property bits 5 and 6
       JOC  CRU24             If numeric
       JLT  CRU26             If digit only
       CI   R8,QUOTE          Is it a string quote?
       JNE  ERRIVN            No, unknown char so error
       MOV  R7,R10            Yes, save current mode
CRU22  LI   R8,QUOTE$         Convert char to quote token
       BL   @PUTCHR           Put in token
       LI   R7,CRU68          Set string, copy mode
       MOV  @RAMPTR,R5        Save pointer to length byte
       JMP  CRU06             Continue copy w/quote token
CRU24  CI   R8,'.'            A decimal point
       JNE  CRU26             No, decode as numeric/line #
       LI   R6,CRU96          Yes, decode as numeric
CRU26  B    *R6               Handle numeric or line #
BERRSY B    @CERSYN           Long distance SYNTAX ERROR
CRU27  BL   @PUTCHR           Put out last char before end
       INC  @VARW             Skip last character
* Here for successful completion of scan
CRU28  SWPB R8                Mark end of line with a null
       BL   @PUTCHR           Put the end of line in
CRNADD EQU  $+2
       LI   R0,CRNBUF         Get start of crunch buffer
       NEG  R0                Negate for backwards add
       A    @RAMPTR,R0        Calculate line length
       MOVB @R0LB,@CHAT       Save length for GPL
       BL   @GETSTK           Restore GROM address
       B    *R12              Return with pointer beyond null
* Keyword table scanning routine. Name has already been
* copied into crunch area starting at R9; RAMPTR point just
* beyond name in input line.
* R3 is name length, R1 indexes into the table
CRU32  BL   @BACKUP           Fix pointer for copy(next line)
CRU36  BL   @GETCHR           Read last character
       MOVB R1,*R4            Put into output buffer
       BL   @PUTCHR           Copy into crunch buffer
CRU38  MOV  @RAMPTR,R3        Get end pointer
       S    R9,R3             Sub start to get length of name
       CI   R3,MAXKEY         Is longer than any keyword?
       JH   CRU61             Yes, can't be a keyword
       MOV  R3,R2             Get name length and
       DEC  R2                 corremt 0 length name indexing
       SLA  R2,1              Turn it into an index
       AI   R2,KEYTAB         Add in address of table list
       MOVB R2,@GRMWAX(R13)    Load address to GROM
       SWPB R2
       MOVB R2,@GRMWAX(R13)
       MOVB *R13,R2           Read address of correct table
       MOVB *R13,@R2LB        Both bytes
* R2 now contains the address of the correct table
CRU40  MOVB R2,@GRMWAX(R13)   Load address of table
       MOV  R3,R0             Copy of length for compare
       MOVB @R2LB,@GRMWAX(R13)
       MOVB @R9LB,*R15        Source is in VDP
       A    R3,R2             Address of next keyword in table
       MOVB R9,*R15
       INC  R2                Skip token value
CRU42  CB   @XVDPRD,*R13      Compare the character
       JL   CRU61A            If no match possible
       JNE  CRU40             No match, but match possible
       DEC  R0                Compared all?
       JNE  CRU42             No, check next one
       MOV  R9,@RAMPTR        Name matched so throw out name
       MOVB *R13,*R4          Read the token value
       CLR  @ARG4             Indicate keyword found
* Check for specially crunched statements
       LI   R7,CRU14          Assume a REM statement
       LI   R0,SPECTB-1       Now check for special cases
***********************************************************                    <
* For GRAM KRACKER XB or RichGKXB or SXB substitute with: *                    <
*      CI   R8,>000B                                      *                    <
***********************************************************                    <
       CI   R8,MERGE$         Is this a command?                               <
       JH   CRU47             No, continue on
       MOV  @FAC,R3           Yes, attempt to put in program?
       JNE  ERRCIP            Yes, *COMMAND ILLEGAL IN PROGRAM*
       CI   R9,CRNBUF         Command 1st token in line?
       JNE  BERRSY            No, *SYNTAX ERROR*
CRU47  INC  R0                Skip offset value
       CB   *R4,*R0+          In special table?
       JEQ  CRU53A            Yes, handle it
       JH   CRU47             If still possible match
***********************************************************                    <
* For GRAM KRACKER XB or RichGKXB or SXB substitute with: *                    <
*      CI   R8,>000C                                      *                    <
***********************************************************                    <
       CI   R8,MERGE$         A specially scanned command?                     <
       JL   CRU27             Yes, exit crunch
       LI   R0,LNTAB          Now check for line number
CRU48  CB   *R4,*R0+          In table?
       JEQ  CRU52             Yes, change to line # crunch
       JH   CRU48             May still be in table
       CI   R8,COMMA$         Just crunch a comma?
       JEQ  CRU50             Yes, so retain current numeric
       CI   R8,TO$            Just crunch a TO?
       JNE  CRU53             No, so reset to normal numeric
CRU50  B    @CRU05            Yes, resume normal copy
CRU52  LI   R6,CRU100         Set line number scan mode
       JMP  CRU50             Set normal scan mode
ERRIVN INC  @ERRCOD           *ILLEGAL VARIABLE NAME
ERRCIP INC  @ERRCOD           *COMMAND ILLEGAL IN PROGRAM
ERRNQT INC  @ERRCOD           *NONTERMINATED QUOTED STING
CBH20  EQU  $+1
ERRNTL A    @C4,@ERRCOD       *NAME TO LONG
       JMP  CRU28             Exit back to GPL
OFFSET EQU  $
CRU53  B    @CRU04            Stmt sep resets to normal scan
CRU53A MOVB *R0,R1            Pick up offset from table
       SRL  R1,8              Make into offset
       B    @OFFSET(R1)       Goto special case handler
* Process a LIST statement
CRU57  BL   @PUTCHR           Put the list token in
       BL   @GETNB            Get next character
       CI   R1,QUOTE*256      Device name available?
       JNE  CRU28             No, no more to crunch, exit
       LI   R10,CRU106        Yes, set after string scan mode
       B    @CRU22            Crunch the device name
* Process an IMAGE statement
CRU54  LI   R10,CRU83B        Image after, string copy mode
       JMP  CRU59             Handle similar to data stmt
* Process a DATA statement
CRU58  LI   R10,CRU83         After-datum skip spaces
CRU59  C    @RAMPTR,@CRNADD   Image & data must be 1st on line
       JNE  JNESY1            If not, error
       LI   R2,CRU84          (non)quote string copy mode
CRU60  LI   R7,CRU80          Now set check-for-quote mode
CRU74  B    @CRU06            And copyin statement token
* Here when don't find something in the keyword table
CRU61  CI   R3,15             Is it longer than name can be?
       JH   ERRNTL            Yes, name to long
CRU61A MOV  @ARG4,R0          Symbol name last time too?
       JNE  JNESY1            Yes, can't have 2 in a row
       DEC  @ARG4             Indicate symbol noe
CRU62  LI   R7,CRU16          No keyword,; leave in CRNBUF
       LI   R6,CRU96          Assume normal numeric scan
CRU64  B    @CRU08            And continue to scan line
* Process a SUB statement
CRU65  MOV  @RAMPTR,R3        Get the current crunch pointer
       DEC  R3                Point at last character put in
       BL   @GETV1            Read it
       CB   R1,@GO$TOK        Was it a GO?
       JEQ  CRU52             Yes, SUB is part of GO SUB
* Process a CALL SUB statement
CRU66  LI   R7,CRU93          Set name copy
       JMP  CRU74             And get next character
CRU32L B    @CRU32
* Now the various mode copy routines; string, names, image,
*  and data statements
CRU68  MOV  R8,R8             Premature end of line?
       JEQ  ERRNQT            Yes, *NONTERMINATED QUOTED STRING
       CI   R8,QUOTE          Reach end of string?
       JNE  CRU74             No, continue copying
       BL   @GETCHR           Get next character
       MOVB R1,R1             Read end of line?
       JEQ  CRU70             Yes, can't be double quote
       CI   R1,QUOTE*256      Is it two quotes in a row?
       JEQ  CRU74             Yes, copy in a normal quote
       BL   @BACKUP           No, backup & rtn to normal scan
CRU70  MOV  R10,R7            Needed for image/data stmts
CRU72  BL   @LENGTH           Calculate length of string
       JMP  CRU64             Resume scan
* Names
*-----------------------------------------------------------*
* Replace following two lines for adding lowercase          *
* character set in 99/4A      5/12/81                       *
*  CRU76  ANDI R0,CPALNM*256    Is this char alpha or digit *
*         JEQ  CRU74            Yes, continue packing       *
CRU76  ANDI R0,CPULNM*256     Is this char alpha (both are  *
*                              upper and lower) or a digit? *
       JNE  CRU78             Yes, continue packing         *
*-----------------------------------------------------------*
*                             No, finish w/name packing
       CI   R8,'$'            Does name end with a $?
       JEQ  CRU32L            Yes, include it in name
       MOVB *R4,*R4           At an end of line?
       JEQ  CRU79             Yes, don't back up pointer
       BL   @BACKUP           Backup for next char
CRU79  B    @CRU38            Jump to name/keyword check
CRU82  B    @CRU22
*-----------------------------------------------------------*
* Add following 2 lines for adding lowercase character set  *
* for 99/4A                   5/12/81                       *
CRU78  BL   @LOWUP            Translate lower to upper if   *
*                              necessary                    *
       JMP  CRU74             Continue packing              *
*-----------------------------------------------------------*
* DATA: Scan spaces after a quoted string datum
CRU83  CI   R8,COMMA          Hit a comma?
       JEQ  CRU85A            Yes, get back into scan
* IMAGE: Scan spaces after a quoted string datum
CRU83B MOVB R0,R0             At a space?
       JLT  CRU64             Yes, ignore it
       MOV  R8,R8             At end of line?
       JEQ  CRU62             Yes, exit scan
JNESY1 JMP  JNESYN            No, unknown character
* DATA: Scan imbedded blanks and check trailing blanks
CRU83A MOV  @VARW,@ARG2       Save input pointer
       BL   @GETNB            Look for next non-blank
       MOVB R1,R1             At end of line?
       JEQ  CRU92             Yes, end string and exit
       CI   R10,CRU83B        Scanning an image?
       JEQ  CRU83C            Yes, commas are not significant
       CI   R1,COMMA*256      Hit a comma?
       JEQ  CRU85             Yes, ignore trailing spaces
CRU83C MOV  @ARG2,@VARW       No, restore input pointer
       JMP  CRU74              and include imbedded space
* DATA: Scan unquoted strings
CRU84  JLT  CRU83A            If hit a space-end of string
       MOV  R8,R8             At end-of-line?
       JEQ  CRU92             Yes, put in length and exit
       CI   R8,COMMA          Reached a comma?
       JNE  CRU74             No, scan unquoted string
       CI   R10,CRU83B        Scanning an IMAGE stmt?
       JEQ  CRU74             Commas are not significant
CRU85  BL   @LENGTH           Yes, end the string
CRU85A LI   R8,COMMA$         Load a comma token
       INC  @VAR5             Count comma for input stmt
       JMP  CRU60             And resume in string mode
* IMAGE/DATA: Check for leading quote mark
CRU80  JLT  CRU64             Ignore leading separators
       CI   R8,QUOTE          Quotoed string?
       JEQ  CRU82             Yes, like any string, R10 ok
       MOV  R8,R8             End of line?
       JEQ  BCRU28            Yes, end it
       CI   R10,CRU83B        Scanning an IMAGE?
       JEQ  CRU88             Yes, ignore commas
       CI   R8,COMMA          At a comma?
       JEQ  CRU85A            Yes, put it in directly
CRU88  MOV  R2,R7             No, set unquote string copy mode
* IMAGE & DATA: Scan unquoted strings
CRU86  LI   R8,UNQST$         Load unquoted string token
       BL   @PUTCHR           Put the token in
       MOV  @RAMPTR,R5        Save current crunch pointer
       BL   @BACKUP           Back up to scan again
CRU87  JMP  CRU74             Resume scan
* CALL and SUB statements
*-----------------------------------------------------------*
* Replace following 2 lines for adding lowercase character  *
* set for 99/4A               5/12/81                       *
*  CRU94 ANDI R0,CPALNM*256     Still an alpha-numeric      *
*        JNE  CRU74             Yes, include in name        *
CRU94  ANDI R0,CPULNM*256     Still an alpha(U & L)-numeric *
       JNE  CRU91             Yes, transfer L to U, then    *
*                              include in name              *
*-----------------------------------------------------------*
       MOV  R8,R8             At end of line?
       JEQ  CRU92             Yes, get out now
CRU90  BL   @BACKUP           No, reset read pointer
CRU92  LI   R7,CRU16          Normal scanning mode
       JMP  CRU72             Calculate & put in string length
*-----------------------------------------------------------*
* Add following lines for adding lowercase character set    *
* for 99/4A                   5/12/81                       *
CRU91  BL   @LOWUP            Transfer lowercase char to    *
*                              uppercase char if necessary  *
       B    @CRU74            Include in name               *
*-----------------------------------------------------------*
* CALL and SUB statements before hit name
CRU93  JLT  CRU64             If a space, ignore it
       MOV  R0,R0             Premature EOL or NIL char, prop?
       JEQ  CERSYN            Yes, *SYNTAX ERROR
*-----------------------------------------------------------*
* Replace following line for adding lowercase character set *
* for 99/4A                   5/12/81                       *
*         ANDI R0,CPALPH*256    An alphabetic to start name?*
       ANDI R0,CPUL*256       An alphabetic (both U & L) to *
*                              start name?                  *
*-----------------------------------------------------------*
       JEQ  CERSYN            No, syntax error
       LI   R7,CRU94          Set up to copy name
       JMP  CRU86             Put in the unqst token
* Numerics
CRU96  LI   R7,CRU98          Set after-initialize scan
       CLR  @ARG              Clear the 'E' flag
       JMP  CRU86             Set up for the numeric
CRU98  MOV  R8,R8             At end of line?
       JEQ  CRU92             Yes end the number
       SLA  R0,2              Scan property bit 2
       JLT  CRU99A            If alpha, might ge 'E'
       SLA  R0,3              Scan property bits 4 and 5
       JNC  CRU99             Bit 4=oper, if not oper, jmp
       MOV  @ARG,R0           If operator, follow an 'E'?
CRU99  CLR  @ARG              Previous char no longer an 'E'
       JLT  CRU87             If still numeric
       JMP  CRU90             No longer numeric
CRU99A CI   R8,'E'            'E' to indicate an exponent?
       JNE  CRU90             No, so end the numeric
       MOV  @ARG,R0           An 'E' already encountered?
JNESYN JNE  CERSYN            Yes, so error
       SETO @ARG              No, indicated 1 encountered now
       JMP  CRU87             And include it in the number
* Line numbers
CRU100 MOV  R8,R8             At end of line?
       JEQ  BCRU28            Yes, exit crunch
       BL   @GETINT           Try to get a line number
       MOV  R0,R0             Get a line number?
       JEQ  CRU105            No, back to normal numeric mode
       LI   R8,LN$            Load a line number token
       BL   @PUTCHR           Put it out
       MOV  R0,R8             Set up to put out binary #
       SWPB R8                Swap to put MSB of # 1st
       BL   @PUTCHR           Put out 1st byte of line #
       SRL  R8,8              Bare the 2nd byte of line #
       JMP  CRU87             Jump back into it
CRU105 B    @CRU04            Back to normal numeric mode
* Handle a list statement
CRU106 JLT  CRU93             If space, ignore it
       MOV  R8,R8             At end of line?
       JEQ  BCRU28            Yes, exit crunch
       CI   R8,':'            Get a colon?
       JNE  CERSYN            No, *SYNTAX ERROR
       LI   R8,COLON$         Need to put colon in
       B    @CRU27            And exit crunch
* Error handling routine
ERRLTL INC  @ERRCOD           * LINE TO LONG      3
       DECT @RAMPTR           Backup so can exit to GPL
ERRBLN INC  @ERRCOD           * BAD LINE NUMBER   2
CERSYN INC  @ERRCOD           * SYNTAX ERROR      1
BCRU28 B    @CRU28            Exit back to GPL
* Back up pointer in input line to rescan last character
BACKUP DEC  @VARW             Back up the pointer
       MOVB @VARW1,*R15       Write LSB of address
       NOP
       MOVB @VARW,*R15        Write MSB of address
       LI   R0,>7F00          >7F is an edge character                <<<<<<<<<<
       SB   @XVDPRD,R0        At an edge chracter?
       JEQ  BACKUP            Yes, back up one more
       RT                     And return to caller
* Put a character into the crunch buffer
PUTCHR MOV  @RAMPTR,R1        Fetch the current pointer
       CI   R1,CRNEND         At end of buffer?
       JH   ERRLTL            Yes, LINE TO LONG
       MOVB @R1LB,*R15        Put out LSB of address
       ORI  R1,WRVDP          Enable VDP write
       MOVB R1,*R15           Put out MSB of address
       INC  @RAMPTR           Increment the pointer
       MOVB *R4,@XVDPWD       Write out the byte
       RT                     And return
*-----------------------------------------------------------*
* Move LENGTH to GETNB, becuase CRUNCH is running out of    *
* space, 1/21/81                                            *
* Calculate and put length of string/number into length     *
* byte                                                      *
* LENGTH MOV  R11,R3            Save return address         *
*        MOV  @RAMPTR,R0        Save current crunch pointer *
*        MOV  R0,R8             Put into R8 for PUTCHR below*
*        S    R5,R8             Calculate length of string  *
*        DEC  R8                RAMPTR is post-incremented  *
*        MOV  R5,@RAMPTR        Address of length byte      *
*        BL   @PUTCHR           Put the length in           *
*        MOV  R0,@RAMPTR        Restore crunch pointer      *
*        B    *R3               And return                  *
*-----------------------------------------------------------*
*
* Get a small non-negative integer
* CALL: VARW - TEXT POINTER, points to second character
*       R8   - First character in low byte
*       BL     @GETINT
*       R0   - NUMBER
*       VARW - Text pointer, if there is a number, points to
*               character after number. If there is not a
*               number, unchanged.
*       R8   - 0 in high byte
*       DESTROYS: R1, R2
GETINT MOV  R11,R3            Save return address
       MOV  R8,R0             Get possible digit
       LI   R2,10             Get radix in register for speed
       AI   R0,-'0'           Convert from ASCII to binary
       C    R0,R2             Is the character a digit?
       JL   GETI02            Yes, there is a number!
       CLR  R0                No, indicate no number
       B    *R3               Done, no number
GETI01 MPY  R2,R0             Multiply previous by radix
       MOV  R0,R0             Overflow?
       JNE  ERRBLN            Yes, bad line number
       MOV  R1,R0             Get low order word of product
       A    R8,R0             Add in next digit
       JLT  ERRBLN            If number went negative, error
GETI02 BL   @GETCHR           Get next character
       MOVB R1,*R4            Put into normal position
       JEQ  GETI03            If read end of line
       AI   R8,-'0'           Convert from ASCII to binary
       C    R8,R2             Is this character a digit?
       JL   GETI01            Yes, try to pack it in
       DEC  @VARW             No point to 1st char after number
GETI03 CLR  R8                Clean up our mess
       MOV  R0,R0             Hit a natural zero?
       JEQ  ERRBLN            Yes, its an error
       B    *R3               And return
* The LINE NUMER TABLE
* All tokens which appear in the table must have numerics
* which follow them crunched as line numbers.
LNTAB  BYTE ELSE$
GO$TOK BYTE GO$                                                       <<<<<<<<<<
       BYTE GOTO$
       BYTE GOSUB$
       BYTE RETUR$
       BYTE BREAK$
       BYTE UNBRK$
       BYTE RESTO$
       BYTE ERROR$
       BYTE RUN$
       BYTE THEN$
       BYTE USING$
       BYTE >FF               Indicate end of table
       EVEN
*************************************************************
* Table of specially crunched statements                    *
* 2 bytes - special token                                   *
*  Byte 1 - token value                                     *
*  Byte 2 - "address" of special handler                    *
*           Offset from label OFFSET in this assembly of    *
*           the special case handler                        *
*************************************************************
SPECTB BYTE LIST$,CRU57-OFFSET
       BYTE OLD$,CRU58-OFFSET
       BYTE SAVE$,CRU58-OFFSET
       BYTE MERGE$,CRU58-OFFSET
       BYTE SSEP$,CRU53-OFFSET
       BYTE TREM$,CRU74-OFFSET
       BYTE DATA$,CRU58-OFFSET
       BYTE REM$,CRU74-OFFSET
       BYTE CALL$,CRU66-OFFSET
       BYTE SUB$,CRU65-OFFSET
       BYTE IMAGE$,CRU54-OFFSET
       BYTE >FF
       EVEN
*
* TRANSFER LOWERCASE CHARACTER TO UPPERCASE CHARACTER
* R0 - Last digit indicates whether this character is a
*       lowercase character
LOWUP  ANDI R0,CPLOW*256      Is lowercase prop set?
       JEQ  LU01              No, just return
       SB   @CBH20,*R4        Change lower to upper
LU01   RT
       AORG >7FFE
       DATA >C68C
********************************************************************************
 
