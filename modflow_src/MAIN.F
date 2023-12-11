C
#include "fintrf.h"
C
#if 0
C
C     MAIN.F
C     .F file need to be preprocessed to generate .for equivalent
C
#endif
C
C     MAIN.f
C
C     This is a simple program that illustrates how to call the MATLAB
C     Engine functions from a FORTRAN program.
C
      USE GLOBAL
      USE GWFBASMODULE
      
      USE GWFHUFMODULE, ONLY:IOHUFHDS,IOHUFFLWS
      USE GWFEVTMODULE, ONLY:NEVTOP
      USE GWFRCHMODULE, ONLY:NRCHOP
      USE GWFLAKMODULE, ONLY:NLAKESAR,THETA,STGOLD,STGNEW,VOL
      USE GWFUZFMODULE, ONLY: IUZFBND, FINF, VKS
      USE GWFSFRMODULE, ONLY: NUMTAB
      USE PCGMODULE
c      USE LMGMODULE
      USE SIPMODULE
      USE DE4MODULE
      USE GMGMODULE
      USE PCGN
      USE LGRMODULE
      USE Q3DMODULE,ONLY:NPILLAR,MXQ3DITER,Q3DDAT,CNVGF,CNVGH,Q3DF,
     1          SY,RrN,RrO,KPILRSTMm,BOTSTMm,SYST,SSST,RrNstm,RrOstm !!,BOT,RELAXF,ZTB0,ZTB1!,IBOT !ADD IBOT 20210305
!     1          KPLRSTm,BOTSTm,SYSTG,SSSTG
	  USE HYDRUS,ONLY:T,DT,NumNP,KPILLAR,HPILLAR !add HPILLAR 20210305
	 
      INCLUDE 'openspec.inc'
C
C-------ASSIGN VERSION NUMBER AND DATE
      CHARACTER*40 VERSION
      CHARACTER*10 MFVNAM
      PARAMETER (VERSION='03/14/2018')
      PARAMETER (MFVNAM='-Q3D')
C
      CHARACTER*80 HEADNG(2)
      CHARACTER*200 FNAME
      INTEGER IBDT(8)
      LOGICAL CNVGQ3D
C     SET THE VARIABLES FOR RUNNING STEMMUS SUBMODULE 

!			  LOGICAL CNVGQ3D
			  REAL tSEC1,tSEC0
!C     SET THE VARIABLES FOR RUNNING STEMMUS SUBMODULE 
			mwPointer engOpen, engGetVariable, mxCreateDoubleMatrix
			mwPointer mxGetPr!,STMSGWD,STMSTS
			mwPointer ep,ENGDT,STMSQMT, STMSQMB,STMSITER,STMST,STEMSKTN!,STMSDELT,KTT,STMSDT STMSITER,STMST,
			  mwPointer THN0p,VSTEMp,DELTp,IBOTp		
			  mwPointer HPLR0p,HPLR1Np,ZTB0p,ZTB1p,RrNp,RrOp,SYp,SSp ! VSTEMp, DELTp, IBOTp
			  
			  integer engPutVariable, engEvalString, engClose
			  integer  status!temp,
			  mwSize M,N,MN,STMSM,STMSN,STMSMN!,I,
			  parameter(N=1)
			  parameter(M=1)
			  parameter(STMSM=44)
			  parameter(STMSN=6)
			  parameter(STMSMN=81)
			  integer NPILRSTm,NunMSTm,NLAYSTm
			  parameter(NPILRSTm=1)
			  parameter(NLAYSTm=6)
			  parameter(NunMSTm=81)
			  DOUBLE PRECISION ENGTIME!,STMSQMTT(1001), STMSQMBB(1001)!,STMSTIME,KT,TEND,Delt_t !(267)STMSKT,NKT,
	          DOUBLEPRECISION,DIMENSION(81)::STMSQMTT, STMSQMBB
			  DOUBLE PRECISION STMSKT,NKT,TTIME,TTEND,STEMSKT,KT!SUMPRES,REFDEPTH,GWDTH,GWDPRES!,STMSTSF(267) !RrNGG,  
              DOUBLE PRECISION DELTSTM
              DOUBLE PRECISION IBOTSTM
              DOUBLEPRECISION,DIMENSION(44)::VSTEM,THN0SM,RrNGG,RrOGG			  
			  DOUBLEPRECISION,DIMENSION(44)::HPLR0STALL,HPLR1NSTAL
			  INTEGER IIBOT,NSSLAY
!              INTEGER, TARGET :: x=34, y=0IIBOT,KPILRSTm(:),,BOTSTm(:,:)
              DOUBLE PRECISION IBOT,IPSTm,IP0STm
			  DOUBLE PRECISION HPLR1NST,HPLR0ST,ZTB0ST
			  DOUBLE PRECISION ZTB1ST,RrNST,RrOST
			  DOUBLE PRECISION HPILR0,HPILR1N,ZTB0G,ZTB1G,RrNG,RrOG
			  DOUBLEPRECISION,DIMENSION(81)::DELTT			  

			  
C
      CHARACTER*4 CUNIT(NIUNIT)
      DATA CUNIT/'BCF6', 'WEL ', 'DRN ', 'RIV ', 'EVT ', 'gfd ', 'GHB ',  !  7
     &           'RCH ', 'SIP ', 'DE4 ', '    ', 'OC  ', 'PCG ', 'lmg ',  ! 14
     &           'gwt ', 'FHB ', 'RES ', 'STR ', 'IBS ', 'CHD ', 'HFB6',  ! 21
     &           'LAK ', 'LPF ', 'DIS ', '    ', 'PVAL', '    ', 'HOB ',  ! 28
     &           '    ', '    ', 'ZONE', 'MULT', 'DROB', 'RVOB', 'GBOB',  ! 35
     &           'STOB', 'HUF2', 'CHOB', 'ETS ', 'DRT ', '    ', 'GMG ',  ! 42
     &           'HYD ', 'SFR ', '    ', 'GAGE', 'LVDA', '    ', 'LMT7',  ! 49
     &           'MNW2', 'MNWI', 'MNW1', 'KDEP', 'SUB ', 'UZF ', 'gwm ',  ! 56
     &           'SWT ', 'cfp ', 'PCGN', '    ', '    ', '    ', 'nrs ',  ! 63
     &           37*'    '/
C     ------------------------------------------------------------------
C
C2------WRITE BANNER TO SCREEN AND DEFINE CONSTANTS.

      INUNIT = 99
      NCVGERR= 0
      ILUNIT = 98
      IQUNIT = 97
      NGRIDS = 1 
      ILGR   = 0
	  
  
C
C3------GET THE NAME OF THE NAME FILE
      CALL GETNAMFIL(ILGR,NGRIDS,FNAME,ILUNIT)
      DO IGRID = 1, NGRIDS
        MAXUNIT= INUNIT
C
C4A------IF USING LGR, READ NAMES FROM LGR NAME FILE
        IF(ILGR .NE. 0) CALL GETNAMFILLGR(ILUNIT,FNAME,IGRID)
C4B-----OPEN NAME FILE.
        OPEN (UNIT=INUNIT,FILE=FNAME,STATUS='OLD',ACTION=ACTION(1))
        NC=INDEX(FNAME,' ')
        WRITE(*,490)' Using NAME file: ',FNAME(1:NC)
  490   FORMAT(A,A)
C
C5------Get current date and time, assign to IBDT, and write to screen
        IF(IGRID .EQ. 1)THEN
          CALL DATE_AND_TIME(VALUES=IBDT)
          WRITE(*,2) (IBDT(I),I=1,3),(IBDT(I),I=5,7)
    2     FORMAT(1X,'Run start date and time (yyyy/mm/dd hh:mm:ss): ',
     &    I4,'/',I2.2,'/',I2.2,1X,I2,':',I2.2,':',I2.2,/)
        ENDIF
   
