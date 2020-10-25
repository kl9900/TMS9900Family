********************************************************************************
       TITL 'CONTROL BLOCK 0'
 
CNS    EQU  >7016             * GROM ADDRESS'S
PWR$$  EQU  >7492             *
LOG$$  EQU  >76C2             *
EXP$$  EQU  >75CA             *
SQR$$  EQU  >783A             *
COS$$  EQU  >78B2             *
SIN$$  EQU  >78C0             *
TAN$$  EQU  >7940             *
ATN$$  EQU  >797C             *
GRINT  EQU  >79EC             *
ROLOUT EQU  >7A90             *
ROLIN  EQU  >7AC4             *
CRUNCH EQU  >7B88             *
PUTCHR EQU  >7F6E             *
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
       COPY "fornexts.asm"
       COPY "strings.asm"
       COPY "cifs.asm"
       COPY "subprogs.asm"
       COPY "subprogs2.asm"
       COPY "scrolls.asm"
       COPY "scans.asm"
       COPY "greads.asm"
       COPY "gwrites.asm"
       COPY "delreps.asm"
       COPY "mvdns.asm"
       COPY "vgwites.asm"
       COPY "gvwites.asm"
 
       END
 
