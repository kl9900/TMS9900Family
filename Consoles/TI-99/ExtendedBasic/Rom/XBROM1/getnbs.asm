********************************************************************************
       AORG >6FAC
       TITL 'GETNBS'
 
* Get a non-space character
GETNB  MOV  R11,R0            Save return address
GETNB1 BL   @GETCHR           Get next character
       CI   R1,' '*256        Space character?
       JEQ  GETNB1            Yes, get next character
       B    *R0               No, return character condition
* Get the next character
GETCHR C    @VARW,@VARA       End of line?
       JH   GETCH2            Yes, return condition
       MOVB @VARW1,*R15       No, write LSB of VDP address
       LI   R1,>A000          Negative screen offset (->60)
       MOVB @VARW,*R15        Write MSB of VDP address
       INC  @VARW             Increment read-from pointer
       AB   @XVDPRD,R1        Read and remove screen offset
       CI   R1,>1F00          Read an edge character?
       JEQ  GETCHR            Yes, skip it
       RT                     Return
GETCH2 CLR  R1                Indicate end of line
       RT                     Return
*-----------------------------------------------------------*
* Remove this routine from CRUNCH because CRUNCH is running *
* out of space                5/11/81                       *
*-----------------------------------------------------------*
*      Calculate and put length of string/number into       *
*      length byte                                          *
LENGTH MOV  R11,R3            Save retun address
       MOV  @RAMPTR,R0        Save current crunch pointer
       MOV  R0,R8             Put into r8 for PUTCHR below
       S    R5,R8             Calculate length of string
       DEC  R8                RAMPTR is post-incremented
       MOV  R5,@RAMPTR        Address of length byte
       BL   @PUTCHR           Put the length in
       MOV  R0,@RAMPTR        Restore crunch pointer
       B    *R3               And return
* FILL IN BYTES OF MODULE WITH COPY OF ORIGINAL?
       DATA >0000
       DATA >EF71             ?????
********************************************************************************
 
