      SUBROUTINE GWF2Q3D1HYDRUS(ITERQ3D,CNVGQ3D,IGRID)
      USE Q3DMODULE,ONLY:CNVGH,CNVGF,NPILLAR,MXQ3DITER,Q3DF
      USE GLOBAL,ONLY:HNEW
      USE GWFBASMODULE,ONLY:TOTIM,DELT
      USE HYDRUS,ONLY:T,DT
      LOGICAL CNVGQ3D
      REAL tSEC1,tSEC0
      
      
      CALL HEAD_RELAX(ITERQ3D)
      
      IF(CNVGH .AND. CNVGF)THEN
        CNVGQ3D=.TRUE.
        RETURN
      ENDIF
      
      tSEC1=(TOTIM)
      
      tSEC0=(TOTIM-DELT)

      DO IP=1,NPILLAR
        
        CALL HYDRUS1PNT(IP,IGRID)
        
        CALL BACK_RECOVER(ITERQ3D,IP,IGRID,TSEC0)
        
        IF(Q3DF)CALL PILLAR_RP(IP,TSEC0)
        
        DO WHILE(.NOT.(T>TSEC1.AND.ABS(T-TSEC1)>0.001*dt))
          
          CALL TIME_INTERPOLATION(TSEC1,TSEC0,IP)
          
          CALL HYDRUS1MAIN(IP,IGRID,TSEC0,ITERQ3D)
          
          CALL HYDRUS1RECHARGE(tSEC1,tSEC0,ITERQ3D,IP,IGRID)
          
          CALL TMCTRL(tSEC1,tSEC0,ITERQ3D)
          
        ENDDO
        
        CALL HYDRUS1REWIND(IP,IGRID)
        
      ENDDO
      
      CALL FLUX_RELAX(ITERQ3D)
      
      IF(CNVGH.AND.CNVGF .OR.MXQ3DITER<=1)THEN
        
        CNVGQ3D=.TRUE.
        
        IF(MXQ3DITER>1)WRITE(*,*)'Q3D-ITERATION CONVERGES'
        
      ENDIF
      
      RETURN
      END
      
      SUBROUTINE HEAD_RELAX(ITERQ3D)
      
      USE Q3DMODULE,ONLY:RELAXH,MXQ3DITER,HP1N,HP1O,CNVGH,HCLOSURE
      USE GLOBAL,ONLY:HNEW
      DOUBLEPRECISION TEMP
      TEMP=RELAXH
      IF(MXQ3DITER<=1 .OR. ITERQ3D<=1)RELAXH=1.
      HP1O=HP1N
      IF(ITERQ3D>1)THEN
        !HP1N=HNEW!UPDATE NEW SOLUTION
        CALL PHREATIC_SURFACE(HP1N,HNEW)
      ENDIF
      HP1N=(1-RELAXH)*HP1O+RELAXH*HP1N!Q3D迭代时，更新目标时刻节点水头
      RELAXH=TEMP
      IF(ITERQ3D>1)THEN
        HMAX=MAXVAL(ABS(HP1N-HP1O))
        IF(HMAX<=HCLOSURE)THEN
          CNVGH=.TRUE.
        ELSE
          WRITE(*,*)'HEAD FAILS TO CONVERGE, HMAX=',HMAX
        ENDIF
      ENDIF
      RETURN
      END
      
      SUBROUTINE PHREATIC_SURFACE(HC,HP)
      USE GLOBAL,ONLY:NCOL,NROW,NLAY,BOTM,IBOUND
      DIMENSION HC(NCOL,NROW),HP(NCOL,NROW,NLAY)
      DOUBLEPRECISION HC,HTEMP,ZTOP,ZBOT,HP
      
      DO J=1,NCOL
        DO I=1,NROW
          DO K=NLAY,1,-1
            HTEMP=HP(J,I,K)
            ZTOP=BOTM(J,I,K-1)
            ZBOT=BOTM(J,I,K)
            IF(K==NLAY .AND.HTEMP<=ZBOT)THEN
              IF(IBOUND(J,I,K)>0)CALL USTOP("AQUIFER OVER-DRY!")
            ENDIF
            IF(HTEMP<ZTOP .AND.HTEMP>=ZBOT)THEN
              HC(J,I)=HP(J,I,K)
              EXIT
            ELSEIF(HTEMP<ZBOT)THEN
              CYCLE
            ELSEIF(HTEMP>=ZTOP.AND.K==1)THEN
              IF(IBOUND(J,I,K)>0)THEN
                CALL USTOP("AQUIFER FULLY SATURATED!")
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
      RETURN
      END
      
      SUBROUTINE FLUX_RELAX(ITERQ3D)
      
      USE Q3DMODULE,ONLY:RELAXF,MXQ3DITER,RRN,RRO,FCLOSURE,
     1 CNVGF
      
      DOUBLEPRECISION TEMP
