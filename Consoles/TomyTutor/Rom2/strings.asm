********************************************************************************
       AORG >9E74                                                         *TOMY*
       TITL 'STRINGS'
 
*************************************************************
*                 MEMORY CHECK ROUTINE                      *
* It checks to see if there is enough room to insert a      *
* symbol table entry or a P.A.B. into the VDP between the   *
* static symbol table/PAB area and the dymamic string area. *
* If there is not it attempts to move the string space down *
* (to  lower address) and then insert the needed area       *
* between the two. NOTE: it may invoke COMPCT to do a       *
* garbage collection. If there is not enough space after    *
* COMPCT then issues *MEMORY FULL* message.                 *
*                                                           *
* INPUT:  # of bytes needed in FAC, FAC+1                   *
* USES:   R0, R12 as temporaries as well as R0 - R6 when    *
*         invoking COMPCT                                   *
*************************************************************
MEMCHG BL   @MEMCHK           GPL entry point
       DATA SETT              If NOT enough memory                        *TOMY*
       B    @RESET            If enough memory
MEMCHK MOV  R11,R12           Save return address
       MOV  @FREPTR,R0        GET BEGINNING OF S.T. FREE SPACE
       S    @STRSP,R0         CALCULATE SIZE OF GAP
       C    @FAC,R0           ENOUGH SPACE ALREADY?
       JL   MEMC08            YES - DONE - RTN
       BL   @COMPCT           NO - COMPACITFY STRING SPACE
       MOV  @STREND,R0        GET STRING FREE SPACE
       S    @VSPTR,R0         CALCULATE SIZE OF GAP
       AI   R0,-64            VSPTR OFFSET TOO
       MOV  @FAC,R10          GET TOTAL # NEEDED BACK
       C    R0,R10            ENOUGH ROOM NOW?
       JL   MEMERR            NO - *MEMORY FULL*
*
* Now move the DYNAMIC STRING AREA DOWN IN MEMORY
*
       MOV  @STRSP,R0         CALCULATE # OF BYTES
       MOV  @STREND,R2        Beginning of move address
       S    R2,R0              in the total string space
       S    R10,@STREND       SET FREE PTR(COPY-TO ADDRESS)
       MOV  R0,R0             NO BYTES TO MOVE?
       JEQ  MEMC04            RIGHT
       MOV  R2,R3             ADDRESS FOR GETV
       INC  R3
       MOV  @STREND,R4        ADDRESS FOR PUTV
       INC  R4
MEMC03 BL   @GETV1            GET THE BYTE
       BL   @PUTV1            PUT THE BYTE
       INC  R3                INC THE FROM
       INC  R4                INC THE TO
       DEC  R0                DEC THE COUNT
       JGT  MEMC03            IF NOT DONE
*                             MOVE IT
MEMC04 S    R10,@STRSP        SET NEW STRIG SPACE PTR
*
* NOW FIX UP STRING PTRS
*
       MOV  @STRSP,R0         GET BEGINNING OF STRING SPACE
MEMC05 C    @STREND,R0        FINISHED?
       JHE  MEMC08            YES
       CLR  R1                CLEAR LOWER BYTE
       MOV  R0,R3             FOR GETV
       BL   @GETV1            GET LENGTH BYTE
       SWPB R1                SWAP FOR ADD
       S    R1,R0             POINT AT BEGINNING OF STRING
       MOV  R0,R3             FOR THE GETV1 BELOW
       AI   R3,-3             POINT AT THE BACKPOITER
       BL   @GET1             GET THE BACK POINTER
*                             BOTH BYTES
       MOV  R1,R1             FREE STRING?
       JEQ  MEMC06            YES
       MOV  R0,R6             PTR TO STRING FOR STVDP
       BL   @STVDP            SET FORWARD PTR
MEMC06 AI   R0,-4             NOW POINT AT NEXT LENGTH
       JMP  MEMC05            CONTINUE ON
MEMC08 B    @2(R12)           Return with space allocated
MEMERR MOV  *R12,R12          Pick up error return address
       B    *R12              * MEMORY FULL(prescan time)
