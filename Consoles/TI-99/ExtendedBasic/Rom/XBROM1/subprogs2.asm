********************************************************************************
 
 
       TITL 'SUBPROGS2'
 
*************************************************************
* RESOLV - Attempt to resolve all subprograms referenced in *
* call statements by first searching the internal subprogram*
* table (SUBTAB), then by searching GROMs for GPL           *
* subprograms. In RESGPL, it builds a subprogram table.     *
* If, after searching all of the subprogram areas, there    *
* are any subprograms whose location cannot be determined,  *
* an error occurs.                                          *
*************************************************************
RESOLV INCT R9                Save return address
       MOV  R11,*R9
       MOV  @CALIST,R5        Pick up call list pointer
       JEQ  RES50             If no subprogram references
RES03  MOV  @SUBTAB,R6        Pick up subprogram table ptr
RES05  JEQ  RES15             Try to resolve by checking
*                                                           *
* Compares two names for a match when trying to resolve all *
*  references to subprograms.                               *
* Register usage is generally as follows:                   *
*         R5  - Pointer to CALIST entry to be compared      *
*         R7  - Pointer to entry to be compared to SUBTAB   *
*               Returns as pointer to name if found or zero *
*                if not found                               *
*         R10 - Returned as length of name                  *
       MOV  R6,R3             Put in place for GETV
       INC  R3                Point at the name length
       BL   @GETV1            Get the name length
       SRL  R1,8              Put in LSB and clear MSB
       MOV  R1,R4             Save it for the move
       AI   R3,3              Point at name pointer
       BL   @GET1             Get the name pointer
       MOV  R1,R7             Save in permanent
       MOV  R1,@PGMPTR        Save for compare
       MOV  R5,R3             To get the CALIST entry
       INC  R3                Point at the name length
       BL   @GETV1            Get the name length
       CB   R1,@R4LB          Name length match?
       JNE  RES20             No, no match possible
       MOV  R4,R0             Save name length for compare
       AI   R3,3              Point at the name pointer
       BL   @GET1             Get the pointer to the name
       MOV  R1,R3             Set up to get the name
COMPTN BL   @GETV1            Get a char of CALIST name
* Next PGMSUB call is the same as PGMCHR except in skipping
*  ERAM check
       BL   @PGMSUB           Get a char of found name
       CB   R1,R8             Chars match?
       JNE  RES20             No, not same name
       INC  R3                Next character
       DEC  R0                Done with compare?
       JNE  COMPTN            No, check the rest
* Found the subprogram in GROM and built the table.
* Set resolved flag and get back.
       MOV  R5,R4             Set resolved flag now
       SETO R1                Set up a resolved flag
       BL   @PUTV1            And put the byte in
RES15  MOV  R5,R3             Get call list pointer
       INCT R3                Point at link
       BL   @GET1             Get the name link
       MOV  R1,R5             Save and set condition
       JEQ  RESGPL            End of call list? Yes
       JNE  RES03             No, go check the next in list
RES20  MOV  R6,R3             Get next entry in subpgm table
       INCT R3                Point at the link
       BL   @GET1             Get the link
       MOV  R1,R6             Update subprogram table pointer
       JMP  RES05             And try next entry
RES50  CLR  R3                Indicate no error return
RES51  MOV  *R9,R11           Restore return address
       DECT R9                Restore stack
       RT                     All resolved and ok
RES52  LI   R3,>001C
       JMP  RES51
*************************************************************
*                   RESGPL routine                          *
* Resolves as a GPL subprogram by comparing names in CALL   *
* list and GROM link list in EXEC. If name found in GROM    *
* then turn the resolved flag on and if not found an error  *
* occurs. Fetch subprogram access address from the link     *
* list and builds a subprogram table for that call.         *
*************************************************************
RESGPL MOV  @CALIST,R5        Get the call list pointer
* Get the next subprogram in the call list that has not been
*  resolved.
GET01  MOV  R5,R3             Get pointer in call list
       JEQ  RES50             If end of list
       BL   @GETV1            Get the resolved flag
       JEQ  GPL00             If not resolved
GET03  INCT R3                Point at link
       BL   @GET1             Get the link
       MOV  R1,R5             Save it and set condition
       JNE  GET01             If not end of list, go on
       JMP  RES50             Return
* Start looking at GROM subprogram link list.
GPL00  LI   R7,GPLIST         Load address of link list
       MOV  R5,R3             Copy CALIST address
       INC  R3                Point to name length
       BL   @GETV1            Get the name length
       SRL  R1,8              Adjust to the right byte
       MOV  R1,R0             Copy for later use
       CLR  R10               Clear for name length
       AI   R3,3              Point to name ptr in call list
