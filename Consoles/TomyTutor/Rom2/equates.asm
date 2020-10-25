********************************************************************************
       TITL 'EQUATES'
 
*
LWCNS  EQU  >90A4                                                         *TOMY*
*
WRVDP  EQU  >4000             Write enable for VDP
XVDPRD EQU  >E000             Read VDP data                               *TOMY*
XVDPWD EQU  >E000             Write VDP data                              *TOMY*
*XGRMRD EQU  >9800            Read GROM data                              *TOMY*
*GRMWAX EQU  >9C02->9800      Write GROM address                          *TOMY*
*GRMRAX EQU  >9802->9800      Read GROM address                           *TOMY*
*GRMWDX EQU  >9C00->9800      GROM write data                             *TOMY*
*
*KEYTAB EQU  >CB00            ADDRESS OF KEYWORD TABLE                    *TOMY*
*
*NEGPAD EQU  >7D00                                                        *TOMY*
PAD0   EQU  >F000                                                         *TOMY*
*PAD1  EQU  >8301                                                         *TOMY*
*PAD5F EQU  >835F                                                         *TOMY*
*PADC2 EQU  >83C2                                                         *TOMY*
*
VAR0   EQU  >F000                                                         *TOMY*
MNUM   EQU  >F002                                                         *TOMY*
MNUM1  EQU  >F003                                                         *TOMY*
PABPTR EQU  >F004                                                         *TOMY*
CCPPTR EQU  >F006                                                         *TOMY*
CCPADR EQU  >F008                                                         *TOMY*
RAMPTR EQU  >F00A                                                         *TOMY*
*CALIST EQU  RAMPTR                                                       *TOMY*
BYTE   EQU  >F00C                                                         *TOMY*
PROA$  EQU  >F010                                                         *TOMY*
VAR5   EQU  PROA$
P$     EQU  >F012                                                         *TOMY*
LINUM  EQU  P$
*OE$   EQU  >8314                                                         *TOMY*
Q$     EQU  >F016                                                         *TOMY*
XFLAG  EQU  Q$
VAR9   EQU  Q$
DSRFLG EQU  >F017                                                         *TOMY*
FORNET EQU  DSRFLG
STRSP  EQU  >F018                                                         *TOMY*
C$     EQU  >F01A                                                         *TOMY*
STREND EQU  C$
WSM    EQU  C$
SREF   EQU  >F01C                                                         *TOMY*
WSM2   EQU  SREF
WSM4   EQU  >F01E                                                         *TOMY*
SMTSRT EQU  WSM4
WSM6   EQU  >F0F8                                                         *TOMY*
VARW   EQU  >F020                                                         *TOMY*
VARW1  EQU  >F021                                                         *TOMY*
ERRCOD EQU  >F022                                                         *TOMY*
WSM8   EQU  >F0E2                                                         *TOMY*
*ERRCO1 EQU  >8323                                                        *TOMY*
STVSPT EQU  >F024                                                         *TOMY*
RTNADD EQU  >F026                                                         *TOMY*
NUDTAB EQU  >F028                                                         *TOMY*
*VARA  EQU  >832A                                                         *TOMY*
PGMPTR EQU  >F08A                                                         *TOMY*
PGMPT1 EQU  >F08B                                                         *TOMY*
EXTRAM EQU  >F0E8                                                         *TOMY*
*EXTRM1 EQU  >832F                                                        *TOMY*
STLN   EQU  >F0EA                                                         *TOMY*
ENLN   EQU  >F0EC                                                         *TOMY*
DATA   EQU  >F0E0                                                         *TOMY*
LNBUF  EQU  >F0E2                                                         *TOMY*
*INTRIN EQU  >8338                                                        *TOMY*
*SUBTAB EQU  >833A                                                        *TOMY*
*SYMTAB EQU  >833E                                                        *TOMY*
*SYMTA1 EQU  >833F                                                        *TOMY*
FREPTR EQU  >F0F4                                                         *TOMY*
CHAT   EQU  >F06F                                                         *TOMY*
*BASE  EQU  >8343                                                         *TOMY*
PRGFLG EQU  >F0F2                                                         *TOMY*
FLAG   EQU  >F0F6                                                         *TOMY*
BUFLEV EQU  >F0BE                                                         *TOMY*
*LSUBP EQU  >8348                                                         *TOMY*
FAC    EQU  >F04A                                                         *TOMY*
FAC1   EQU  >F04B                                                         *TOMY*
FAC2   EQU  >F04C                                                         *TOMY*
FAC4   EQU  >F04E                                                         *TOMY*
*FAC5  EQU  >834F                                                         *TOMY*
FAC6   EQU  >F050                                                         *TOMY*
FAC7   EQU  >F051                                                         *TOMY*
FAC8   EQU  >F052                                                         *TOMY*
*FAC9  EQU  >8353                                                         *TOMY*
FAC10  EQU  >F054                                                         *TOMY*
FLTNDX EQU  FAC10
FDVSR  EQU  FAC10
FAC11  EQU  >F055                                                         *TOMY*
SCLEN  EQU  FAC11
FDVSR1 EQU  FAC11
FAC12  EQU  >F056                                                         *TOMY*
FDVSR2 EQU  FAC12
*FAC13 EQU  >8357                                                         *TOMY*
*FAC14 EQU  >8358                                                         *TOMY*
FAC15  EQU  >F059                                                         *TOMY*
*FAC16 EQU  >835A                                                         *TOMY*
FDVSR8 EQU  >F05C                                                         *TOMY*
ARG    EQU  FDVSR8
ARG1   EQU  >F05D                                                         *TOMY*
ARG2   EQU  >F05E                                                         *TOMY*
*ARG3  EQU  >835F                                                         *TOMY*
ARG4   EQU  >F060                                                         *TOMY*
*ARG8  EQU  >8364                                                         *TOMY*
*ARG9  EQU  >8365                                                         *TOMY*
*ARG10 EQU  >8366                                                         *TOMY*
FAC33  EQU  >F06B                                                         *TOMY*
*TEMP2 EQU  >836C                                                         *TOMY*
*FLTERR EQU  TEMP2                                                        *TOMY*
*TYPE  EQU  >836D                                                         *TOMY*
VSPTR  EQU  >F0D4                                                         *TOMY*
VSPTR1 EQU  >F0D5                                                         *TOMY*
*STKDAT EQU  >8372                                                        *TOMY*
STKADD EQU  >F073                                                         *TOMY*
STACK  EQU  >F073                                                         *TOMY*
*PLAYER EQU  >8374                                                        *TOMY*
KEYBRD EQU  >F075                                                         *TOMY*
SIGN   EQU  KEYBRD
JOYY   EQU  >F076                                                         *TOMY*
EXP    EQU  >F080                                                         *TOMY*
*JOYX  EQU  >8377                                                         *TOMY*
*RANDOM EQU  >8378                                                        *TOMY*
*TIME  EQU  >8379                                                         *TOMY*
*MOTION EQU  >837A                                                        *TOMY*
*VDPSTS EQU  >837B                                                        *TOMY*
STATUS EQU  >F086                                                         *TOMY*
*CHRBUF EQU  >837D                                                        *TOMY*
*YPT   EQU  >837E                                                         *TOMY*
*XPT   EQU  >837F                                                         *TOMY*
RAMFLG EQU  >F08D                                                         *TOMY*
STKEND EQU  >F0BA                                                         *TOMY*
STND12 EQU  STKEND-12
*CRULST EQU  >83C0                                                        *TOMY*
*SAVEG EQU  >83CB                                                         *TOMY*
*SADDR EQU  >83D2                                                         *TOMY*
*RAND16 EQU  >83D4                                                        *TOMY*
*
*WS    EQU  >83E0                                                         *TOMY*
R0LB   EQU  >F02B                                                         *TOMY*
R1LB   EQU  >F02D                                                         *TOMY*
R2LB   EQU  >F02F                                                         *TOMY*
R3LB   EQU  >F031                                                         *TOMY*
R4LB   EQU  >F033                                                         *TOMY*
R5LB   EQU  >F035                                                         *TOMY*
R6LB   EQU  >F037                                                         *TOMY*
*R7LB  EQU  >83EF                                                         *TOMY*
R8LB   EQU  >F03B                                                         *TOMY*
R9LB   EQU  >F03D                                                         *TOMY*
R10LB  EQU  >F03F                                                         *TOMY*
*R11LB EQU  >83F7                                                         *TOMY*
R12LB  EQU  >F043                                                         *TOMY*
*R13LB EQU  >83FB                                                         *TOMY*
*R14LB EQU  >83FD                                                         *TOMY*
*R15LB EQU  >83FF                                                         *TOMY*
*
*GDST  EQU  >8302                                                         *TOMY*
*AAA11 EQU  >8303                                                         *TOMY*
*GDST1 EQU  >8303                                                         *TOMY*
*VARY  EQU  >8304                                                         *TOMY*
VARY2  EQU  >F006                                                         *TOMY*
*BCNT2 EQU  >8308                                                         *TOMY*
*CSRC  EQU  >830C                                                         *TOMY*
*ADDR1 EQU  >834C                                                         *TOMY*
*ADDR11 EQU  >834D                                                        *TOMY*
*BCNT1 EQU  >834E                                                         *TOMY*
*ADDR2 EQU  >8350                                                         *TOMY*
*ADDR21 EQU  >8351                                                        *TOMY*
*GSRC  EQU  >8354                                                         *TOMY*
*DDD11 EQU  >8355                                                         *TOMY*
*GSRC1 EQU  >8355                                                         *TOMY*
*BCNT3 EQU  >8356                                                         *TOMY*
*DEST  EQU  >8358                                                         *TOMY*
*DEST1 EQU  >8359                                                         *TOMY*
*RAMTOP EQU  >8384                                                        *TOMY*
*
*SYMBOL EQU  >0376                                                        *TOMY*
*ERRLN EQU  >038A                                                         *TOMY*
*TABSAV EQU  >0392                                                        *TOMY*
FPSIGN EQU  >03DC
VROA$  EQU  >03C0
CRNBUF EQU  >0820
CRNEND EQU  >08BE
********************************************************************************
 
