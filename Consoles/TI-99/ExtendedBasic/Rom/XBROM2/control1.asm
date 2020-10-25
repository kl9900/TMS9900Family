********************************************************************************
       TITL 'CONTROL BLOCK 0'
 
CIF    EQU  >74AA             * GROM ADDRESS'S
CALL   EQU  >750A             *
COMPCT EQU  >73D8             *
DELREP EQU  >7EF4             *
GETSTR EQU  >736C             *
GREAD  EQU  >7EB4             *
GREAD1 EQU  >7EA6             *
GVWITE EQU  >7FDA             *
GWITE1 EQU  >7ECA             *
GWRITE EQU  >7ED8             *
IO     EQU  >7B48             *
MEMCHG EQU  >72CE             *
MEMCHK EQU  >72D8             *
MVDN   EQU  >7F7E             *
MVDN2  EQU  >7F8A             *
NFOR   EQU  >7000             *
NNEXT  EQU  >7230             *
NSTRCN EQU  >7442             *
PSCAN  EQU  >7C56             *
RESOLV EQU  >7946             *
SCROLL EQU  >7ADA             *
SUBXIT EQU  >78D2             *
VGWITE EQU  >7FC0             *
*
       COPY "equates.asm"
       COPY "xml359.asm"
       COPY "ref359.asm"
       COPY "cpt.asm"
       COPY "bassups.asm"
       COPY "parses.asm"
       COPY "parses2.asm"
       COPY "getputs.asm"
       COPY "nud359.asm"
       COPY "speeds.asm"
       COPY "mvups.asm"
       COPY "getnbs.asm"
*
       COPY "cns359.asm"
       COPY "cns3592.asm"
       COPY "trinsics.asm"
       COPY "trinsics2.asm"
       COPY "crunchs.asm"
 
       END
 
 
