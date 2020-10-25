********************************************************************************
       AORG >6ED6
       TITL 'SPEEDS'
 
 
BSYNCH B    @SYNCHK
BERSYN B    @ERRSYN
BERSNM B    @ERRT
SPEED  MOVB *R13,R0           Read XML code
       SRL  R0,8              Shift for word value
       JEQ  BSYNCH            0 is index for SYNCHK
       DEC  R0                Not SYNCHK, check further
       JEQ  PARCOM            1 is index for PARCOM
       DEC  R0                Not PARCOM, check further
       JEQ  RANGE             2 is index for RANGE
* All otheres assumed to be SEETWO
*************************************************************
* Find the line specified by the number in FAC              *
* Searches the table from low address (high number) to      *
*  high address (low number).                               *
*************************************************************
SEETWO LI   R10,SET           Assume number will be found
       LI   R7,GET1           Assume reading from the VDP
       MOVB @RAMTOP,R0        But correct
       JEQ  SEETW2               If
       LI   R7,GETG2              ERAM is present
SEETW2 MOV  @ENLN,R3          Get point to start from
       AI   R3,-3             Get into table
SEETW4 BL   *R7               Read the number from table
       ANDI R1,>7FFF          Throw away possible breakpoint
       C    R1,@FAC           Match the number needed?
       JEQ  SEETW8            Yes, return with condition set
       JH   SEETW6            No, and also passed it =>return
       AI   R3,-4             No, but sitll might be there
       C    R3,@STLN          Reached end of table?
       JHE  SEETW4            No, so check further
       MOV  @STLN,R3          End of table, default to last
SEETW6 LI   R10,RESET         Indicate not found
SEETW8 MOV  R3,@EXTRAM        Put pointer in for GPL
       B    *R10              Return with condition
RANGE  MOV  R11,R12           Save return address
       CB   @FAC2,@CBH63      Have a numeric
       JH   BERSNM            Otherwise string number mismatch
       CLR  @FAC10            Assume no conversion error
       BL   @CFI              Convert from float to integer
       MOVB @FAC10,R0         Get an error?
       JNE  RANERR            Yes, indicate it
       MOVB *R13,R0           Read lower limit
       SRL  R0,8              Shift for word compare
       MOVB *R13,R1           Read 1st byte of upper limit
       SWPB R1                Kill time
       MOVB *R13,R1           Read 2nd byte of upper limit
       SWPB R1                Restore upper limit
       MOV  @FAC,R2           Get the value
       JLT  RANERR            If negative, error
       C    R2,R0             Less then low limit?
       JLT  RANERR            Yes, error
       C    R2,R1             Greater then limit?
       JH   RANERR            Yes, error
       B    *R12              All ok, so return
RANERR BL   @SETREG           Set up registers for error
       B    @GOTO90           * BAD VALUE
* Make sure at a left parenthesis
LPAR   CB   @CHAT,@LBLP$      At a left parenthesis
       JNE  BERSYN            No, syntax error
* Parse up to a comma and insure at a comma
PARCOM BL   @PUTSTK           Save GROM address
       BL   @SETREG           Set up R8/R9
       BL   @PARSE            Parse the next item
       BYTE COMMA$            Up to a comma
LBLP$  BYTE LPAR$
       CI   R8,COMMA$*256     End on a comma?
       JNE  BERSYN            No, syntax error
       BL   @PGMCHR           Yes, get character after it
       BL   @SAVREG           Save R8/R9 for GPL
       BL   @GETSTK           Restore GROM address
       B    @RESET            Return to GPL reset
********************************************************************************
 
