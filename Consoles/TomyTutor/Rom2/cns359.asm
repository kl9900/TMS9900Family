********************************************************************************
       AORG >A7E4                                                         *TOMY*
       TITL 'CNS359'
 
*
*      CONVERT THE NUMBER IN THE FAC TO A STRING
* CALL  : FAC NUMBER
*         R0  0 for free format(R1 & R2 are ignored)
*             Bit 0 on for fixed format
*             Bit 1 on for an explicit sign
*             Bit 2 on to output the sign of a positive
*             NO. as a plus sign ('+') instead of a space
*              (bit 1 must also be on)
*             Bit 3 on for E-notation output
*             Bit 4 also on for extended E-notation
*         R1 and R2 specify the field size.
*         R1  Number of places in the field to the left of
*              the decimal point including an explicit sign
*              and excluding the dicimal point.
*         R2  Number of places in the field to the right of
*              the decimal point.
*         R1 and R2 exclude ths 4 positions for the exponent
*              if bit 3 is on.
* ERRORS:   The field has more than 14 significant digits if
*            the number is too big to fit in the field. The
*            field is filled with asterisks.
*           The original contents of the FAC are lost.
 
 
LWCNP  DATA >0004
LWCNE  DATA >0008
LWCNF  DATA >0010
* Integer power of ten table
CNSITT DATA 10000
       DATA 1000
LW100  BYTE 0
LB100  BYTE 100
LW10   BYTE 0
LB10   BYTE 10
       DATA 1
LBSPC  BYTE ' '
LBAST  BYTE '*'
LBPER  BYTE '.'
LBE    BYTE 'E'
LBZER  BYTE '0'
       BYTE 0                 changed from EVEN to 0 to match binary      *TOMY*
 
CNS    MOV  R11,R10           In ROLOUT: use R10 to return
       BL   @ROLOUT
       INCT R9
       MOV  R13,*R9
       LI   R6,FAC11          Optimize for space and speed
       MOVB *R6+,R0           @FAC11=0 if free format output
       SRL  R0,8              Put in LSB
       MOVB *R6+,R1           @FAC12 places to left of dec
       SRL  R1,8              Put in LSB
       MOVB *R6+,R2           @FAC13 places to right of dec
       SRL  R2,8              Put in LSB
       MOVB @LBSPC,*R6+       Put extra space at beginning
*                              for CNSCHK
       LI   R3,'-'*256        Assume number is negative
       ABS  @FAC              Is number negative?
       JLT  CNS01             Yes, its sign is known
       LI   R3,' '*256        No, assume a space will be used
       CZC  @LWCNP,R0         Do positive numbers get a plus
*                              sign?
       JEQ  CNS01             No, use a space
       LI   R3,'+'*256        Yes, get a plus sign
CNS01  MOVB R3,*R6+           Put sign in buffer
       MOV  R0,@WSM           Is free fomat output specified
       JNE  CNSX              No, use fix format output
* FREE FORMAT FLOATING OUTPUT
       MOV  @FAC,R4           Is it 0?
       JNE  CNSF1             No
       DEC  R6
       LI   R4,' 0'           Yes, convert to a '0' and quit
       MOVB R4,*R6+
       MOVB @R4LB,*R6+
       CLR  R4                Put 0 at end of string
       MOVB R4,*R6
       LI   R4,>5902          Put the beginning of string
*                              in FAC11, LENGTH in FAC12
*                              FAC15=59, LENGTH=2
       MOVB R4,@FAC11
       MOVB @R4LB,@FAC12
       B    @ROLIN            RT in ROLIN
CNSF1  BL   @CNSTEN           Get base ten exponent, is NO.
*                              less then one?
       JLT  CNSF02            Yes, it can't be printed as an
*                              integer
       CI   R13,9             No, is number to big to print
       JGT  CNSF02            Yes, round NO. for E-notataion
*                              output
       MOVB @FAC,@R0LB        No, check if the number is an
*                              integer, get exponent, high
*                              byte is still zero
       AI   R0,PAD0           R0=PAD+FAC+2-64
       AI   R0,>C             Get pointer to first
*                              fractional byte
CNSF01 CLR  R1
       MOVB *R0+,R1           Is next byte of fraction zero?
       JNE  CNSF02            No, print NO. in fixed point
