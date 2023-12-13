C-----VERSION 1.0 15FEBRUARY2006 GETNAMFILLGR
      SUBROUTINE GETNAMFILLGR(INLGR,FNAME,IGRID)
C     ******************************************************************
C     READ NAMES OF THE CORRESPONDING NAME FILES FROM LGR CONTROL FILE
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*200 LINE, FNAME
      LOGICAL EXISTS
C     ------------------------------------------------------------------
C1-----READ IN THE NAME OF THE NAME FILE FOR THIS GRID
      CALL URDCOM(INLGR,0,LINE)
      ICOL = 1
      CALL URWORD(LINE,ICOL,ISTART,ISTOP,0,N,R,0,0)
      FNAME=LINE(ISTART:ISTOP)
      INQUIRE (FILE=FNAME,EXIST=EXISTS)
      IF(.NOT.EXISTS) THEN
        NC=INDEX(FNAME,' ')
        FNAME(NC:NC+3)='.nam'
        INQUIRE (FILE=FNAME,EXIST=EXISTS)
        IF(.NOT.EXISTS) THEN
          WRITE (*,480) FNAME(1:NC-1),FNAME(1:NC+3)
  480     FORMAT(1X,'Can''t find name file ',A,' or ',A)
          CALL USTOP(' ')
        ENDIF
      ENDIF
C
      RETURN
      END
C***********************************************************************
C-----VERSION 1.1 10OCTOBER2006 GWF2LGR1AR      
      SUBROUTINE GWF2LGR2AR(INLGR,FNAME,NGRIDS,IGRID)
C     ******************************************************************
C     ALLOCATE SPACE FOR LOCAL GRID REFINEMENT AND READ DATA
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IOUT,IUNIT,IBOUND,GLOBALDAT,
     1                      DELR,DELC,BOTM
      USE LGRMODULE,   ONLY:ISCHILD,IBFLG,NBNODES,HK,VK,XX,YY,ZZ,ICOL,
     &    ILAY,IROW,JMAT,IMAT,KMAT,HBOLD,HBNEW
      CHARACTER*200 FNAME 
      DOUBLEPRECISION X0,Y0
      
      READ(INLGR,*)X0,Y0

      ALLOCATE(ISCHILD,IBFLG,NBNODES)
      ALLOCATE(XX(NCOL,NROW,NLAY),YY(NCOL,NROW,NLAY),ZZ(NCOL,NROW,NLAY))
      IF(IGRID>1)ALLOCATE(JMAT(NCOL,NROW,NLAY),IMAT(NCOL,NROW,NLAY),
     1 KMAT(NCOL,NROW,NLAY))

      !求节点坐标
      DO 12 K=1,NLAY
        DO 12 J=1,NCOL
          DO 12 I=1,NROW
            IF(I.EQ.1)THEN              
              YY(J,I,K)=Y0
            ELSE
              YY(J,I,K)=YY(J,I-1,K)-(DELC(I-1)+DELC(I))/2.
            ENDIF
            IF(J.EQ.1)THEN
              XX(J,I,K)=X0
            ELSE
              XX(J,I,K)=XX(J-1,I,K)+(DELR(J-1)+DELR(J))/2.
            ENDIF
12    CONTINUE
      DO 13 K=1,NLAY
        DO 13 I=1,NROW
          DO 13 J=1,NCOL
            ZZ(J,I,K)=(BOTM(J,I,K)+BOTM(J,I,K-1))/2.
13    CONTINUE
      IF(IGRID>1)THEN
        IBFLG=-IGRID
        NBNODES = COUNT(IBOUND .EQ. IBFLG) 
        ALLOCATE(iROW(NBNODES),iCOL(NBNODES),iLAY(NBNODES))
        ALLOCATE(HBOLD(NBNODES),HBNEW(NBNODES))
        NUM=1
        DO 14 K=1,NLAY
          DO 14 I=1,NROW
            DO 14 J=1,NCOL
              IF(IBOUND(J,I,K)==IBFLG)THEN
                IROW(NUM)=I
                ICOL(NUM)=J
                ILAY(NUM)=K
                NUM=NUM+1
              ENDIF
14      CONTINUE
      ENDIF