GPL10  MOVB R7,@GRMWAX(R13)    Specify address in link list
       SWPB R7                Need to kill time here
       MOVB R7,@GRMWAX(R13)    Move next byte
       SWPB R7                Get R7 in right order
       MOVB *R13,R8           Read next link address from
       MOVB *R13,@R8LB         linked list
       INCT R7                Point to name length in GROM
       MOVB R7,@GRMWAX(R13)    Specify name length address
       SWPB R7                Need to kill time here
       MOVB R7,@GRMWAX(R13)    Move next byte
       SWPB R7                Get R7 in right order
       MOVB *R13,@R10LB       Get the name length in GROM
       C    R0,R10            Compare name length
       JEQ  GPL25             If matches, compare names
GPLNXT MOV  R8,R7             Didn't match, get link to next
       JNE  GPL10             Loop if not end of list
       MOV  R5,R3             If end of GPL list, ignore this
       JMP  GET03              entry in CALIST
* Start comparing the names
GPL25  BL   @GET1             Get name ptr form call list
*                             R1 contains address of name
       MOVB @R1LB,*R15        Get one character from VDP
       NOP
       MOVB R1,*R15           Then compare with the one in
GPL30  CB   *R13,@XVDPRD       GROM - R13 points to GROM
       JNE  GPLNXT            If no match get next in GROM
       DEC  R10               All matched?
       JNE  GPL30             No, loop for next characters
* Found the GPL subprogram. Now start building GPL's
*  subprogram table.
* First put all information in FAC since they might get
*  destroyed in MEMCHK.
* @FAC2  = Set program bit and name length
* @FAC4  = Subprogram table link address
* @FAC6  = Pointer to name
* @FAC8  = Access address in GROM
* @FAC10 = Current call list address
       LI   R12,FAC2          Optimize for speed and space
       MOV  R0,*R12           Keep length in FAC2
       SOC  @FNCFLG,*R12+     Set program bit
       MOV  @SUBTAB,*R12+     Set up subtable link address
       BL   @GET1             Get pointer to name
       MOV  R1,*R12+          Move it to FAC6
       MOVB *R13,*R12+        Get access address from GROM
       NOP
       MOVB *R13,*R12+         and put it in FAC8
       MOV  R5,*R12           Save current call list address
* Check if ERAM exists or imperative statement. If so then
* copy name into appropriate VDP area.
       MOVB @RAMFLG,R6        ERAM present?
       JNE  GPL40             Yes, then save name in table
       MOVB @PRGFLG,R6        Imperative call
       JNE  GPL60             No, handle normally
* Copy name into table area
GPL40  MOV  R0,@FAC           Copy name length
       BL   @MEMCHK           Get the space. FAC = name length
       DATA RES52             Error return address
       MOV  @FAC6,R3          Get pointer to name
       S    @FAC,@FREPTR      New free pointer
       MOV  @FREPTR,R4        New place of name
       INC  R4
       MOV  R4,@FAC6          New pointer to name
       MOV  @FAC,R2           Counter for the move
* Now copy the name, character by character
GPL50  BL   @GETV1            Get a byte
       BL   @PUTV1            Put a byte
       INC  R3
       INC  R4
       DEC  R2                Done?
       JNE  GPL50             No, move the rest
* Restore all the information from FAC area and build
*  subprograms symbol table.
GPL60  MOV  @C8,@FAC          Need 8 bytes
       BL   @MEMCHK           Get the bytes. Check the space
       DATA RES52             Error return address
       S    @C8,@FREPTR       Updata the free pointer
       MOV  @FREPTR,R0        Get location to move to
       INC  R0                True pointer
       MOV  R0,@SUBTAB        Update subprogram table ptr
       LI   R1,FAC2           Subprograms info starts FAC2
       MOVB @R0LB,*R15        Load out address
       ORI  R0,WRVDP          Enable VDP write
       MOVB R0,*R15
       LI   R0,XVDPWD         Optimize to save bytes
       LI   R3,8              Going to move 8 bytes
GPL70  MOVB *R1+,*R0          Copy mode, name length, link,
       DEC  R3                 ptr to name, ptr to subprogram
       JNE  GPL70
       MOV  *R1,R3            Restore ptr into call list
       B    @GET03            Check next entry in call list
********************************************************************************
 
