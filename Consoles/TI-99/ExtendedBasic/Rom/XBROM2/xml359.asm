********************************************************************************
       AORG >6000
       TITL 'XML359'
 
* PAGE SELECTOR FOR PAGE 1
PAGE1  EQU  $                 >6000
C2     DATA 2                 0
* PAGE SELECTOR FOR PAGE 2
PAGE2  EQU  $                 >6002
C7     BYTE >00
CBH7   BYTE >07               2
CBHA   BYTE >0A
CBH94  BYTE >94               4
C40    DATA 40                6
C100   DATA 100               8
C1000  DATA >1000             A
       DATA 0                 C
FLTONE DATA >4001             E
*************************************************************
* XML table number 7 for Extended Basic - must have         *
*     it's origin at >6010                                  *
*************************************************************
*           0      1      2      3      4      5     6
       DATA COMPCG,GETSTG,MEMCHG,CNSSEL,PARSEG,CONTG,EXECG
*           7      8    9     A    B    C      D
       DATA VPUSHG,VPOP,PGMCH,SYMB,SMBB,ASSGNV,FBSYMB
*             E     F
       DATA SPEED,CRNSEL
*************************************************************
* XML table number 8 for Extended Basic - must have         *
*     it's origin at >6030                                  *
*************************************************************
*           0   1      2    3      4  5     6      7
       DATA CIF,CONTIN,RTNG,SCROLL,IO,GREAD,GWRITE,DELREP
*           8    9    A      B      C      D      E
       DATA MVDN,MVUP,VGWITE,GVWITE,GREAD1,GWITE1,GDTECT
*           F
       DATA PSCAN
 
* Determine if and how much ERAM is present
GDTECT MOVB R11,@PAGE1        First enable page 1 ROM
*-----------------------------------------------------------*
* Replace following line      6/16/81                       *
* (Extended Basic must be made to leave enough space at     *
* top of RAM expansion for the "hooks" left by the 99/4A    *
* for TIBUG.)                                               *
*      SETO R0                Start at >FFFF                *
* with
       LI   R0,>FFE7          Start at >FFE7
*-----------------------------------------------------------*
       MOVB R11,*R0           Write a byte of data
       CB   R11,*R0           Read and compare the data
       JEQ  DTECT2            If matches-found ERAM top
*-----------------------------------------------------------*
* Change the following line   6/16/81                       *
*      AI   R0,->2000         Else drop down 8K             *
       LI   R0,>DFFF          Else drop down 8K
*-----------------------------------------------------------*
       MOVB R11,*R0           Write a byte of data
       CB   R11,*R0           Read and compare the data
       JEQ  DTECT2            If matches-found ERAM top
       CLR  R0                No match so no ERAM
DTECT2 MOV  R0,@RAMTOP        Set the ERAM top
       RT                     And return to GPL
CNSSEL LI   R2,CNS
       JMP  PAGSEL
CRNSEL LI   R2,CRUNCH
* Select page 2 for CRUNCH and CNS
PAGSEL INCT @STKADD           Get space on subroutine stack
       MOVB @STKADD,R7        Get stack pointer
       SRL  R7,8              Shift to use as offset
       MOVB R11,@PAD0(R7)     Save return addr to GPL interpeter
       MOVB @R11LB,@PAD1(R7)
       MOVB R11,@PAGE2        Select page 2
       BL   *R2               Do the conversion
       MOVB R11,@PAGE1        Reselect page 1
       MOVB @STKADD,R7        Get subroutine stack pointer
       DECT @STKADD           Decrement pointer
       SRL  R7,8              Shift to use as offset
       MOVB @PAD0(R7),R11     Restore return address
       MOVB @PAD1(R7),@R11LB
       RT                     Return to GPL interpeter
GETCH  MOVB @R6LB,*R15
       NOP
       MOVB R6,*R15
       INC  R6
       MOVB @XVDPRD,R8
GETCH1 SRL  R8,8
       RT
GETCHG MOVB R6,@GRMWAX(R13)
       MOVB @R6LB,@GRMWAX(R13)
       INC  R6
       MOVB *R13,R8
       JMP  GETCH1
GETCGR MOVB *R6+,R8
       JMP  GETCH1
*
CBHFF  EQU  $+2
POPSTK LI   R5,-8
       MOVB @VSPTR1,*R15
       LI   R6,ARG
       MOVB @VSPTR,*R15
       A    R5,@VSPTR
STKMOV MOVB @XVDPRD,*R6+
       INC  R5
       JNE  STKMOV
       RT
*
PUTSTK INCT @STKADD
       MOVB @STKADD,R4
       SRL  R4,8
       MOVB @GRMRAX(13),@PAD0(R4)
       MOVB @GRMRAX(13),@PAD1(R4)
       DEC  @PAD0(R4)
       RT
*
GETSTK MOVB @STKADD,R4
       SRL  R4,8
       DECT @STKADD
       MOVB @PAD0(R4),@GRMWAX(R13)
       MOVB @PAD1(R4),@GRMWAX(R13)
       RT
********************************************************************************
 