C10-----START THE MATLAB ENGINE 202312 BY LY		  
				  ep = engOpen('/opt/matlab/R2019b/bin/matlab ')
C
			  if (ep .eq. 0) then
				 write(6,*) 'Can''t start MATLAB engine'
				 stop
			  endif
C
C6------ALLOCATE AND READ (AR) PROCEDURE
 
        NSOL=1
        CALL GWF2BAS7AR(INUNIT,CUNIT,VERSION,24,31,32,MAXUNIT,IGRID,12,
     1                  HEADNG,26,MFVNAM)
        IF(IUNIT(50).GT.0 .AND. IUNIT(52).GT.0) THEN
          WRITE(IOUT,'(1X,/,1X,A)')
     1    'MNW1 and MNW2 cannot both be active in the same grid'
          CALL USTOP(' ')
        ENDIF
        IF(ILGR .NE.0) CALL GWF2LGR2AR(ILUNIT,FNAME,NGRIDS,IGRID)
        CALL GWF2Q3D1AR(IQUNIT,IGRID,NGRIDS)
        
        IF(IUNIT(1).GT.0)  CALL GWF2BCF7AR(IUNIT(1),ILGR,IGRID)
        IF(IUNIT(23).GT.0) CALL GWF2LPF7AR(IUNIT(23),IGRID)
        IF(IUNIT(37).GT.0) CALL GWF2HUF7AR(IUNIT(37),IUNIT(47),
     1                                     IUNIT(53),ILGR,IGRID)
        IF(IUNIT(2).GT.0)  CALL GWF2WEL7AR(IUNIT(2),IGRID)
        IF(IUNIT(3).GT.0)  CALL GWF2DRN7AR(IUNIT(3),IGRID)
        IF(IUNIT(4).GT.0)  CALL GWF2RIV7AR(IUNIT(4),IGRID)
        IF(IUNIT(5).GT.0)  CALL GWF2EVT7AR(IUNIT(5),IGRID)
        IF(IUNIT(7).GT.0)  CALL GWF2GHB7AR(IUNIT(7),IGRID)
        IF(IUNIT(8).GT.0)  CALL GWF2RCH7AR(IUNIT(8),IGRID)
        IF(IUNIT(16).GT.0) CALL GWF2FHB7AR(IUNIT(16),IGRID)
        IF(IUNIT(17).GT.0) CALL GWF2RES7AR(IUNIT(17),IGRID)
        IF(IUNIT(18).GT.0) CALL GWF2STR7AR(IUNIT(18),IGRID)
        IF(IUNIT(19).GT.0) CALL GWF2IBS7AR(IUNIT(19),IUNIT(54),IGRID)
        IF(IUNIT(20).GT.0) CALL GWF2CHD7AR(IUNIT(20),IGRID)
        IF(IUNIT(21).GT.0) CALL GWF2HFB7AR(IUNIT(21),IGRID)
        IF(IUNIT(44).GT.0) CALL GWF2SFR7AR(IUNIT(44),IUNIT(1),IUNIT(23),
     1                             IUNIT(37),IUNIT(15),NSOL,IOUTS,
     2                             IUNIT(55),IGRID)
        IF(IUNIT(55).GT.0) CALL GWF2UZF1AR(IUNIT(55),IUNIT(1),
     1                                     IUNIT(23),IUNIT(37),IGRID)
        IF(IUNIT(22).GT.0 .OR. IUNIT(44).GT.0) CALL GWF2LAK7AR(
     1               IUNIT(22),IUNIT(44),IUNIT(15),IUNIT(55),NSOL,IGRID)
        IF(IUNIT(46).GT.0) CALL GWF2GAG7AR(IUNIT(46),IUNIT(44),
     1                                     IUNIT(22),IGRID)
        IF(IUNIT(39).GT.0) CALL GWF2ETS7AR(IUNIT(39),IGRID)
        IF(IUNIT(40).GT.0) CALL GWF2DRT7AR(IUNIT(40),IGRID)
        IF(IUNIT(54).GT.0) CALL GWF2SUB7AR(IUNIT(54),IGRID)
        IF(IUNIT(9).GT.0) CALL SIP7AR(IUNIT(9),MXITER,IGRID)
        IF(IUNIT(10).GT.0) CALL DE47AR(IUNIT(10),MXITER,IGRID)
        IF(IUNIT(13).GT.0) CALL PCG7AR(IUNIT(13),MXITER,IGRID)
c        IF(IUNIT(14).GT.0) CALL LMG7AR(IUNIT(14),MXITER,IGRID)
        IF(IUNIT(42).GT.0) CALL GMG7AR(IUNIT(42),MXITER,IGRID)
        IF(IUNIT(59).GT.0) CALL PCGN2AR(IUNIT(59),IFREFM,MXITER,IGRID)
        IF(IUNIT(50).GT.0) CALL GWF2MNW27AR(IUNIT(50),IGRID)
        IF(IUNIT(51).GT.0) CALL GWF2MNW2I7AR(IUNIT(51),IUNIT(50),IGRID)
        IF(IUNIT(52).GT.0) CALL GWF2MNW17AR(IUNIT(52),IUNIT(9),
     1                       IUNIT(10),0,IUNIT(13),
     2                       IUNIT(42),IUNIT(59),FNAME,IGRID)
        IF(IUNIT(57).GT.0) CALL GWF2SWT7AR(IUNIT(57),IGRID)
        IF(IUNIT(43).GT.0) CALL GWF2HYD7BAS7AR(IUNIT(43),IGRID)
        IF(IUNIT(43).GT.0 .AND. IUNIT(19).GT.0)
     1                     CALL GWF2HYD7IBS7AR(IUNIT(43),IGRID)
        IF(IUNIT(43).GT.0 .AND. IUNIT(54).GT.0)
     1                     CALL GWF2HYD7SUB7AR(IUNIT(43),IGRID)
        IF(IUNIT(43).GT.0 .AND. IUNIT(18).GT.0)
     1                     CALL GWF2HYD7STR7AR(IUNIT(43),IGRID)
        IF(IUNIT(43).GT.0 .AND. IUNIT(44).GT.0)
     1                     CALL GWF2HYD7SFR7AR(IUNIT(43),IGRID)
        IF(IUNIT(49).GT.0) CALL LMT7BAS7AR(INUNIT,CUNIT,IGRID)
C
C  Observation allocate and read
        CALL OBS2BAS7AR(IUNIT(28),IGRID)
        IF(IUNIT(33).GT.0) CALL OBS2DRN7AR(IUNIT(33),IUNIT(3),IGRID)
        IF(IUNIT(34).GT.0) CALL OBS2RIV7AR(IUNIT(34),IUNIT(4),IGRID)
        IF(IUNIT(35).GT.0) CALL OBS2GHB7AR(IUNIT(35),IUNIT(7),IGRID)
        IF(IUNIT(36).GT.0) CALL OBS2STR7AR(IUNIT(36),IUNIT(18),IGRID)
        IF(IUNIT(38).GT.0) CALL OBS2CHD7AR(IUNIT(38),IGRID)

      ENDDO
      CLOSE(ILUNIT)

	 