ERRMEM B    @VPSH23           * MEMORY FULL(execution tiem)
*************************************************************
* GETSTR - Checks to see if there is enough space in the    *
*          string area to allocate a string, if there is it *
*          allocates it. If there is not it does a garbage  *
*          collection and once again checks to see if there *
*          is enough room. If so it allocates it, if not it *
*          issues a *MEMORY FULL* message.                  *
*                                                           *
* INPUT :  # of bytes needed in @BYTE                       *
* OUTPUT:  Pointer to new string in @SREF                   *
*          Both length bytes in place & zeroed Breakpointer *
*          @STREND points 1st free byte(new)                *
*                                                           *
* USES  :  R0 - R6 Temporaries                              *
*                                                           *
* Note  :  COMPCT allows a buffer zone of 8 stack entries   *
*          above what is there when COMPCT is called. This  *
*          should allow enough space to avoid a collision   *
*          between the string space and the stack. If       *
*          garbage begins to appear in the string space     *
*          that can't be accounted for, the buffer zone     *
*          will be increased.                               *
*************************************************************
GETSTR MOV  @BYTE,R0          GET # OF BYTES NEEDED
       MOV  R11,R12           SAVE RTN ADDRESS
       C    *R0+,*R0+         ADJUST FOR BACKPTR & 2 LENGTHS
*                              (INCREMENT BY 4)
       MOV  @STREND,R1        CHECK IF ENOUGH ROOM
       S    R0,R1             BY ADVANCING THE FREE PTR
       MOV  @VSPTR,R2         GET VALUE STACK PTR
       AI   R2,64             ALLOW BUFFER ZONE
       C    R1,R2             ENOUGH SPACE?
       JH   GETS10            YES, ALL IS WELL
       BL   @COMPCT           NO, COMPACTIFY
       MOV  @VSPTR,R2         GET VALUE STACK POINTER
       AI   R2,64             ALLOW BUFFER ZONE
       MOV  @BYTE,R0          GET # OF BYTES BACK
       C    *R0+,*R0+         INCREMENT BY 4
       MOV  @STREND,R1        GET NEW END OF STRING SPACE
       S    R0,R1             ADVANCE IT
       C    R1,R2             ENOUGH SPACE NOW?
       JLE  ERRMEM            NO, *MEMORY FULL*
GETS10 AI   R0,-4             GET EXACT LENGTH BACK
       MOVB @R0LB,R1          STORE ENTRY LENGTH
       BL   @PUTV             PUT THE ENDING LENGTH
       DATA STREND             BYTE IN THE STRING
       S    R0,@STREND        PT AT FIRST BYTE OF STRING
       MOV  @STREND,@SREF     POINT SREF AT THE STRING
       DEC  @STREND           POINT AT LEADING LENGTH BYTE
       BL   @PUTV             PUT THE LEADING LENGTH BYTE IN
       DATA STREND            THE STRING
       DECT @STREND           POINT AT BACKPOINTER
       CLR  R6                ZERO FOR THE BACKPOINTER
       MOV  @STREND,R1        ADDR OR THE BACKPOINTER
       BL   @STVDP            CLEAR THE BACKPOINTER
       DEC  @STREND           POINT AT 1ST FREE BYTE
       B    *R12              ALL DONE
*************************************************************
* COMPCT - Is the string garbage collection routine. It can *
*          be invoked by GETSTR or MEMCHK. It copies all    *
*          used strings to the top of the string space      *
*          suppressing out all of the unused strings        *
*    INPUT : None                                           *
*    OUTPUT: UPDATED @STRSP AND @STREND                     *
*    USES  : R0-R6 AS TEMPORARIES                           *
*************************************************************
COMPCT MOV  R11,R7            Save rtn address
       MOV  @FREPTR,R0        Get pointer to free space
       MOV  @STRSP,R5         Get pointer to string space
       MOV  R0,@STRSP         Set new string space pointer
       INC  R5                Compensate for decrement
COMP03 DEC  R5                Point at length of string
       C    @STREND,R5        At end of string space?
       JL   COMP05            No, check this string for copy
       MOV  R0,@STREND        Yes, set end of free space
       B    *R7               Return to caller
