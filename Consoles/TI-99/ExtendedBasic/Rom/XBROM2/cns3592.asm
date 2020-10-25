********************************************************************************
 
       TITL 'CNS3592'
 
* PUT EXPONENT INTO THE BUFFER
* CALL        R6     Text pointer into buffer
*             R13    Exponent
*   BL      CNSEXP
*             R6     Updated to point after exponent
* DESTORYS:   R0,R13
*
CNSEXP INCT R9                Save return address
       MOV  R11,*R9+
       MOV  R12,*R9           Save contents of registers
       MOVB @LBE,*R6+         Put an "E" into the buffer
       LI   R0,'-'*256        Assume the exponent is negative
       ABS  R13               Is exponent negative?
       JLT  CNSE01            Yes, sign is correct
       LI   R0,'+'*256        No, get sign for positive exp
CNSE01 MOVB R0,*R6+           Put the exponent's sign into
*                              buffer
       CI   R13,100           Is the exponent to big?
       JLT  CNSE02            No, convert it to ASCII
       MOV  @WSM,R0           Is free format output?
       JEQ  CNSE04            Yes, get the asterisk
       CZC  @LWCNF,R0         No, is extended exp specified?
       JNE  CNSE02            Yes, convert it to ASCII
CNSE04 LI   R0,'*'*256        No, get an asterisk
       MOVB R0,*R6+           Put two asterisks in the buffer
*                              for the exponent
       MOVB R0,*R6+           Because it is too big
       JMP  CNSE03            Go finish up
CNSE02 BL   @CNSINT           Convert the exp to ASCII digit
       AI   R6,-5             Point back to start of exp
       MOV  @WSM,R0           Is free format output?
       JEQ  CNSE05            Yes
       CZC  @LWCNF,R0         No, is extended exp specified?
       JEQ  CNSE05            No
       MOVB @2(R6),*R6+       Yes, move 3(instead of 2)
*                              significant
       MOVB @2(R6),*R6+        digits of exponent up pass the
       MOVB @2(R6),*R6+        leading zeros from CNSINT
       JMP  CNSE03
CNSE05 MOVB @3(R6),*R6+       Move significant digits of
*                              exponent up pass the leading
*                              zeros from
       MOVB @3(R6),*R6+        CNSINT
CNSE03 MOVB @LW10,*R6         Put a zero byte at the end of
*                              the number
       MOV  *R9,R12           Restore original contents of
*                              R12
       DECT R9
       JMP  CNSD05            POP address and return
* CONVERT AN UNSIGNED INTEGER INTO A STRING OF 5 ASCII DIGITS
* CALL        R6     Text pointer
*             R13    Integer
*   BL      CNSINT
*             R6     Updated to point after number
* DESTROYS:   R0,R12,R13
CNSINT LI   R0,CNSITT         Get pointer to integer power of
*                              ten table
CNSI01 CLR  R12               Clear high word of integer for
*                              divide
       DIV  *R0+,R12          Divide by next power of ten
       AI   R12,'0'           Convert quotient to ASCII
       MOVB @R12LB,*R6+       Put next digit into the buffer
       CI   R0,CNSITT+10      Divided by all the powers of ten?
       JL   CNSI01            No, compute the next digit of
*                              the NO.
       MOVB R12,*R6           Yes, put a zero byte at the
*                              end of the number
       RT
* PUT SOME ZEROS IN THE BUFFER AND MAYBE A DECIMAL POINT
* CALL        R0     Number of zeros+1
*             R6     Text pinter into buffer
*   BL     CNSPER :  To put in a decimal point before zeros
*   BL     CNSZER :  Updated to point after the zeros
* DESTROYS:   R0
CNSPER MOVB @LBPER,*R6+       Put a decimal point in the buffer
       JMP  CNSZER            Then some zeros
CNSZ01 MOVB @LBZER,*R6+       Put a zero in the buffer
CNSZER DEC  R0                Are there more zeros to put in?
       JGT  CNSZ01            Yes, go put in another zero
       MOVB R0,*R6            No, put a null byte after the
*                              zeros
       RT
* SUPPRESS LEADING ZEROS AND FLOAT THE SIGN
* CALL
*   JMP    CNSMLS : Entry to finish up after zero suppressing
*   BL     CNSLEA : Entry to return afterwards
*            R1     ASCII sign in high byte
*            R6     Pointer to start of number
* DESTROYS:  R0-R1
CNSMLS LI   R11,CNSSTR        Entry to finish up number
*                              afterward
CNSLEA LI   R6,FAC15          Get pointer to sign
       MOVB *R6,R1            Get sign
CNSL01 MOVB @LBSPC,*R6+       Put a space where the zero
*                              or sign was
       CB   *R6,@LBZER        Is the next byte zero?
       JEQ  CNSL01            Yes, suppress it
       MOVB *R6,R0            No, is this the end of
*                              the number?
       JEQ  CNSL02            Yes, put the zero back in,
*                              NO. is 0
       CB   R0,@LBE           No, is this the start of
*                              the exponent?
       JEQ  CNSL02            Yes, put the zero back in,