C7------SIMULATE EACH STRESS PERIOD.
      DO KPER=1,GLOBALDAT(1)%NPER
       DO KSTP=1,GLOBALDAT(1)%NSTP(KPER)
        DO IGRID=1,NGRIDS
         CALL SGWF2BAS7PNT(IGRID)
         CALL SGWF2LGR2PNT(IGRID)
         CALL SGWF2Q3D1PNT(IGRID)
         IF(IGRID==1)IPER=KPER 
         IF(IGRID>=2)IPER=KSTP+SUM(GLOBALDAT(1)%NSTP(1:KPER))-
     1          GLOBALDAT(1)%NSTP(KPER)
         DO ISTP=1,GLOBALDAT(IGRID)%NSTP(IPER)
          IF(IGRID==1 .AND. ISTP>1)EXIT
          IF(IGRID==1)THEN
           KKPER=KPER
           KKSTP=KSTP
          ELSEIF(IGRID>1)THEN
           KKPER=IPER
           KKSTP=ISTP
          ENDIF
          
          IF(KKSTP==1)THEN
           CALL GWF2BAS7ST(KKPER,IGRID)
           IF(IUNIT(19).GT.0) CALL GWF2IBS7ST(KKPER,IGRID)
           IF(IUNIT(54).GT.0) CALL GWF2SUB7ST(KKPER,IGRID)
           IF(IUNIT(57).GT.0) CALL GWF2SWT7ST(KKPER,IGRID)
           
           IF(ILGR.NE.0)CALL GWF2LGR2RP(KKPER,IGRID)
           
           IF(IUNIT(2).GT.0)  CALL GWF2WEL7RP(IUNIT(2), IGRID)
           IF(IUNIT(3).GT.0)  CALL GWF2DRN7RP(IUNIT(3), IGRID)
           IF(IUNIT(4).GT.0)  CALL GWF2RIV7RP(IUNIT(4), IGRID)
           IF(IUNIT(5).GT.0)  CALL GWF2EVT7RP(IUNIT(5), IGRID)
           IF(IUNIT(7).GT.0)  CALL GWF2GHB7RP(IUNIT(7), IGRID)
           IF(IUNIT(8).GT.0)  CALL GWF2RCH7RP(IUNIT(8), IGRID)
           IF(IUNIT(17).GT.0) CALL GWF2RES7RP(IUNIT(17),IGRID)
           IF(IUNIT(18).GT.0) CALL GWF2STR7RP(IUNIT(18),IGRID)
           IF(IUNIT(43).GT.0 .AND. IUNIT(18).GT.0)
     1                        CALL GWF2HYD7STR7RP(IUNIT(43),KKPER,IGRID)
           IF(IUNIT(20).GT.0) CALL GWF2CHD7RP(IUNIT(20),IGRID)
           IF(IUNIT(44).GT.0) CALL GWF2SFR7RP(IUNIT(44),IUNIT(15),
     1                                   IUNIT(22),KKPER,KKSTP,NSOL,
     2                                   IOUTS,IUNIT(1),IUNIT(23),
     3                                   IUNIT(37),IUNIT(55),IGRID)
           IF(IUNIT(43).GT.0 .AND. IUNIT(44).GT.0)
     1                        CALL GWF2HYD7SFR7RP(IUNIT(43),KKPER,IGRID)
           IF(IUNIT(55).GT.0) CALL GWF2UZF1RP(IUNIT(55),KKPER,IUNIT(44),
     1                                        IGRID)
           IF(IUNIT(22).GT.0) CALL GWF2LAK7RP(IUNIT(22),IUNIT(1),
     1                  IUNIT(15),IUNIT(23),IUNIT(37),IUNIT(44),
     2                  IUNIT(55),KKPER,NSOL,IOUTS,IGRID)
           IF(IUNIT(46).GT.0.AND.KKPER.EQ.1) CALL GWF2GAG7RP(IUNIT(15),
     1                IUNIT(22),IUNIT(55),NSOL,IGRID)
           IF(IUNIT(39).GT.0) CALL GWF2ETS7RP(IUNIT(39),IGRID)
           IF(IUNIT(40).GT.0) CALL GWF2DRT7RP(IUNIT(40),IGRID)
           IF(IUNIT(50).GT.0) CALL GWF2MNW27RP(IUNIT(50),KKPER,IUNIT(9),
     1                        IUNIT(10),0,IUNIT(13),IUNIT(42),
     2                        IUNIT(59),0,IGRID)
           IF(IUNIT(51).GT.0.AND.KKPER.EQ.1) CALL GWF2MNW2I7RP(
     1                        IUNIT(51),0,IGRID)
           IF(IUNIT(52).GT.0) CALL GWF2MNW17RP(IUNIT(52),IUNIT(1),
     1                               IUNIT(23),IUNIT(37),KKPER,IGRID)
           IF(NPILLAR>0)CALL GWF2Q3D1RP(KKPER,IGRID)
          ENDIF
          
C7C1----CALCULATE TIME STEP LENGTH. SET HOLD=HNEW.
!     ********************************************
          CALL GWF2BAS7AD(KKPER,KKSTP,IGRID)
!     ********************************************
          IF(IUNIT(20).GT.0) CALL GWF2CHD7AD(KKPER,IGRID)
          IF(IUNIT(1).GT.0)  CALL GWF2BCF7AD(KKPER,IGRID)
          IF(IUNIT(17).GT.0) CALL GWF2RES7AD(KKSTP,KKPER,IGRID)
          IF(IUNIT(23).GT.0) CALL GWF2LPF7AD(KKPER,IGRID)
          IF(IUNIT(37).GT.0) CALL GWF2HUF7AD(KKPER,IGRID)
          IF(IUNIT(16).GT.0) CALL GWF2FHB7AD(IGRID)
          IF(IUNIT(22).GT.0) CALL GWF2LAK7AD(KKPER,KKSTP,IUNIT(15),
     1                                           IGRID)
          IF( IUNIT(44).GT.0 .AND. NUMTAB.GT.0 ) 
     2                             CALL GWF2SFR7AD(IUNIT(22))
          IF(IUNIT(50).GT.0) THEN
            IF (IUNIT(1).GT.0) THEN
              CALL GWF2MNW27BCF(KKPER,IGRID)
            ELSE IF (IUNIT(23).GT.0) THEN
              CALL GWF2MNW27LPF(KKPER,IGRID)
            ELSE IF(IUNIT(37).GT.0) THEN
              CALL GWF2MNW27HUF(KKPER,IGRID)
            ELSE
              CALL USTOP('MNW2 error-flow package')
            END IF
            CALL GWF2MNW27AD(KKSTP,KKPER,IGRID)
          END IF
          IF(IUNIT(52).GT.0) CALL GWF2MNW17AD(IUNIT(1),IUNIT(23),
     1                                       IUNIT(37),IGRID)
!!!!!!!!!!*************每个MODFLOW时间步开始之前，更新土柱的内容
          IF(NPILLAR>0)CALL GWF2Q3D1AD(IGRID)
!!!!!!!!!!*********************************************!!!!!!!!!!!!!
C
C---------INDICATE IN PRINTOUT THAT SOLUTION IS FOR HEADS
          CALL UMESPR('SOLVING FOR HEAD',' ',IOUT)

          WRITE(*,25)KKPER,KKSTP,IGRID
   25     FORMAT(' Solving:  Stress period: ',i5,4x,
     &       'Time step: ',i5,4x,'Ground-Water Flow Eqn For Grid:',
     1        I5)
C          
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        IF(ILGR.NE.0)CALL GWF2LGR2DARCY(KKPER,KKSTP,IGRID)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*********************************************************************
				  
		IF(NPILLAR>0)THEN
          CNVGH  =.FALSE.
          CNVGF  =.FALSE.
          CNVGQ3D=.FALSE.
        ENDIF
        DO ITERQ3D=1,MXQ3DITER