*                              format
       CI   R0,FAC8           Yes, reached end of number?
       JL   CNSF01            No, continue looking at
*                              fractional bytes
       CLR  R10               Yes, number is an integer,
*                              set integer flag
       JMP  CNSF05            Go print the number,
*                              no rounding is necessary
CNSF02 LI   R1,5              Assume rounding for E-notation
       CI   R13,9             Is NO. too big for fixed point
*                              output?
       JGT  CNSF04            Yes, round for E-notataion
       CI   R13,-4            No, is number to small for
*                              fixed point output?
       JLT  CNSF04            Yes, round for E-notation output
       C    *R1+,*R1+         Force R1 to =9
       CI   R13,-2            No, will NO. be printed with
*                              maximum number for fixed
*                              format significant digits?
       JGT  CNSF04            Yes, round accordingly
       INC  R1                No, round number for maximum
*                              significant digits (R1=10)
       A    R13,R1            That can be printed for this
*                              number
CNSF04 BL   @CNSRND           Round NO. accordingly,
*                              rounding can change the
*                              exponent and so the print
*                              format to be used
       SETO R10               Set non-integer flag
CNSF05 CI   R13,9             Decide which print format to
       JGT  CNSG               use, too big for fixed format
       CI   R13,-6            Use E-notation number in range
*                              for max fixed point digits?
       JGT  CNSF08            Yes, use fixed format output
       CI   R13,-10           No, NO. too small for fixed
*                              format?
       JLT  CNSG              Yes, use E-notation ouput
*                             No, the NO. of significant
*                              digits will determine fixed
*                              format ouput or not
       LI   R0,FAC8           Get pointer to last byte
*                              of FAC1
       CLR  R1                Clear low byte of least
*                              significant byte regester
       LI   R3,4              4=15-11 Get NO. of
*                              digits+2-exponent scale factor
       A    R7,R3             Take into acccount a leading
*                              zero in FAC1
CNSF06 DECT R3                Decrement sig digit count for
*                              last zero byte
       DEC  R0                Point to next higher byte of FAC
       MOVB *R0,R1            Is next byte all zero?
       JEQ  CNSF06            Yes, continue looking for LSB
*                             No, found the LSB, this loop
*                              will always terminate since
*                              FAC1 never 0
       CLR  R0                Take into account if the LSB is
*                              divisible by ten
       SWPB R1                Is divisible by ten
       DIV  @LW10,R0          Divide LSB by ten
       MOV  R1,R1             Is the remainder zero?
       JNE  CNSF07            No, significant digit count is
*                              correct
       DEC  R3                Yes, LSB has a trailing zero
CNSF07 C    R3,R13            Too many significant digits for
*                              fixed format?
       JGT  CNSG              Yes, use E-notation
* FREE FORMAT FIXED POINT AND INTEGER FLOATING OUTPUT
CNSF08 S    R7,R13            Make the exponent even
       JLT  CNSF12             are there digits to left of
*                              decimal point? Jump if not
*                             Yes, print decimal point with
*                              the number
       LI   R4,3              Figure out where the decimal
*                              point goes in
       A    R13,R4            The number's digits
CNSF10 LI   R3,12             Convert the maximum number of
*                              decimal digits, leading and
*                              trailing zeros are suppressed
*                              later
       BL   @CNSDIG           Convert number to decimal digits
       BL   @CNSUTR           Remove trailing zeros
       JMP  CNSG01            Suppress leading zeros and
CNSF12 SETO R0                 figure out how many zeros
*                              there are
       S    R13,R0            Between decimal point and
*                              first digit
       BL   @CNSPER           Put decimal point and zeros
*                              in buffer
       CLR  R4                Don't print another decimal
*                              point in the number
       JMP  CNSF10            Convert NO. to decimal digits
*                              finish up
* FREE FORMAT E-NOTATION FLOATING OUTPUT
CNSG   LI   R3,8              Get maximum NO. of digits to
*                              print
       LI   R4,3              Figure out where to put decimal
*                              point
       S    R7,R4             Take a leading zero into account
       BL   @CNSDIG           Convert NO. to decimal digits
       BL   @CNSUTR           Suppress trailing zeros
       BL   @CNSEXP           Put exponent into buffer