COMP05 MOV  R5,R2             Copy ptr to end in case moved
       MOV  R5,R3             Copy ptr to end in read length
       BL   @GETV1            Read the length byte
       MOVB R1,R6             Put it in R6 for address
       SRL  R6,8              Need in LSB for word
       S    R6,R5             Point at the string start
       AI   R5,-3             Point at the back pointer
       MOV  R5,R3             Set up for GETV
       BL   @GET1             Get the backpointer
       MOV  R1,R1             Is this string garbage?
       JEQ  COMP03            Yes, just ignore it
* PERTINENT REGISTERS AT THIS POINT
*        R0 - is where the sting will end
*        R6 - # of bytes to be moved(does not)
*             include lengths and backpointer
*        R2 - points at trailing length byte of string
*             to be moved
* IN GENERAL : MOVE (R6) BYTES FROM VDP(R2-R6) TO VDP(R0-R6)
*              VDP(R0-R6) moving backwards i.e. the last
*              byte of the entry is moved first, then the
*              next to the last byte...
       C    *R6+,*R6+         INCR by 4 to include overhead
       MOV  R2,R3             Restore ptr to end of string
       MOV  R0,R4             Get ptr to end of string space
COMP10 BL   @GETV1            Read a byte
       BL   @PUTV1            Write a byte
       DEC  R3                Decrement source pointer
       DEC  R4                Decrement destination pointer
       DEC  R6                Decrement the counter
       JGT  COMP10            Loop if not finished
       ANDI R4,>3FFF          Delete VDP write-enable & reg
       MOV  R4,R0             Set new free space pointer
       INC  R4                Point at backpointer just moved
       MOV  R4,R3             Copy pointer to read it
       BL   @GET1             Get the backpointer
* R1 now contains the address of the forward pointer
       MOV  R3,R6             Address of the string entry
       AI   R6,3              Point at the string itself
* R6 now contains the address of the string
       BL   @STVDP            Reset the forward pointer
       JMP  COMP03            Loop for next string
*************************************************************
* NSTRCN - Nud for string constants                         *
*          Copies the string into the string space and sets *
*          up the FAC with a string entry of the following  *
*          form:                                            *
*                                                           *
* +-------+-----+----+------------+-----------+             *
* | >001C | >65 | XX | Pointer    | Length of |             *
* |       |     |    | to string  | string    |             *
* +-------+-----+----+------------+-----------+             *
* FAC     +2    +3   +4           +6                        *
*************************************************************
NSTRCN SWPB R8
       MOV  R8,@FAC6          Save length
       MOV  R8,@BYTE          For GETSTR
       SWPB R8
       BL   @GETSTR           Get result string
       LI   R0,>001C          Get address of SREF
       LI   R1,FAC            Optimize to save bytes
       MOV  R0,*R1+           Indicate temporary string
       MOVB @CBH65,*R1+       Indicate a string
       MOVB R0,*R1+           Byte is not used
       MOV  @SREF,*R1         Save pointer to string
       MOV  @BYTE,R2          Get number of bytes to copy in
       JEQ  NSTR20            If none to copy
       MOV  *R1,R4            Get pointer to destination
       MOV  @PGMPTR,R3        Get pointer to source
*      MOVB @RAMFLG,R0        ERAM or VDP?                                *TOMY*
*      JNE  NSTR10            ERAM                                        *TOMY*
* Get the string from VDP
NSTR05 BL   @GETV1            Get a byte
       BL   @PUTV1            Put a byte
       INC  R3                Next in source
       INC  R4                Next in destination
       DEC  R2                1 less to move
       JNE  NSTR05            If more to move, do it
       JMP  NSTR20            Else if done, exit
*NSTR10 MOVB @R4LB,*R15       Write 2nd byte of VDP address               *TOMY*
*      ORI  R4,WRVDP          Enable VDP write                            *TOMY*
*      MOVB R4,*R15           Write 1st byte of VDP address               *TOMY*
*NSTR15 MOVB *R3+,@XVDPWD     Move byte from ERAM to VDP                  *TOMY*
*      DEC  R2                1 less to move                              *TOMY*
*      JNE  NSTR15            If ont done, loop for more                  *TOMY*
NSTR20 A    @FAC6,@PGMPTR     Skip the string
       BL   @PGMCHR           Get character following string
       B    @CONT             And continue on
********************************************************************************
 