!           ADD EACH MODFLOW IGRID WITH NPILLAR STEMMUS SOIL COLUMNS
!************为每个MODFLOW网格IGRID加入NPILLAR个Hydrus土柱
!          IF(NPILLAR>0)CALL GWF2Q3D1HYDRUS(ITERQ3D,CNVGQ3D,IGRID)
!       EXTEND GWF2Q3D1HYDRUS SUBROUTINE HERE
          IF(NPILLAR>0) THEN
     
			  CALL HEAD_RELAX(ITERQ3D)
			  
			  IF(CNVGH .AND. CNVGF)THEN
				CNVGQ3D=.TRUE.
				GOTO 1915 !RETURN
			  ENDIF
			  
			  tSEC1=(TOTIM)  ! TIME AT THE END OF CURRENT TIME STEP
			  
			  tSEC0=(TOTIM-DELT)  ! TIME AT THE START OF CURRENT TIME STEP
			  
!C.....PUT THE TIME CONTROL VARIABLE INTO MATLAB SUB MODULE	  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
			  ! tSEC1=(TOTIM)
	  
			  ! tSEC0=(TOTIM-DELT)			  
			NKT=dble(DELT) !KT+1                          ! Counting Number of timesteps	
			STEMSKT=dble(KKPER)
			STMSKT=dble(tSEC0)
!      ! WRITE(*,*)'DELT = ',DELTSTM,IBOTSTM,DELTT,IIBOT,NKT,STMSKT,KKSTP				  

			STMST = mxCreateDoubleMatrix(M, N, 0)
			call mxCopyReal8ToPtr(STMSKT, mxGetPr(STMST), N)
			STMSITER = mxCreateDoubleMatrix(M, N, 0)
			call mxCopyReal8ToPtr(NKT, mxGetPr(STMSITER), N)
			STEMSKTN = mxCreateDoubleMatrix(M, N, 0)
			call mxCopyReal8ToPtr(STEMSKT, mxGetPr(STEMSKTN),N)
!C
!C     Place the variable TIME and KT into the MATLAB workspace
!C
			  status = engPutVariable(ep, 'TTIME', STMST)
! C
			  if (status .ne. 0) then 
				 write(6,*) 'engPutVariable failed'
				 stop
			  endif
			  status = engPutVariable(ep, 'KTN', STEMSKTN)
! C
			  if (status .ne. 0) then 
				 write(6,*) 'engPutVariable failed'
				 stop
			  endif
!	  write(*,*) TIME, STMSKT, KKSTP, TEND
			  status = engPutVariable(ep, 'TTEND', STMSITER)
			  if (status .ne. 0) then 
				write(6,*) 'engPutVariable failed'
				 stop
			  endif

	          IF(KKPER .eq. 1 .AND. ITERQ3D .eq. 1)THEN
                open(3957,file='BOT_NODES.txt',  ! EXPORT THE MODFLOW BOTTOM, SPECIFIC YIELD AND STORAGE PARAMETER, 20210324 Lianyu
     1          STATUS='unknown')
   
                WRITE(3957,*)BOTSTMm,SYST,SSST

                close(3957)	   
        	  ENDIF
			  
			  DO IP=1,NPILLAR
				
				CALL HYDRUS1PNT(IP,IGRID)
				
				CALL BACK_RECOVER(ITERQ3D,IP,IGRID,TSEC0)
				
				IF(Q3DF)CALL PILLAR_RP(IP,TSEC0,HPLR0ST,HPLR1NST)
				

			    RrNST=dble(RrN(1))
			    RrOST=dble(RrO(1))
			 
  			    IPSTm=dble(IP)
! 20211007 parellel	LY			
				HPLR0STALL(IP)=dble(HPLR0ST)
				HPLR1NSTAL(IP)=dble(HPLR1NST)
			 
				
				CALL HYDRUS1REWIND(IP,IGRID)	

    
			  ENDDO

!20211007PAR LY	
!		      write(*,*)'HEAD =',  HPLR0STALL,HPLR1NSTAL
			  HPLR0p = mxCreateDoubleMatrix(STMSM, N, 0)
			  call mxCopyReal8ToPtr(HPLR0STALL,mxGetPr(HPLR0p),STMSM)
			  HPLR1Np = mxCreateDoubleMatrix(STMSM, N, 0)
			  call mxCopyReal8ToPtr(HPLR1NSTAL,mxGetPr(HPLR1Np),STMSM)

			  status = engPutVariable(ep, 'HPILR0', HPLR0p)
! C
			  if (status .ne. 0) then 
				 write(6,*) 'engPutVariable failed'
				 stop
			  endif
			  status = engPutVariable(ep, 'HPILR1N', HPLR1Np)
! C
			  if (status .ne. 0) then 
				 write(6,*) 'engPutVariable failed'
				 stop
			  endif

			  if (engEvalString(ep, 'run MainLoop') .ne. 0) then
				 write(6,*) 'engEvalString failed'
				 stop
			  endif
			  			  
			  VSTEMp = engGetVariable(ep, 'RrNGG')
			  call mxCopyPtrToReal8(mxGetPr(VSTEMp),VSTEM,STMSM)
!			  THN0p = engGetVariable(ep, 'RrOGG')
! 	          call mxCopyPtrToReal8(mxGetPr(THN0p),THN0SM,STMSM)
			  
			  DO IP=1,NPILLAR
			  CALL GWF2Q3D1HYDRUS(IP)			  
				  RrOstm(IP)=dble(RrO(IP))
				  RrNstm(IP)=dble(VSTEM(IP))      
			  ENDDO			  
	          write(*,*)'FLUX =', VSTEM,RrNstm,RrOstm			  
!C-----destroy the pointers	THN0SM,		  

			  call mxDestroyArray(STMSITER)
		  
			  call mxDestroyArray(VSTEMp)
!			  call mxDestroyArray(THN0p)

			  call mxDestroyArray(STMST)

			  call mxDestroyArray(STEMSKTN)
		  
			  call mxDestroyArray(HPLR0p)
			  call mxDestroyArray(HPLR1Np)
	  
!C	  EXCHANGE INFORMATION BETWEEN MODFLOW AND STEMMUS COMPLETE		  
			  WRITE(*,*) 'TIME STEP =', tSEC0, DELT				  