*                              NO. is 0
       CB   R0,@LBPER         No, is this the decimal point?
       JNE  CNSL03            No, put the sign back in
       MOV  @WSM,R0           Yes, is free format output?
       JNE  CNSL03            No, then put the sign
*                              back in fix fomat output
       MOVB @1(R6),R0         Yes, any digits to right of DP?
       JEQ  CNSL02            No, put the sign back
       CB   R0,@LBE           Does exponent start after DP?
       JNE  CNSL03            No, put the sign back
CNSL02 DEC  R6                Yes, point back to where the
*                              zero was
       MOVB @LBZER,*R6        Put the zero back in, the NO.
*                              is 0
CNSL03 DEC  R6                Point back to where the sign
*                              will go
       MOVB R1,*R6            Put the sign back in the buffer
       RT
* REMOVE TRAILING ZEROS
* CALL      R3      0
*           R6      Pointer to one past end of number
*           R12     Pointer to decimal point
*           R10     Zero if an integer is being printed
*   BL   CNSUTR
*           R6      Pointer to new end of number
* DESTROYS: NONE
CNSU01 DEC  R6                Point back to next digit in
*                              the NO.
CNSUTR CB   @-1(R6),@LBZER    Is the last digit in the NO. 0?
       JEQ  CNSU01            Yes, look back for a non-zero
*                              digit
       MOV  R10,R10           No, is an integer being printed?
       JNE  CNSU02            No, put a null at the end of
*                              the NO.
       MOV  R12,R6            Yes, end of number is where DP
*                              is all digits after the
*                              decimal point should be zero
CNSU02 MOVB R3,*R6            Put a zero byte at the end of
*                              the number
       RT
* SET UP A POINTER TO THE BEGINNING OF A FIXED FORMAT FIELD
* AND SEE IF THE FIELD IS LARGE ENOUGH AND FINISH UP
* CALL      R12     Pointer to decimal point or where it
*                    would go
*   JMP   CNSCHK
*           R6      Pointer to beginning of number
* DESTROYS: R0,R1
CNSCHK BL   @CNSLEA           Suppress leading zeros and fix
*                              up the sign
       MOV  R12,R6            Point to decimal point
       S    @WSM2,R6          Point to where the beginning of
*                              the field is
       CB   @-1(R6),@LBSPC    Does number extend before the
*                              field beginning?
       JNE  CNSAST            Yes, error
       MOV  @WSM,R0           No, get R0 format specification
       CZC  @LWCNS,R0         Is an explicit sign required?
       JEQ  CNSSTR            No, finish up and return
       CB   *R6,@LBSPC        Yes, is first character of
*                              number a space?
       JEQ  CNSSTR            Yes, finish up and return
       CB   *R6,R1            No, is first character of
*                              number the sign?
       JEQ  CNSSTR            Yes, finish up and return
*                             No, error
* ASTRISK FILL A FIXED FORMAT FIELD AND FINISH UP
* CALL
*   JMP   CNSAST
*           R6        Pointer to the beginning of the string
* DESTROYS: R0,R1
CNSAST LI   R6,WSM            Optimize for speed and space
       MOV  *R6+,R0           Get R0 format spacification
       MOV  *R6+,R1           Get left of decimal point size
       A    *R6+,R1           Compute length of field
       CZC  @LWCNE,R0         Is E-format being used?
       JEQ  CNSA01            No, field length is correct
       C    *R1+,*R1+         Yes, increase field length for
*                              the exponent (Increments R1
*                              by 4)
       CZC  @LWCNF,R0         Is extended E-format being used?
       JEQ  CNSA01            No, field length is correct
       INC  R1                Yes, increase field length for
*                              the exponent (Increments R1
*                              by 1)
CNSA01 LI   R6,FAC15          Get pointer to beginning of buffer
       MOV  R6,R0             Get a pointer to put asterisks
*                              in the buffer
CNSA02 MOVB @LBAST,*R0+       Put an asterisk into the buffer
       DEC  R1                Is the field filled yet?
       JGT  CNSA02            No, continue asterisk filling it
       MOVB R1,*R0            Yes, put a zero byte at the end
*                              of string
*                             Finish up and return
* FINSH UP -- COMPUTE THE LENGTH OF THE STRING AND RETURN
* CALL       R6    Pointer to first character in the string,
*                   the string ends with a zero byte
* DESTROYS:  R0-R1
CNSSTR MOV  R6,R0             Get pointer to beginning of the
*                              string
CNSS01 MOVB *R0+,R1           Look for end of string,
*                              found it?
       JNE  CNSS01            No, keep looking
       DEC  R0                Yes, point to back to the
*                              zero byte
       S    R6,R0             Compute length of string
       MOVB @R0LB,@FAC12      Put length of string in FAC12
       LI   R0,PAD0
       S    R0,R6             Put beginning of string
*                              in FAC11
       MOVB @R6LB,@FAC11
       MOV  *R9,R13           Restore GROM address
       DECT R9                Off the stack
       B    @ROLIN            In ROLIN return
********************************************************************************
 