!     为饱和模型提供松弛的上边界通量
      TEMP=RELAXF
      IF(MXQ3DITER<=1 .OR.ITERQ3D<=1)RELAXF=1.
      RrN=(1-RELAXF)*RrO+RELAXF*RrN  !Q3D迭代时，更新目标时刻节点补给通量
      RELAXF=TEMP
      IF(ITERQ3D>1)THEN
        FMAX=MAXVAL(ABS(RrN-RrO))/MAX(abs(MAXVAL(RrO)),1.)
        IF(FMAX<=FCLOSURE)THEN
          CNVGF=.TRUE.
        ELSE
          WRITE(*,*)'FLUX FAILS TO CONVERGE, FMAX=',FMAX
        ENDIF
      ENDIF
      RETURN
      END
      
      SUBROUTINE BACK_RECOVER(ITERQ3D,IP,IGRID,TSEC0)
      
      USE HYDRUS,ONLY:SVTOP,SVBOT,SVROOT,SVTOP0,SVBOT0,SVROOT0,
     1 IPLEVELBACK,IPLEVEL,HBACK,HYDRUSDAT,TOLD,T,ITLEVEL,dtback,dt
      REAL TSEC0
      TOLD=TSEC0
      T=tSEC0
      iTlevel=0
      IF(ITERQ3D==1)THEN      ! RECORDING OR FORWARD
          hBACK       = HYDRUSDAT(IP,IGRID)%HNEW  !备份初始条件
          iPLEVELBACK = iPLEVEL
          SvTop0      = SvTop 
          SvBot0      = SvBot 
          SvRoot0     = SvRoot
      ELSEIF(ITERQ3D>1)THEN ! BACKWARD
          DT          = DTBACK
          iPLEVEL     = iPLEVELBACK
          SvTop       = SvTop0
          SvBot       = SvBot0
          SvRoot      = SvRoot0
      ENDIF
      RETURN
      END
      SUBROUTINE GWF2Q3D1AR(INQ3D,IGRID,NGRIDS)
      USE Q3DMODULE
      USE GLOBAL,ONLY:GLOBALDAT
      USE HYDRUS,ONLY:NUMNP
      
      ALLOCATE(NPILLAR,MXQ3DITER,HCLOSURE,FCLOSURE,RELAXH,RELAXF,Q3DF,
     1 LINEARF,ADAPTF)
      IF(IGRID==1)OPEN(INQ3D,FILE='Q3D.ctrl',STATUS='OLD')

      READ(INQ3D,*)NPILLAR,MXQ3DITER,Q3DF,LINEARF,ADAPTF
      IF(NPILLAR.eq.0.OR.Q3DF.eqv..FALSE.)MXQ3DITER=1
      Q3DDAT(IGRID)%NPILLAR=>NPILLAR
      Q3DDAT(IGRID)%MXQ3DITER=>MXQ3DITER
      
      IF(NPILLAR>0)THEN
        READ(INQ3D,*)HCLOSURE,FCLOSURE,RELAXH,RELAXF
      ELSEIF(NPILLAR<=0)THEN
        READ(INQ3D,*)
      ENDIF
      IF(IGRID==NGRIDS)CLOSE(INQ3D)
      NP=NPILLAR
      IF(NP>0)THEN
        DO I=1,NP
          CALL HYDRUS1AR(I,IGRID)!给hydrus土柱模型分配存储空间
        ENDDO
        NLAY=GLOBALDAT(IGRID)%NLAY
        NCOL=GLOBALDAT(IGRID)%NCOL
        NROW=GLOBALDAT(IGRID)%NROW
        ALLOCATE(ACELL(NP),BOT(0:NLAY,NP))
        
        ALLOCATE(ITERQ3D,DELT0,
     1   HP00(NCOL,NROW),HP0(NCOL,NROW),
     1   HP1O(NCOL,NROW),HP1N(NCOL,NROW),
     1   CNVGH,CNVGF,RRO(NP),RRN(NP),SY(NP,NLAY),
     1   IPILLAR(NCOL,NROW,NLAY),SS(NP,NLAY),
     1   ZTB0(NP),ZTB1(NP),ICTRL0(NP),ICTRL1(NP),IBOT(NP))
        
        ACELL=0.
        BOT=0.
        ITERQ3D=0
        HP00=0.
        HP0=0.
        HP1O=0.
        HP1N=0.
        SY=0.
        SS=0.
        IPILLAR=0
        ZTB0=0.
        ZTB1=0.
        ICTRL0=0
        ICTRL1=0
        IBOT=0! Node number at the moving lower boundary
        CALL SGWF2Q3D1PSV(IGRID)
      ENDIF
      END
      SUBROUTINE SGWF2Q3D1PNT(IGRID)
      USE Q3DMODULE
      NPILLAR=>Q3DDAT(IGRID)%NPILLAR
      MXQ3DITER=>Q3DDAT(IGRID)%MXQ3DITER
      IF(Q3DDAT(IGRID)%NPILLAR>0)THEN
        ITERQ3D=>Q3DDAT(IGRID)%ITERQ3D
        IPILLAR=>Q3DDAT(IGRID)%IPILLAR
        DELT0=>Q3DDAT(IGRID)%DELT0
        RELAXH=>Q3DDAT(IGRID)%RELAXH
        RELAXF=>Q3DDAT(IGRID)%RELAXF
        ACELL=>Q3DDAT(IGRID)%ACELL
        BOT=>Q3DDAT(IGRID)%BOT
        HP00=>Q3DDAT(IGRID)%HP00
        HP0=>Q3DDAT(IGRID)%HP0
        HP1O=>Q3DDAT(IGRID)%HP1O
        HP1N=>Q3DDAT(IGRID)%HP1N
        HCLOSURE=>Q3DDAT(IGRID)%HCLOSURE
        FCLOSURE=>Q3DDAT(IGRID)%FCLOSURE
        CNVGH=>Q3DDAT(IGRID)%CNVGH
        CNVGF=>Q3DDAT(IGRID)%CNVGF
        Q3DF=>Q3DDAT(IGRID)%Q3DF
        LINEARF=>Q3DDAT(IGRID)%LINEARF
        ADAPTF=>Q3DDAT(IGRID)%ADAPTF
        RRO=>Q3DDAT(IGRID)%RRO
        RRN=>Q3DDAT(IGRID)%RRN
        SY=>Q3DDAT(IGRID)%SY
        SS=>Q3DDAT(IGRID)%SS
        ZTB0=>Q3DDAT(IGRID)%ZTB0
        ZTB1=>Q3DDAT(IGRID)%ZTB1
        ICTRL0=>Q3DDAT(IGRID)%ICTRL0
        ICTRL1=>Q3DDAT(IGRID)%ICTRL1
        IBOT=>Q3DDAT(IGRID)%IBOT
      ENDIF
      RETURN
      END
      SUBROUTINE SGWF2Q3D1PSV(IGRID)
      USE Q3DMODULE
      
      Q3DDAT(IGRID)%NPILLAR=>NPILLAR
      Q3DDAT(IGRID)%MXQ3DITER=>MXQ3DITER
      
      IF(Q3DDAT(IGRID)%NPILLAR>0)THEN
        Q3DDAT(IGRID)%ITERQ3D=>ITERQ3D
        Q3DDAT(IGRID)%IPILLAR=>IPILLAR
        Q3DDAT(IGRID)%DELT0=>DELT0
        Q3DDAT(IGRID)%RELAXH=>RELAXH
        Q3DDAT(IGRID)%RELAXF=>RELAXF
        Q3DDAT(IGRID)%ACELL=>ACELL
        Q3DDAT(IGRID)%BOT=>BOT
        Q3DDAT(IGRID)%HP00=>HP00
        Q3DDAT(IGRID)%HP0=>HP0
        Q3DDAT(IGRID)%HP1O=>HP1O
        Q3DDAT(IGRID)%HP1N=>HP1N
        Q3DDAT(IGRID)%HCLOSURE=>HCLOSURE
        Q3DDAT(IGRID)%FCLOSURE=>FCLOSURE
        Q3DDAT(IGRID)%CNVGH=>CNVGH
        Q3DDAT(IGRID)%CNVGF=>CNVGF
        Q3DDAT(IGRID)%Q3DF=>Q3DF
        Q3DDAT(IGRID)%LINEARF=>LINEARF
        Q3DDAT(IGRID)%ADAPTF=>ADAPTF
        Q3DDAT(IGRID)%RRO=>RRO
        Q3DDAT(IGRID)%RRN=>RRN
        Q3DDAT(IGRID)%SY=>SY
        Q3DDAT(IGRID)%SS=>SS
        Q3DDAT(IGRID)%ZTB0=>ZTB0
        Q3DDAT(IGRID)%ZTB1=>ZTB1
        Q3DDAT(IGRID)%ICTRL0=>ICTRL0
        Q3DDAT(IGRID)%ICTRL1=>ICTRL1
        Q3DDAT(IGRID)%IBOT=>IBOT
      ENDIF
      END

      SUBROUTINE GWF2Q3D1AD(IGRID)
      USE Q3DMODULE,   ONLY:DELT0,NPILLAR,HP1N,HP0,HP00,Q3DF,LINEARF
      USE GLOBAL,      ONLY:HNEW,HOLD
      USE GWFBASMODULE,ONLY:DELT,TOTIM
      USE HYDRUS,      ONLY:HYDRUSDAT
      IF(.NOT.Q3DF)RETURN
      T0=(TOTIM-DELT)
      IF(T0<=0 .OR..NOT.LINEARF)THEN
        HP1N=HP0
      ELSEIF(T0>0 .AND.LINEARF)THEN
        HP1N=HP0+(HP0-HP00)*(DELT)/DELT0!DELT0、HP00、HP0的更新见 GWF2BAS7AD(...)
        !得到预测的饱和模型解
      ENDIF
      RETURN
      END
      
      SUBROUTINE GWF2Q3D1RP(KKPER,IGRID)
      USE Q3DMODULE,ONLY:ACELL,BOT,NPILLAR,IPILLAR
      USE HYDRUS,ONLY:NumNP,X,KPILLAR
      USE GLOBAL,ONLY:NLAY,NCOL,NROW,IBOUND,DELC,DELR,BOTM
      IF(KKPER>1)RETURN
