********************************************************************************
       AORG >7EA6
       TITL 'GREADS'
 
* Read data from ERAM
* @GSRC  : Source address on ERAM
* @DEST  : Destination address in CPU
*           Where the data stored after read from ERAM
* @BCNT3 : byte count
GREAD1 LI   R3,BCNT3          # of bytes to move
       LI   R2,GSRC           Source in ERAM
       LI   R1,DEST           Destination in CPU
       JMP  GR$1              Jump to common routine
* Read data from ERAM to CPU
* @ADDR1 : Source address on ERAM
* @ADDR2 : Destination address in CPU
*           Where the data stored after read from ERAM
* @BCNT1 : byte count
GREAD  LI   R3,BCNT1          # of bytes to move
       LI   R2,ADDR1          Source in ERAM
       LI   R1,ADDR2          Destination in CPU
* Common ERAM to CPU transfer routine
GR$1   MOV  *R2,R4
GR$2   MOVB *R4+,*R1+         Move byte from ERAM to CPU
       DEC  *R3               One less to move, done?
       JNE  GR$2              No, copy the rest
       RT
********************************************************************************
 
