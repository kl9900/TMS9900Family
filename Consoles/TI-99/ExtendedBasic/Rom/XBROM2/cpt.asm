********************************************************************************
       AORG >612C
       TITL 'CPT'
 
*
* The CHARACTER PROPERTY TABLE
* There is a one-byte entry for every character code
* in the range LLC(lowest legal character) to
* HLC(highest legal character), inclusive.
LLC    EQU  >20
CPNIL  EQU  >00               " $ % ' ?
CPDIG  EQU  >02               digit (0-9)
CPNUM  EQU  >04               digit, period, E
CPOP   EQU  >08               1 char operators(!#*+-/<=>^ )
CPMO   EQU  >10               multiple operator ( : )
CPALPH EQU  >20               A-Z, @, _
CPBRK  EQU  >40               ( ) , ;
CPSEP  EQU  >80               space
CPALNM EQU  CPALPH+CPDIG      alpha-digit
*-----------------------------------------------------------*
* Following lines are for adding lowercase character set in *
* 99/4A,                      5/12/81                       *
CPLOW  EQU  >01               a-z                           *
CPULNM EQU  CPALNM+CPLOW      Alpha(both upper and lower)+  *
*                             digit-legal variable characters
CPUL   EQU  CPALPH+CPLOW      Alpha(both upper and lower)   *
*-----------------------------------------------------------*
CPTBL  EQU  $-LLC
       BYTE CPSEP               SPACE
       BYTE CPOP              ! EXCLAMATION POINT
       BYTE CPNIL             " QUOTATION MARKS
       BYTE CPOP              # NUMBER SIGN
       BYTE CPNIL             $ DOLLAR SIGN
       BYTE CPNIL             % PERCENT
       BYTE CPOP              & AMPERSAND
       BYTE CPNIL             ' APOSTROPHE
       BYTE CPBRK             ( LEFT PARENTHESIS
       BYTE CPBRK             ) RIGHT PARENTHESIS
       BYTE CPOP              * ASTERISK
       BYTE CPOP+CPNUM        + PLUS
       BYTE CPBRK             , COMMA
       BYTE CPOP+CPNUM        - MINUS
       BYTE CPNUM             . PERIOD
       BYTE CPOP              / SLANT
       BYTE CPNUM+CPDIG       0 ZERRO
       BYTE CPNUM+CPDIG       1 ONE
       BYTE CPNUM+CPDIG       2 TWO
       BYTE CPNUM+CPDIG       3 THREE
       BYTE CPNUM+CPDIG       4 FOUR
       BYTE CPNUM+CPDIG       5 FIVE
       BYTE CPNUM+CPDIG       6 SIX
       BYTE CPNUM+CPDIG       7 SEVEN
       BYTE CPNUM+CPDIG       8 EIGHT
       BYTE CPNUM+CPDIG       9 NINE
LBCPMO BYTE CPMO              : COLON
       BYTE CPBRK             : SEMICOLON
       BYTE CPOP              < LESS THAN
       BYTE CPOP              = EQUALS
       BYTE CPOP              > GREATER THAN
       BYTE CPNIL             ? QUESTION MARK
       BYTE CPALPH            @ COMMERCIAL AT
       BYTE CPALPH            A UPPERCASE A
       BYTE CPALPH            B UPPERCASE B
       BYTE CPALPH            C UPPERCASE C
       BYTE CPALPH            D UPPERCASE D
       BYTE CPALPH+CPNUM      E UPPERCASE E
       BYTE CPALPH            F UPPERCASE F
       BYTE CPALPH            G UPPERCASE G
       BYTE CPALPH            H UPPERCASE H
       BYTE CPALPH            I UPPERCASE I
       BYTE CPALPH            J UPPERCASE J
       BYTE CPALPH            K UPPERCASE K
       BYTE CPALPH            L UPPERCASE L
       BYTE CPALPH            M UPPERCASE M
       BYTE CPALPH            N UPPERCASE N
       BYTE CPALPH            O UPPERCASE O
       BYTE CPALPH            P UPPERCASE P
       BYTE CPALPH            Q UPPERCASE Q
       BYTE CPALPH            R UPPERCASE R
       BYTE CPALPH            S UPPERCASE S
       BYTE CPALPH            T UPPERCASE T
       BYTE CPALPH            U UPPERCASE U
       BYTE CPALPH            V UPPERCASE V
       BYTE CPALPH            W UPPERCASE W
       BYTE CPALPH            X UPPERCASE X
       BYTE CPALPH            Y UPPERCASE Y
       BYTE CPALPH            Z UPPERCASE Z
       BYTE CPALPH            [ LEFT SQUARE BRACKET
       BYTE CPALPH            \ REVERSE SLANT
       BYTE CPALPH            ] RIGHT SQUARE BRACKET
       BYTE CPOP              ^ CIRCUMFLEX
       BYTE CPALPH            _ UNDERLINE
*-----------------------------------------------------------*
* Following "`" and lowercase characters are for            *
* adding lowercase character set in 99/4A, 5/12/81          *
*-----------------------------------------------------------*
       BYTE CPNIL             ` GRAVE ACCENT
       BYTE CPALPH+CPLOW      a LOWERCASE a
       BYTE CPALPH+CPLOW      b LOWERCASE b
       BYTE CPALPH+CPLOW      c LOWERCASE c
       BYTE CPALPH+CPLOW      d LOWERCASE d
       BYTE CPALPH+CPLOW      e LOWERCASE e
       BYTE CPALPH+CPLOW      f LOWERCASE f
       BYTE CPALPH+CPLOW      g LOWERCASE g
       BYTE CPALPH+CPLOW      h LOWERCASE h
       BYTE CPALPH+CPLOW      i LOWERCASE i
       BYTE CPALPH+CPLOW      j LOWERCASE j
       BYTE CPALPH+CPLOW      k LOWERCASE k
       BYTE CPALPH+CPLOW      l LOWERCASE l
       BYTE CPALPH+CPLOW      m LOWERCASE m
       BYTE CPALPH+CPLOW      n LOWERCASE n
       BYTE CPALPH+CPLOW      o LOWERCASE o
       BYTE CPALPH+CPLOW      p LOWERCASE p
       BYTE CPALPH+CPLOW      q LOWERCASE q
       BYTE CPALPH+CPLOW      r LOWERCASE r
       BYTE CPALPH+CPLOW      s LOWERCASE s
       BYTE CPALPH+CPLOW      t LOWERCASE t
       BYTE CPALPH+CPLOW      u LOWERCASE u
       BYTE CPALPH+CPLOW      v LOWERCASE v
       BYTE CPALPH+CPLOW      w LOWERCASE w
       BYTE CPALPH+CPLOW      x LOWERCASE x
       BYTE CPALPH+CPLOW      y LOWERCASE y
       BYTE CPALPH+CPLOW      z LOWERCASE z
 
       EVEN
********************************************************************************
 
