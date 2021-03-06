********************************************************************************
       AORG >A3E0                                                         *TOMY*
       TITL 'SCROLLS'
 
FLG    EQU  5
 
* R12  total number of bytes to move
* R10  move from
* R9   move to
* R8   minor counter (buffer counter)
* R7   buffer pointer
 
SCROLL LI   R12,736           Going to move 736 bytes
       LI   R10,32            Address to move from
       CLR  R9                Address to move to
       MOV  R11,R6            Save return address
       BL   @SCRO1            Scroll the screen
       LI   R5,XVDPWD         Optimize for speed later
       LI   R4,>02E0          Addr of bottom line on screen
       LI   R1,>7F80          Edge character and space char ~~~~~~~~~~~~
       BL   @PUTV1            Init VDP & put out 1st edge char            *TOMY*
       LI   R2,28             28 characters on bottom line                *TOMY*
       MOVB R1,*R5            Put out 2nd edge character
       SWPB R1                Bare the space character
SCRBOT SWPB R14                                                           *TOMY*
       MOVB R1,*R5            Write out space character                   *TOMY*
       DEC  R2                One less to move
       JNE  SCRBOT            Loop if more
       SWPB R1                Bare the edge character again
       MOVB R1,*R5            Output edge character
       SWPB R14                                                           *TOMY*
       MOVB R1,*R5            Output edge character
       B    *R6               And return go GPL
* Generalized move routine
SCRO1  CLR  R8                Clear minor counter
       MOVB @R10LB,*R15       Write out LSB of read-address
       SWPB R14                                                           *TOMY*
       STWP R7                Get the WorkSpace pointer
       MOVB R10,*R15          Write out MSB of read-address
       SWPB R14                                                           *TOMY*
SCRO2  MOVB @XVDPRD,*R7+      Read a byte
       INC  R10               Inc read-from address
       INC  R8                Inc minor counter
       DEC  R12               Dec total counter
       JEQ  SCRO4             If all bytes read-write them
       CI   R8,12             Filled WorkSpace buffer area?
       JLT  SCRO2             No, read more
SCRO4  MOVB @R9LB,*R15        Write LSB of write-address
       C    R14,R14                                                       *TOMY*
       ORI  R9,WRVDP          Enable the VDP write
       MOVB R9,*R15           Write MSB of write-address
       SWPB R14                                                           *TOMY*
       STWP R7                Get WorkSpace buffer pointer
SCRO6  MOVB *R7+,@XVDPWD      Write a byte
       C    R14,R14                                                       *TOMY*
       INC  R9                Increment write-address
       DEC  R8                Decrement counter
       JNE  SCRO6             Move more if not done
       MOV  R12,R12           More on major counter?
       JNE  SCRO1             No, go do another read
       RT                     Yes, done
*************************************************************
* Decode which I/O utility is being called                  *
* Tag field following the XML IO has the following          *
* meaning:                                                  *
*     0 - Line list - utility to search keyword table to    *
*         restore keyword from token                        *
*     1 - Fill space - utility to fill record with space    *
*         when outputting imcomplete records                *
*     2 - Copy string - utility to copy a string, adding    *
*         the screen offset to each character for display   *
*         purposes                                          *
*     3 - Clear ERAM - utility to clear ERAM at the address *
*         specified by the data word following the IO tag   *
*         and the # of bytes specified by the length        *
*         following the address word. Note that each data   *
*         word is the address of a CPU memory location.     *
*************************************************************
IO     MOV  *R13+,R0          Read selector from GROM                     *TOMY*
       SRL  R0,8              Shift for decoding
       JEQ  LLIST             0 is tag for Line list
       DEC  R0
       JEQ  FILSPC            1 is tag for Fill space
       DEC  R0
       JEQ  CSTRI2            2 is tag for Copy string                    *TOMY*
*                             3 is tag for CLRGRM string
*                                fall into it
       DEC  R0                                                            *TOMY*
       JEQ  TLAB10                                                        *TOMY*
       DEC  R0                                                            *TOMY*
       JEQ  FILSP2                                                        *TOMY*
       DEC  R0                                                            *TOMY*
       JEQ  TLAB12                                                        *TOMY*
       DEC  R0                                                            *TOMY*
       JEQ  TLAB11                                                        *TOMY*
       RT                                                                 *TOMY*
TLAB10 CLR  R6                                                            *TOMY*
       JMP  CSTRIN                                                        *TOMY*
CSTRI2 SETO R6                                                            *TOMY*
* CALGRM
* R1 - address of clearing start
* R2 - number of bytes to clear
*CLRGRM LI   R1,PAD0          Get CPU RAM offset                          *TOMY*
*      MOV  R1,R2             Need for next read too                      *TOMY*
*      AB   *R13,@R1LB        Add address of ERAM pointer                 *TOMY*
*      MOV  *R1,R1            Read the ERAM address                       *TOMY*
*      AB   *R13,@R2LB        Read address of byte count                  *TOMY*
*      MOV  *R2,R2            Read the byte count                         *TOMY*
*      CLR  R0                Clear of clearing ERAM                      *TOMY*
*CLRGR1 MOVB R0,*R1+          Clear a byte                                *TOMY*
*      DEC  R2                One less to clear, done?                    *TOMY*
*      JNE  CLRGR1            No, loop for rest                           *TOMY*
*      RT                     Yes, return                                 *TOMY*
* CSTRIN
* R0 - MNUM
* R1 - GETV/PUTV buffer
* R3 - FAC4/GETV address
* R5 - return address
CSTRIN MOV  R11,R5            Save return address
       MOVB @MNUM,R0          Get MNUM
       JEQ  CSTR1O            If no bytes to copy
       SRL  R0,8              Shift to use as counter
       MOV  @CCPADR,R4        Get copy-to address
       MOV  @FAC4,R3          Get copy-from address
