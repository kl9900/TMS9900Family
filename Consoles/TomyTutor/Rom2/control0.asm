********************************************************************************
       TITL 'CONTROL BLOCK 0'
 
*CNS   EQU  >7016             * GROM ADDRESS'S                            *TOMY*
*PWR$$ EQU  >7492             *                                           *TOMY*
*LOG$$ EQU  >76C2             *                                           *TOMY*
*EXP$$ EQU  >75CA             *                                           *TOMY*
*SQR$$ EQU  >783A             *                                           *TOMY*
*COS$$ EQU  >78B2             *                                           *TOMY*
*SIN$$ EQU  >78C0             *                                           *TOMY*
*TAN$$ EQU  >7940             *                                           *TOMY*
*ATN$$ EQU  >797C             *                                           *TOMY*
*GRINT EQU  >79EC             *                                           *TOMY*
*ROLOUT EQU  >7A90            *                                           *TOMY*
*ROLIN EQU  >7AC4             *                                           *TOMY*
*CRUNCH EQU  >7B88            *                                           *TOMY*
*PUTCHR EQU  >7F6E            *                                           *TOMY*
CALL   EQU  >F032                                                         *TOMY*
SUBXIT EQU  >95D4                                                         *TOMY*
UNQST$ EQU  >C8               Unquoted string token                       *TOMY*

       AORG >8000                                                         *TOMY*
	   BYTE >00                                                           *TOMY*

*
       COPY "equates.asm"
*      COPY "mvups.asm"         >6F98 ERAM feature, not in Tomy ROM       *TOMY*
*
*      COPY "subprogs.asm"      >7502 might not be in Tomy ROM            *TOMY*
*      COPY "subprogs2.asm"           might not be in Tomy ROM            *TOMY*
*      COPY "greads.asm"        >7EA6 ERAM feature, not in Tomy ROM       *TOMY*
*      COPY "gwrites.asm"       >7ECA ERAM feature, not in Tomy ROM       *TOMY*
*      COPY "vgwites.asm"       >7FC0 ERAM feature, not in Tomy ROM       *TOMY*
*      COPY "gvwites.asm"       >7FDA >7FFE ERAM feature, not in Tomy ROM *TOMY*
* 
       COPY "xml359.asm"        >9050 - >908B                             *TOMY*
*                               >90A4 - >90B5                             *TOMY*
*                               >90B6 - >9135                             *TOMY*
       COPY "cpt.asm"           >9136 - >9175                             *TOMY*
       COPY "bassups.asm"       >9176 - >9415                             *TOMY*
       COPY "parses.asm"        >9416 - >98AF                             *TOMY*
       COPY "parses2.asm"       >98B0 - >9BEF                             *TOMY*
       COPY "getputs.asm"       >9BF0 - >9C2B                             *TOMY*
       COPY "cifs.asm"          >9C2C - >9C83                             *TOMY*
       COPY "nud359.asm"        >9C84 - >9E73                             *TOMY*
       COPY "strings.asm"       >9E74 - >A037                             *TOMY*
       COPY "speeds.asm"        >A038 - >A0F9                             *TOMY*
       COPY "getnbs.asm"        >A0FA - >A13F                             *TOMY*
       COPY "fornexts.asm"      >A140 - >A3DF                             *TOMY*
       COPY "scrolls.asm"       >A3E0 - >A57B                             *TOMY*
       COPY "scans.asm"         >A5C4 - >A747                             *TOMY*
       COPY "delreps.asm"       >A748 - >A7A9                             *TOMY*
       COPY "mvdns.asm"         >A7AA - >A7E3                             *TOMY*
       COPY "cns359.asm"        >A7E4 - >AB13                             *TOMY*
       COPY "cns3592.asm"       >AB14 - >AC71                             *TOMY*
       COPY "trinsics.asm"      >AC72 - >B0A1                             *TOMY*
*                               >B346 - >B347                             *TOMY*
       COPY "trinsics2.asm"     >B0A2 - >B3DD                             *TOMY*
       COPY "crunchs.asm"       >B4DE - >B933                             *TOMY*
*                               >BFFE - >BFFF                             *TOMY*
       COPY "ref359.asm"        >B9EE - >B9F3                             *TOMY*
       COPY "tomy.asm"          >A57C - >A5C3                             *TOMY*
*	                            >B910 - >B911                             *TOMY*
 
       END
 
