********************************************************************************
       AORG >6188
       TITL 'BASSUP'
 
* General Basic support routines (not includeing PARSE)
 
*
ERRBS  EQU  >0503             BAD SUBSCRIPT ERROR CODE
ERRTM  EQU  >0603             ERROR STRING/NUMBER MISMATCH
*
STCODE DATA >6500
C6     DATA >0006
*
* Entry to find Basic symbol table entry for GPL
*
FBSYMB BL   @FBS              Search the symbol table
       DATA RESET             If not found - condition reset
SET    SOCB @BIT2,@STATUS     Set GPL condition
       B    @NEXT             If found - condition set
* GPL entry for COMPCT to take advantage of common code
COMPCG  LI   R6,COMPCT        Address of COMPCT
       JMP  SMBB10            Jump to set up
* GPL entry for GETSTR to take advantage of common code
GETSTG LI   R6,GETSTR         Address of MEMCHK
       JMP  SMBB10            Jump to set up
* GPL entry for SMB to take advantage of common code
SMBB   LI   R6,SMB            Address of SMB routine
       JMP  SMBB10            Jump to set up
* GPL entry for ASSGNV to take advantage of common code
ASSGNV LI   R6,ASSG           Address of ASSGNV routine
       JMP  SMBB10            Jump to set up
* GPL entry for SMB to take advantage of common code
SYMB   LI   R6,SYM            Address of SYM routine
       JMP  SMBB10            Jump to set up
* GPL entry for SMB to take advantage of common code
VPUSHG LI   R6,VPUSH          Address of VPUSH routine
SMBB10 MOV  R11,R7            Save return address
       BL   @PUTSTK           Save current GROM address
       BL   @SETREG           Set up Basic registers
       INCT R9                Get space on subroutine stack
       MOV  R7,*R9            Save the return address
       BL   *R6               Branch and link to the routine
       MOV  *R9,R7            Get return address
       DECT R9                Restore subroutine stack
       BL   @SAVREG           Save registers for GPL
       BL   @GETSTK           Restore GROM address
       B    *R7               Return to GPL
*************************************************************
* Subroutine to find the pointer to variable space of each  *
* element of symbol table entry. Decides whether symbol     *
* table entry pointed to by FAC, FAC+1 is a simple variable *
* and returns proper 8-byte block in FAC through FAC7       *
*************************************************************
SMB    INCT R9                Get space on subroutine stack
       MOV  R11,*R9           Save return address
       MOV  @FAC,@FAC4        Copy pointer to table entry
       A    @C6,@FAC4         Add 6 so point a value space
       BL   @GETV             Get 1st byte of table entry
       DATA FAC               Pointer is in FAC
*
       MOV  R1,R4             Copy for later use.
       MOV  R1,R2             Copy for later use.
       SLA  R1,2              Check for UDF entry
       JOC  BERMUV            If UDF - then error
       MOV  R4,R4             Check for string.
       JLT  SMB02             Skip if it is string.
       CLR  @FAC2             Clear for numeric case.
*
* In case of subprogram call check if parameter is shared by
* it's  calling program.
*
SMB02  SLA  R1,1              Check for the shared bit.
       JNC  SMB04             If it is not shared skip.
       BL   @GET              Get the value space pointer
       DATA FAC4                in the symbol table.
       MOV  R1,@FAC4          Store the value space address.
*
* Branches to take care of string and array cases.
* Only the numeric variable case stays on.
*
SMB04  MOVB R4,R4             R4 has header byte information.
       JLT  SMBO50            Take care of string.
SMB05  SLA  R4,5              Get only the dimension number.
       SRL  R4,13
       JNE  SMBO20             go to array case.
*
* Numeric ERAM cases are special.
* If it is shared get the actual v.s. address from ERAM.
* Otherwise get it from VDP RAM.
*
       MOVB @RAMTOP,R4        Check for ERAM.
       JEQ  SMBO10            Yes ERAM case.
       SLA  R2,3              R2 has a header byte.
       JNC  SMB06             Shared bit is not ON.
       BL   @GETG             Get v.s. pointer from ERAM
       DATA FAC4
       JMP  SMB08
SMB06  BL   @GET              Not shared.
       DATA FAC4              Get v.s. address from VDP RAM.
