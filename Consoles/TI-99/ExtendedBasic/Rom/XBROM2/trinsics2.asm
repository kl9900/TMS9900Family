********************************************************************************
 
 
       TITL 'TRINSICS2'
 
*************************************************************
* SINE FUNCTION                                             *
* FAC          : = SIN(FAC)                                 *
* STACK LEVELS USED:                                        *
*     IF FAC < 0 THEN SIN(FAC) : = -SIN(-FAC)               *
*     X       : = 2/PI*FAC                                  *
*     K       : = INT(X)                                    *
*     R       : = X-K, 0 <= R < 1                           *
*     Q       : = K MOD 4                                   *
*  SO K       : = 4*N+Q                                     *
*    FAC      : = PI/2 * K + PI/2 * R                       *
*             : = 2*PI*N + PI/2*Q + PI/2*R                  *
*    SIN(FAC) : = SIN(P/2*Q+PI/2*R)                         *
* QUADRANT  Q     Identity                                  *
* I         0     SIN(FAC)    : = SIN(PI/2*R)               *
* II        1     SIN(FAC)    : = SIN(PI/2+PI/2*R           *
*                             : = SIN(PI-*(PI/2+PI/2R))     *
*                             : = SIN(PI/2*(1-R))           *
* III       2     SIN(FAC)    : = SIN(PI+PI/2*R)            *
*                             : = SIN(PI-(PI+PI/2*R))       *
*                             : = SIN(PI/2 * (R-1))         *
* IV        3     SIN(FAC)    : = SIN(3*PI/2 + PI/2*R       *
*                             : = SIN(3*PI/2 + PI/2*R-2*PI) *
*                             : = SIN(PI/2 * (R-1))         *
* QUADRANT  Q  ARGUMENT TO APPROXIMATION POLYNOMIAL         *
* I         0    R      = R         0 <= R   <  1           *
* II        1  1-R      = 1-R       0 <  1-R <= 1           *
* III       2   -R      = -R       -1 <  -R  <= 0           *
* IV        3    R-1    = -(1-R)   -1 <= R-1 <  0           *
*                                                           *
* A polynomial approximation is used for SIN(P/2*R)         *
*                      -1 <= R < 1                          *
* (HART SIN 3344)                                           *
*************************************************************
SIN$$  MOV  R11,R10
       BL   @ROLOUT           Get workspace and save return
       BL   @MOVROM           Get 2/PI
       DATA RPI2               into ARG
*
       BL   @FMULT            X : = 2/PI*FAC
       MOVB @FAC,R12          Save sign
       ABS  @FAC              Consider positive numbers
       CB   @FAC,@CBH44       Check exponent range
*                              by checking with >44
       JGT  TRIERR            ERR in range of exponent
       BL   @PUSH             Save X
       BL   @GRINT            K : = INT(K)
       CLR  R1                Assume Q is zero
       CLR  R0
       MOVB @FAC,R0           Is FAC zero?
       JEQ  SIN02             Yes, Q is zero
       AI   R0,>BA00          Bias exponent (->46 byte)
*                              is K too big for (K MOD 4)
*                              to have a significance?
       JGT  SIN01             Yes, defualt Q to zero
       AI   R0,>51*256        (FAC+7-PAD0)*256
CBH80  EQU  $+1               CONSTANT >80
       SRL  R0,8
       AI   R0,PAD0
       MOVB *R0,@R1LB         No, get 10's and 1's place of K
CC3    EQU  $+2
SIN01  ANDI R1,3              Q : = (K MOD 4)
SIN02  MOV  R1,@Q$
       BL   @SSUB             R : = X-K
       MOV  @Q$,R1
       SRL  R1,1              Is Q even?
       MOV  R1,@Q$
       JNC  SIN03             Yes
       BL   @MOVROM           Get a floating 1
       DATA FPOS1              into ARG
*
       BL   @FSUB             Compute 1-R
SIN03  MOV  @Q$,R1            Quadrant III or IV?
       JEQ  SIN04             No
       INV  R12               Yes, change sign or result
SIN04  BL   @POLYW            Evaluate it
       DATA SINP               get poly P's coefficients
*
       JMP  ATNSGN              and set sign
TRIERR MOVB @CCBH7,@FAC10     TRIG error (>7 in FAC10)
       JMP  ATNSG3
*************************************************************
* TANGENT FUCTION                                           *
* FAC            : = TAN(FAC)                               *
* TAN(FAC)       : = SIN(FAC)/COS(FAC)                      *
*************************************************************
TAN$$  MOV  R11,R10
       BL   @SAVRTN           Save return address
       BL   @PUSH             Save FAC on stack
       BL   @SIN$$            Compute SIN
       BL   @XTFAC$
       BL   @COS$$            Compute COS
       BL   @POPSTK           Pop stack into ARG
       CB   @FAC10,@CCBH7     Check for error
       JEQ  PWRTN3            If error
       MOV  @FAC,R0           Is COS = zero?
       JEQ  TAN01             Yes
       BL   @FDIV             No, TAN : = SIN(ARG)/COS(ARG)
PWRTN3 B    @ROLIN2
TAN01  MOVB @ARG,@SIGN
       BL   @OVEXP            Issue overflow message
       JMP  PWRTN3            Clean up and exit
*************************************************************
* INVERSE TANGENT FUCTION                                   *
* FAC            : = ATN(FAC)                               *
* STACK LEVELS USED:                                        *
*     IF FAC <  0 THEN ARCTAN(FAC) = -ARCTAN(-FAC)          *
*     IF 0   <= FAC <= TAN(PI/8)                            *
*                 THEN T = FAC, ARCTAN(FAC) : = ARCTAN(T)   *
*     IF TAN(PI/8) < FAC < TAN(3*PI/8)                      *
*                 THEN T = (FAC-1) / (FAC+1),               *
*                      ARCTAN(FAC) : = PI/4 + ARCTAN(T)     *
*     IF TAN(3*PI/8) <= FAC                                 *
*                 THEN T = -1/FAC,                          *
*                      ARCTAN(FAC) : = PI/2 + ARCTAN(T)     *
*                                                           *
* A polynomial approximation is used for ARCTAN(T),         *
*              -TAN(PI/8) <= T <= TAN(PI/8)                 *
* (HART ARCTN 4967)                                         *
*************************************************************
ATN$$  MOV  R11,R10
       BL   @ROLOUT           Get workspace and save return
       MOVB @FAC,R12          Save sign
       ABS  @FAC              Use ABS(FAC)
       CLR  @Q$               Assume ARG is in range
       BL   @MOVROM           Need TAN(PI/8)
       DATA TANPI8             into ARG
*
       BL   @FCOMPB           Is TAN(3*PI/8) >= ARG?
       JEQ  ATN02             If =
       JGT  ATN02             If >
       BL   @MOVROM           Need TAN(3*PI/8)
       DATA TAN3P8             into ARG
*
       BL   @FCOMPB           Is TAN(3*PI/8) > ARG?
       JGT  ATN01             Yes, use case 2
       BL   @MOVROM           Get a floating 1
       DATA FPOS1              into ARG
*
       NEG  @ARG              Use case 3 to compute
       BL   @FDIV             T = -1/ARG
       LI   R3,PI2            Get PI/2
       JMP  ATN02A            Add it in at the end
ATN01  BL   @FORMA            Case 2 : T : = (ARG-1)/(ARG+1)
       LI   R3,PI4            Get PI/4
ATN02A MOV  R3,@Q$            Set up to evaluate
ATN02  BL   @POLYW            ATN(T) : = T * P(T^^2)
       DATA ATNP              Poly to evlauate
*
       MOV  @Q$,R3            Case 1?
       JEQ  ATNSGN            Yes, don't add anything in
       LI   R0,ARG
       BL   @MOVRM2
       BL   @FADD             Add in the constant
ATNSGN INV  R12               Check sign of result
       JLT  ATNSG3            If sign is already on
       NEG  @FAC               else negate it
ATNSG3 B    @ROLIN            And return
*************************************************************
* GREATEST INTEGER FUNCTION                                 *
*************************************************************
GRINT  MOV  R11,R7            Save return address
       MOVB @FAC,@SIGN        Save result sign
       ABS  @FAC              Absolute value
       MOVB @FAC,R5           Get exponent
       SRL  R5,8              Make it into word
       MOV  R5,@EXP           For rounding
       CI   R5,>40            Exponent < 0?
       JLT  BITINT            Yes, handle it
       CI   R5,>45            Exponent > 10^5 ?
       JGT  INT02             Yes, handle it
       AI   R5,->46           Locate position
       MOVB @R5LB,@FAC10      Save for rounding
       CLR  R2
       LI   R3,FAC8
       A    R5,R3             Point to 1st fractional digit
INT01  SOCB *R3,R2            Remember if non-zero
       MOVB @R2LB,*R3+        Clear the digit
       INC  R5
       JNE  INT01
       MOVB @SIGN,R0          Get the sign
       JGT  INT03             If non-negative(i.e. Positive)
       MOVB R2,R2
       JEQ  INT02
       AB   @CCBH7,@FAC10     Where to round up
       BL   @ROUNU            Do the rounding
       JMP  INT03
INT02  MOVB @SIGN,R0          Check the sign
       JGT  INT03             If positive don't negate
       NEG  @FAC              Make result negative
INT03  CLR  @FAC10            Indicate no error
       B    *R7          <<<< Return from here
BITINT LI   R0,FAC            Zero or -1
       LI   R1,>BFFF          Default to -1
       MOVB @SIGN,R2          Negative or Positive?
       JLT  INT04             If really negative put in -1
       CLR  R1                If Positive put in a 0
INT04  MOV  R1,*R0+           Copy in 0 or -1
       CLR  *R0+               and
       CLR  *R0+                clear
       CLR  *R0                  the
       JMP  INT03                 rest
* MOVE 8 BYTES FROM ROM(R3) TO CPU AT R0
MOVRM5 LI   R0,FAC            Move to FAC
       JMP  MOVRM1            Merge into common code
MOVROM LI   R0,ARG            Move to ARG
MOVRM1 MOV  *R11+,R3          Constant to load
MOVRM2 LI   R2,8              Constants are 8 bytes long
       A    @INTRIN,R3        Add in GROM offset                      <<<<<<<<<<
       MOVB R3,@GRMWAX(R13)    Write MSB of address
       SWPB R3                Bare the LSB
       MOVB R3,@GRMWAX(R13)    Write the LSB
MOVRM4 MOVB *R13,*R0+         Read a byte
       DEC  R2                Moved them all yet?
       JNE  MOVRM4            No, copy the next one
       RT                     Yes, return
* ROLL OUT CPU AREA FOR WORKSPACE
ROLOUT LI   R1,PROA$          Processor roll out area
CVROA$ EQU  $+2
       LI   R3,VROA$          VDP roll out area
       MOVB @R3LB,*R15
       ORI  R3,WRVDP
       MOVB R3,*R15
       LI   R0,26
ROLOT1 MOVB *R1+,@XVDPWD
       DEC  R0
       JNE  ROLOT1
       CLR  @FAC8             And save return address
* SAVE RETURN ADDRESS
SAVRTN INCT @STKADD
       MOVB @STKADD,R9
       SRL  R9,8
       AI   R9,PAD0
       MOV  R10,*R9
       RT
* ROLL IN CPU AREA AFTER WORK IS DONE
ROLIN  LI   R1,PROA$          Processor roll out area
       MOVB @CVROA$+1,*R15    LSB of address
       MOVB @CVROA$,*R15      MSB of address
       LI   R0,26             Number of bytes rolled out
ROLIN1 MOVB @XVDPRD,*R1+
       DEC  R0
       JNE  ROLIN1
       CLR  @FAC8
ROLIN2 MOVB @STKADD,R9
       SRL  R9,8
       AI   R9,PAD0
       MOV  *R9,R11
       DECT @STKADD
       RT
* PUSH FAC ONTO STAK
C8     EQU  $+2
PUSH   LI   R0,8              Number to push
       A    R0,@VSPTR         Bump stack pointer
       MOV  @VSPTR,R1         Get stack poiter
       MOVB @R1LB,*R15
       ORI  R1,WRVDP
       MOVB R1,*R15
       LI   R1,FAC
PUSH1  MOVB *R1+,@XVDPWD
       DEC  R0
       JGT  PUSH1
       RT
* POP VALUE OFF STACK INTO FAC
POP    LI   R2,FAC
       MOVB @VSPTR1,*R15      LSB of address
       LI   R0,8
       MOVB @VSPTR,*R15       MSB of address
       S    R0,@VSPTR
POP1   MOVB @XVDPRD,*R2+
       DEC  R0
       JGT  POP1
       RT
* EXCHANGE TOP OF STACK AND FAC
XTFAC$ MOV  R11,R10           Save return address
       BL   @PUSH             Put FAC on top
       LI   R3,8              Working with 8 byte entries
       MOV  R3,R5             Need another copy for below
       S    R3,@VSPTR         Point back to old top
       BL   @POP              Put it in FAC
       A    R3,@VSPTR         Restore pointer to old top
       MOV  @VSPTR,R4         Place to move to
       A    R4,R3             Place to move from
XTFAC1 BL   @GETV1            Get a byte
       BL   @PUTV1            Put a byte
       INC  R3
       INC  R4
       DEC  R5                Done?
       JNE  XTFAC1            No
       B    *R10              Yes, retrun
* GET BASE 10 EXPONENT OF THE NUMBER IN FAC
* EXP:      Gets the base 10 exponent
* OE$:      0 if exp is even and 1 if exp is odd
TENCNS CLR  R0                Get base 100 exponent
       MOVB @FAC,R0           Put in MSB
       AI   R0,>C000          Remove bias (SUBT >64 from MSB)
       SLA  R0,1              Multiply it by 2
       SRA  R0,8              Sign fill high order byte
       CLR  R3                 and put in LSB
       CB   @FAC1,@CBHA       1st digit of FAC one decimal
*                              digit?
       JLT  CNST10            Yes, base 10 exponent is even
       INC  R0                No, take this into account in
*                              exponent
       INC  R3                This makes base 10 exp odd
CNST10 MOV  R0,@EXP
       MOV  R3,R3             Set condition for return
       RT
*************************************************************
* MISCELLANEOUS CONSTANTS:
* CBH411
* EXC127    BYTE >41,1,27,0,0,0,0,0          127
* FHALF     BYTE >3F,50                      .5
* ZER3      BYTE 0,0,0,0,0,0
* SQRTEN    BYTE >40,3,16,22,77,66,01,69     SQR(10)
* LOG10E    BYTE >3F,43,42,94,48,19,03,25    LOG10(E)
* LN10      BYTE >40,2,30,25,85,09,29,94     LN(10)
* CBH7      EQU  $+3
* PI2       BYTE >40,1,57,7,96,32,67,95      PI/2
* RPI2      BYTE >3F,63,66,19,77,23,67,58    2/PI
* PI4       BYTE >3F,78,53,98,16,33,97,45    PI/4
* CBHA      EQU  $+7
* CBH3F
* TANPI8    BYTE >3F,41,42,13,56,23,73,10    TAN(PI/8)=SQR(2)-1
* TAN3P8    BYTE >40,2,41,42,13,56,23,73     TAN(3*PI/8)=SQR(2)+1
**          SQR POLYNOMIALS  (HART SQRT 0231)
* SQRP      BYTE >3F,58,81,22,90,00,00,00    P02=.58812 29E+00
*           BYTE >3F,52,67,87,50,00,00,00    P01=.52678 75E+00
*           BYTE >3E,58,81,20,00,00,00,00    P00=.58812 E-02
*           DATA SGNBIT
* FLTONE
* FPOS1
* SQRQ      BYTE >40,01,00,00,00,00,00,00    Q01=.1 E+01
*           BYTE >3F,09,99,99,80,00,00,00    Q00=.99999 8 E-01
*           DATA SGNBIT
**          EXPPONENT POLYNOMIALS  (HART EXPD 1444)
**          P02 = .18312 36015 92753 84761 54 E+02
* EXPP      BYTE >40,18,31,23,60,15,92,75
**          P01 = .83140 67212 93711 03487 3446 E+03
*           BYTE >41,08,31,40,67,21,29,37
*           P00 = .51780 91991 51615 35743 91297 E+04
*           BYTE >41,51,78,09,19,91,51,62
*           DATA SGNBIT
**          Q03 = .1 E+01
* EXPQ      BYTE >40,1,0,0,0,0,0,0
**          Q02 = .15937 41523 60306 52437 552 E+03
*           BYTE >41,01,59,37,41,52,36,03
**          Q01 = .27093 16940 85158 99126 11636 E+04
*           BYTE >41,27,09,31,69,40,85,16
**          Q00 = .44976 33557 40578 41762 54723 E+04
*           BYTE >41,44,97,63,35,57,40,58
*           DATA SGNBIT
**          LOG POLYNOMIALS  (HART LOGE 2687)
**          P04 = .35670 51030 88437 69 E+00
* LOGP      BYTE >3F,35,67,05,10,30,88,44
**          P03 = -.11983 03331 36876 1464 E+02
*           BYTE >BF,>F5,98,30,33,31,36,88
**          P02 = .63775 48228 86166 05782 E+02
*           BYTE >40,63,77,54,82,28,86,17
**          P01 = -.10883 71223 55838 3228 E+03
*           BYTE >BE,>FF,08,83,71,22,35,58
**          P00 = .57947 38138 44442 78265 7 E+02
*           BYTE >40,57,94,73,81,38,44,44
*           DATA SGNBIT
* LOGQ
**          Q04 = .1 E+01
*           BYTE >40,01,0,0,0,0,0,0
**          Q03 = -.13132 59772 88464 0339 E+02
*           BYTE >BF,>F3,13,25,97,72,88,46
**          Q02 = .47451 82236 02606 00365 E+02
*           BYTE >40,47,45,18,22,36,02,61
**          Q01 = -.64076 45807 52556 00596 E+02
*           BYTE >BF,>C0,07,64,58,07,52,56
**          Q00 = .28973 69069 22217 71601 9 E+02
*           BYTE >40,28,97,36,90,69,22,22
*           DATA SGNBIT
**          SIN POLYNOMIAL  (HART SIN 3344)
* SINP
**          REFLECTS CHANGE IN 99/4 CONSTANT TO CORRECT VALUES
**          OF SIN AND COS >1
**          P07 = -.64462 13674 9 E-09
**          BYTE >C4,>FA,44,62,13,67,49,00
**          P07 = -.64473 16000 0 E-09
*           BYTE >C4,>FA,44,73,16,00,00,00
**          P06 = .56882 03332 688 E-07
* CBH44     EQU  $+2
*           BYTE >3C,05,68,82,03,33,26,88
**          P05 = -.35988 09117 03133 E-05
*           BYTE >C2,>FD,59,88,09,11,70,31
**          P04 = .16044 11684 69828 31 E-03
*           BYTE >3E,01,60,44,11,68,46,98
**          P03 = -.46817 54131 06023 168 E-02
*           BYTE >C1,>D2,81,75,41,31,06,02
**          P02 = .79692 62624 56180 0806 E-01
*           BYTE >3F,07,96,92,62,62,45,62
**          P01 = -.64596 40975 06219 07082 E+00
*           BYTE >C0,>C0,59,64,09,75,06,22
**          P00 = .15707 96323 79489 63959 E+01
*           BYTE >40,01,57,07,96,32,67,95
*           DATA SGNBIT
**          ATN POLYNOMIAL  (HART ARCTN 4967)
* ATNP
**          P09 = -.25357 18798 82 E-01
*           BYTE >C0,>FE,53,57,18,79,88,20
**          P08 = .50279 13843 885 E-01
*           BYTE >3F,05,02,79,13,84,38,85
**          P07 = -.65069 99940 1396 E-01
*           BYTE >C0,>FA,50,69,99,94,01,40
**          P06 = .76737 12439 1641 E-01
*           BYTE >3F,07,67,37,12,43,91,64
**          P05 = -.90895 47919 67196 E-01
*           BYTE >C0,>F7,08,95,47,91,96,72
**          P04 = .11111 04992 50526 62 E+00
*           BYTE >3F,11,11,10,49,92,50,53
**          P03 = -.14285 71269 75961 157 E+00
*           BYTE >C0,>F2,28,57,12,69,75,96
**          P02 = .19999 99997 89961 5228 E+00
*           BYTE >3F,19,99,99,99,97,89,96
**          P01 = -.33333 33333 32253 4275 E+00
*           BYTE >C0,>DF,33,33,33,33,32,25
**          P00 = .99999 99999 99999 08253 E+00
*           BYTE >40,01,0,0,0,0,0,0
*           DATA SGNBIT
********************************************************************************
 
