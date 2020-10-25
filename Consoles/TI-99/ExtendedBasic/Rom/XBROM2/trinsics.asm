********************************************************************************
       AORG >748E
       TITL 'TRINSICS'
 
CBH411 DATA >4101
 
CBH3F  BYTE >3F
CBH44  BYTE >44
       EVEN
*
* VROA$  EQU >03C0            VDP roll out area
* FPSIGN EQU >03DC
* PROA$  EQU PAD0+>10         Processor roll out area
* P$     EQU PAD0+>12
* Q$     EQU PAD0+>16
* C$     EQU PAD0+>1A
* SGN$   EQU PAD0+>75
* EXP$   EQU PAD0+>76
* OE$    EQU PAD0+>14
EXC127 EQU  >00
FHALF  EQU  >08
SQRTEN EQU  >10
LOG10E EQU  >18
LN10   EQU  >20
PI2    EQU  >28
RPI2   EQU  >30
PI4    EQU  >38
TANPI8 EQU  >40
TAN3P8 EQU  >48
SQRP   EQU  >50
SQRQ   EQU  >6A
FPOS1  EQU  >6A
EXPP   EQU  >7C
EXPQ   EQU  >96
LOGP   EQU  >B8
LOGQ   EQU  >E2
SINP   EQU  >010C
ATNP   EQU  >014E
 
*************************************************************
* INVOLUTION                                                *
* FAC           - exponent                                  *
* Top of stack  - Base                                      *
* If integer Base and integer exponent do multiplies to     *
* keep result exact, otherwise, use logarithm to calculate  *
* value.                                                    *
*************************************************************
PWR$$  MOV  R11,R10
       BL   @SAVRTN           Save return
       BL   @POPSTK           Get Base into ARG
       MOV  @FAC,R0           If exponent=0
       JEQ  PWRG01            Then result = 1
       MOV  @ARG,R0           If Base=0
       JEQ  PWRG02            Then return 0 or warning
       A    @C8,@VSPTR        Use Base on stack
       BL   @PUSH             Check to see if E is floating
*                              integer
       BL   @GRINT            Convert 1 copy of exp to int
       MOVB @C8,@SIGN         Assume sign is positive
       BL   @XTFAC$           FAC=ARG     STACK=INT(ARG)
       BL   @SCOMPB           Integer exponent?
       JNE  PWR$$3            No, try floating code
* COMPUTE INTEGER POWER B^E
       BL   @PUSH             Put Exp above Base on stack
       MOVB @C8,@FAC10        Assume no error
       BL   @CFI              Try to convert E to integer
CCBH7  ABS  @FAC              Absolute value of exponent
       MOV  @FAC,R12          Save integer exponent
       BL   @POP              Return E to FAC; B on stack
       MOVB @FAC10,R0         If E>32767
       JNE  PWR$$1            Return to floating point code
       BL   @XTFAC$           Get Base in accumulator
       BL   @PUSH             Put E on stack for later sign
*                              check
       DEC  R12               Reduce exponent by one since
*                              accumulator starts with Base
       JEQ  PWRJ40            If 0 then done already
PWRJ30 SRL  R12,1             Check l.s. bit
       JNC  PWRJ10            If 0, skip the work
       BL   @SMULT            Multiply in this power
       A    @C8,@VSPTR        Restore stack
PWRJ10 MOV  R12,R12           Finished?
       JEQ  PWRJ40            Yes
       BL   @XTFAC$           No, exchange: B in FAC,
*                              accumulator on stack
       BL   @PUSH             Copy B onto stack
       BL   @SMULT            Square it for new B
       BL   @XTFAC$           Restore order: B on stack
*                              accumulator in FAC
       JMP  PWRJ30            Loop for next bit
PWRJ40 S    @C16,@VSPTR       Done, clean up
       MOV  @VSPTR,R3         Get stack pointer
       AI   R3,8              Test exponent sign now
       BL   @GETV1            Get it
       JLT  PWRJ41            If negative, compute negative
PWRRTN B    @ROLIN2           Use commone code to return
PWRJ41 MOVB @FAC10,R0         If overflow has occured
       JNE  PWRJ45            Go make it zero
       BL   @MOVROM           Get a floating point one
       DATA FPOS1              into ARG