*
SMB08  MOV  R1,@FAC4          Store it in FAC4 area.
*
* Return from the SMB routine.
*
SMBO10 MOV  *R9,R11           Restore return address
       DECT R9                Restore stack
       RT                     And return
BERMUV B    @ERRMUV           * INCORRECT NAME USAGE
*
* Start looking for the real address of the symbol.
*
SMBO50 CI   R8,LPAR$*256      String - now string array?
       JEQ  SMB05             Yes, process as an array
SMB51  MOV  @STCODE,@FAC2     String ID code in FAC2
       MOV  @FAC4,@FAC        Get string pointer address
       BL   @GET              Get exact pointer to string
       DATA FAC
*
       MOV  R1,@FAC4          Save pointer to string
       MOV  R1,R3             Was it a null?
       JEQ  SMB57             Length is 0 - so is null
       DEC  R3                Otherwise point at length byte
       BL   @GETV1            Get the string length
       SRL  R1,8              Shift for use as double
SMB57  MOV  R1,@FAC6          Put into FAC entry
       JMP  SMBO10            And return
*
* Array cases are taken care of here.
*
SMBO20  MOV R4,@FAC2          Now have a dimension counter
*                              that is initilized to maximum.
*  *FAC+4,FAC+5 already points to 1st dimension maximum in
*    in symbol table.
       CLR  R2                Clear index accumulator
SMBO25 MOV  R2,@FAC6          Save accumulator in FAC
       BL   @PGMCHR           Get next character
       BL   @PSHPRS           PUSH and PARSE subscript
       BYTE LPAR$,0           Up to a left parenthesis or less
*
       CB   @FAC2,@STCODE     Dimension can't be a string
       JHE  ERRT              It is - so error
* Now do float to interger conversion of dimension
       CLR  @FAC10            Assume no error
       BL   @CFI              Gets 2 byte integer in FAC,FAC1
       MOVB @FAC10,R4         Error on conversion?
       JNE  ERR3              Yes, error BAD SUBSCRIPT
       MOV  @FAC,R5           Save index just read
       BL   @VPOP             Restore FAC block
       BL   @GET              Get next dimension maximum
       DATA FAC4              FAC4 points into symbol table
*
       C    R5,R1             Subscript less-then maximum?
       JH   ERR3              No, index out of bounds
BIT2   EQU  $+1               Constant >20 (Opcode is >D120)
       MOVB @BASE,R4          Fetch option base to check low
       JEQ  SMBO40            If BASE=0, INDEX=0 is ok
       DEC  R5                Adjust BASE 1 index
       JLT  ERR3              If subscript was =0 then error
       JMP  SMBO41            Accumulate the subscripts
SMBO40 INC  R1                Adjust size if BASE=0
SMBO41 MPY  @FAC6,R1          R1,R2 has ACCUM*MAX dimension
       A    R5,R2             Add latest to accumulator
       INCT @FAC4             Increment dimension max pointer
       DEC  @FAC2             Decrement remaining-dim count
       JEQ  SMBO70            All dimensions handled ->done
       CI   R8,COMMA$*256     Otherwise, must be at a comma
       JEQ  SMBO25            We are, so loop for more
ERR1   B    @ERRSYN           Not a comma, so SYNTAX ERROR
*
* At this point the required number of dimensions have been
*  scanned.
* R2 Contains the index
* R4 Points to the first array element or points to the
*  address in ERAM where the first array element is.
SMBO70 CI   R8,RPAR$*256      Make sure at a right parenthesis
       JNE  ERR1              Not, so error
       BL   @PGMCHR           Get nxt token
       BL   @GETV             Now check string or numeric
       DATA FAC                array by checking s.t.
*
       JLT  SMB71             If MSB set is a string array
       SLA  R2,3              Numeric, multiply by 8
       MOVB @RAMTOP,R3        Does ERAM exist?
       JEQ  SMBO71            No
       BL   @GET              Yes, get the content of value
       DATA FAC4               pointer
*
       MOV  R1,@FAC4          Put it in FAC4
SMBO71 A    R2,@FAC4          Add into values pointer
       JMP  SMBO10            And return in the normal way
SMB71  SLA  R2,1              String, multiply by 2
       A    R2,@FAC4          Add into values pointer
       JMP  SMB51             And build the string FAC entry
ERR3   LI   R0,ERRBS          Bad subscript return vector
ERRX   B    @ERR              Exit to GPL
ERRT   LI   R0,ERRTM          String/number mismatch vector
       JMP  ERRX              Use the long branch