CSTRO5 BL   @GETV1            Get byte
       MOV  R6,R6                                                         *TOMY*
       JNE  TLAB8                                                         *TOMY*
       BL   @BLTOM1                                                       *TOMY*
       JMP  TLAB9                                                         *TOMY*
TLAB8  AB   @DSRFLG,R1        Add screen offset                           *TOMY*
       BL   @PUTV1            Put the offset byte out
TLAB9  INC  R3                Increment from address                      *TOMY*
       INC  R4                Increment to address
       DEC  R0                One less to move
       JNE  CSTRO5            Loop if not done
       MOV  R3,@FAC4          Restore for GPL
CSTR07 MOVB R0,@MNUM          Clear for GPL
CCBHFF EQU  $+3
       ANDI R4,>BFFF          Throw away VDP write enable
       MOV  R4,@CCPADR        Restore for GPL
FILS$6 EQU  $
CSTR1O B    *R5               Return
* FILSPC
* R0 - MNUM
* R1 - Buffer for GETV/PUTV
* R2 - MNUM1
* R3 - Pointer for GETV
* R4 - CCPADR, pointer for PUTV
* R5 - return address
FILSP2 CLR  R6                                                            *TOMY*
       JMP  >A4CA                                                         *TOMY*
FILSPC SETO R6                                                            *TOMY*
       MOV  R11,R5            Save return address                         *TOMY*
       MOVB @MNUM1,R2         Get pointer to end of record
       JNE  FILS$1            If space to fill for sure
       CB   R2,@CCPPTR        Any filling to do?
       JNE  FILS$2            Yes, do it normalling
       B    *R5               No, 255 record already full
FILS$1 CB   R2,@CCPPTR        Any filling to do?
       JLE  FILS$6            No, record is complete
FILS$2 SB   @CCPPTR,R2        Compute # of bytes to change
       AB   R2,@CCPPTR        Point to end
       MOVB @DSRFLG,R0        Filling with zeroes?
       JNE  FILS$3            No, fill with spaces
       MOV  @PABPTR,R3        Check if internal files
       AI   R3,FLG            5 byte offset into PAB
       CLR  R1                Initialize to test below
       BL   @GETV1            Get byte from PAB
       ANDI R1,>0800          Internal?
       JNE  FILS$4            Yes, zero fill
FILS$3 AI   R0,>2000          Add space character for filler
FILS$4 SRL  R2,8              Shift count for looping
       MOV  @CCPADR,R4        Get start address to fill
       MOVB R0,R1             Put filler in place for PUTV
FILS$7 MOV  R6,R6                                                         *TOMY*
       JNE  FILS$5                                                        *TOMY*
       SB   @>F017,R1                                                     *TOMY*
       BL   @BLTOM1                                                       *TOMY*
       JMP  >A520                                                         *TOMY*
FILS$5 BL   @PUTV1            Put out a filler                            *TOMY*
       INC  R4                Increment filler position
       DEC  R2                One less to fill
       JNE  FILS$7            Loop if move                                *TOMY*
       MOVB R2,@MNUM1         Restore for GPL
       JMP  CSTR07
TLAB11 JMP  JPTOM1                                                        *TOMY*
TLAB12 MOV  R11,R5                                                        *TOMY*
       LI   R1,>0D00                                                      *TOMY*
       BL   @BLTOM1                                                       *TOMY*
       B    *R5                                                           *TOMY*
* LLIST
* R0 - FAC - address of keytab in GROM
* R1 - keyword length
LLIST  MOV  R11,R12           Save return address
       BL   @PUTSTK           Save GROM address
       MOV  @FAC,R0           Get address of keytab
       MOVB @CHAT,R8          Get token to search for
       LI   R1,1              Assume one character keyword
*LLIS$4 MOVB R0,@GRMWAX(R13)  Load GROM address of table                  *TOMY*
LLIS$4 MOVB *R0+,R3                                                       *TOMY*                                                   
*      MOVB @R0LB,@GRMWAX(R13)  Both bytes                                *TOMY*
*      MOVB *R13,R3           Read address of x-char table                *TOMY*
*      MOVB *R13,@R3LB        Both bytes                                  *TOMY*
       MOVB *R0+,@R3LB                                                    *TOMY*
LLIS$5 A    R1,R3             Add length of keyword to point
*                              at token
*      MOVB R3,@GRMWAX(R13)   Write out new GROM address                  *TOMY*
*      MOVB @R3LB,@GRMWAX(R13)  Which points to token                     *TOMY*
*      MOVB *R13,R4           Read token value                            *TOMY*
*      MOVB *R13,R5           Read possible end of x-char                 *TOMY*
*                              table
       MOVB *R3+,R4                                                       *TOMY*
       MOVB *R3,R5                                                        *TOMY*
       CB   R4,R8             Token value match?
       JEQ  LLIS$6            Yes!!! Found the keyword
*      INC  R3                No, so skip token value                     *TOMY*
       CB   R5,@CCBHFF        Reach end of x-char table?
       JNE  LLIS$5            No, so check more in the table
*      INCT R0                Point into x+1 char table                   *TOMY*
       INC  R1                Try x+1 char table
       JMP  LLIS$4            Loop to check it
* Come here when found keyword
LLIS$6 S    R1,R3             Subtract length to pnt at K.W.
       DEC  R3                                                            *TOMY*
       MOV  R3,@FAC8          Save ptr to KeyWord for GPL
       MOV  R1,@FAC4          Save KeyWord length for GPL
       MOVB R8,@FAC           Save CHAT for GPL
       BL   @GETSTK           Restore GROM addres
       B    *R12              And return to GPL
********************************************************************************
 
