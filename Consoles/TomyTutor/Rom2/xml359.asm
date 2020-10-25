********************************************************************************
       AORG >90A4                                                         *TOMY*
       TITL 'XML359'
 
* PAGE SELECTOR FOR PAGE 1
PAGE1  EQU  $                 >6000
C2     DATA 2                 0
* PAGE SELECTOR FOR PAGE 2
PAGE2  EQU  $                 >6002
C7     BYTE >00
       BYTE >07               2                                           *TOMY*
CBHAT  BYTE >0A                                                           *TOMY*
CBH94  BYTE >94               4
TLAB3  DATA >4000                                                         *TOMY*
C40    DATA 40                6
C100   DATA 100               8
C1000  DATA >1000             A
       DATA 0                 C
FLT1   DATA >4001             E                                           *TOMY*
*************************************************************
* XML table number 7 for Extended Basic - must have         *
*     it's origin at >9050                                  *             *TOMY*
*************************************************************
       AORG >9050                                                         *TOMY*
*           0      1      2      3      4      5     6
       DATA COMPCG,GETSTG,MEMCHG,CNSSEL,PARSEG,CONTG,EXECG
*           7      8    9     A    B    C      D
       DATA VPUSHG,VPOP,PGMCH,SYMB,SMBB,ASSGNV,FBSYMB
*             E     F
       DATA SPEED,CRNSEL
*************************************************************
* XML table number 8 for Extended Basic - must have         *
*     it's origin at >9070                                  *             *TOMY*
*************************************************************
*           0   1      2    3      4  5                                   *TOMY*
       DATA CIF,CONTIN,RTNG,SCROLL,IO,DELREP                              *TOMY*
*           8                                                             *TOMY*
       DATA MVDN,>90BA                                                    *TOMY*
*           9                                                             *TOMY*
       DATA PSCAN
*           A     B     C     D     E     F                               *TOMY*
       DATA >BF36,>BC98,>BB2C,>BA1C,>BA28,>BA2C                           *TOMY*
       DATA >8DC8                                                         *TOMY*
       DATA >BE44                                                         *TOMY*
       DATA GRINT                                                         *TOMY*
       DATA >0001                                                         *TOMY*
       DATA >0002                                                         *TOMY*
       DATA >0003                                                         *TOMY*
       DATA >0004                                                         *TOMY*
       DATA >0005                                                         *TOMY*
       DATA >0006                                                         *TOMY*
       DATA >0007                                                         *TOMY*
       DATA >0008                                                         *TOMY*
       AORG >90B6                                                         *TOMY*
       DATA >0D1C                                                         *TOMY*
       DATA >4002                                                         *TOMY*
       DATA >1000                                                         *TOMY*
       DATA >04C0                                                         *TOMY*
* Determine if and how much ERAM is present
*GDTECT MOVB R11,@PAGE1       First enable page 1 ROM                     *TOMY*
*-----------------------------------------------------------*
* Replace following line      6/16/81                       *
* (Extended Basic must be made to leave enough space at     *
* top of RAM expansion for the "hooks" left by the 99/4A    *
* for TIBUG.)                                               *
*      SETO R0                Start at >FFFF                *
* with
*      LI   R0,>FFE7          Start at >FFE7                              *TOMY*
*-----------------------------------------------------------*
*      MOVB R11,*R0           Write a byte of data                        *TOMY*
*      CB   R11,*R0           Read and compare the data                   *TOMY*
*      JEQ  DTECT2            If matches-found ERAM top                   *TOMY*
*-----------------------------------------------------------*
* Change the following line   6/16/81                       *
*      AI   R0,->2000         Else drop down 8K             *
*      LI   R0,>DFFF          Else drop down 8K                           *TOMY*
*-----------------------------------------------------------*
*      MOVB R11,*R0           Write a byte of data                        *TOMY*
*      CB   R11,*R0           Read and compare the data                   *TOMY*
*      JEQ  DTECT2            If matches-found ERAM top                   *TOMY*
*      CLR  R0                No match so no ERAM                         *TOMY*
*DTECT2 MOV  R0,@RAMTOP       Set the ERAM top                            *TOMY*
       RT                     And return to GPL
CNSSEL LI   R2,CNS
       JMP  PAGSEL
CRNSEL LI   R2,CRUNCH
* Select page 2 for CRUNCH and CNS
*PAGSEL INCT @STKADD          Get space on subroutine stack               *TOMY*
*      MOVB @STKADD,R7        Get stack pointer                           *TOMY*
*      SRL  R7,8              Shift to use as offset                      *TOMY*
PAGSEL B    *R2                                                           *TOMY*
GETCH  MOVB @>F037,*R15                                                   *TOMY*
       SWPB R14                                                           *TOMY*
       MOVB R6,*R15                                                       *TOMY*
       SWPB R14                                                           *TOMY*
*      MOVB R11,@PAD0(R7)     Save return addr to GPL interpeter          *TOMY*
*      MOVB @R11LB,@PAD1(R7)                                              *TOMY*
*      MOVB R11,@PAGE2        Select page 2                               *TOMY*
*      BL   *R2               Do the conversion                           *TOMY*
*      MOVB R11,@PAGE1        Reselect page 1                             *TOMY*
*      MOVB @STKADD,R7        Get subroutine stack pointer                *TOMY*
*      DECT @STKADD           Decrement pointer                           *TOMY*
*      SRL  R7,8              Shift to use as offset                      *TOMY*
*      MOVB @PAD0(R7),R11     Restore return address                      *TOMY*
*      MOVB @PAD1(R7),@R11LB                                              *TOMY*
*      RT                     Return to GPL interpeter                    *TOMY*
*GETCH MOVB @R6LB,*R15                                                    *TOMY*
*      NOP                                                                *TOMY*
*      MOVB R6,*R15                                                       *TOMY*
       INC  R6
       MOVB @XVDPRD,R8
GETCH1 SRL  R8,8
       RT
       MOV  R6,R13                                                        *TOMY*
*GETCHG MOVB R6,@GRMWAX(R13)                                              *TOMY*
*      MOVB @R6LB,@GRMWAX(R13)                                            *TOMY*
       INC  R6
       MOVB *R13,R8
       JMP  GETCH1
GETCGR MOVB *R6+,R8
       JMP  GETCH1
*
CBHFF  EQU  $+2
POPSTK LI   R5,-8
       SWPB @VSPTR                                                        *TOMY*
       MOVB @VSPTR,*R15                                                   *TOMY*
       SWPB @VSPTR                                                        *TOMY*
       LI   R6,ARG
       MOVB @VSPTR,*R15
       C    R14,R14                                                       *TOMY*
       A    R5,@VSPTR
STKMOV MOVB @XVDPRD,*R6+
       SWPB R14                                                           *TOMY*
       INC  R5
       JNE  STKMOV
       RT
*
PUTSTK INCT @STKADD
       MOVB @STKADD,R4
       SRL  R4,8
       MOV  R13,@PAD0(R4)                                                 *TOMY*
*      MOVB @GRMRAX(13),@PAD0(R4)                                         *TOMY*
*      MOVB @GRMRAX(13),@PAD1(R4)                                         *TOMY*
*      DEC  @PAD0(R4)                                                     *TOMY*
       RT
*
GETSTK MOVB @STKADD,R4
       SRL  R4,8
       DECT @STKADD
*      MOVB @PAD0(R4),@GRMWAX(R13)                                        *TOMY*
*      MOVB @PAD1(R4),@GRMWAX(R13)                                        *TOMY*
       MOV  @PAD0(R4),R13                                                 *TOMY*
       RT
********************************************************************************
 
