********************************************************************************
       AORG >7F7E
       TITL 'MVDNS'
 
* WITHOUT ERAM : Move the contents in VDP RAM from a lower
*                 address to a higher address avoiding a
*                 possible over-write of data
*                ARG    : byte count
*                VAR0   : source address
*                VARY2  : destination address
* WITH ERAM    : Same as above except moves ERAM to ERAM
 
MVDN   MOV  @ARG,R1           Get byte count
       MOV  @VARY2,R5         Get destination
       MOV  @VAR0,R3          Get source
MVDN2  MOV  @RAMTOP,R7        ERAM or VDP?
       JNE  MV01              ERAM, so handle it
       JMP  MV05              VDP, so jump into loop
MVDN1  DEC  R5
       DEC  R3
MV05   EQU  $
       MOVB @R3LB,*R15        Write out read address
       MOVB R3,*R15
       MOVB @XVDPRD,R7        Read a byte
       MOVB @R5LB,*R15        Write out write address
       ORI  R5,WRVDP          Enable VDP write
       MOVB R5,*R15
       MOVB R7,@XVDPWD        Write the byte
       DEC  R1                One less byte to move
       JNE  MVDN1             Loop if more to move
       RT
MV01   EQU  $
MVDN$1 MOVB *R3,*R5           Move a byte
       DEC  R3                Decrement destination
       DEC  R5                Decrement source
       DEC  R1                One less byte to move
       JNE  MVDN$1            Loop if more to move
       RT
********************************************************************************
 