C------------------------------------------------------------------
C-------ALLOCATE SPACE FOR STORING HK AND VK DEPENDING ON FLOW PACKAGE
C-------NOTE: ALLOCATING NLAY FOR VK EVEN THOUGH CHILD MODELS WILL ONLY 
C-------NEED BOTTOM LAYER.  I WOULD NEED A DIFFERENT VK VARIABLE FOR 
C-------PARENT VS CHILD MODELS.
      IF(IUNIT(1) .NE. 0) THEN
        ALLOCATE(HK(NCOL,NROW,NLAY),VK(NCOL,NROW,NLAY))
      ELSE IF (IUNIT(37) .NE. 0) THEN
        ALLOCATE(HK(1,1,1),VK(NCOL,NROW,NLAY))
      ELSE IF (IUNIT(23) .NE. 0) THEN
        ALLOCATE(HK(1,1,1),VK(1,1,1))
      END IF
C
C-------SAVE POINTER DATA TO ARRARYS
      CALL SGWF2LGR2PSV(IGRID)
C
      RETURN
      END 
C***********************************************************************
      SUBROUTINE GWF2LGR2RP(KKPER,IGRID)
      USE LGRMODULE,ONLY:LGRDAT
      
      USE GLOBAL,ONLY:GLOBALDAT
      
      REAL,ALLOCATABLE::XP(:,:,:),YP(:,:,:),ZP(:,:,:),DELCP(:),DELRP(:)
      REAL,ALLOCATABLE::DISX(:),DISY(:)
      REAL,ALLOCATABLE::XC(:,:,:),YC(:,:,:),ZC(:,:,:)
      IF(KKPER>1)RETURN
      IF(IGRID>1)THEN
        NCOLC=GLOBALDAT(IGRID)%NCOL
        NROWC=GLOBALDAT(IGRID)%NROW
        NLAYC=GLOBALDAT(IGRID)%NLAY
        ALLOCATE(XC(NCOLC,NROWC,NLAYC),YC(NCOLC,NROWC,NLAYC),
     1  ZC(NCOLC,NROWC,NLAYC))
        XC=LGRDAT(IGRID)%XX
        YC=LGRDAT(IGRID)%YY
        ZC=LGRDAT(IGRID)%ZZ
        
        NCOLP=GLOBALDAT(1)%NCOL
        NROWP=GLOBALDAT(1)%NROW
        NLAYP=GLOBALDAT(1)%NLAY
        ALLOCATE(XP(NCOLP,NROWP,NLAYP),YP(NCOLP,NROWP,NLAYP),
     1  ZP(NCOLP,NROWP,NLAYP),DELCP(NROWP),DELRP(NCOLP))
        XP=LGRDAT(1)%XX
        YP=LGRDAT(1)%YY
        ZP=LGRDAT(1)%ZZ
        DELCP=GLOBALDAT(1)%DELC
        DELRP=GLOBALDAT(1)%DELR
        
        ALLOCATE(DISX(NCOLP),DISY(NROWP))
        DO JJ=1,NCOLP
          DO II=1,NROWP
            DISX(JJ)=SUM(DELRP(1:JJ))-DELRP(1)/2.
            DISY(II)=SUM(DELCP(1:II))-DELCP(1)/2.
          ENDDO
        ENDDO
        DO K=1,NLAYC
          DO I=1,NROWC
            DO J=1,NCOLC
              DISTX=ABS(XC(J,I,K)-XP(1,1,1))
              DISTY=ABS(YC(J,I,K)-YP(1,1,1))
              LOCZ=ZC(J,I,K)
              DO II=2,NROWP
                DO JJ=2,NCOLP
                  IF(DISTX>=DISX(JJ-1).AND.DISTX<DISX(JJ))THEN
                    IF(DISTY>=DISY(II-1).AND.DISTY<DISY(II))THEN
                      LGRDAT(IGRID)%JMAT(J,I,K)=JJ
                      LGRDAT(IGRID)%IMAT(J,I,K)=II
                      DO KK=1,NLAYP
                        UP=GLOBALDAT(1)%BOTM(JJ,II,KK-1)
                        BT=GLOBALDAT(1)%BOTM(JJ,II,KK)
                        IF(LOCZ>=BT.AND.LOCZ<UP)
     1                       LGRDAT(IGRID)%KMAT(J,I,K)=KK
                      ENDDO
                    ENDIF
                  ENDIF
                ENDDO
              ENDDO
            ENDDO
          ENDDO
        ENDDO
      ENDIF

      RETURN
      END
      
      SUBROUTINE GWF2LGR2DA(IGRID)