CNSG01 B    @CNSMLS           Suppress leading zeros and
*                              finish up
* FIXED FORMAT OUTPUT
* WSM       R0 format specifications
* WSM2      R1 format specifications
* WSM4      R2 format specifications
* WSM6      Number of digit places to left of decimal point
* WSM8      Number of digit places to right of decimal point
CNSX   MOV  R1,@WSM2          Save R1 format specifications
       MOV  R2,@WSM4          Save R2 format specifications
       CZC  @LWCNE,R0         Is E-notation to be used?
       JNE  CNSX01            Yes, remove place for sign from
*                              left of DP count
       CI   R3,'-'*256        No, is number negative?
       JEQ  CNSX01            Yes, remove sign from digit count
       CZC  @LWCNS,R0         No, is explicit sign specified?
       JEQ  CNSX02            No, digit count correct as is
CNSX01 DEC  R1                Remove place for sign form left
*                              of DP digit count
       JGT  CNSX02            Any places for digits left?
       CI   R3,'-'*256        No, is number negative?
       JEQ  CNSX02            Yes, can't do anything about it
       CLR  R1                No, see if NO. digits to left
*                              of DP will work
CNSX02 MOV  R1,@WSM6          Save number of digits to left
*                              of DP
       JLT  CNSJ04            Field to small if there are
*                              negative places
       DEC  R2                Take decimal point from right
*                              of DP count
       JGT  CNSX03            Are there still places left?
       CLR  R2                No, don't print any digits there
CNSX03 MOV  R2,@WSM8          Save right of DP digit count
       MOV  R1,R4             Compute how many significant
*                              digits are to be printed
       A    R2,R4
       JEQ  CNSJ04            None, error
*   FALL INTO NO-TO FIXED FORMAT FLOATING OUTPUT
*
* Fixed format floating output
       BL   @CNSTEN           Get base ten exponent of the FAC
       CZC  @LWCNE,R0         Is E-format call for?
       JNE  CNSK              Yes, go do it
* FIXED FORMAT FLOATING F-FORMAT OUTPUT
       C    R13,@WSM6         Are there too many digits in
*                              the number for the field size?
       JLT  CNSJ00            No, ok
CNSJ04 B    @CNSAST
CNSJ00 MOV  R13,R1            No, get exponent
       A    R2,R1             Compute where rounding should
*                              take place
       CI   R1,-1             Is the NO. too small for the
*                              field?
       JLT  CNSVZR            Yes, result is zero
       BL   @CNSRND           No, round NO. to the proper
*                              place
       S    R7,R13            Convert exponent to an even
*                              number
       JLT  CNSJ01            Any digits to left of DP?
       SETO R0                Yes, compute how many zero are
*                              needed before the number to
*                              fill out the field to the
*                              proper size
       A    @WSM6,R0
       S    R13,R0
       BL   @CNSZER           Put zeros in the buffer if
*                              needed
       LI   R3,3              Compute the number of digits to
*                              convert
       A    R13,R3            Take into account the number's
*                              size
       MOV  R3,R4             Yes, compute where the DP will
*                              go
       A    @WSM8,R3          Take into account the NO. of
*                              decimal palces
       JMP  CNSJ02            Go convert the number
CNSJ01 MOV  @WSM8,R3          Number is less then one
       JEQ  CNSVZR            NO. decimal places, print zero
       MOV  @WSM6,R0          Get size of field to right of DP
       INC  R0                Add one for CNSZER
       BL   @CNSZER           Fill field with zeros, they
*                              will be suppressed
       MOV  R6,R12            Save pointer to DP
       SETO R0                Compute NO. of zeros after DP
       S    R13,R0            And before the number
       BL   @CNSPER           Put them and a DP into the
*                              buffer
       A    R13,R3            Figure out how many digits to
*                              convert
       AI   R3,3              Scale accordingly
       CLR  R4                Do not print a decimal point
CNSJ02 BL   @CNSDIG           Convert the NO. decimal digits
       MOV  @WSM4,R0          Is a decimal point required?
       JNE  CNSJ03            Yes, it is already there
       MOVB R0,*R12           No, overwrite it with zero
