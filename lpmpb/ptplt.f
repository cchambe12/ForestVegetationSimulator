      SUBROUTINE PTPLT(IPLTNO,IPTLUN,IXFORM,LCTX,NEXP)
      IMPLICIT NONE
C----------
C LPMPB $Id$
C----------
C
C     LIBRARY ROUTINE TO PLOT GRAPH NUMBER IPLTNO
C             ASSUMES 122 CHAR WIDTH
C
C             IPLTNO -- PLOT NUMBER
C             IPTLUN -- OUTPUT UNIT NUMBER
C             IXFORM -- FORMAT FOR X VALUES ('F6.?')
C             LCTX -- LINES TO BE LABELED WITH X VALUES
C                     (NEGATIVE LCTX SUPRESSES - - - ACROSS PAGE)
C             NEXP -- EXPANSION FACTOR FOR X AXIS
C
C             NVAR--NUMBER OF VARIABLES
C             VAR--VALUES TO VARIABLES TO BE PLOTTED
C             LCT--LINE COUNTER
C             LSP(.,1) COLUMN WITH SUPERPOSITION
C             LSP(.,2-10) SUPERIMPOSED VARIABLES
C             NLS(.)  NUMBER SUPERIMPOSED LETTERS +1
C
C
C Revision History
C   02/16/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C----------
COMMONS
C
C
      INCLUDE 'PT.F77'
C
C
COMMONS
C
      CHARACTER*18 IFORM1
      CHARACTER*10 IFORM2
      CHARACTER*23 IFORM3
      CHARACTER*15 IFORM4
      CHARACTER*1  PL,SPC,COM,MIN,IPLUS,MINX
      CHARACTER*1  LINE(101),LNS(14),LSP(5,10)

      INTEGER  I, IFLAG, ILUN, IPLTNO, IPTLUN, IXFORM, J, JLINE,
     &         K, L, LCT, LCTX, LCTX1, LIN, M, N, NEXP, NEXP1,
     &         NLS(5), NSP, NSPL, NVAR

      REAL ALIN, RANGE, TEMP, VAR(10), XAXIS

      DATA  IFORM1 /'(7X,101A1,1X,14A1)'/
      DATA  IFORM2 /'(7X,101A1)'/
      DATA  IFORM3 /'(1X,F6.0,101A1,1X,14A1)'/
      DATA  IFORM4 /'(1X,F6.0,101A1)'/
      DATA  PL/'.'/, SPC/' '/, COM/','/, MIN/'-'/, IPLUS/'+'/
      DATA  IFLAG/0/