*
       BL   @FDIV             Compute the inverse
       JMP  PWRRTN            And return
PWRJ45 CLR  @FAC              If overflow, the result=0
       MOVB @FAC,@FAC10       Indicate no error
       JMP  PWRRTN            And return
PWRG02 MOVB @FAC,R0           Is Exp negative?
       JLT  PWRG05            Yes, divide by 0 =>put in overflow
       JMP  PWRJ45            No, result is zero and return
PWRG01 LI   R0,FAC            Need to put floating 1 in FAC
       BL   @MOVRM1           Get the floating 1
       DATA FPOS1              into FAC
*
       JMP  PWRRTN            And return
PWR$$3 BL   @GETV             Check for negative
       DATA VSPTR             On the stack
*
       JGT  PWR$$2            If ok
       MOVB @ERRNIP,@FAC10    Else error code
       S    @C8,@VSPTR        Throw away entry on stack
       JMP  PWRRTN            And return
* INTEGER EXPONENT OUT OF INTEGER RANGE
PWR$$1 BL   @GETV             Positive or negative Base?
       DATA VSPTR
*
       JGT  PWR$$2            Positive Base
* NEGATIVE BASE - So see if exponent is even or odd to set
*                  the sign of the result
PWR$$4 CLR  R1                For double
       MOVB @FAC,R1           Get exponent
       ABS  R1                Work with positive
       CI   R1,>4600          Too big to have one's byte?
       JGT  PWR$$2            Yes, assume number is even
       SWPB R1                Get in low order byte
       AI   R1,>830B          No, get one's radix digit
*                              location in FAC
       MOVB *R1,R1            Get the digit
       SLA  R1,7              If last bit set, set top bit
PWR$$2 LI   R4,FPSIGN         Save sign of result
       BL   @PUTV1             in a permanent place
       BL   @XTFAC$           Base in FAC; Exponent on stack
       ABS  @FAC              Must work with positive
       BL   @LOG$$            Compute LOG(B) in FAC
       BL   @SMULT            Compute E*LOG(B) in FAC
       BL   @EXP$$            Let exp give error on warning
       LI   R3,FPSIGN         Check sign of result
       BL   @GETV1
       JLT  PWR$$5            If E is negative
       JMP  PWRRTN            If E is positive
ERRNIP EQU  $
PWR$$5 NEG  @FAC              Make it negative
       JMP  PWRRTN
PWRG05 BL   @OVEXP            Return overflow
       JMP  PWRRTN            And return
*************************************************************
* EXPONENTIAL FUNCTION                                      *
* FAC   =   EXP(FAC)                                        *
* CALL      BL   @EXP$$                                     *
* WARNING:  WRNOV             Overflow                      *
* STACK LEVELS USED:                                        *
*      X : = FAC * LOG10(E)                                 *
*      So EXP(FAC) = 10^X                                   *
*      Make sure X is in range LOG100(X) = LOG10(X)/2       *
*      N : = INT(X)                                         *
*      R : = X-N, 0 <= R < 1                                *
*      IF R < .5 THEN R : = R                               *
*                ELSE S : = R-5                             *
* A rational function approximation is used for 10^S        *
* (HART EXPD 1444)                                          *
* EXP : = IF R .LT. .5 THEN 10^N * 10^S                     *
*                      ELSE 10^N * 10^.5 * 10^S             *
*************************************************************
EXP$$  MOV  R11,R10
       BL   @ROLOUT           Get workspace and save return
       BL   @MOVROM           Get LOG10(E)
       DATA LOG10E               into ARG
*
       BL   @FMULT            X : = FAC * LOG10(E)
       BL   @PUSH             Save X
       BL   @GRINT            Compute N : = INT(X)
       BL   @MOVROM           Get floating 127
       DATA EXC127              into ARG
*
       BL   @FCOMPB           Is N > 127?
       JEQ  EXP03             If = 127
       JLT  EXP01             If > 127
       NEG  @ARG              Check negative range
       BL   @FCOMPB           Is N < -127?
       JLT  EXP03             N > -127
       JEQ  EXP03             N = -127