*************************************************************
* Subroutine to put symbol name into FAC and to call FBS to *
* find the symbol table for the symbol                      *
*************************************************************
SYM    CLR  @FAC15            Clear the caharacter counter
       LI   R2,FAC            Copying string into FAC
       MOV  R11,R1            Save return address
*-----------------------------------------------------------*
* Fix "A long constant in a variable field in INPUT,        *
*      ACCEPT, LINPUT, NEXT and READ etc. may crash the     *
*      sytem" bug,            5/22/81
* Insert the following 2 lines
       MOVB R8,R8
       JLT  ERR1              If token
SYM1   MOVB R8,*R2+           Save the character
       INC  @FAC15            Count it
       BL   @PGMCHR           Get next character
       JGT  SYM1              Still characters in the name
       BL   @FBS              Got name, now find s.t. entry
       DATA ERR1              Return vector if not found
*
       B    *R1               Return to caller if found
*************************************************************
* ASSGNV, callable from GPL or 9900 code, to assign a value *
* to a symbol (strings and numerics) . If numeric, the      *
* 8 byte descriptor is in the FAC. The descriptor block     *
* (8 bytes) for the destination variable is on the stack.   *
* There are two types of descriptor entries which are       *
* created by SMB in preparation for ASSGNV, one for         *
* numerics and one for strings.                             *
*                     NUMERIC                               *
* +-------------------------------------------------------+ *
* |S.T. ptr | 00 |       |Value ptr |                     | *
* +-------------------------------------------------------+ *
*                     STRING
* +-------------------------------------------------------+ *
* |Value ptr| 65 |       |String ptr|String length        | *
* +-------------------------------------------------------+ *
*                                                           *
* CRITICAL NOTE: Becuase of the BL @POPSTK below, if a      *
* string entry is popped and a garbage collection has taken *
* place while the entry was pushed on the stack, and the    *
* entry was a permanent string the pointer in FAC4 and FAC5 *
* will be messed up. A BL @VPOP would have taken care of    *
* the problem but would have taken a lot of extra code.     *
* Therefore, at ASSG50-ASSG54 it is assumed that the        *
* previous value assigned to the destination variable has   *
* been moved and the pointer must be reset by going back to *
* the symbol table and getting the correct value pointer.   *
*************************************************************
ASSG   MOV  R11,R10           Save the retun address
       BL   @ARGTST           Check arg and variable type
       STST R12               Save status of type
       BL   @POPSTK           Pop destination descriptor
*                              into ARG
       SLA  R12,3             Variable type numeric?
       JNC  ASSG70            Yes, handle it as such
* Assign a string to a string variable
       MOV  @ARG4,R1          Get destination pointer
*                             Dest have non-null  value?
       JEQ  ASSG54            No, null->never assigned
* Previously assigned - Must first free the old value
       BL   @GET              Correct for POPSTK above
       DATA ARG               Pointer is in ARG
*
       MOV  R1,@ARG4          Correct ARG+4,5 too
*-----------------------------------------------------------*
* Fix "Assigning a string to itself when memory is full can *
*      destroy the string" bug, 5/22/81                     *
* Add the following 2 lines and the label ASSG80            *
       C    R1,@FAC4          Do not do anything in assign- *
*                              ing a string to itself case  *
       JEQ  ASSG80            Detect A$=A$ case, exit       *
*-----------------------------------------------------------*
       CLR  R6                Clear for zeroing backpointer
       BL   @STVDP3           Free the string
ASSG54 MOV  @FAC6,R4          Is source string a null?
       JEQ  ASSG57            Yes, handle specially
       MOV  @FAC,R3           Get address of source pointer
       CI   R3,>001C          Got a temporay string?
       JNE  ASSG56            No, more complicated
       MOV  @FAC4,R4          Pick up direct ptr to string
* Common string code to set forward and back pointers
ASSG55 MOV  @ARG,R6           Ptr to symbol table pointer
       MOV  R4,R1             Pointer to source string
       BL   @STVDP3           Set the backpointer
ASSG57 MOV  @ARG,R1           Address of symbol table ptr
       MOV  R4,R6             Pointer to string
       BL   @STVDP            Set the forward pointer