C     ******************************************************************
C     DEALLOCATE LGR DATA
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE LGRMODULE
C     ------------------------------------------------------------------
      DEALLOCATE(LGRDAT(IGRID)%ISCHILD)
      
      DEALLOCATE(LGRDAT(IGRID)%HK)
      DEALLOCATE(LGRDAT(IGRID)%VK)
      DEALLOCATE(LGRDAT(IGRID)%XX)
      DEALLOCATE(LGRDAT(IGRID)%YY)
      DEALLOCATE(LGRDAT(IGRID)%ZZ)
      IF(IGRID>1)THEN
        DEALLOCATE(LGRDAT(IGRID)%ICOL)
        DEALLOCATE(LGRDAT(IGRID)%ILAY)
        DEALLOCATE(LGRDAT(IGRID)%IROW)
        DEALLOCATE(LGRDAT(IGRID)%IBFLG)
        DEALLOCATE(LGRDAT(IGRID)%NBNODES)
        DEALLOCATE(LGRDAT(IGRID)%JMAT)
        DEALLOCATE(LGRDAT(IGRID)%IMAT)
        DEALLOCATE(LGRDAT(IGRID)%KMAT)
        DEALLOCATE(LGRDAT(IGRID)%HBOLD)
        DEALLOCATE(LGRDAT(IGRID)%HBNEW)
      ENDIF
      RETURN
      END 
C***********************************************************************
      SUBROUTINE SGWF2LGR2PNT(IGRID)
C     ******************************************************************
C     CHANGE POINTERS FOR LGR DATA TO A DIFFERENT GRID
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE LGRMODULE
C     ------------------------------------------------------------------
      ISCHILD=>LGRDAT(IGRID)%ISCHILD
      HK=>LGRDAT(IGRID)%HK
      VK=>LGRDAT(IGRID)%VK
      XX=>LGRDAT(IGRID)%XX
      YY=>LGRDAT(IGRID)%YY
      ZZ=>LGRDAT(IGRID)%ZZ
      IF(IGRID>1)THEN
        IROW=>LGRDAT(IGRID)%IROW
        ICOL=>LGRDAT(IGRID)%ICOL
        ILAY=>LGRDAT(IGRID)%ILAY
        IBFLG=>LGRDAT(IGRID)%IBFLG
        NBNODES=>LGRDAT(IGRID)%NBNODES
        JMAT=>LGRDAT(IGRID)%JMAT
        IMAT=>LGRDAT(IGRID)%IMAT
        KMAT=>LGRDAT(IGRID)%KMAT
        HBNEW=>LGRDAT(IGRID)%HBNEW
        HBOLD=>LGRDAT(IGRID)%HBOLD
      ENDIF
C
      RETURN
      END
C***********************************************************************
      SUBROUTINE SGWF2LGR2PSV(IGRID)
C     ******************************************************************
C     SAVE POINTERS ARRAYS FOR LGR DATA
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE LGRMODULE
C     ------------------------------------------------------------------
      LGRDAT(IGRID)%HK=>HK
      LGRDAT(IGRID)%VK=>VK
      LGRDAT(IGRID)%XX=>XX
      LGRDAT(IGRID)%YY=>YY
      LGRDAT(IGRID)%ZZ=>ZZ
      LGRDAT(IGRID)%ISCHILD=>ISCHILD
      IF(IGRID>1)THEN
        LGRDAT(IGRID)%IROW=>IROW
        LGRDAT(IGRID)%ILAY=>ILAY
        LGRDAT(IGRID)%ICOL=>ICOL
        LGRDAT(IGRID)%IBFLG=>IBFLG
        LGRDAT(IGRID)%NBNODES=>NBNODES
        LGRDAT(IGRID)%JMAT=>JMAT
        LGRDAT(IGRID)%IMAT=>IMAT
        LGRDAT(IGRID)%KMAT=>KMAT
        LGRDAT(IGRID)%HBOLD=>HBOLD
        LGRDAT(IGRID)%HBNEW=>HBNEW
      ENDIF
C
      RETURN
      END
C***********************************************************************
      SUBROUTINE GWF2LGR2DARCY(KPER,KSTP,IGRID)
