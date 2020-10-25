********************************************************************************
       AORG >9BF0                                                         *TOMY*
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
       SWPB R14                                                           *TOMY*
       MOVB R3,*R15
*      NOP                                                                *TOMY*
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       MOVB @XVDPRD,R1
       SWPB R14                                                           *TOMY*
       MOVB @XVDPRD,@R1LB
       RT
* Put two bytes from R1 to RAM(R4)
PUT1   MOVB @R4LB,*R15
       ORI  R4,WRVDP
       SWPB R14                                                           *TOMY*
       MOVB R4,*R15
*      NOP                                                                *TOMY*
       SWPB R14                                                           *TOMY*
       SWPB R14                                                           *TOMY*
       MOVB R1,@XVDPWD
       SWPB R14                                                           *TOMY*
       MOVB @R1LB,@XVDPWD
       RT
* Get two bytes from ERAM(R3) to R1                                       *TOMY*
*GETG  MOV  *R11+,R3                                                      *TOMY*
*      MOV  *R3,R3                                                        *TOMY*
*GETG2 EQU  $                                                             *TOMY*
*      MOVB *R3+,R1                                                       *TOMY*
*      MOVB *R3,@R1LB                                                     *TOMY*
*      DEC  R3                                                            *TOMY*
*      RT                                                                 *TOMY*
* Put two bytes from R1 to ERAM(R4)
*PUTG2 EQU  $                                                             *TOMY*
*      MOVB R1,*R4+                                                       *TOMY*
*      MOVB @R1LB,*R4                                                     *TOMY*
*      DEC  R4                Preserve R4                                 *TOMY*
*      RT                                                                 *TOMY*
********************************************************************************
 