* N is out of range
EXP01  S    @C8,@VSPTR        Pop X off stack
       MOV  @FAC,@EXP         Recall exponent sign
       MOVB @C8,@SIGN         Result is positive
       BL   @OVEXP            Take over or underflow action
       JMP  BROLIN            Restore CPU RAM and return
EXP03  BL   @PUSH             Save value on stack
       BL   @CFI              Convert to integer exponent
       MOV  @FAC,R12          Get it in REG to mpy by 2
       SLA  R12,1             Compute 2*N
       BL   @POP              Restore value
       BL   @SSUB             Compute R = X - N
       BL   @MOVROM           Get a floating .5
       DATA FHALF              into ARG
*
       BL   @FCOMPB           Is .5 > R?
       JGT  EXP04             Yes, S=R
       NEG  @ARG              -.5
       BL   @FADD             Compute S : = R - .5
       INC  R12               Remember R >= .5, (2*N+1)
*                              save a copy of S
EXP04  BL   @PUSH             Save a copy of S
       BL   @POLYW            Compute S * P(S^2)
       DATA EXPP              Poly to evaluate
*
       BL   @XTFAC$           FAC = S, stack = S * P(S^2)
       BL   @POLYX            Compute Q(S^2)
       DATA EXPQ              Poly to evaluate
*
       BL   @POPSTK           S * P(S^2) -> ARG
       A    @C8,@VSPTR
       BL   @PUSH             Save comp of Q(S^2)
       BL   @FADD             Q(S^2) + S * P(S^2)
       LI   R3,FAC            Save FAC in a temp
       LI   R4,C$
       MOV  *R3+,*R4+         1st two bytes
       MOV  *R3+,*R4+         2nd two bytes
       MOV  *R3+,*R4+         3rd two bytes
       MOV  *R3,*R4           Last two bytes
       BL   @POP              FAC = Q(S^S), stack = S*P(S^2)
       BL   @XTFAC$           Revese same
       BL   @SSUB             Compte Q(S^2)-S*P*(S^2)
       LI   R3,C$             Get fac back from temp
       LI   R4,ARG
       MOV  *R3+,*R4+         1st two bytes
       MOV  *R3+,*R4+         2nd two bytes
       MOV  *R3+,*R4+         3rd two bytes
       MOV  *R3,*R4           Last rwo bytes
       BL   @FDIV             Compute Q-P/Q-P
EXPSQT SRA  R12,1             Check flag that was set above
       JNC  EXPSQ5            If not set
       BL   @MOVROM           Get SQR(10)
       DATA SQRTEN             into ARG
*
       BL   @FMULT            Multipy by SQU(10) if N odd
EXPSQ5 BL   @MOVROM           Need a floating 1
       DATA FPOS1              into ARG
*
       SRA  R12,1             Check odd power of ten
       JNC  EXPSQ8            If not odd power
       MOVB @CBHA,@ARG1       Odd power of ten (>0A)
EXPSQ8 AB   @R12LB,@ARG       Add in power of 100 to Exp
       BL   @FMULT