!     开始关联土柱节点和对应MODFLOW模型
!     先求各个柱子覆盖的MODFLOW单元面积Acell(NPILLAR)，以及各个土柱底板高程BOT(NLAY,NPILLAR)
      IPILLAR=IBOUND
      DO K=0,NLAY
        DO J=1,NCOL
          DO I=1,NROW
            IP=IPILLAR(J,I,1)
            IF(IP<=0)CYCLE
            IF(K==0)ACELL(IP)=ACELL(IP)+DBLE(DELC(I)*DELR(J))
            BOT(K,IP)=BOT(K,IP)+DBLE(DELC(I)*DELR(J)*BOTM(J,I,K))
          ENDDO
        ENDDO
      ENDDO
      DO K=0,NLAY
        DO IP=1,NPILLAR
          BOT(K,IP)=BOT(K,IP)/ACELL(IP)
        ENDDO
      ENDDO
!     将各个土柱节点与虚拟土柱层号对应
      DO IP=1,NPILLAR
        CALL HYDRUS1PNT(IP,IGRID)
        KPILLAR(1)=1! JCZENG 20180412 强制柱子顶部位于地表
        DO I=2,NumNP
          DO K=1,NLAY
            Z1=BOT(K-1,IP)
            Z0=BOT(K,IP)
            ZZ=BOT(0,IP)-X(I)
            IF(ZZ<=Z1 .AND. ZZ>Z0)THEN
              KPILLAR(I)=K
              EXIT
            ELSEIF(ZZ==Z0 .AND.K==NLAY)THEN
              KPILLAR(I)=K
              EXIT
            ENDIF
          ENDDO
        ENDDO
      ENDDO
      RETURN
      END
      

      SUBROUTINE PILLAR_RP(IP,T0)
      USE Q3DMODULE,ONLY:HP00,HP0,HP1N
      USE HYDRUS,ONLY:HPILLAR00,HPILLAR0,HPILLAR1N
      REAL T0
      !IF(T0==0)HP00=HP0
      CALL EQUIVALENT_PILLAR(HPILLAR00,HP00,IP)
      CALL EQUIVALENT_PILLAR(HPILLAR0, HP0, IP)
      CALL EQUIVALENT_PILLAR(HPILLAR1N,HP1N,IP)
      
      RETURN
      END
      
      SUBROUTINE TIME_INTERPOLATION(T1,T0,IP)
      ! PREDICTING THE LOWER BOUNDARY OF THE SOIL COLUMNS
      USE Q3DMODULE,ONLY:DELT0,IBOT,BOT,Q3DF,ADAPTF
      USE HYDRUS,ONLY:T,NUMNP,HPILLAR00,HPILLAR0,HPILLAR1N,HPILLAR,X
      USE GWFBASMODULE,ONLY:DELT
      
      DIMENSION A(NUMNP),B(NUMNP),C(NUMNP)
      REAL T1,T0
      DOUBLEPRECISION XTABLE,XMID
      IF(Q3DF)THEN
        !IF(T0<=0)THEN
        
        HPILLAR=HPILLAR0+(HPILLAR1N-HPILLAR0)*(T-T0)/DELT
          