!输出T,hnew，thn
!C-----END 			  
			  

			
!       write(*,*)'FLUX5 =', RrOstm,RrNstm			
			  CALL FLUX_RELAX(ITERQ3D,RrNstm,RrOstm)
			  
			  IF((CNVGH.AND.CNVGF) .OR.MXQ3DITER<=1)THEN
				
				CNVGQ3D=.TRUE.
				
				IF(MXQ3DITER>1)WRITE(*,*)'Q3D-ITERATION CONVERGES'
			
			  ENDIF			  
			  
          ENDIF
					          
 1915     IF(CNVGQ3D.AND.MXQ3DITER>1)EXIT!此时认为Q3D迭代收敛
          !************
          
          DO KITER=1, MXITER
            KKITER=KITER
            CALL GWF2BAS7FM(IGRID,ITERQ3D)
            IF(IUNIT(1).GT.0) CALL GWF2BCF7FM(KKITER,KKSTP,
     1                               KKPER,ILGR,IGRID)
            IF(IUNIT(23).GT.0) CALL GWF2LPF7FM(KKITER,
     1                             KKSTP,KKPER,ILGR,IGRID)
            IF(IUNIT(37).GT.0) CALL GWF2HUF7FM(KKITER,
     1                    KKSTP,KKPER,IUNIT(47),ILGR,IGRID)
            IF(IUNIT(21).GT.0) CALL GWF2HFB7FM(IGRID)
            IF(IUNIT(2).GT.0) CALL GWF2WEL7FM(IGRID)
            IF(IUNIT(3).GT.0) CALL GWF2DRN7FM(IGRID)
            IF(IUNIT(4).GT.0) CALL GWF2RIV7FM(IGRID)
            IF(IUNIT(5).GT.0) THEN
              IF(IUNIT(22).GT.0.AND.NEVTOP.EQ.3) CALL GWF2LAK7ST(
     1                                                    0,IGRID)
              CALL GWF2EVT7FM(IGRID)
              IF(IUNIT(22).GT.0.AND.NEVTOP.EQ.3) CALL GWF2LAK7ST(
     1                                                    1,IGRID)
            END IF
            IF(IUNIT(7).GT.0) CALL GWF2GHB7FM(IGRID)
            IF(IUNIT(8).GT.0) THEN
               IF(IUNIT(22).GT.0.AND.NRCHOP.EQ.3) CALL GWF2LAK7ST(
     1                                                    0,IGRID)
               CALL GWF2RCH7FM(IGRID)
               IF(IUNIT(22).GT.0.AND.NRCHOP.EQ.3) CALL GWF2LAK7ST(
     1                                                    1,IGRID)
            END IF
            IF(IUNIT(16).GT.0) CALL GWF2FHB7FM(IGRID)
            IF(IUNIT(17).GT.0) CALL GWF2RES7FM(IGRID)
            IF(IUNIT(18).GT.0) CALL GWF2STR7FM(IGRID)
            IF(IUNIT(19).GT.0) CALL GWF2IBS7FM(KKPER,IGRID)
            IF(IUNIT(39).GT.0) CALL GWF2ETS7FM(IGRID)
            IF(IUNIT(40).GT.0) CALL GWF2DRT7FM(IGRID)
            IF(IUNIT(55).GT.0) CALL GWF2UZF1FM(KKPER,KKSTP,KKITER,
     1                           IUNIT(44),IUNIT(22),IUNIT(58),
     2                           IGRID)
            IF(IUNIT(44).GT.0) CALL GWF2SFR7FM(KKITER,KKPER,KKSTP,
     1                              IUNIT(22),IUNIT(8),IUNIT(55),
     2                              ILGR,LGRITER,NGRIDS,IGRID)
            IF(IUNIT(22).GT.0) CALL GWF2LAK7FM(KKITER,KKPER,KKSTP,
     1                                     IUNIT(44),IUNIT(55),
     2                                     IGRID)
            IF(IUNIT(50).GT.0) THEN
              IF (IUNIT(1).GT.0) THEN
                 CALL GWF2MNW27BCF(KKPER,IGRID)
              ELSE IF (IUNIT(23).GT.0) THEN
                 CALL GWF2MNW27LPF(KKPER,IGRID)
              ELSE IF(IUNIT(37).GT.0) THEN
                 CALL GWF2MNW27HUF(KKPER,IGRID)
              END IF
              CALL GWF2MNW27FM(KKITER,kkstp,kkper,IGRID)
            END IF
            IF(IUNIT(52).GT.0) CALL GWF2MNW17FM(KKITER,IUNIT(1),
     1                               IUNIT(23),IUNIT(37),IGRID)
            IF(IUNIT(54).GT.0) CALL GWF2SUB7FM(KKPER,KKITER,
     1                                         IUNIT(9),IGRID)
            IF(IUNIT(57).GT.0) CALL GWF2SWT7FM(KKPER,IGRID)
!           *************************************************
            IF(NPILLAR>0)CALL GWF2Q3D1RECHARGE(ITERQ3D,IGRID)
!           *************************************************
            IERR=0
            IF (IUNIT(9).GT.0) THEN
                   CALL SIP7PNT(IGRID)
                   CALL SIP7AP(HNEW,IBOUND,CR,CC,CV,HCOF,RHS,EL,
     1               FL,GL,V,W,HDCG,LRCH,NPARM,KKITER,HCLOSE,ACCL,
     2               ICNVG,KKSTP,KKPER,IPCALC,IPRSIP,MXITER,
     3               NSTP(KKPER),NCOL,NROW,NLAY,NODES,IOUT,0,IERR)
            END IF
            IF (IUNIT(10).GT.0) THEN
                   CALL DE47PNT(IGRID)
                   CALL DE47AP(HNEW,IBOUND,AU,AL,IUPPNT,IEQPNT,
     1               D4B,MXUP,MXLOW,MXEQ,MXBW,CR,CC,CV,HCOF,RHS,
     2               ACCLDE4,KITER,ITMX,MXITER,NITERDE4,HCLOSEDE4,
     3               IPRD4,ICNVG,NCOL,NROW,NLAY,IOUT,LRCHDE4,
     4               HDCGDE4,IFREQ,KKSTP,KKPER,DELT,NSTP(KKPER),
     5               ID4DIR,ID4DIM,MUTD4,DELTL,NBWL,NUPL,NLOWL,
     6               NLOW,NEQ,NUP,NBW,IERR)  
            END IF
            IF (IUNIT(13).GT.0) THEN
                   CALL PCG7PNT(IGRID)
                   CALL PCG7AP(HNEW,IBOUND,CR,CC,CV,HCOF,RHS,VPCG,
     1               SS,P,CD,HCHG,LHCH,RCHG,LRCHPCG,KKITER,NITER,
     2               HCLOSEPCG,RCLOSEPCG,ICNVG,KKSTP,KKPER,IPRPCG,
     3               MXITER,ITER1,NPCOND,NBPOL,NSTP(KKPER),NCOL,
     4               NROW,NLAY,NODES,RELAXPCG,IOUT,MUTPCG,IT1,
     5               DAMPPCG,BUFF,HCSV,IERR,HPCG,DAMPPCGT,
     6               ISSFLG(KKPER),HDRY,IHCOFADD)  
            END IF
c            IF (IUNIT(14).GT.0) THEN
c              CALL LMG7PNT(IGRID)
c              CALL LMG7AP(HNEW,IBOUND,CR,CC,CV,HCOF,RHS,A,IA,JA,
c     1           U1,FRHS,IG,ISIZ1,ISIZ2,ISIZ3,ISIZ4,KKITER,BCLOSE,
c     2           DAMPLMG,ICNVG,KKSTP,KKPER,MXITER,MXCYC,NCOL,NROW,
c     3           NLAY,NODES,HNOFLO,IOUT,IOUTAMG,ICG,IADAMPLMG,
c     4           DUPLMG,DLOWLMG) 
c            END IF
            IF (IUNIT(42).GT.0) THEN
                   CALL GMG7PNT(IGRID)
                   CALL GMG7AP(HNEW,RHS,CR,CC,CV,HCOF,HNOFLO,
     1               IBOUND,IITER,MXITER,RCLOSEGMG,
     2               HCLOSEGMG,KKITER,KKSTP,KKPER,NCOL,
     3               NROW,NLAY,ICNVG,SITER,TSITER,
     4               DAMPGMG,IADAMPGMG,IOUTGMG,IOUT,
     5               GMGID,IUNITMHC,DUP,DLOW,CHGLIMIT,
     6               BIGHEADCHG,HNEWLAST)
            ENDIF
            IF (IUNIT(59).GT.0) THEN
              CALL PCGN2AP(HNEW,RHS,CR,CC,CV,HCOF,IBOUND,
     1               KKITER,KKSTP,KKPER,ICNVG,HNOFLO,IGRID)
            ENDIF
            IF(IERR.EQ.1) CALL USTOP(' ')

