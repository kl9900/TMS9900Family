********************************************************************************
       AORG >A0FA                                                         *TOMY*
       TITL 'GETNBS'
 
* Get a non-space character
GETNB  MOV  R11,R0            Save return address
GETNB1 BL   @GETCHR           Get next character
       JEQ  TLAB4                                                         *TOMY*
       CI   R1,' '*256        Space character?
       JEQ  GETNB1            Yes, get next character
TLAB4  B    *R0               No, return character condition              *TOMY*
* Get the next character
*GETCHR C    @VARW,@VARA      End of line?                                *TOMY*
GETCHR MOV  @VARW,R14                                                     *TOMY*
TLAB6  SWPB R14                                                           *TOMY*
       MOVB R14,*R15                                                      *TOMY*
       SWPB R14                                                           *TOMY*
       MOVB R14,*R15                                                      *TOMY*
       CLR  R1                                                            *TOMY*
       C    R14,@>F088                                                    *TOMY*
       JH   GETCH2            Yes, return condition
*      MOVB @VARW1,*R15       No, write LSB of VDP address                *TOMY*
*      LI   R1,>A000          Negative screen offset (->60)               *TOMY*
*      MOVB @VARW,*R15        Write MSB of VDP address                    *TOMY*
*      INC  @VARW             Increment read-from pointer                 *TOMY*
*      AB   @XVDPRD,R1        Read and remove screen offset               *TOMY*
       MOVB @XVDPRD,R1                                                    *TOMY*
       CI   R1,>7F00          Read an edge character?                     *TOMY*
*      JEQ  GETCHR            Yes, skip it                                *TOMY*
       JNE  TLAB5                                                         *TOMY*
       C    *R14+,*R14+                                                   *TOMY*
       JMP  TLAB6                                                         *TOMY*
TLAB5  AI   R1,>A000                                                      *TOMY*
       INC  R14                                                           *TOMY*
       MOV  R14,@VARW                                                     *TOMY*
       RT                     Return
*GETCH2 CLR  R1               Indicate end of line                        *TOMY*
GETCH2 MOV  R14,@VARW                                                     *TOMY*
       SB   R14,R14                                                       *TOMY*
       RT                     Return
*-----------------------------------------------------------*
* Remove this routine from CRUNCH because CRUNCH is running *
* out of space                5/11/81                       *
*-----------------------------------------------------------*
*      Calculate and put length of string/number into       *
*      length byte                                          *
*LENGTH MOV  R11,R3           Save retun address                          *TOMY*
*      MOV  @RAMPTR,R0        Save current crunch pointer                 *TOMY*
*      MOV  R0,R8             Put into r8 for PUTCHR below                *TOMY*
*      S    R5,R8             Calculate length of string                  *TOMY*
*      DEC  R8                RAMPTR is post-incremented                  *TOMY*
*      MOV  R5,@RAMPTR        Address of length byte                      *TOMY*
*      BL   @PUTCHR           Put the length in                           *TOMY*
*      MOV  R0,@RAMPTR        Restore crunch pointer                      *TOMY*
*      B    *R3               And return                                  *TOMY*
* FILL IN BYTES OF MODULE WITH COPY OF ORIGINAL?
*      DATA >0000                                                         *TOMY*
*      DATA >EF71             ?????                                       *TOMY*
********************************************************************************
 