!        ELSEIF(T0>0)THEN !SECOND ORDER INTERPOLATION
!         A=((HPILLAR1N-HPILLAR0)/DELT-(HPILLAR0-HPILLAR00)/DELT0)
!       1  /(DELT+DELT0)
!         B=(HPILLAR0-HPILLAR00)/DELT0
!         C=HPILLAR1N-A*T1*T1-B*T1
!         HPILLAR=A*T*T+B*T+C
!        ENDIF
        IF(ADAPTF)THEN
          XTABLE=BOT(0,IP)-HPILLAR
          DO I=1,NUMNP-1
            XMID=(X(I)+X(I+1))/2.
            
            IF(XTABLE>=X(I).AND.XTABLE<X(I+1))THEN
              IF(XTABLE<XMID)THEN
                IBOT(IP)=I
              ELSEIF(XTABLE>=XMID)THEN
                IBOT(IP)=I+1
              ENDIF
              EXIT
            ELSEIF(XTABLE>=X(I+1))THEN
              CYCLE
            ENDIF
            CALL USTOP('NO TABLE FOUND FOR MOVING LOWER BOUNDARY')
          ENDDO
          IBOT(IP)=IBOT(IP)+3
          
        ELSE
          IBOT(IP)=NUMNP
        ENDIF
      ELSE
        IBOT(IP)=NUMNP
        RETURN
      ENDIF
	  write(*,*) IBOT,XTABLE
      RETURN
      END
      
      SUBROUTINE EQUIVALENT_PILLAR(HC,HP,IP)
      USE GLOBAL,ONLY:NCOL,NROW,NLAY,DELC,DELR,BOTM
      USE HYDRUS,ONLY:NUMNP,KPILLAR
      USE Q3DMODULE,ONLY:ACELL,IPILLAR
      
      DIMENSION HP(NCOL,NROW)
      DOUBLEPRECISION HP,HC
      HC=0.
      DO I=1,NROW
        DO J=1,NCOL
          JP=IPILLAR(J,I,1)
          IF(JP.NE.IP)CYCLE
          HC=HC+DBLE(DELC(I))*DBLE(DELR(J))*HP(J,I)
        ENDDO
      ENDDO
      HC=HC/ACELL(IP)
      RETURN
      END
      
      SUBROUTINE HYDRUS1BOT(IP,A,P,N)
      USE HYDRUS,ONLY:X,CON,T,HPILLAR
      USE Q3DMODULE,ONLY:BOT,Q3DF
      DOUBLEPRECISION A,P
      DIMENSION A(N,3),P(N)
      
      IF(.NOT.Q3DF)RETURN
      A(N,2)=1.D+30
      A(N,3)=0.
      P(N)=(HPILLAR-BOT(0,IP)+X(N))*1.D+30