C7C2C---IF CONVERGENCE CRITERION HAS BEEN MET STOP ITERATING.
            IF (ICNVG.EQ.1)THEN
              WRITE(*,*)'MODFLOW GRID:',IGRID,'CONVERGES WITH',KKITER,
     1        'TERATIONS!'
              EXIT
            ENDIF
            IF(KKITER==MXITER .AND. ICNVG<1)CALL USTOP('MODFLOW FAILS 
     1TO CONVERGE!')
          ENDDO
        ENDDO
        write(9996,'(F15.8,I5)')TOTIM,iterq3d
          
        CALL GWF2BAS7OC(KKSTP,KKPER,ICNVG,
     1                    GLOBALDAT(IGRID)%IUNIT(12),IGRID)
C---------SWAP POINTERS FOR LGR DATA   !swm: needed for SFR
            IF(ILGR.NE.0) CALL SGWF2LGR2PNT(IGRID)
C
C7C4----CALCULATE BUDGET TERMS. SAVE CELL-BY-CELL FLOW TERMS.
            MSUM=1
            IF (IUNIT(1).GT.0) THEN
              CALL GWF2BCF7BDS(KKSTP,KKPER,IGRID)
              CALL GWF2BCF7BDCH(KKSTP,KKPER,IGRID)
              IBDRET=0
              IC1=1
              IC2=NCOL
              IR1=1
              IR2=NROW
              IL1=1
              IL2=NLAY
              DO 37 IDIR=1, 3
                CALL GWF2BCF7BDADJ(KKSTP,KKPER,IDIR,IBDRET,
     1                            IC1,IC2,IR1,IR2,IL1,IL2,IGRID)
   37         CONTINUE
            ENDIF
            IF(IUNIT(23).GT.0) THEN
              CALL GWF2LPF7BDS(KKSTP,KKPER,IGRID)
              CALL GWF2LPF7BDCH(KKSTP,KKPER,IGRID)
              IBDRET=0
              IC1=1
              IC2=NCOL
              IR1=1
              IR2=NROW
              IL1=1
              IL2=NLAY
              DO 157 IDIR=1,3
                CALL GWF2LPF7BDADJ(KKSTP,KKPER,IDIR,IBDRET,
     &                          IC1,IC2,IR1,IR2,IL1,IL2,IGRID)
157           CONTINUE
            ENDIF
            IF(IUNIT(37).GT.0) THEN
              CALL GWF2HUF7BDS(KKSTP,KKPER,IGRID)
              CALL GWF2HUF7BDCH(KKSTP,KKPER,IUNIT(47),IGRID)
              IBDRET=0
              IC1=1
              IC2=NCOL
              IR1=1
              IR2=NROW
              IL1=1
              IL2=NLAY
              DO 159 IDIR=1,3
                CALL GWF2HUF7BDADJ(KKSTP,KKPER,IDIR,IBDRET,
     &                          IC1,IC2,IR1,IR2,IL1,IL2,IUNIT(47),IGRID)
159           CONTINUE
            ENDIF
            IF(IUNIT(2).GT.0) CALL GWF2WEL7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(3).GT.0) CALL GWF2DRN7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(4).GT.0) CALL GWF2RIV7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(5).GT.0) THEN
               IF(IUNIT(22).GT.0.AND.NEVTOP.EQ.3) CALL GWF2LAK7ST(
     1                                                       0,IGRID)
               CALL GWF2EVT7BD(KKSTP,KKPER,IGRID)
               IF(IUNIT(22).GT.0.AND.NEVTOP.EQ.3) CALL GWF2LAK7ST(
     1                                                       1,IGRID)
            END IF
            IF(IUNIT(7).GT.0) CALL GWF2GHB7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(8).GT.0) THEN
               IF(IUNIT(22).GT.0.AND.NRCHOP.EQ.3) CALL GWF2LAK7ST(
     1                                                       0,IGRID)
               CALL GWF2RCH7BD(KKSTP,KKPER,IGRID)
               IF(IUNIT(22).GT.0.AND.NRCHOP.EQ.3) CALL GWF2LAK7ST(
     1                                                       1,IGRID)
            END IF
            IF(IUNIT(16).GT.0) CALL GWF2FHB7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(17).GT.0) CALL GWF2RES7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(18).GT.0) CALL GWF2STR7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(19).GT.0) CALL GWF2IBS7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(39).GT.0) CALL GWF2ETS7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(40).GT.0) CALL GWF2DRT7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(44).GT.0) CALL GWF2SFR7BD(KKSTP,KKPER,IUNIT(15),
     1                          IUNIT(22),IUNIT(46),IUNIT(55),NSOL,
     2                          IUNIT(8),ILGR,NGRIDS,IGRID)
            IF(IUNIT(55).GT.0) CALL GWF2UZF1BD(KKSTP,KKPER,IUNIT(22),
     1                               IUNIT(44),IGRID)
            IF(IUNIT(22).GT.0) CALL GWF2LAK7BD(KKSTP,KKPER,IUNIT(15),
     1                         IUNIT(46),IUNIT(44),IUNIT(55),NSOL,IGRID)
            IF(IUNIT(50).GT.0) CALL GWF2MNW27BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(52).GT.0) CALL GWF2MNW17BD(NSTP(KPER),KKSTP,KKPER,
     1                        IGRID)
            IF(IUNIT(54).GT.0) CALL GWF2SUB7BD(KKSTP,KKPER,IGRID)
            IF(IUNIT(57).GT.0) CALL GWF2SWT7BD(KKSTP,KKPER,IGRID)

            
CLMT
CLMT----CALL LINK-MT3DMS SUBROUTINES TO SAVE FLOW-TRANSPORT LINK FILE
CLMT----FOR USE BY MT3DMS FOR TRANSPORT SIMULATION
CLMT
CLMT                              
            IF(IUNIT(49).GT.0) CALL LMT7BD(KKSTP,KKPER,IGRID)
C
C  Observation and hydrograph simulated equivalents
            CALL OBS2BAS7SE(IUNIT(28),IGRID)
            IF(IUNIT(33).GT.0) CALL OBS2DRN7SE(IGRID)
            IF(IUNIT(34).GT.0) CALL OBS2RIV7SE(IGRID)
            IF(IUNIT(35).GT.0) CALL OBS2GHB7SE(IGRID)
            IF(IUNIT(36).GT.0) CALL OBS2STR7SE(IGRID)
            IF(IUNIT(38).GT.0) CALL OBS2CHD7SE(KKPER,IGRID)
            IF(IUNIT(43).GT.0) CALL GWF2HYD7BAS7SE(1,IGRID)
            IF(IUNIT(43).GT.0 .AND. IUNIT(19).GT.0)
     1                                CALL GWF2HYD7IBS7SE(1,IGRID)
            IF(IUNIT(43).GT.0 .AND. IUNIT(54).GT.0)
     1                                CALL GWF2HYD7SUB7SE(1,IGRID)
            IF(IUNIT(43).GT.0 .AND. IUNIT(18).GT.0)
     1                                CALL GWF2HYD7STR7SE(1,IGRID)
            IF(IUNIT(43).GT.0 .AND. IUNIT(44).GT.0)
     1                                CALL GWF2HYD7SFR7SE(1,IGRID)