CNSJ03 B    @CNSCHK           Go finish up
* FIXED FORMAT OUTPUT OF ZERO
CNSVZR MOV  @WSM6,R0          Get left of DP field size
       INC  R0                Adjust it for CNSZER
       BL   @CNSZER           Put in correct amount of zeros
       MOV  R6,R12            Save pointer to where DP will
*                              go
       MOV  @WSM4,R0          Is a DP called for?
       JEQ  CNSV01            No, don't print one
       BL   @CNSPER           Yes, print it & some zeros
*                              after if needed
CNSV01 MOV  @WSM,R0           Get R0 format specification
       CZC  @LWCNE,R0         Is E-format called for?
       JEQ  CNSJ03            No, finish up
       JMP  CNSK01            Yes, print an exponent
* FIXED FORMAT FLOATING E-FORMAT OUTPUT
CNSK   MOV  @FAC,R5           Is it zero?
       JNE  CNSK1             No, go to CNSK1
       CLR  R7                Yes, do it differently:
       CLR  R13                R7,R13 set to be 0 and jump
       JMP  CNSVZR             to CNSVZR
CNSK1  A    R2,R1             Get total number of digits to
*                              print
       DEC  R1                Compute where rounding should
*                              occur
       BL   @CNSRND           Round number for E-format output
       MOV  @WSM6,R3          Get number of digits to left
*                             of DP
       S    R3,R13            Compute what exponent should be
*                              printed
       INC  R13               Scale properly
       S    R7,R3             Consider only even exponents
       INCT R3                Compute number of digits to
*                              print & where to put the
*                              decimal point
       MOV  R3,R4
       A    @WSM8,R3          Take digits to right of DP
*                              into account
       BL   @CNSDIG           Convert number to decimal digits
       MOV  @WSM4,R0          Is a decimal point needed?
       JNE  CNSK01            Yes, leave it alone
       DEC  R6                No, overwrite it with exponent
CNSK01 BL   @CNSEXP           Put exponent into the buffer
       JMP  CNSJ03            Finish up and zero suppress
* ROUND THE NUMBER IN FAC
* CALL    R1     Number of decimal digits to right of most
*                 significant digit to round to
*         R13    Base ten exponent
*         R7     0 if R13 is even, 1 if R13 is odd
*         BL     CNSRND
*         STATUS Bits reflect exponent
*         R13    Base ten exponent of rounded result
*         R7     0 if R13 is even, 1 if R13 is odd
*      DESTORYS: R0-R3,R12,R10
*      ASSUMES R12 GE -1
CNSRND INCT R9                Save return address
       MOV  R11,*R9
       S    R1,R13            Compute base ten exponent of
*                              place to round to
       S    R7,R1             Take position of first digit
*                              into account
       SRA  R1,1              Compute address in FAC of byte
*                             to be looked at
       INCT R1                To determine if rounding occurs
       LI   R3,49*256         Assume 50 will be added to that
*                              byte
       SRA  R13,1             Rounding to an even ten's place?
       JNC  CNSR01            Yes, assumption was correct
       LI   R3,4*256          No,add 5 to byte to be looked at
CNSR01 CI   R1,7              Is all of FAC significant?
       JGT  CNSR05            Yes, no need to round
       LI   R7,FAC            No, get pointer into FAC
       CLR  R12               The number is positive
       MOVB *R7,R13           Get current FAC exponent
       MOVB R13,R10           Save it to see if it will change
       SRL  R13,8             Put exponent in the low byte
       A    R1,R7             Get address of byte to look at
       AB   R3,*R7            Add NO. to add to round-1 into
*                              correct byte
       MOV  R3,R11            In ROUNUP: Change R3 value
       MOV  R10,R4            In ROUNUP: Use R10 to return
       LI   R10,CNSROV
       MOVB @FAC,R5           In ROUNUP: Get the exponent value
*                                        from EXP and EXP+1, so
*                                        now provide
       SRL  R5,8
       MOV  R5,@EXP
       MOVB R5,@SIGN          Clear sign which is used in ROUNUP
       MOV  R9,R5             In ROUNUP: R9 value may be
*                                        changed
       B    @ROUNUP           Propigate carry upwards in FAC
CNSROV MOV  R4,R10
       MOV  R11,R3
       MOV  R5,R9
       CLR  R1                Label prevents getting an