!	  write(*,*) X(N),HPILLAR, N
      RETURN
      END
      
      SUBROUTINE HYDRUS1RECHARGE(T1,T0,ITERQ3D,IP,IGRID)
      USE HYDRUS,      ONLY:CON,HNEW,X,NUMNP,T,DT,THN,Z,v,THO,iTlevel,
     1                      KPILLAR,QS,THETA0,THETA0,THETA1
      USE GWFBASMODULE,ONLY:DELT
      USE Q3DMODULE,   ONLY:RrN,RrO,BOT,MXQ3DITER,RELAXF,SY,SS,
     1                      ICTRL0,ICTRL1,ZTB0,ZTB1,Q3DF
      REAL T1,T0,SC2
      
      IF(.NOT.Q3DF)RETURN !JCZENG 20180414
      
      !记录初始T0时刻含水率曲线
      IF(iTlevel==0)THEN
        THETA0(:)=THN(:)
        QS(:)=0.
!		write(*,*) THN, HNEW
        CALL FINDTABLE(ICTRL0(IP),ZTB0(IP),IP,HNEW)
        RETURN
      ENDIF
      !记录T1末时刻含水率曲线
      IF(ABS(T-T1)<=0.001*dt.AND.T<=T1)THEN
        THETA1(:)=THN(:)