ASSG80 B    *R10              Done, return
* Symbol-to-symbol assigments of strings
* Must create copy of string
ASSG56 MOV  @FAC6,@BYTE       Fetch length for GETSTR
* NOTE: FAC through FAC+7 cannot be destroyed
*       address^of string length^of string
       BL   @VPUSH            So save it on the stack
       MOV  R10,@FAC          Save return link in FAC since
*                              GETSTR does not destroy FAC
       BL   @GETSTR           Call GPL to do the GETSTR
       MOV  @FAC,R10          Restore return link
       BL   @VPOP             Pop the source info back
* Set up to copy the source string into destination
       MOV  @FAC4,R3          R3 is now copy-from
       MOV  @SREF,R5          R5 is now copy-to
       MOV  R5,R4             Save for pointer setting
* Registers to be used in the copy
* R1 - Used for a buffer
* R3 - Copy-from address
* R2 - # of bytes to be moved
* R5 - copy-to address
       MOV  @FAC6,R2          Fetch the length of the string
       ORI  R5,WRVDP          Enable the VDP write
ASSG59 BL   @GETV1            Get the character
       MOVB @R5LB,*R15        Load out destination address
       INC  R3                Increment the copy-from
       MOVB R5,*R15           1st byte of address to
       INC  R5                Increment for next character
       MOVB R1,@XVDPWD        Put the character out
       DEC  R2                Decrement count, finished?
       JGT  ASSG59            No, loop for more
       JMP  ASSG55            Yes, now set pointers
* Code to copy a numeric value into the symbol table
ASSG70 LI   R2,8              Need to assign 8 bytes
       MOV  @ARG4,R5          Destination pointer(R5)
*                              from buffer(R4), (R2)bytes
       MOV  @RAMTOP,R3        Does ERAM exist?
       JNE  ASSG77            Yes, write to ERAM
*                             No, write to VDP
       MOVB @R5LB,*R15        Load out 2nd byte of address
       ORI  R5,WRVDP          Enable the write to the VDP
       MOVB R5,*R15           Load out 1st byte of address
       LI   R4,FAC            Source is FAC
ASSG75 MOVB *R4+,@XVDPWD      Move a byte
       DEC  R2                Decrement the counter, done?
       JGT  ASSG75            No, loop for more
       B    *R10              Yes, return to the caller
ASSG77 LI   R4,FAC            Source is in FAC
ASSG79 MOVB *R4+,*R5+         Move a byte
       DEC  R2                Decrement the counter, done?
       JGT  ASSG79            No, loop for more
       B    *R10              Yes, return to caller
* Check for required token
SYNCHK MOVB *R13,R0           Read required token
*
       CB   R0,@CHAT          Have the required token?
       JEQ  PGMCH             Yes, read next character
       BL   @SETREG           Error return requires R8/R9 set
       B    @ERRSYN           * SYNTAX ERROR
*      PGMCH - GPL entry point for PGMCHR to set up registers
PGMCH  MOV  R11,R12           Save return address
       BL   @PGMCHR           Get the next character
       MOVB R8,@CHAT          Put it in for GPL
       B    *R12              Return to GPL
       RT                     And return to the caller
PUTV   MOV  *R11+,R4
       MOV  *R4,R4
PUTV1  MOVB @R4LB,*R15
       ORI  R4,WRVDP
       MOVB R4,*R15
       NOP
       MOVB R1,@XVDPWD
       RT
* MOVFAC - copies 8 bytes from VDP(@FAC4) or ERAM(@FAC4)
*          to FAC
MOVFAC MOV @FAC4,R1           Get pointer to source
       LI  R2,8               8 byte values
       LI  R3,FAC             Destination is FAC
       MOV @RAMTOP,R0         Does ERAM exist?
       JNE MOVFA2             Yes, from ERAM
*                             No, from VDP RAM
       SWPB R1
       MOVB R1,*R15           Load 2nd byte of address
       SWPB R1
       MOVB R1,*R15           Load 1st byte of address
       LI   R5,XVDPRD
MOVF1  MOVB *R5,*R3+          Move a byte
       DEC  R2                Decrement counter, done?
       JGT  MOVF1             No, loop for more
       RT                     Yes, return to caller
MOVFA2 MOVB *R1+,*R3+
       DEC  R2
       JNE  MOVFA2
       RT
       RT                     And return to caller
********************************************************************************
 