C     ******************************************************************
C     THIS ROUTINE USES A DARCY-PLANAR INTERPOLATION BETWEEN THE PARENT 
C     HEADS ONTO THE GHOST NODES. 
C     IF ISHFLG .NE. 0 AND ON THE FIRST ITERATION OF THE FIRST TIME STEP 
C     OF THE FIRST STRESS PERIOD, THEN ALSO USE THE PARENT SOLUTION TO 
C     INTIALIZE THE INTERIOR SOLUTION OF THE CHILD GRID.
C
C     NOTE: NEED TO ADD CHECKS FOR REFINEMENT BEGINNING/ENDING AT EDGE
C     OF PARENT GRID (DOES IT MATTER?  MIGHT BE EASIER TO SET GNCOND=0)
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,      ONLY:GLOBALDAT
      USE GWFBASMODULE,ONLY:GWFBASDAT
      USE LGRMODULE,   ONLY:LGRDAT
      REAL,ALLOCATABLE::HPG(:,:,:)
      IF(IGRID==1)RETURN
      
      NCOLP=GLOBALDAT(1)%NCOL
      NROWP=GLOBALDAT(1)%NROW
      NLAYP=GLOBALDAT(1)%NLAY
      ALLOCATE(HPG(NCOLP,NROWP,NLAYP))
      
C     ------------------------------------------------------------------
      NCOLC=GLOBALDAT(IGRID)%NCOL
      NROWC=GLOBALDAT(IGRID)%NROW
      NLAYC=GLOBALDAT(IGRID)%NLAY
      
      IF(KSTP==1)LGRDAT(IGRID)%HBOLD=LGRDAT(IGRID)%HBNEW
      ! 赋初值
      IF(KPER==1 .AND. KSTP==1)THEN
        HPG=GLOBALDAT(1)%HOLD
        DO 11 K=1,NLAYC
          DO 11 I=1,NROWC
            DO 11 J=1,NCOLC
              XC=LGRDAT(IGRID)%XX(J,I,K)
              YC=LGRDAT(IGRID)%YY(J,I,K)
              ZC=LGRDAT(IGRID)%ZZ(J,I,K)
              JJ=LGRDAT(IGRID)%JMAT(J,I,K)
              II=LGRDAT(IGRID)%IMAT(J,I,K)
              KK=LGRDAT(IGRID)%KMAT(J,I,K)
              CALL SGWF2LGR2DARCY3D(XC,YC,ZC,JJ,II,KK,
     1             HPG,NCOLP,NROWP,NLAYP,HC)
              GLOBALDAT(IGRID)%HNEW(J,I,K)=HC
              GLOBALDAT(IGRID)%HOLD(J,I,K)=HC
              GLOBALDAT(IGRID)%STRT(J,I,K)=HC
11      CONTINUE
        DO NN=1,LGRDAT(IGRID)%NBNODES
          J=LGRDAT(IGRID)%ICOL(NN)
          I=LGRDAT(IGRID)%IROW(NN)
          K=LGRDAT(IGRID)%ILAY(NN)
          LGRDAT(IGRID)%HBOLD(NN)=GLOBALDAT(IGRID)%HNEW(J,I,K)
        ENDDO
      ENDIF
      IF(KSTP==1)THEN
        HPG=GLOBALDAT(1)%HNEW
        DO NN=1,LGRDAT(IGRID)%NBNODES      
          J= LGRDAT(IGRID)%ICOL(NN)
          I= LGRDAT(IGRID)%IROW(NN)
          K= LGRDAT(IGRID)%ILAY(NN)
          XC=LGRDAT(IGRID)%XX(J,I,K)
          YC=LGRDAT(IGRID)%YY(J,I,K)
          ZC=LGRDAT(IGRID)%ZZ(J,I,K)
          JJ=LGRDAT(IGRID)%JMAT(J,I,K)
          II=LGRDAT(IGRID)%IMAT(J,I,K)
          KK=LGRDAT(IGRID)%KMAT(J,I,K)
          CALL SGWF2LGR2DARCY3D(XC,YC,ZC,JJ,II,KK,
     1         HPG,NCOLP,NROWP,NLAYP,HC)
          LGRDAT(IGRID)%HBNEW(NN)=HC
        ENDDO
      ENDIF
      
      DO NN=1,LGRDAT(IGRID)%NBNODES
        PERTIM=GWFBASDAT(IGRID)%PERTIM
        DELT=GWFBASDAT(1)%DELT
        H0=LGRDAT(IGRID)%HBOLD(NN)
        H1=LGRDAT(IGRID)%HBNEW(NN)
        J=LGRDAT(IGRID)%ICOL(NN)
        I=LGRDAT(IGRID)%IROW(NN)
        K=LGRDAT(IGRID)%ILAY(NN)
        GLOBALDAT(IGRID)%HNEW(J,I,K)=H0+(H1-H0)*PERTIM/DELT
      ENDDO
      
      RETURN
      END