*                              overflow warning
       CI   R7,FAC1           Did rounding occur at first
*                              byte of FAC?
       JNE  CNSR02            No, go clear rest of FAC
       CB   @FAC,R10          Yes, did exponent change?
       JNE  CNSR03            Yes, FAC is correctly zeroed
*                              as is
CNSR02 CI   R3,4*256          Did rounding occur on a byte
*                              boundry?
       JNE  CNSR04            Yes, clear rest of bytes in FAC
       CLR  R0                No, make this digit divisible
*                              by ten
       MOVB *R7,@R1LB         Get byte where rounding occured
       DIV  @LW10,R0          Divide by ten to get quotient
       MPY  @LW10,R0          Pack quotient back in, ignore
       MOVB @R1LB,*R7         Put the byte back into the FAC
CNSR03 INC  R7                Point to next byte of FAC
CNSR04 MOVB R1,*R7+           Zero next byte of FAC
       CI   R7,FAC8           Done zeroing the rest of the
*                              FAC?
       JL   CNSR04            No, continue to do it
CNSR05 MOV  *R9,R11           Yes, restore return address
       DECT R9                Get new base ten exponent of FAC
*
* GET BASE TEN EXPONENT OF THE NUMBER IN THE FAC
* CALL     BL        CSNTEN
*        STATUS      Status bits reflect exponent
*          R13       Base ten exponent
*          R7        0 if R13 is even, 1 it R13 is odd
CNSTEN LI   R13,->4000        Negative bias
       AB   @FAC,R13          Get base 1 hundred exponent of
*                              FAC
       SRA  R13,7             Multiply it by two and put it
*                              in the low byte
       CLR  R7                High bit of FAC1 is always off
       CB   @FAC1,@CBHAT      Is first digit of FAC one                   *TOMY*
*                              decimal digit?
       JLT  CNST01            Yes, base ten exponent is even
       INC  R13               No, take this into account in
*                              base ten exponent
       INC  R7                This makes the base ten
*                              exponent odd
CNST01 MOV  R13,R13           Set stauts bits to reflect
*                              base ten exponent
       RT
*
* CONVERT FACTION OF FLOATING NUMBER IN FAC TO ASCII DIGITS
* CALL        R3     Number of decimal digits+1 to convert
*             R4     Number of digits the decimal point is to
*                     the left of
*             R6     Text pointer to where to put result
* BL       CNSDIG
*             R3(MB) 0
*             R6     Updated to point to end of digits
*             R12    Pointer to decimal point
* DESTORYS: R0-R2,R4
*
CNSDIG INCT R9                Save return address
       MOV  R11,*R9
       CLR  @FAC8             Clear guard digits in case they
*                              are printed
       CLR  R1                Clear high byte of current byte
*                              of FAC register
       LI   R2,FAC1           Get pointer to first byte of FAC
       BL   @CNSD03           Check for a leading dec point
CNSD01 CLR  R0                Clear high word of this byte
*                              of FAC for divide
       MOVB *R2+,@R1LB        Get next byte of FAC
       DIV  @LW10,R0          Separate the two decimal digits
       BL   @CNSD02           Put the first one in the buffer
       MOV  R1,R0             Get the one's place digit
       LI   R11,CNSD01        Set up return addressto loop and
*                              get the next byte of the FAC
*                              after this digit is printed
CNSD02 AI   R0,'0'            Convert this decimal digit to
*                              ASCII
       MOVB @R0LB,*R6+        Put this ASCII digit into buffer
CNSD03 DEC  R4                Is it time for decimal point?
       JNE  CNSD04            No, check for end of number
       MOV  R6,R12            Yes, save ptr to decimal point
       MOVB @LBPER,*R6+       Put decimal point in buffer
* VSPTR (Value stack pointer) at CPU >6E, make sure not to
*  destroy it here
CNSD04 CI   R6,FAC33          Field overflow?
       JHE  CNSD06            Yes, put a zero byte at the
*                              end and return
       DEC  R3                No, all digits been printed?
       JGT  CNSDRT            No, return & print next digit
CNSD06 MOVB R3,*R6            Yes, put a zero byte at the end
*                              of the number
CNSD05 MOV  *R9,R11           Restore return address
       DECT R9
CNSDRT RT
********************************************************************************
 
