********************************************************************************
       AORG >7EF4
       TITL 'DELREPS'
 
* Delete the text in crunched program on VDP or ERAM
*  point to the line # (to be deleted) in the line # table
* RAMTOP  0 if no ERAM
* ENLN    Last location used by the line # table
* STLN    First location used by the line # table
*
 
DELREP MOV  R11,R8            Save return
       INCT @EXTRAM           Point to line ptr in table
       MOV  @EXTRAM,R3        Prepare to read it
       MOV  @RAMTOP,R7        Check ERAM flag & get in reg
       JNE  DE01              ERAM, get from it
       BL   @GET1             Get line ptr from VDP
       JMP  DE02
DE01   BL   @GETG2            Get line ptr from ERAM
DE02   DEC  R1                Point to line length
       MOV  R1,R3             Prepare to read length
       MOV  R1,R9             Save copy for use later
       MOV  R7,R7             Editing in ERAM?
       JNE  DE03              ERAM, get length from it
       BL   @GETV1            Get line length from VDP
       JMP  DE04
DE03   MOVB *R3,R1
DE04   MOVB R1,R2             Move text length for use
       SRL  R2,8              Need as a word
       INC  R2                Text length = length + length
*                              byte
       MOV  @ENLN,R3          Get end of line # table
       INC  R3                Adjust for inside loop
* UPDATE THE LINE # TABLE
DEREA  DECT R3                Point to line pointer
       MOV  R7,R7             Editing in ERAM?
       JNE  DE05              ERAM, read it as such
       BL   @GET1             Get line pointer from VDP
       JMP  DE06
DE05   BL   @GETG2            Get line pointer from ERAM
DE06   MOV  R1,R5             Move for use
       DEC  R5                Point to length byte
       C    R9,R5             Compare location of delete
*                              line & this line
       JLE  DEREB             This line won't move ,
*                              don't fix pointer
       A    R2,R1             Add distance to move to pointer
       MOV  R3,R4             Write it to same place
       MOV  R7,R7             Editing in ERAM?
       JNE  DE10              Yes
       BL   @PUT1             Put back into line # table
       JMP  DEREB
DE10   BL   @PUTG2            Put back into line # table
DEREB  DECT R3                Point at the line #
       C    R3,@STLN          At last line in table?
       JNE  DEREA             No, loop for more
* UPDATA OF LINE # TABLE IS COMPLETE, NOW DELETE TEXT
* R9 still contains pointer to length byte of text to delete
* R2 still contains text length
       DEC  R9
       MOV  R9,R3
       MOV  R9,R5
       A    R2,R5             Point to 1st token
       MOV  R3,R1             Save for later use
       S    @STLN,R1          VDP, calculate # of bytes to move
       INC  R1                Correct offset by one
       BL   @MVDN2            Delete the text
* NOW SET UP POINTERS TO LINE TABLE
DE18   LI   R1,EXTRAM         Start with EXTRAM
       A    R2,*R1+           Update EXTRAM
       A    R2,*R1+           Update STLN
       A    R2,*R1            Update ENLN
       B    *R8               And return
********************************************************************************
 
