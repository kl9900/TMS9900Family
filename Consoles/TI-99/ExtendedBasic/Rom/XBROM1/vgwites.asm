********************************************************************************
       AORG >7FC0
       TITL 'VGWITES'
 
* Move data from VDP to ERAM
* @ADDR1 : Source address where the data stored on VDP
* @ADDR2 : Destination address on ERAM
* @BCNT1 : byte count
 
VGWITE EQU  $
       MOVB @ADDR11,*R15      LSB of VDP address
       MOV  @ADDR2,R2         Address in ERAM
       MOVB @ADDR1,*R15       MSB of VDP address
       NOP
VG$1   MOVB @XVDPRD,*R2+      Move a byte
       DEC  @BCNT1            One less to move
       JNE  VG$1              If not done, loop for more
       RT                     Return
********************************************************************************
 