BROLIN B    @ROLIN
*************************************************************
* LOGARITHM FUNCTION                                        *
* FAC       : = LOG(FAC)                                    *
* ERRORS    : ERRLOG     LOG of negative number or zero     *
*                         attempted.                        *
* STACK LEVELS USED:                                        *
*    IF FAC <= 0 THEN ERRLOG                                *
*    LOG(FAC)=LN(FAC)=LOG10(FAC)*LN(10)                     *
*    FAC      : = A * 10^N,     .1 <= A < 1                 *
*    S        : = A * SQR(10),  1/SQR(10) <= S < SQR(10)    *
*    LOG10(A) : = LOG10(S/SQR(10))                          *
*             : = LOG10(S) - LOG10(SQR(10))                 *
*             : = LOG10(S) - .5                             *
*    LOG      : = (N - .5 + LOG10(S)) * LN(10)              *
*             : = (N - .5 * LN(10) + LN(S)                  *
* A rational function approximation is used for LN(S)       *
* (HART LOGE 2687)                                          *
*************************************************************
LOG$$  MOV  R11,R10
       BL   @ROLOUT           Get workspace and save return
       MOV  @FAC,R0           Check for negative or zero
       JGT  LOG$$3            If positive
       MOVB @ERRLOG,@FAC10    Load error code
       JMP  BROLIN            Restore CPU and return
ERRLOG EQU  $
LOG$$3 BL   @TENCNS           Get base 10 exponent
       JNE  LOG$$5
       BL   @MOVROM           Get a floating 1
       DATA FPOS1              into ARG
*                         Make it a floating 10
       MOVB @CBHA,@ARG1        by putting in >0A
       BL   @FMULT            Multipy FAC by 10
       BL   @TENCNS           Get new exponent of 10
       JMP  LOG$5A            Compensate for Mult
LOG$$5 INC  @EXP              Compenstat for where radix
*                              point is
LOG$5A MOVB @CBH3F,@FAC       Put A in proper range
*                              by putting in >3F
       MOV  @EXP,R12
       BL   @MOVROM           Get SQR(10)
       DATA SQRTEN             into ARG
*
       BL   @FMULT            S : = A * SQR(10)
       BL   @FORMA            Z : = (S-1) / (S+1)
       BL   @PUSH             Push Z
       BL   @POLYW            Compute Z * P(Z^2)
       DATA LOGP
*
       BL   @XTFAC$
       BL   @POLYX            Compute Q(Z^2)
       DATA LOGQ              Poly to evaluate
*
       BL   @SDIV             Compute Z*P(Z^2)/Q(Z^2)
       BL   @PUSH             Push it
       LI   R0,ARG            Build entry in ARG
       MOV  R12,*R0+          Put in exponent
       CLR  *R0+               and
       CLR  *R0+                clear the
       CLR  *R0                        rest
* STATUS WAS SET BY THE MOVE ABOVE
       JEQ  LOG$$7            If zero exponent
       ABS  @ARG              Work with ABS value
       MOV  @ARG,R0             in register
       CI   R0,99             Too large?
       JGT  LOG$$9            Yes
       MOVB @FLTONE,@ARG      Exponent = >40
LOG$$6 MOVB R12,R12           Exponent positive?
       JEQ  LOG$$7            Yes
       NEG  @ARG              No, make it negative
LOG$$7 BL   @MOVRM5           Need a floating .5
       DATA FHALF              in FAC
*
       BL   @FSUB             Compute N - .5
       BL   @MOVROM           Need LN(10)
       DATA LN10               into ARG
*
       BL   @FMULT            Compute (N - .5) * LN(10)
       BL   @SADD             Add to LN(S)
       JMP  BROLIN            Restore CPU and return
LOG$$9 S    @C100,@ARG        Subtract first 100
       MOVB @ARG1,@ARG2
       MOV  @CBH411,@ARG      Load exponent and
*                              leading digit of >4101
       JMP  LOG$$6
*************************************************************
* EVALUATE X * P(X^^2)                                      *
* ON CALL  : P$          Pointer to polynomial coefficients *
*          : FAC         Contains X                         *
*      BL    @POLYW                                         *
*          : FAC         Returns  X * P(X^^2)               *
*************************************************************
POLYW  MOV  *R11+,@P$         Get the poly to evaluate
       MOV  R11,R10
       BL   @SAVRTN           Save return address
       BL   @PUSH             Push the argument
       BL   @POLYX1           Compute P(X^^2)
       BL   @SMULT            Compute X*P(X^^2)
       JMP  PWRTN2            And return
POLY   MOV  *R11+,@P$
       MOV  R11,R10
       BL   @SAVRTN           Save return address
       JMP  POLY01            And merge in below
POLYX  MOV  *R11+,@P$
POLYX1 MOV  R11,R10
       BL   @SAVRTN           Save return address
       BL   @PUSH             Need to copy FAC
*                              into ARG to square it
       BL   @SMULT            Square X (SMULT pops into ARG)
POLY01 BL   @PUSH             Push the argument
       MOV  @P$,R3            Get the poly to evaluate
       LI   R0,FAC             into FAC
       BL   @MOVRM2
       JMP  POLY03
POLY02 BL   @POPSTK           Get X back
       A    @C8,@VSPTR        Keep it on stack
       BL   @FMULT            Multiply previous result by X
       MOV  @P$,R3
       LI   R0,ARG            Get polynomial to evaluate
       BL   @MOVRM2            into ARG
       BL   @FADD             Add in this coefficient
POLY03 A    @C8,@P$           Point to next coefficient
*                              and get first two bytes
*                               into ARG
       CB   *R13,@CBH80       Read first byte
*                              and test it to see if done
       JNE  POLY02            No, continue computing poly
       S    @C8,@VSPTR        Pop X off stack
       JMP  PWRTN2            Return with poly in FAC
*
FORMA  MOV  R11,R10
       BL   @SAVRTN           Save return address
       BL   @PUSH             Save X on stack
       BL   @FORMA2
       BL   @FORMA2
       BL   @XTFAC$           Swap (X-1) and X
       BL   @MOVROM           Get a floating 1
       DATA FPOS1              into ARG
*
       BL   @FADD             X+1
       BL   @SDIV             (X-1)/(X+1)
       JMP  PWRTN2            And return
FORMA2 MOV  R11,R10
       BL   @SAVRTN           Save return address
       BL   @MOVROM           Get a floating .5
       DATA FHALF              int ARG
*
       NEG  @ARG
       BL   @FADD             X - .5
PWRTN2 B    @ROLIN2
*************************************************************
* SQUARE ROOT FUNCTION                                      *
* Reference for scientific function approximations.         *
* JOHN F. HART ET AL, Comper approximations,                *
*  JOHN WILEY & SONS, 1968                                  *
* FAC    : = SQR(FAC)                                       *
* ERRORS :   ERRSQR      Square root of negative number     *
*                         attempted                         *
* STACK LEVELS USED:                                        *
*     IF FAC = 0 THEN SQR : = 0                             *
*     IF FAC < 0 THEN ERRSQR                                *
*     FAC : = A * 100^N,        .01 <= A < 1                *
*     SQR : = 10^N * SQR(A)                                 *
* Newton's method with a fixed number of iterations is used *
* to approximate SQR(A):                                    *
* A rational function approximation is used for Y(0)        *
*      (HART SQRT 0231)                                     *
* Y(N+1) = (Y(n))/2                                         *
*************************************************************
SQR$$  MOV  R11,R10
       BL   @ROLOUT           Get workspace and save return
       MOV  @FAC,R12          Check exponent
       JEQ  SQR03             FAC is zero, return zero
       JLT  SQR02             FAC is < 0, error
       MOVB @CBH3F,@FAC       Create A in range .01 <= A <1
*                              by loading >3F
       AI   R12,>C100         Remove bias (-63)
       SRA  R12,8             Sign extend
       SLA  R12,1             Save 2 * N
       BL   @PUSH             Save A
       BL   @PUSH             Save A again
       BL   @POLY             Compute P(A)
       DATA SQRP              Poly to evaluate
*
       BL   @XTFAC$           Stack : = P(A), FAC : = A
       BL   @POLY             Compute Q(A)
       DATA SQRQ              Poly to evaluate
*
       BL   @SDIV             Compute P(A)/Q(A)
       MOV  @CC3,@P$          Save in permanent
SQR01  BL   @POPSTK           Pop into ARG
       A    @C8,@VSPTR        But keep it on stack
       BL   @PUSH             Push Y(N)
       BL   @FDIV             Compute A/Y(N)
       BL   @SADD             Compute A/Y(N) + Y(N)
       BL   @MOVROM           Nead a floating .5
       DATA FHALF              into ARG
*
       BL   @FMULT            Compute .5 * (A/Y(N) + Y(N))
       DEC  @P$               Decrement loop counter
       JNE  SQR01             Loop three times
       S    @C8,@VSPTR        Pop off stack
       B    @EXPSQT           To finish up
SQR02  MOVB @ERRSQR,@FAC10    Load error code for return
ERRSQR EQU  $
SQR03  B    @ROLIN            Restore CPU RAM and return
*************************************************************
* COSINE FUNCTION                                           *
* FAC         : = COS(FAC)                                  *
* COS(FAC)    : = SIN(FAC + PI/2)                           *
*************************************************************
COS$$  MOV  R11,R12
       BL   @MOVROM           Need to get PI/2
       DATA PI2                into ARG
*
       BL   @FADD             Compute FAC + PI/2
       MOV  R12,R11           And fall into SIN code
********************************************************************************
 