!		write(*,*) THN, HNEW
      ENDIF
!      write(*,*) BOT(0,IP)
      
      !DELT内各节点的通量累积量Qs(NumNP,NPillar)
      IF(ITLEVEL>0)QS(:)=QS(:)+V(:)*DT 
      
      IF(ABS(T-T1)<=0.001*dt.AND.T<=T1)THEN
        CALL FINDTABLE(ICTRL1(IP),ZTB1(IP),IP,HNEW)!用这个变动节点作为下边界会很不稳定，所以仍然以N节点为柱子下边界
        QS(:)=QS(:)/DELT
        
!       通过ictrl0和ictrl1来确认is和imax
        IS=MIN(ICTRL0(IP),ICTRL1(IP))-3

        IMAX=MAX(ICTRL0(IP),ICTRL1(IP))+2
!       储水变化量
        DW=0.
        DO I=IS,IMAX-1
          DW=DW+0.5*(X(I+1)-X(I))*
     1    (THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1))
        ENDDO
        DW=DW/DELT
        
!       修正项
        KT=KPILLAR(ICTRL1(IP))
        THK=BOT(0,IP)-BOT(KT,IP)-ZTB1(IP)
        dMOD=(SY(IP,KT)-SS(IP,KT)*THK)*(ZTB0(IP)-ZTB1(IP))/DELT
