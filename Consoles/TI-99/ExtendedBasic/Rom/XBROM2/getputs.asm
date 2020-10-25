********************************************************************************
       AORG >6C9A
       TITL 'GETPUTS'
 
* GET,GET1          : Get two bytes of data from VDP
*                   : R3 : address in VDP
*                   : R1 : where the one byte data stored
* PUT1              : Put two bytes of data into VDP
*                   : R4 : address on VDP
*                   : R1 : data
* GETG,GETG2        : Get two bytes of data from ERAM
*                   : R3 : address on ERAM
*                   : R1 : where the two byte data stored
* PUTG2             : Put two bytes of data into ERAM
*                   : R4 : address on ERAM
*                   : R1 : data
* PUTVG1            : Put one byte of data into ERAM
*                   : R4 : address in ERAM
*                   : R1 : data
 
* Get two bytes from RAM(R3) into R1
GET    MOV  *R11+,R3
       MOV  *R3,R3
GET1   MOVB @R3LB,*R15
       MOVB R3,*R15
       NOP
       MOVB @XVDPRD,R1
       MOVB @XVDPRD,@R1LB
       RT
* Put two bytes from R1 to RAM(R4)
PUT1   MOVB @R4LB,*R15
       ORI  R4,WRVDP
       MOVB R4,*R15
       NOP
       MOVB R1,@XVDPWD
       MOVB @R1LB,@XVDPWD
       RT
* Get two bytes from ERAM(R3) to R1
GETG   MOV  *R11+,R3
       MOV  *R3,R3
GETG2  EQU  $
       MOVB *R3+,R1
       MOVB *R3,@R1LB
       DEC  R3
       RT
* Put two bytes from R1 to ERAM(R4)
PUTG2  EQU  $
       MOVB R1,*R4+
       MOVB @R1LB,*R4
       DEC  R4                Preserve R4
       RT
********************************************************************************
 