C7C5---PRINT AND/OR SAVE DATA.
            CALL GWF2BAS7OT(KKSTP,KKPER,ICNVG,1,IGRID,BUDPERC)
            IF(IUNIT(19).GT.0) CALL GWF2IBS7OT(KKSTP,KKPER,IUNIT(19),
     1                                         IGRID)
            IF(IUNIT(37).GT.0)THEN
              IF(IOHUFHDS .NE.0 .OR.IOHUFFLWS .NE.0)
     1           CALL GWF2HUF7OT(KKSTP,KKPER,ICNVG,1,IGRID)
            ENDIF
            IF(IUNIT(51).NE.0) CALL GWF2MNW2I7OT(NSTP(KKPER),KKSTP,
     1                         KKPER,IGRID)
            IF(IUNIT(54).GT.0) CALL GWF2SUB7OT(KKSTP,KKPER,IUNIT(54),
     1                                         IGRID)
            IF(IUNIT(57).GT.0) CALL GWF2SWT7OT(KKSTP,KKPER,IGRID)
            IF(IUNIT(43).GT.0) CALL GWF2HYD7BAS7OT(KKSTP,KKPER,IGRID)
C------CHECK FOR CHANGES IN HEAD AND FLUX BOUNDARY CONDITIONS 
         ENDDO
        ENDDO
       ENDDO 
      ENDDO

C
			  status = engClose(ep)
C	  write(6,*) status
C      
			  if (status .ne. 0) then 
				 write(6,*) 'engClose failed'
				 stop
			  endif	  
C8------END OF MATLAB SIMULATION 
 
      DO IGRID=1, NGRIDS
        CALL SGWF2BAS7PNT(IGRID)
        IF(IUNIT(52).NE.0 .AND. ICNVG.NE.0)
     1     CALL GWF2MNW17OT(IGRID)
C
C-------SAVE RESTART RECORDS FOR SUB PACKAGE
         IF(IUNIT(54).GT.0) CALL GWF2SUB7SV(IGRID)
C  Observation output
         IF(IUNIT(28).GT.0) CALL OBS2BAS7OT(IUNIT(28),IGRID)
         IF(IUNIT(33).GT.0) CALL OBS2DRN7OT(IGRID)
         IF(IUNIT(34).GT.0) CALL OBS2RIV7OT(IGRID)
         IF(IUNIT(35).GT.0) CALL OBS2GHB7OT(IGRID)
         IF(IUNIT(36).GT.0) CALL OBS2STR7OT(IGRID)
         IF(IUNIT(38).GT.0) CALL OBS2CHD7OT(IGRID)
      ENDDO
      CALL GLO1BAS6ET(IOUT,IBDT,1)
      DO IGRID=1, NGRIDS
C9------CLOSE FILES AND DEALLOCATE MEMORY.  GWF2BAS7DA MUST BE CALLED
C9------LAST BECAUSE IT DEALLOCATES IUNIT.
        CALL SGWF2BAS7PNT(IGRID)
        IF(ILGR.NE.0) CALL GWF2LGR2DA(IGRID)
        IF(IUNIT(1).GT.0) CALL GWF2BCF7DA(IGRID)
        IF(IUNIT(2).GT.0) CALL GWF2WEL7DA(IGRID)
        IF(IUNIT(3).GT.0) CALL GWF2DRN7DA(IGRID)
        IF(IUNIT(4).GT.0) CALL GWF2RIV7DA(IGRID)
        IF(IUNIT(5).GT.0) CALL GWF2EVT7DA(IGRID)
        IF(IUNIT(7).GT.0) CALL GWF2GHB7DA(IGRID)
        IF(IUNIT(8).GT.0) CALL GWF2RCH7DA(IGRID)
        IF(IUNIT(9).GT.0) CALL SIP7DA(IGRID)
        IF(IUNIT(10).GT.0) CALL DE47DA(IGRID)
        IF(IUNIT(13).GT.0) CALL PCG7DA(IGRID)
c        IF(IUNIT(14).GT.0) CALL LMG7DA(IGRID)
        IF(IUNIT(16).GT.0) CALL GWF2FHB7DA(IGRID)
        IF(IUNIT(17).GT.0) CALL GWF2RES7DA(IGRID)
        IF(IUNIT(18).GT.0) CALL GWF2STR7DA(IGRID)
        IF(IUNIT(19).GT.0) CALL GWF2IBS7DA(IGRID)
        IF(IUNIT(20).GT.0) CALL GWF2CHD7DA(IGRID)
        IF(IUNIT(21).GT.0) CALL GWF2HFB7DA(IGRID)
        IF(IUNIT(22).GT.0 .OR. IUNIT(44).GT.0)
     1                     CALL GWF2LAK7DA(IUNIT(22),IGRID)
        IF(IUNIT(23).GT.0) CALL GWF2LPF7DA(IGRID)
        IF(IUNIT(37).GT.0) CALL GWF2HUF7DA(IGRID)
        IF(IUNIT(39).GT.0) CALL GWF2ETS7DA(IGRID)
        IF(IUNIT(40).GT.0) CALL GWF2DRT7DA(IGRID)
        IF(IUNIT(42).GT.0) CALL GMG7DA(IGRID)
        IF(IUNIT(59).GT.0) CALL PCGN2DA(IGRID)
        IF(IUNIT(44).GT.0) CALL GWF2SFR7DA(IGRID)
        IF(IUNIT(46).GT.0) CALL GWF2GAG7DA(IGRID)
        IF(IUNIT(50).GT.0) CALL GWF2MNW27DA(IGRID)
        IF(IUNIT(51).GT.0) CALL GWF2MNW2I7DA(IGRID)
        IF(IUNIT(52).GT.0) CALL GWF2MNW17DA(IGRID)
        IF(IUNIT(54).GT.0) CALL GWF2SUB7DA(IGRID)
        IF(IUNIT(55).GT.0) CALL GWF2UZF1DA(IGRID)
        IF(IUNIT(57).GT.0) CALL GWF2SWT7DA(IGRID)
        CALL OBS2BAS7DA(IUNIT(28),IGRID)
        IF(IUNIT(33).GT.0) CALL OBS2DRN7DA(IGRID)
        IF(IUNIT(34).GT.0) CALL OBS2RIV7DA(IGRID)
        IF(IUNIT(35).GT.0) CALL OBS2GHB7DA(IGRID)
        IF(IUNIT(36).GT.0) CALL OBS2STR7DA(IGRID)
        IF(IUNIT(38).GT.0) CALL OBS2CHD7DA(IGRID)
        IF(IUNIT(43).GT.0) CALL GWF2HYD7DA(IGRID)
        IF(IUNIT(49).GT.0) CALL LMT7DA(IGRID)
        CALL GWF2BAS7DA(IGRID)
      ENDDO
C
C10-----END OF PROGRAM.
      IF(NCVGERR.GT.0) THEN
        WRITE(*,*) 'FAILED TO MEET SOLVER CONVERGENCE CRITERIA ',
     1          NCVGERR,' TIME(S)'
      ELSE
        WRITE(*,*) ' Normal termination of simulation'
      END IF
      
      CALL USTOP(' ')
      END
      SUBROUTINE GETNAMFIL(ILGR,NGRIDS,FNAME,ILUNIT)
C     ******************************************************************
C     GET THE NAME OF THE NAME FILE
C     ******************************************************************
C        SPECIFICATIONS:
C
C     ------------------------------------------------------------------
      CHARACTER*(*) FNAME
      CHARACTER*200 COMLIN,LINE
      LOGICAL EXISTS
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
C Get name file from command line or user interaction.
        FNAME=' '
        COMLIN=' '
C *** Subroutines GETARG and GETCL are extensions to Fortran 90/95 that
C *** allow a program to retrieve command-line arguments.  To enable
C *** Modflow-2000 to read the name of a Name file from the command
C *** line, either GETARG or GETCL must be called, but not both.  As
C *** distributed, the call to GETARG is uncommented.  For compilers
C *** that support GETCL but not GETARG, comment out the call to GETARG
C *** and uncomment the call to GETCL.  The calls to both GETARG and
C *** GETCL may be commented out for compilers that do not support
C *** either extension.
        CALL GETARG(1,COMLIN)
