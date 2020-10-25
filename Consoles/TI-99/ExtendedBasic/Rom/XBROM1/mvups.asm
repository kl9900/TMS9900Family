********************************************************************************
       AORG >6F98
       TITL 'MVUPS'
 
* WITH ERAM    : Move the contents in ERAM FROM a higher
*                 address to a lower address
*                ARG    : byte count
*                VAR9   : source address
*                VAR0   : destination address
 
MVUP   MOV  @ARG,R1           Get byte count
       MOV  @VAR9,R3          Get source
       MOV  @VAR0,R5          Get destination
MVUP05 MOVB *R3+,*R5+         Move a byte
       DEC  R1                Decrement the counter
       JNE  MVUP05            Loop if more to move
       RT
********************************************************************************
 
