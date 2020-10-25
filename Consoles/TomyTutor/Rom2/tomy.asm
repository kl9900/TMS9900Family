********************************************************************************
       TITL 'TOMY'                                                        *TOMY*

       AORG >A57C
JPTOM1 MOV  @ARG,R1
BLTOM1 MOVB R1,@>E810
       SETO R14
TLAB16 MOVB @>E820,R1
       SLA  R1,8
       JOC  TLAB15
       LI   R1,>000A
TLAB14 DEC  R1
       JNE  TLAB14
       DEC  R14
       JNE  TLAB16
       SB   @>F071,@>F071
       MOV  @>027A,R13
       B    @NEXT
TLAB15 SETO R1
       MOVB R1,@>E840
       LI   R1,>0005
TLAB17 DEC  R1
       JNE  TLAB17
       MOVB R1,@>E840
       LI   R1,>0032
TLAB18 DEC  R1
       JNE  TLAB18
       RT
       
       AORG >B910
SETT   SOCB @BIT2,@STATUS

********************************************************************************
 