C***********************************************************************
!     根据母网格水头状态Hp，插值产生任意子网格节点c（lyr，num）的水头
**********************************************************************
      SUBROUTINE SGWF2LGR2DARCY3D(XC,YC,ZC,JJ,II,KK,HPG,NCOLP,NROWP,
     1 NLAYP,HC)
      USE GLOBAL,ONLY:GLOBALDAT
      USE LGRMODULE,ONLY:LGRDAT
      USE GWFBCFMODULE,ONLY:GWFBCFDAT
    
      DIMENSION HPG(NCOLP,NROWP,NLAYP)
      
!     X Y Z
      XP=LGRDAT(1)%XX(JJ,II,KK)
      YP=LGRDAT(1)%YY(JJ,II,KK)
      ZP=LGRDAT(1)%ZZ(JJ,II,KK)
      
!     水头
      HP=DBLE(HPG(JJ,II,KK))
!     单元大小
      DRp=GLOBALDAT(1)%DELR(JJ)
      DCp=GLOBALDAT(1)%DELC(II)
      CALL FIND_DV(JJ,II,KK,Hp,DVp)
      
!     K
      CXp=LGRDAT(1)%HK(JJ,II,KK)
      CYp=GWFBCFDAT(1)%TRPY(KK)*LGRDAT(1)%HK(JJ,II,KK)
      CZp=LGRDAT(1)%VK(JJ,II,KK)
      
*********************相邻母网格间通量*****************************
!     x方向参数
      IF(XC>=XP .AND. JJ<NCOLP)THEN
        Hqx=DBLE(HPG(JJ+1,II,KK))
        CRx=GLOBALDAT(1)%CR(JJ,II,KK)
      ELSEIF(XC<XP .AND. JJ>1)THEN
        Hqx=DBLE(HPG(JJ-1,II,KK))
        CRx=GLOBALDAT(1)%CR(JJ-1,II,KK)
      ELSE
        Hqx=0.
        CRx=0.
      ENDIF
      DHX=CRX*(HP-HQX)*ABS(XP-XC)/(CXP*DCP*DVP)
      
!     判断y方向
      IF(YC>=YP .AND.II>1)THEN
        CCy=GLOBALDAT(1)%CC(JJ,II-1,KK)
        Hqy=DBLE(HPG(JJ,II-1,KK))
      ELSEIF(YC<YP.AND.II<NROWP)THEN
        CCy=GLOBALDAT(1)%CC(JJ,II,KK)
        Hqy=DBLE(HPG(JJ,II+1,KK))
      ELSE
        CCy=0.
        Hqy=0.
      ENDIF
      DHY=CCy*(HP-Hqy)*ABS(YP-YC)/(CYp*DRP*DVP)
!     判断z方向
      IF(ZC>=ZP.AND.KK>1)THEN
        Hqz=DBLE(HPG(JJ,II,KK-1))
        CVz=GLOBALDAT(1)%CV(JJ,II,KK-1)
      ELSEIF(ZC<ZP.AND.KK<NLAYP)THEN
        Hqz=DBLE(HPG(JJ,II,KK+1))
        CVz=GLOBALDAT(1)%CV(JJ,II,KK)
      ELSE
        Hqz=0.
        CVZ=0.
      ENDIF
      DHZ=CVz*(HP-HQZ)*ABS(ZP-ZC)/(CZP*DCP*DRP)
**************************************************************
!     插值点总水头
      hc=hp-DHx-DHy-DHz
      RETURN
      END
**********************************************************************
!     H为该母网格水头，DV为该母网格垂向等效高度
      SUBROUTINE FIND_DV(J,I,K,H,DV)
      USE GLOBAL,ONLY:GLOBALDAT
      USE GWFBASMODULE,ONLY:GWFBASDAT
      TOP=GLOBALDAT(1)%BOTM(J,I,K-1)
      BOT=GLOBALDAT(1)%BOTM(J,I,K)
      IF(H.GE.TOP)THEN
        DV=TOP-BOT
      ELSEIF(H.LE.BOT)THEN
        DV=GWFBASDAT(1)%HDRY
      ELSE
        DV=H-BOT
      ENDIF
      RETURN      
      END
C***********************************************************************