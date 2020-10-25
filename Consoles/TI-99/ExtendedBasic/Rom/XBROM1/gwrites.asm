********************************************************************************
       AORG >7ECA
       TITL 'GWRITES'
 
 
* Write the dat whcih is stored in CPU to ERAM
* @GDST  : Destination address on ERAM where data is going
*           to be stored
* @CSRC  : Soruce address on CPU where data stored
* @BCNT2 : byte count
GWITE1 LI   R3,BCNT2          Count
       LI   R2,GDST           Destination
       LI   R1,CSRC           Source
       JMP  GW$1
* Write the data which is stored in CPU to ERAM
* @ADDR1 : Destination address on ERAM where data is going
*           to be stroed
* @ADDR2 : Source address on CPU where dta is stored
* @BCNT1 : byte count
GWRITE LI   R3,BCNT1          Count
       LI   R2,ADDR1          Destination
       LI   R1,ADDR2          Source
* Common routine to copy from CPU to ERAM
GW$1   EQU  $
       MOV  *R2,R4            Get distination address
       MOV  *R1,R1            Get CPU RAM address
       AI   R1,PAD0           Add in CPU offset
GW$2   MOVB *R1+,*R4+         Move a byte
       DEC  *R3               One less to move, done?
       JNE  GW$2              No, more to move
       RT
********************************************************************************
 
