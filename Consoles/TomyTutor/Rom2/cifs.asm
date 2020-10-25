********************************************************************************
       AORG >9C2C                                                         *TOMY*
       TITL 'CIFS'
 
*************************************************************
* CIF     - Convert integer to floating                     *
*           Assume that the value in the FAC is an integer  *
*            and converts it into an 8 byte floating point  *
*            value                                          *
*************************************************************
CIF    LI   R4,FAC            Will convert into the FAC
       MOV  *R4,R0            Get integer into register
       MOV  R4,R6             Copy pointer to FAC to clear it
       CLR  *R6+              Clear FAC & FAC+1
       CLR  *R6+              In case had a string in FAC
       MOV  R0,R5             Is integer equal to zero?
       JEQ  CIFRT             Yes, zero result and return
       ABS  R0                Get ABS value of ARG
       LI   R3,>40            Get exponent bias
       CLR  *R6+              Clear words in result that
       CLR  *R6                might not get a value
       CI   R0,100            Is integer less than 100?
       JL   CIF02             Yes, just put in 1st fraction
*                              part
       CI   R0,10000          No, is ARG less then 100^2?
       JL   CIF01             Yes, just 1 division necessary
*                             No, 2 divisions are necessary
       INC  R3                Add 1 to exponent for 1st
       MOV  R0,R1             Put # in low order word for the
*                              divide
       CLR  R0                Clear high order word for the
*                              divide
       DIV  @C100,R0          Divide by the radix
       MOVB @R1LB,@3(R4)  ~@  Move the radix digit in
CIF01  INC  R3                Add 1 to exponent for divide
       MOV  R0,R1             Put in low order for divide
       CLR  R0                Clear high order for divide
       DIV  @C100,R0          Divide by the radix
       MOVB @R1LB,@2(R4)  ~@  Put next radix digit in
CIF02  MOVB @R0LB,@1(R4)  ~@  Put highest order radix digit in
       MOVB @R3LB,*R4         Put exponent in
       INV  R5                Is result positive?
       JLT  CIFRT             Yes, sign is correct
       NEG  *R4               No, make it negative
CIFRT  RT
********************************************************************************
 