!       DMOD=SY(IP)*(ZTB0(IP)-ZTB1(IP))/DELT
        RrO(IP)=RrN(IP)
        RrN(IP)=DW+QS(IS)+dMOD
!       RRN(IP)=QS(IMAX-1)+DMOD
        
!     ***************************************************
!     CALCULATE SMALL-SCALE SPECIFIC YIELDS JCZENG 20180423
!                write(*,*) ICTRL0(IP),ICTRL1(IP)
				SC2=0.
        DO I=IS+3,IMAX-1
          SC2=SC2+0.5*(X(I+1)-X(I))*
     1    (THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1))
        ENDDO
        SC2=ABS(SC2/(DELT*(ZTB0(IP)-ZTB1(IP))))
        !SC2=ABS(DW/((ZTB0(IP)-ZTB1(IP))))
!     ***************************************************
        IF(ITERQ3D>1)BACKSPACE(9999)
        write(9999,'(100f20.10)')t,RRN(IP),SC2
      ENDIF
      RETURN
      END
      
      SUBROUTINE FINDTABLE(ICTRL,ZTB,IP,HC)
      USE Q3DMODULE,ONLY:BOT
      USE HYDRUS,ONLY:X,NUMNP
      INTEGER ICTRL,IP
      DOUBLEPRECISION HEAD1,HEAD0,XMID,HCHILD,X0,X1
      DOUBLEPRECISION ZTB, HC
      DIMENSION HC(NUMNP)
      ZTB=0.
      DO I=NUMNP,2,-1!找到各个虚拟柱子控制潜水面的非饱和节点编号
        HEAD1=HC(I)
        X1=X(I)
        HEAD0=HC(I-1)
        X0=X(I-1)
        IF(HEAD1>0 .AND. HEAD0<=0)THEN
          ZTB=(HEAD1*X0-HEAD0*X1)/(HEAD1-HEAD0)
          XMID=(X(I)+X(I-1))/2.
          IF(ZTB>=XMID)THEN
            ICTRL=I
          ELSEIF(ZTB<XMID)THEN
            ICTRL=I-1
          ENDIF
          EXIT
        ENDIF
      ENDDO
      IF(ZTB<=0)CALL USTOP('NO GROUNDWATER TABLE FOUND IN MODFLOW!')

      RETURN
      END
      
      SUBROUTINE GWF2Q3D1RECHARGE(ITERQ3D,IGRID)
      USE Q3DMODULE,ONLY:RrN,IPILLAR,Q3DF,NPILLAR
      USE HYDRUS,ONLY:KPILLAR,HYDRUSDAT
      USE GLOBAL,ONLY:NCOL,NROW,NLAY,IBOUND,RHS,DELR,DELC,hnew,BOTM
      
      DOUBLEPRECISION ZTB
      INTEGER ICTRL
      DIMENSION ICTRL(NPILLAR)
!	  write(*,*) NLAY
      IF(.NOT.Q3DF)RETURN
      
      !DO IP=1,NPILLAR
      !  CALL FINDTABLE(ICTRL(IP),ZTB,IP,HYDRUSDAT(IP,IGRID)%HBACK)
      !ENDDO
      
      DO IR=1,NROW
        DO IC=1,NCOL
          IP=IPILLAR(IC,IR,1)
          DO IL=1,NLAY
            IB=IBOUND(IC,IR,IL)  
            IF(IB<=0)CYCLE
            IF(IP==IB)THEN
              RHS(IC,IR,IL)=RHS(IC,IR,IL)-DELC(IR)*DELR(IC)*RrN(IB)
              EXIT
            ENDIF
          ENDDO
        ENDDO
      ENDDO
      RETURN
      END
!      
      SUBROUTINE HYDRUS1REWIND(I,J)
      USE HYDRUSPARA,ONLY:IWAT
      
      IDC=1000*(J-1)+25*(I-1)+100
      REWIND(IDC+IWAT)
      
      RETURN
      END


