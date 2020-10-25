********************************************************************************
       AORG >7FDA
       TITL 'GVWITES'
 
* Move data from ERAM to VDP
* @GSRC  : Source address where the data stored on ERAM
* @DEST  : Destination address on VDP
* @BCNT3 : byte count
 
GVWITE MOV  @DEST,R2          VDP address
       MOVB @R2LB,*R15        LSB of VDP address
       ORI  R2,WRVDP          Enable VDP write
       MOVB R2,*R15           MSB of VDP address
       MOV  @GSRC,R3          ERAM address
GV$1   MOVB *R3+,@XVDPWD      Move a byte
       DEC  @BCNT3            One less to move
       JNE  GV$1              If not done, loop for more
       RT                     Return
 
       AORG >7FFE
       DATA >9226
 
********************************************************************************
 