C
C         POSITION PAGE
      WRITE (IPTLUN,100)
  100 FORMAT (//)
      GO TO 10
C
      ENTRY PTNSC(IPLTNO,IPTLUN,IXFORM,LCTX,NEXP)
C        ALLOWS USER TO SUPPRESS PRINTING OF SCALES.
C        HE MUST SUPPLY HIS OWN CARRIAGE CONTROL.
      IFLAG=1
C
C
      ENTRY PTOPT(IPLTNO,IPTLUN,IXFORM,LCTX,NEXP)
C        ALLOWS USER TO PRINT A TITLE AND/OR COMMENTS AT TOP
C        OF GRAPH.  HE MUST FIRST SUPPLY HIS OWN CARRIAGE CONTROL.
C
   10 IF (IPTSPL(IPLTNO) .EQ. 0) RETURN
C
C
C        SET SCALES
      CALL PTSSC(IPLTNO)
      IF (IFLAG .EQ. 1) GO TO 11
C
C        PRINT SCALES
      CALL PTSCL(IPLTNO,IPTLUN)
C
C         SET LINE LENGTH PARAMETERS
   11 CONTINUE
      LIN = 101
      ALIN = 100.
C
C        SET UP X AXIS
      MINX = MIN
      IF (LCTX .LT. 0) MINX = SPC
C        ABOVE ALLOWS SUPRESSION OF - - - FOR NEGATIVE LCTX
C
      NEXP1 = NEXP - 1
      IF (NEXP1 .LT. 0) NEXP1 = 0
      LCTX1 = IABS(LCTX)/(NEXP1 + 1)
C     NOTE1 -- WHILE NEXP IS THE X AXIS EXPANSION FACTOR,
C              NEXP1 HAS MEANING AS THE NUMBER OF 'BLANK'
C              LINES TO BE INSERTED TO CAUSE AN EXPANSION
C              OF NEXP TIMES.
C
C     NOTE2 -- NEXP1 AND LCTX1 ARE USED INSTEAD OF REDEFINING
C              NEXP AND LCTX IN ORDER TO AVOID CHANGING THE
C              CALLING PARAMETERS.
C
C
C        BUILD BODY OF PLOT
      LCT = 0
      ILUN=19+IPLTNO
      REWIND ILUN
      NVAR=IPTVAR(IPLTNO)
      NSPL=IPTSPL(IPLTNO)
C
      DO 32 JLINE=1,NSPL
C**** WRITE(IPTLUN,777)
C****  777 FORMAT('READ ILUN')
C
C         ******EACH PASS PLOTS ONE LINE*********
C
      READ(ILUN) XAXIS,(VAR(I),I=1,10)
C
C             INITIALIZE SUPERPOSITION COUNTER
      NSP=0
      LNS(1) = SPC
C
C             BLANK OUT LINE IMAGE
      DO 1 I=1,LIN
    1 LINE(I)=SPC
C
C             FILL IN LINE
      DO 2 N=1,NVAR
      TEMP = 0.
      RANGE = PTU(IPLTNO,N) - PTL(IPLTNO,N)
      IF (RANGE .NE. 0.) TEMP = (VAR(N) - PTL(IPLTNO,N))/RANGE
      TEMP=TEMP*ALIN+1.5
      IF(TEMP .LT. 1. .OR. TEMP .GE. ALIN+2.) GO TO 2
      I=TEMP
      IF(LINE(I) .EQ. SPC) GO TO 4
C
C             HAVE SUPERPOSITION
      IF(NSP .EQ. 0) GO TO 6
      DO 7 M=1,NSP
      IF(LSP(M,1) .EQ. LINE(I)) GO TO 8
    7 CONTINUE
    6 NSP=NSP+1
      LSP(NSP,1)=LINE(I)
      LSP(NSP,2)=IPTLET(IPLTNO,N)
      NLS(NSP)=2
      GO TO 2
C
C             MANY SUPERPOSITIONS ON THIS COMUMN
    8 J=NLS(M)+1
      LSP(M,J)=IPTLET(IPLTNO,N)
      NLS(M)=J
      GO TO 2
    4 LINE(I)=IPTLET(IPLTNO,N)
C
    2 CONTINUE
C             END OF FILL IN LINE LOOP
C
C             NEXT ELEMENT OF LNS(.) TO BE FILLED
      K=1
      IF(NSP.EQ.0) GO TO 12
      DO 15 L=1,NSP
      IF(K .EQ. 1) GO TO 14
      LNS(K)=COM
      K=K+1
   14 J=NLS(L)
      DO 16 I=1,J
      LNS(K)=LSP(L,I)
   16 K=K+1
   15 CONTINUE
   12 K=K-1
      LCT=LCT-1
      IF (LCT .LE. 0 .OR. JLINE .EQ. NSPL) GO TO 19
C
C           PRINT UNLABELED LINE
      DO 9 I=1,LIN,25
      IF(LINE(I) .EQ. SPC) LINE(I)=PL
    9 CONTINUE
C             PUTS ...DOWN THE PAGE
C
C***  WRITE(IPTLUN,778) LIN,K
C*** 778  FORMAT ('WRITE IFORM1 LIN K',2I5)
      IF (K .EQ. 0) GO TO 55
      WRITE(IPTLUN,IFORM1) (LINE(I),I=1,LIN),(LNS(I),I=1,K)
      GO TO 56
  55  WRITE(IPTLUN,IFORM2) (LINE(I),I=1,LIN)
  56  CONTINUE
      IF (NEXP1 .GT. 0) GO TO 30
      GO TO 32
C
C        PRINT LABELED LINE
   19 DO 20 I=1,LIN,25
      IF (LINE(I) .EQ. SPC) LINE(I) = IPLUS
   20 CONTINUE
      DO 22 I=3,LIN,2
      IF(LINE(I) .EQ. SPC) LINE(I)=MINX
   22 CONTINUE
C
      LCT = LCTX1
C***  WRITE(IPTLUN,779) LIN,K
C*** 779  FORMAT ('WRITE IFORM2 LIN K',2I5)
      IF (K .EQ. 0) GO TO 65
      WRITE(IPTLUN,IFORM3) XAXIS,(LINE(I),I=1,LIN),(LNS(I),I=1,K)
      GO TO 66
  65  WRITE(IPTLUN,IFORM4) XAXIS,(LINE(I),I=1,LIN)
  66  CONTINUE
      IF (NEXP1 .EQ. 0 .OR. JLINE .EQ. NSPL) GO TO 32
C
C              EXPAND X AXIS IF REQUESTED
   30 DO 31 I=1,NEXP1
C*****  WRITE(IPTLUN,780)
C*****  780   FORMAT('EXPAND WRITE LOOP')
        WRITE(IPTLUN,120)
  120   FORMAT(6X,'.',4(24X,'.'))
   31 CONTINUE
C        NOTE-- ABOVE FORMAT MUST BE CHANGED FOR VARIABLE LINE LENGTH
C
C
   32 CONTINUE
C              ***************
C
      IFLAG=0
C
C     REWIND ADDED BY N. CROOKSTON
C
      REWIND ILUN
C
      RETURN
      END