C        CALL GETCL(COMLIN)
        ICOL=1
        IF(COMLIN.NE.' ') THEN
          FNAME=COMLIN
        ELSE
   15    WRITE (*,*) ' Enter the name of the NAME FILE or LGR CONTROL ',
     &              'FILE:'
          !READ (*,'(A)') FNAME
          !FNAME='parent.NAM'
          FNAME='LGR'
          CALL URWORD(FNAME,ICOL,ISTART,ISTOP,0,N,R,0,0)
          FNAME=FNAME(ISTART:ISTOP)
          IF (FNAME.EQ.' ') GOTO 15
        ENDIF
        INQUIRE (FILE=FNAME,EXIST=EXISTS)
        IF(.NOT.EXISTS) THEN
          NC=INDEX(FNAME,' ')
          FNAME(NC:NC+3)='.nam'
          INQUIRE (FILE=FNAME,EXIST=EXISTS)
          IF(.NOT.EXISTS) THEN
            WRITE (*,480) FNAME(1:NC-1),FNAME(1:NC+3)
  480       FORMAT(1X,'Can''t find name file ',A,' or ',A)
            CALL USTOP(' ')
          ENDIF
        ENDIF
C1A-----CHECK FOR LGR KEYWORD.  IF AN LGR SIMULATION, THEN READ THE 
C1A-----NUMBER OF GRIDS AND LEAVE FILE OPEN FOR PARSING.
C1A-----IF NOT LGR, THEN CLOSE FILE AND CONTINUE AS NORMAL.
      OPEN(UNIT=ILUNIT,FILE=FNAME,STATUS='OLD',ACTION=ACTION(1))
      CALL URDCOM(ILUNIT,0,LINE)
      ICOL=1
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,1,N,R,0,ILUNIT)
      IF(LINE(ISTART:ISTOP) .EQ. 'LGR') THEN
        ILGR=1
        WRITE(*,*) ' RUNNING MODFLOW WITH LGR '
        CALL URDCOM(ILUNIT,0,LINE)
        ICOL=1
        CALL URWORD(LINE,ICOL,ISTART,ISTOP,2,NGRIDS,R,0,ILUNIT)
        WRITE(*,*) 'NGRIDS=', NGRIDS 
        
      ELSE
        CLOSE(ILUNIT)
      ENDIF
C
      RETURN
      END
      SUBROUTINE GLO1BAS6ET(IOUT,IBDT,IPRTIM)
C     ******************************************************************
C     Get end time and calculate elapsed time
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      INTEGER IBDT(8), IEDT(8), IDPM(12)
      DATA IDPM/31,28,31,30,31,30,31,31,30,31,30,31/ ! Days per month
      DATA NSPD/86400/  ! Seconds per day
C     ------------------------------------------------------------------
C
C     Get current date and time, assign to IEDT, and write.
      CALL DATE_AND_TIME(VALUES=IEDT)
      WRITE(*,1000) (IEDT(I),I=1,3),(IEDT(I),I=5,7)
 1000 FORMAT(1X,'Run end date and time (yyyy/mm/dd hh:mm:ss): ',
     &I4,'/',I2.2,'/',I2.2,1X,I2,':',I2.2,':',I2.2)
      IF(IPRTIM.GT.0) THEN
        WRITE(IOUT,'(1X)')
        WRITE(IOUT,1000) (IEDT(I),I=1,3),(IEDT(I),I=5,7)
      END IF
C
C     Calculate elapsed time in days and seconds
      NDAYS=0
      LEAP=0
      IF (MOD(IEDT(1),4).EQ.0) LEAP = 1
      IBD = IBDT(3)            ! BEGIN DAY
      IED = IEDT(3)            ! END DAY
C     FIND DAYS
      IF (IBDT(2).NE.IEDT(2)) THEN
C       MONTHS DIFFER
        MB = IBDT(2)             ! BEGIN MONTH
        ME = IEDT(2)             ! END MONTH
        NM = ME-MB+1             ! NUMBER OF MONTHS TO LOOK AT
        IF (MB.GT.ME) NM = NM+12
        MC=MB-1
        DO 10 M=1,NM
          MC=MC+1                ! MC IS CURRENT MONTH
          IF (MC.EQ.13) MC = 1
          IF (MC.EQ.MB) THEN
            NDAYS = NDAYS+IDPM(MC)-IBD
            IF (MC.EQ.2) NDAYS = NDAYS + LEAP
          ELSEIF (MC.EQ.ME) THEN
            NDAYS = NDAYS+IED
          ELSE
            NDAYS = NDAYS+IDPM(MC)
            IF (MC.EQ.2) NDAYS = NDAYS + LEAP
          ENDIF
   10   CONTINUE
      ELSEIF (IBD.LT.IED) THEN
C       START AND END IN SAME MONTH, ONLY ACCOUNT FOR DAYS
        NDAYS = IED-IBD
      ENDIF
      ELSEC=NDAYS*NSPD
C
C     ADD OR SUBTRACT SECONDS
      ELSEC = ELSEC+(IEDT(5)-IBDT(5))*3600.0
      ELSEC = ELSEC+(IEDT(6)-IBDT(6))*60.0
      ELSEC = ELSEC+(IEDT(7)-IBDT(7))
      ELSEC = ELSEC+(IEDT(8)-IBDT(8))*0.001
C
C     CONVERT SECONDS TO DAYS, HOURS, MINUTES, AND SECONDS
      NDAYS = ELSEC/NSPD
      RSECS = MOD(ELSEC,86400.0)
      NHOURS = RSECS/3600.0
      RSECS = MOD(RSECS,3600.0)
      NMINS = RSECS/60.0
      RSECS = MOD(RSECS,60.0)
      NSECS = RSECS
      RSECS = MOD(RSECS,1.0)
      MSECS = NINT(RSECS*1000.0)
      NRSECS = NSECS
      IF (RSECS.GE.0.5) NRSECS=NRSECS+1
C
C     Write elapsed time to screen
        IF (NDAYS.GT.0) THEN
          WRITE(*,1010) NDAYS,NHOURS,NMINS,NRSECS
 1010     FORMAT(1X,'Elapsed run time: ',I3,' Days, ',I2,' Hours, ',I2,
     &      ' Minutes, ',I2,' Seconds',/)
        ELSEIF (NHOURS.GT.0) THEN
          WRITE(*,1020) NHOURS,NMINS,NRSECS
 1020     FORMAT(1X,'Elapsed run time: ',I2,' Hours, ',I2,
     &      ' Minutes, ',I2,' Seconds',/)
        ELSEIF (NMINS.GT.0) THEN
          WRITE(*,1030) NMINS,NSECS,MSECS
 1030     FORMAT(1X,'Elapsed run time: ',I2,' Minutes, ',
     &      I2,'.',I3.3,' Seconds',/)
        ELSE
          WRITE(*,1040) NSECS,MSECS
 1040     FORMAT(1X,'Elapsed run time: ',I2,'.',I3.3,' Seconds',/)
        ENDIF
C
C     Write times to file if requested
      IF(IPRTIM.GT.0) THEN
        IF (NDAYS.GT.0) THEN
          WRITE(IOUT,1010) NDAYS,NHOURS,NMINS,NRSECS
        ELSEIF (NHOURS.GT.0) THEN
          WRITE(IOUT,1020) NHOURS,NMINS,NRSECS
        ELSEIF (NMINS.GT.0) THEN
          WRITE(IOUT,1030) NMINS,NSECS,MSECS
        ELSE
          WRITE(IOUT,1040) NSECS,MSECS
        ENDIF
      ENDIF
C
      RETURN
      END
  