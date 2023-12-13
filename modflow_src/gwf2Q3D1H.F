      SUBROUTINE HYDRUS1AR(I,J)
      USE HYDRUS
      USE HYDRUSPARA
      
      CHARACTER*260 PATH
      CHARACTER*5 CC,PP
      INTEGER idc
      
      WRITE(CC,'(I5)')J
      WRITE(PP,'(I5)')I
      idc=1000*(J-1)+25*(I-1)+100
      PATH='GRID'//TRIM(ADJUSTL(CC))//'/HYDRUS'//TRIM(ADJUSTL(PP))//'/'
      open(idc+imain,file=TRIM(ADJUSTL(PATH))//'MAIN.IN',
     1status='old')!,access='stream',convert='little_endian'
      open(idc+irun,file=TRIM(ADJUSTL(PATH))//'RUN.OUT', 
     1  status='unknown')
      open(idc+icheck,file=TRIM(ADJUSTL(PATH))//'CHECK.OUT'  , 
     1  status='unknown')
      ALLOCATE(
     . WaterF,SolutF,HeatF,RootF,WLayrF,qGWLF,ShortF,H_weight,
     . SeepF,AtmBCF,ConvgF,SatF,ChangF,Linear,ScrnF,weight,SStrsF,
     . SteadyF,Picard,UserF,LUNIT,TUNIT,HEADING,
     ! IHys,iPlevel,IRoot,ItCum,ItCumS,Iter,iTlevel,KBotCh,KBotH,
     ! KodBot,KodTop,KODTOP0,KTopCh,KTopH,MaxIt,Nit,NItMax,NMat,
     ! NMatD,NObs,NParD,NReg,NTabD,NumNP,NUMNPD,
     ! Ampl,cBot,Courant,Cs,Ctol,cTop,CosAlf,DMul1,DMul2,
     ! dt,dtH,dtMax,dtMin,dtS,dtW,Epsi,hBot,DTBACK,dtforward,
     ! hCritA,HPeclet,hRoot,hTabM,hTop,Omega,Omega_H,Omega0,
     ! Peclet,rBot,rRoot,rTop,Sv0C,Sv1C,Sv1T,SvBot,SvBotC,
     ! SvBotH,SvRoot,SvTop,SvTopC,SvTopH,t,tBC,tBCH,tBCR,tBCS,
     ! tEnd,Tol,tOld,Tolh,TpBot,TpTop,vBot,vRoot,vTop,
     1 IPLEVELBACK,DTINIT)
      ALLOCATE(TBC0,RTOP0,RBOT0,HTOP0,HBOT0,RTOP1,RBOT1,HTOP1,
     ! HBOT1,RTOP2,RBOT2,HTOP2,HBOT2,CTOP1,CTOP2,CBOT1,CBOT2,
     ! TPTOP1,TPTOP2,TPBOT1,TPBOT2,AMPL1,AMPL2,RROOT1,RROOT2,
     ! vinitW,vinitS,vinitH,CRROOT,CVROOT,SRTOP,TBC1,
     ! TBCS1,plnmsF,plnmhF,TBCH1,TBCR1,plnmrF,PLNMWF,BCKSPWF)
      ALLOCATE(SvTop0,SvBot0,SvRoot0)  !BACKUP ACCUMULATED BOUNDARY
      
!     NumNPD = 300    !Maximum number of nodal points
!     NMatD  =  10    !Maximum number of soil layers
      NParD  =   6    !Maximum number of soil hydraulic parameters
!     NTabD  = 100    !Maximum number of lines in soil tables
      CALL DIMENSIONIZE(NUMNPD,NMATD,NTABD,IDC,PATH)
      ALLOCATE(
*     Shared arrays
     .x(NumNPD),MatNum(NumNPD),iReg(NumNPD),TPrint(50),CAP(NumNPD),
     .CONO(NumNPD),HTEMP(NumNPD),HOLD(NumNPD),P(NumNPD),A(NumNPD,3),
     .xObs(5),iObs(5),z(NumNPD),
*     Water specific arrays
     .Par(NParD,NMatD,2),ConSat(NMatD),ThS(NMatD),ThR(NMatD),phi(NumNPD)
     .,hSat(NMatD),Ah(NumNPD),AK(NumNPD),ATh(NumNPD),hTab(NTabD),
     .ConTab(NTabD,NMatD),CapTab(NTabD,NMatD),STab(NTabD,NMatD),
     .hNew(NumNPD),ThN(NumNPD),ThO(NumNPD),Con(NumNPD),Kappa(NumNPD),
     .KappaO(NumNPD),AThS(NumNPD),ThRR(NumNPD),ConR(NumNPD),AKS(NumNPD),
     .AhW(NMatD),AThW(NMatD),AKW(NMatD),v(NumNPD),vOld(NumNPD),
*     Solute, heat and root specific arrays
     .ChPar(20,NMatD),Conc(NumNPD),g1(NumNPD),g0(NumNPD),HPar(20,NMatD),
     .Temp(NumNPD),RSPar(9,NMatD),Sink(NumNPD),Beta(NumNPD),Salt(NumNPD)
     .,SaltO(NumNPD),Alpha(NumNPD),Bet(NumNPD),qt(NumNPD),qtOld(NumNPD),
     .CapS(NumNPD),gT1(NumNPD))
      ALLOCATE(hBACK(NUMNPD))
      ALLOCATE(iEQ(NUMNPD),iELE(NUMNPD),DIFF(NUMNPD),THRESH,icoup,
     1 thTab(NTabD,NMatD),DIFFTAB(NTABD,NMATD))!,FLUX(NUMNPD))
      ALLOCATE(INTERF(NUMNPD),THNA(NUMNPD),THNB(NUMNPD))
      
      ! JCZENG 2018.4.7 FOR QUASI-3D COUPLING
      ALLOCATE(THETA0(NUMNPD),THETA1(NUMNPD),HPILLAR,
     1KPILLAR(NUMNPD),QS(NUMNPD),HPILLAR00,HPILLAR0,
     1HPILLAR1N)
      
      THETA0=0.
      THETA1=1.
      HPILLAR=0.
      HPILLAR00=0.
      HPILLAR0=0.
      HPILLAR1N=0.
      KPILLAR=0
      QS=0.
      
      CALL ZEROIZE()
      CALL Main_In(
     . Heading,WaterF,SteadyF,SolutF,HeatF,RootF,LUnit,CosAlf,
     . NumNP,NMat,NReg,iReg,TUnit,t,tEnd,dt,dtMin,dtMax,
     . tBC,tBCS,tBCH,dtW,dtS,dtH,TPrint,iPlevel,ShortF,Sink,SvTop,
     . SvBot,SvRoot,vRoot,SvTopC,SvBotC,Sv0C,Sv1C,Sv1T,Cs,xObs,iObs,
     . NObs,ScrnF,tBCR,MaxIt,idc)
      CALL Main_Check_Out(NumNP,x,MatNum,iReg,IDC)
      
      IF(WATERF)open(idc+iwat, file=TRIM(ADJUSTL(PATH))//'WATER.IN',
     1status='old')!,access='stream',convert='little_endian'
      IF(SOLUTF)open(idc+islt, file=TRIM(ADJUSTL(PATH))//'SOLUTE.IN',
     1status='old')
      IF(ROOTF)open(idc+irt,  file=TRIM(ADJUSTL(PATH))//'ROOT.IN',
     1status='old')
      IF(HEATF)open(idc+iHEAT,file=TRIM(ADJUSTL(PATH))//'HEAT.IN',
     1status='old')
        
      open(idc+iwmat,file=TRIM(ADJUSTL(PATH))//'W_MATER.OUT', 
     1    status='unknown')
      open(idc+iwbc,file=TRIM(ADJUSTL(PATH))//'W_BC.OUT',
     1status='unknown')
      open(idc+iwnod,file=TRIM(ADJUSTL(PATH))//'W_NODES.OUT',
     1status='unknown')
      open(idc+iwbal,file=TRIM(ADJUSTL(PATH))//'W_BALANC.OUT',
     1status='unknown')
      open(idc+iwobs,file=TRIM(ADJUSTL(PATH))//'W_OBSERV.OUT',
     1status='unknown')
      
      IF(SOLUTF)THEN
        open(idc+isbc,file=TRIM(ADJUSTL(PATH))//'S_BC.OUT',    
     1  status='unknown')
        open(idc+isnod,file=TRIM(ADJUSTL(PATH))//'S_NODES.OUT' ,
     1  status='unknown')
        open(idc+isbal,file=TRIM(ADJUSTL(PATH))//'S_BALANC.OUT',
     1  status='unknown')
        open(idc+isobs,file=TRIM(ADJUSTL(PATH))//'S_OBSERV.OUT',
     1  status='unknown')
      ENDIF
      IF(HEATF)THEN
        open(idc+ihbc,file=TRIM(ADJUSTL(PATH))//'H_BC.OUT',    
     1  status='unknown')
        open(idc+ihnod,file=TRIM(ADJUSTL(PATH))//'H_NODES.OUT' ,
     1  status='unknown')
        open(idc+ihbal,file=TRIM(ADJUSTL(PATH))//'H_BALANC.OUT',
     1  status='unknown')
        open(idc+ihobs,file=TRIM(ADJUSTL(PATH))//'H_OBSERV.OUT',
     1  status='unknown')
      ENDIF
      
      IF(ROOTF)THEN
        open(idc+irbc,file=TRIM(ADJUSTL(PATH))//'R_BC.OUT',    
     1  status='unknown')
        open(idc+irobs,file=TRIM(ADJUSTL(PATH))//'R_OBSERV.OUT',
     1  status='unknown')
        open(idc+irnod,file=TRIM(ADJUSTL(PATH))//'R_NODES.OUT', 
     1  status='unknown')
      ENDIF
        CALL HYDRUS1PSV(I,J)
      RETURN
      END
      SUBROUTINE DIMENSIONIZE(NUMNPD,NMATD,NTABD,IDC,PATH)
      
      USE HYDRUSPARA,ONLY:IMAIN,IWAT
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      LOGICAL STARF
      CHARACTER*260 PATH
      
      ALLOCATABLE Z(:)
      call SkipStars(idc+imain)
      read(idc+imain,*) 
      call SkipStars(idc+imain)
      read(idc+imain,*)
      call SkipStars(idc+imain)
      read(idc+imain,*) 
      call SkipStars(idc+imain)
      read(idc+imain,*) 
      call SkipStars(idc+imain)
      read(idc+imain,*) Ndx
      NumNPD=Ndx+1
      ALLOCATE(Z(NDX))
      call SkipStars(idc+imain)
      read(idc+imain,*) (z(i),i=1,Ndx)
      call SkipStars(idc+imain)
      DO WHILE(.NOT.STARF(IDC+IMAIN))
        read(idc+imain,*) x,Depth,Mat,Reg
        NMATD=MAX(NMATD,MAT)
      ENDDO
      open(idc+iwat, file=TRIM(ADJUSTL(PATH))//'WATER.IN',
     1status='old')!,access='stream',convert='little_endian'
      call SkipStars(idc+iwat)
      read(idc+iwat,*) II!,NTABD
      NTABD=20  !Table size is limited for saving memory usage
      REWIND(IDC+IMAIN)
      CLOSE(IDC+IWAT)
      RETURN
      END

      SUBROUTINE HYDRUS1MAIN(hNew1,ThN1)	  
      USE HYDRUS
      USE HYDRUSPARA
	  DOUBLEPRECISION,DIMENSION(1001)::hNew1,ThN1
!      implicit doubleprecision(A-H,O-Z)
!      DOUBLEPRECISION ThN
!      call STEMWater(hNew,ThN,dble(hNew1),dble(ThN1))
!    .  hNew,ThN,hNew1,ThN1)
!       write(*,*)'HYDRUS =',hNew,ThN
!       dimension
!      .hNew(NUMNP),ThN(NUMNP)!,hNew1(NUMNP),ThN1(NUMNP),STab(NTabD,*),ConO(NUMNP),
!	  ! hNew=hNew1
!	  ! ThN=ThN1
!     ! .MatNum(*),x(NUMNP),Par(NParD,NMatD,2),Con(NUMNP),Cap(NUMNP),
!     ! 1ConSat(NUMNP),hSat(NUMNP),
!     ! .ThR(NUMNP),ThS(NUMNP),Ah(*),AK(*),ATh(*),xObs(*),iObs(*),
!     ! 1hTab(*),vOld(NUMNP),ConTab(NTabD,*),CapTab(NTabD,*),
!
!     ! .hOld(NUMNP),hTemp(NUMNP),ThO(NUMNP),Sink(NUMNP),
!     ! 1A(NumNP,3),TPrint(*),v(NUMNP),iReg(*),P(NUMNP),Kappa(*),KappaO(*),
!     ! .AThS(*),ThRR(*),ConR(*),AKS(*),
!     ! .AhW(*),AThW(*),AKW(*),qt(NUMNP),qtOld(NUMNP)	  
!      REAL T0
!      idc=1000*(J-1)+25*(I-1)+100!idc为逻辑单元基准
      IF(WATERF)call STEMWater(hNew,ThN,dble(hNew1),dble(ThN1))
!     .  hNew,ThN,dble(hNew1),dble(ThN1))
!     .  TUnit,iTlevel,t,tBC,tEnd,dt,dtMin,dtMax,tOld,dtW,Iter,
!     .  ItCum,Tol,Tolh,MaxIt,DMul1,DMul2,ConvgF,ChangF,iPlevel,
!     .  TPrint,ShortF,Heading,xObs,iObs,NObs,ScrnF,Par,
!     .  NParD,ConSat,hSat,ThR,ThS,Ah,AK,ATh,NTabD,hTab,
!     .  hTabM,ConTab,CapTab,STab,IHys,Kappa,KappaO,
!     .  AThS,ThRR,ConR,AKS,AhW,AThW,AKW,KodTop,KodBot,
!     .  rTop,rBot,hTop,hBot,hCritA,SteadyF,AtmBCF,SeepF,
!     .  WLayrF,qGWLF,vRoot,SvTop,SvBot,SvRoot,SatF,hNew,
!     .  HOLD,HTEMP,ThN,ThO,Con,CONO,CAP,Sink,A,P,vTop,vBot,v,
!     .  vOld,qt,qtOld,IDC,I,T0,ITERQ3D)
!      if(iTlevel.gt.2.and.SteadyF)stop
!      ! if(SolutF)call Solute(
!     ! .  NumNP,NMat,NReg,MatNum,iReg,x,LUnit,TUnit,iTlevel,
!     ! .  t,tBCS,tEnd,dt,dtMax,TPrint,iPlevel,ShortF,dtS,xObs,iObs,
!     ! .  NObs,ScrnF,Heading,Linear,weight,Alpha,Nit,ItCumS,NItMax,
!     ! .  Ctol,Epsi,ChPar,Peclet,Courant,KTopCh,KBotCh,cTop,cBot,
!     ! .  SvTopC,SvBotC,Sv0C,Sv1C,Sink,Cs,WaterF,Conc,HOLD,HTEMP,
!     ! .  CAP,CONO,v,vOld,g0,g1,A,P,ThN,ThO,qt,qtOld,phi,Salt,
!     ! .  SaltO,CapS,Picard,UserF,IDC,T0,ITERQ3D)
!      ! if(HeatF)call Heat(
!     ! .   NumNP,NMat,NReg,MatNum,iReg,x,LUnit,TUnit,iTlevel,t,tBCH,
!     ! .   tEnd,dt,dtH,TPrint,iPlevel,ShortF,xObs,iObs,NObs,ScrnF,
!     ! .   Heading,HPar,KTopH,KBotH,Ampl,Omega,Omega0,TpTop,TpBot,
!     ! .   SvTopH,SvBotH,WaterF,SolutF,HTEMP,Temp,CAP,CONO,
!     ! .   v,vOld,A,P,ThN,ThO,bet,H_weight,HPeclet,phi,Omega_H,
!     ! .   Sink,gT1,Sv1T,IDC,T0,ITERQ3D)
!      ! if(RootF)call Root(
!     ! .   NumNP,NMat,x,Beta,RSPar,t,tBCR,tEnd,dt,iTlevel,rRoot,vRoot,
!     ! .   hRoot,Cs,ScrnF,TPrint,iPlevel,ShortF,hNew,MatNum,Sink,Conc,
!     ! .   IRoot,HTEMP,WaterF,SolutF,xObs,iObs,NObs,CAP,SStrsF,IDC,
!     ! 1   T0,ITERQ3D)
!      ! call Run_Out(
!     ! .   iTlevel,t,dt,Iter,ItCum,ItcumS,ConvgF,ShortF,WaterF,TPrint,
!     ! 1   iPlevel,Nit,Peclet,Courant,SolutF,IDC,T0,ITERQ3D)
!      ! RETURN
      END

*     Source file WATER.FOR
      subroutine STEMWater(hNew,ThN,hNew1,ThN1)
!*     Geometry, time, iteration and print control parameters
!     .hNew,ThN,hNew1,ThN1)
      USE HYDRUSPARA
!      USE HYDRUS,ONLY:tBC1,IEQ,IELE,PlnmWF,BckspWF
!      USE Q3DMODULE,ONLY:IBOT
	  DOUBLEPRECISION,DIMENSION(1001)::hNew,ThN,hNew1,ThN1
!      implicit doubleprecision(A-H,O-Z)
!      character*72 Heading
!      character*7 LUnit,TUnit
!      integer iTlevel,iPlevel,iReg
!      DOUBLEPRECISION ThN,ThN1!ConTab,CapTab,STab,Con,Cap,ConO,ThN,ThO,RT,ST,
!     1PT,A,P,t,
!     1tOld,tBC,tEnd,TPrint
!      logical ConvgF,qGWLF,AtmBCF,WLayrF,SeepF,ChangF,ShortF,
!     .SatF,ScrnF,SteadyF
!      REAL T0
!      dimension
!     .hNew(NUMNP),ThN(NUMNP),hNew1(NUMNP),ThN1(NUMNP) 
	 
	  hNew=dble(hNew1)
	  ThN=dble(ThN1)
!	  write(*,*)'HPILLAR = ',ThN1,HNEW1
	  END
	  
      SUBROUTINE HYDRUS1PNT(I,J)
      USE HYDRUS
      ! FOR QUASI-3D  JCZENG 2018.4.7
      THETA0=>HYDRUSDAT(I,J)%THETA0
      THETA1=>HYDRUSDAT(I,J)%THETA1
      HPILLAR=>HYDRUSDAT(I,J)%HPILLAR
      HPILLAR00=>HYDRUSDAT(I,J)%HPILLAR00
      HPILLAR0=>HYDRUSDAT(I,J)%HPILLAR0
      HPILLAR1N=>HYDRUSDAT(I,J)%HPILLAR1N
      KPILLAR=>HYDRUSDAT(I,J)%KPILLAR
      QS=>HYDRUSDAT(I,J)%QS
      
        A=>HYDRUSDAT(I,J)%A
        Ah=>HYDRUSDAT(I,J)%Ah
        AhW=>HYDRUSDAT(I,J)%AhW
        AK=>HYDRUSDAT(I,J)%AK
        AKS=>HYDRUSDAT(I,J)%AKS
        AKW=>HYDRUSDAT(I,J)%AKW
        Alpha=>HYDRUSDAT(I,J)%Alpha
        Ampl=>HYDRUSDAT(I,J)%Ampl
        ATh=>HYDRUSDAT(I,J)%ATh
        AThS=>HYDRUSDAT(I,J)%AThS
        AThW=>HYDRUSDAT(I,J)%AThW
        AtmBCF=>HYDRUSDAT(I,J)%AtmBCF
        Bet=>HYDRUSDAT(I,J)%Bet
        Beta=>HYDRUSDAT(I,J)%Beta
        CapS=>HYDRUSDAT(I,J)%CapS
        CAPTAB=>HYDRUSDAT(I,J)%CAPTAB
        cBot=>HYDRUSDAT(I,J)%cBot
        ChangF=>HYDRUSDAT(I,J)%ChangF
        CHPAR=>HYDRUSDAT(I,J)%CHPAR
        CAP=>HYDRUSDAT(I,J)%CAP
        CONO=>HYDRUSDAT(I,J)%CONO
        HTEMP=>HYDRUSDAT(I,J)%HTEMP
        HOLD=>HYDRUSDAT(I,J)%HOLD
        Con=>HYDRUSDAT(I,J)%Con
        Conc=>HYDRUSDAT(I,J)%Conc
        ConR=>HYDRUSDAT(I,J)%ConR
        ConSat=>HYDRUSDAT(I,J)%ConSat
        CONTAB=>HYDRUSDAT(I,J)%CONTAB
        ConvgF=>HYDRUSDAT(I,J)%ConvgF
        CosAlf=>HYDRUSDAT(I,J)%CosAlf
        Courant=>HYDRUSDAT(I,J)%Courant
        Cs=>HYDRUSDAT(I,J)%Cs
        Ctol=>HYDRUSDAT(I,J)%Ctol
        cTop=>HYDRUSDAT(I,J)%cTop
        DMul1=>HYDRUSDAT(I,J)%DMul1
        DMul2=>HYDRUSDAT(I,J)%DMul2
        dt=>HYDRUSDAT(I,J)%dt
        dtBACK=>HYDRUSDAT(I,J)%dtBACK
        dtforward=>hydrusdat(i,j)%dtforward
        dtH=>HYDRUSDAT(I,J)%dtH
        dtMax=>HYDRUSDAT(I,J)%dtMax
        dtMin=>HYDRUSDAT(I,J)%dtMin
        dtS=>HYDRUSDAT(I,J)%dtS
        dtW=>HYDRUSDAT(I,J)%dtW
        DTINIT=>HYDRUSDAT(I,J)%DTINIT
        Epsi=>HYDRUSDAT(I,J)%Epsi
        g0=>HYDRUSDAT(I,J)%g0
        g1=>HYDRUSDAT(I,J)%g1
        gT1=>HYDRUSDAT(I,J)%gT1
        H_weight=>HYDRUSDAT(I,J)%H_weight
        hBot=>HYDRUSDAT(I,J)%hBot
        hCritA=>HYDRUSDAT(I,J)%hCritA
        HeatF=>HYDRUSDAT(I,J)%HeatF
        hNew=>HYDRUSDAT(I,J)%hNew
        HPAR=>HYDRUSDAT(I,J)%HPAR
        HPeclet=>HYDRUSDAT(I,J)%HPeclet
        hRoot=>HYDRUSDAT(I,J)%hRoot
        hSat=>HYDRUSDAT(I,J)%hSat
        hTab=>HYDRUSDAT(I,J)%hTab
        hTabM=>HYDRUSDAT(I,J)%hTabM
        hTop=>HYDRUSDAT(I,J)%hTop
        IHys=>HYDRUSDAT(I,J)%IHys
        iObs=>HYDRUSDAT(I,J)%iObs
        iPlevel=>HYDRUSDAT(I,J)%iPlevel
        iPlevelBACK=>HYDRUSDAT(I,J)%iPlevelBACK
        iReg=>HYDRUSDAT(I,J)%iReg
        IRoot=>HYDRUSDAT(I,J)%IRoot
        ItCum=>HYDRUSDAT(I,J)%ItCum
        ItCumS=>HYDRUSDAT(I,J)%ItCumS
        Iter=>HYDRUSDAT(I,J)%Iter
        iTlevel=>HYDRUSDAT(I,J)%iTlevel
        Kappa=>HYDRUSDAT(I,J)%Kappa
        KappaO=>HYDRUSDAT(I,J)%KappaO
        KBotCh=>HYDRUSDAT(I,J)%KBotCh
        KBotH=>HYDRUSDAT(I,J)%KBotH
        KodBot=>HYDRUSDAT(I,J)%KodBot
        KodTop=>HYDRUSDAT(I,J)%KodTop
        KodTop0=>HYDRUSDAT(I,J)%KodTop0
        KTopCh=>HYDRUSDAT(I,J)%KTopCh
        KTopH=>HYDRUSDAT(I,J)%KTopH
        Linear=>HYDRUSDAT(I,J)%Linear
        MatNum=>HYDRUSDAT(I,J)%MatNum
        PLNMWF=>HYDRUSDAT(I,J)%PLNMWF
        BCKSPWF=>HYDRUSDAT(I,J)%BCKSPWF
        MaxIt=>HYDRUSDAT(I,J)%MaxIt
        Nit=>HYDRUSDAT(I,J)%Nit
        NItMax=>HYDRUSDAT(I,J)%NItMax
        NMat=>HYDRUSDAT(I,J)%NMat
        NMatD=>HYDRUSDAT(I,J)%NMatD
        NObs=>HYDRUSDAT(I,J)%NObs
        NParD=>HYDRUSDAT(I,J)%NParD
        NReg=>HYDRUSDAT(I,J)%NReg
        NTabD=>HYDRUSDAT(I,J)%NTabD
        NumNP=>HYDRUSDAT(I,J)%NumNP
        NUMNPD=>HYDRUSDAT(I,J)%NUMNPD
        Omega=>HYDRUSDAT(I,J)%Omega
        Omega_H=>HYDRUSDAT(I,J)%Omega_H
        Omega0=>HYDRUSDAT(I,J)%Omega0
        P=>HYDRUSDAT(I,J)%P
        Par=>HYDRUSDAT(I,J)%Par
        Peclet=>HYDRUSDAT(I,J)%Peclet
        phi=>HYDRUSDAT(I,J)%phi
        Picard=>HYDRUSDAT(I,J)%Picard
        qGWLF=>HYDRUSDAT(I,J)%qGWLF
        qt=>HYDRUSDAT(I,J)%qt
        qtOld=>HYDRUSDAT(I,J)%qtOld
        rBot=>HYDRUSDAT(I,J)%rBot
        RootF=>HYDRUSDAT(I,J)%RootF
        rRoot=>HYDRUSDAT(I,J)%rRoot
        RSPAR=>HYDRUSDAT(I,J)%RSPAR
        rTop=>HYDRUSDAT(I,J)%rTop
        Salt=>HYDRUSDAT(I,J)%Salt
        SaltO=>HYDRUSDAT(I,J)%SaltO
        SatF=>HYDRUSDAT(I,J)%SatF
        ScrnF=>HYDRUSDAT(I,J)%ScrnF
        SeepF=>HYDRUSDAT(I,J)%SeepF
        ShortF=>HYDRUSDAT(I,J)%ShortF
        Sink=>HYDRUSDAT(I,J)%Sink
        SolutF=>HYDRUSDAT(I,J)%SolutF
        SStrsF=>HYDRUSDAT(I,J)%SStrsF
        STAB=>HYDRUSDAT(I,J)%STAB
        SteadyF=>HYDRUSDAT(I,J)%SteadyF
        Sv0C=>HYDRUSDAT(I,J)%Sv0C
        Sv1C=>HYDRUSDAT(I,J)%Sv1C
        Sv1T=>HYDRUSDAT(I,J)%Sv1T
        SvBot=>HYDRUSDAT(I,J)%SvBot
        SvBotC=>HYDRUSDAT(I,J)%SvBotC
        SvBotH=>HYDRUSDAT(I,J)%SvBotH
        SvRoot=>HYDRUSDAT(I,J)%SvRoot
        SvTop=>HYDRUSDAT(I,J)%SvTop
        SvTopC=>HYDRUSDAT(I,J)%SvTopC
        SvTopH=>HYDRUSDAT(I,J)%SvTopH
        t=>HYDRUSDAT(I,J)%t
        tBC=>HYDRUSDAT(I,J)%tBC
        tBCH=>HYDRUSDAT(I,J)%tBCH
        tBCR=>HYDRUSDAT(I,J)%tBCR
        tBCS=>HYDRUSDAT(I,J)%tBCS
        Temp=>HYDRUSDAT(I,J)%Temp
        tEnd=>HYDRUSDAT(I,J)%tEnd
        ThN=>HYDRUSDAT(I,J)%ThN
        ThO=>HYDRUSDAT(I,J)%ThO
        ThR=>HYDRUSDAT(I,J)%ThR
        ThRR=>HYDRUSDAT(I,J)%ThRR
        ThS=>HYDRUSDAT(I,J)%ThS
        Tol=>HYDRUSDAT(I,J)%Tol
        tOld=>HYDRUSDAT(I,J)%tOld
        Tolh=>HYDRUSDAT(I,J)%Tolh
        TpBot=>HYDRUSDAT(I,J)%TpBot
        TPrint=>HYDRUSDAT(I,J)%TPrint
        TpTop=>HYDRUSDAT(I,J)%TpTop
        UserF=>HYDRUSDAT(I,J)%UserF
        v=>HYDRUSDAT(I,J)%v
        vBot=>HYDRUSDAT(I,J)%vBot
        vOld=>HYDRUSDAT(I,J)%vOld
        vRoot=>HYDRUSDAT(I,J)%vRoot
        vTop=>HYDRUSDAT(I,J)%vTop
        WaterF=>HYDRUSDAT(I,J)%WaterF
        weight=>HYDRUSDAT(I,J)%weight
        WLayrF=>HYDRUSDAT(I,J)%WLayrF
        x=>HYDRUSDAT(I,J)%x
        xObs=>HYDRUSDAT(I,J)%xObs
        z=>HYDRUSDAT(I,J)%z
        LUNIT=>HYDRUSDAT(I,J)%LUNIT
        TUNIT=>HYDRUSDAT(I,J)%TUNIT
        HEADING=>HYDRUSDAT(I,J)%HEADING
        TBC0=>HYDRUSDAT(I,J)%TBC0
        RTOP0=>HYDRUSDAT(I,J)%RTOP0
        RBOT0=>HYDRUSDAT(I,J)%RBOT0
        HTOP0=>HYDRUSDAT(I,J)%HTOP0
        HBOT0=>HYDRUSDAT(I,J)%HBOT0
        RTOP1=>HYDRUSDAT(I,J)%RTOP1
        RBOT1=>HYDRUSDAT(I,J)%RBOT1
        HTOP1=>HYDRUSDAT(I,J)%HTOP1
        HBOT1=>HYDRUSDAT(I,J)%HBOT1
        RTOP2=>HYDRUSDAT(I,J)%RTOP2
        RBOT2=>HYDRUSDAT(I,J)%RBOT2
        HTOP2=>HYDRUSDAT(I,J)%HTOP2
        HBOT2=>HYDRUSDAT(I,J)%HBOT2
        CTOP1=>HYDRUSDAT(I,J)%CTOP1
        CTOP2=>HYDRUSDAT(I,J)%CTOP2
        CBOT1=>HYDRUSDAT(I,J)%CBOT1
        CBOT2=>HYDRUSDAT(I,J)%CBOT2
        TPTOP1=>HYDRUSDAT(I,J)%TPTOP1
        TPTOP2=>HYDRUSDAT(I,J)%TPTOP2
        TPBOT1=>HYDRUSDAT(I,J)%TPBOT1
        TPBOT2=>HYDRUSDAT(I,J)%TPBOT2
        AMPL1=>HYDRUSDAT(I,J)%AMPL1
        AMPL2=>HYDRUSDAT(I,J)%AMPL2
        RROOT1=>HYDRUSDAT(I,J)%RROOT1
        RROOT2=>HYDRUSDAT(I,J)%RROOT2
        vinitW=>HYDRUSDAT(I,J)%vinitW
        vinitS=>HYDRUSDAT(I,J)%vinitS
        vinitH=>HYDRUSDAT(I,J)%vinitH
        CRROOT=>HYDRUSDAT(I,J)%CRROOT
        CVROOT=>HYDRUSDAT(I,J)%CVROOT
        SRTOP=>HYDRUSDAT(I,J)%SRTOP
        SvTop0 =>HYDRUSDAT(I,J)%SvTop0 
        SvBot0 =>HYDRUSDAT(I,J)%SvBot0 
        SvRoot0=>HYDRUSDAT(I,J)%SvRoot0
        TBC1=>HYDRUSDAT(I,J)%TBC1
        TBCS1=>HYDRUSDAT(I,J)%TBCS1
        plnmsF=>HYDRUSDAT(I,J)%plnmsF
        plnmhF=>HYDRUSDAT(I,J)%plnmhF
        TBCH1=>HYDRUSDAT(I,J)%TBCH1
        TBCR1=>HYDRUSDAT(I,J)%TBCR1
        plnmrF=>HYDRUSDAT(I,J)%plnmrF
        HBACK=>HYDRUSDAT(I,J)%HBACK
        IEQ=>HYDRUSDAT(I,J)%IEQ
        IELE=>HYDRUSDAT(I,J)%IELE
        THRESH=>HYDRUSDAT(I,J)%THRESH
        DIFF=>HYDRUSDAT(I,J)%DIFF
        icoup=>HYDRUSDAT(I,J)%icoup
        THTAB=>HYDRUSDAT(I,J)%THTAB
        DIFFTAB=>HYDRUSDAT(I,J)%DIFFTAB
   !     FLUX=>HYDRUSDAT(I,J)%FLUX
        INTERF=>HYDRUSDAT(I,J)%INTERF
        THNA=>HYDRUSDAT(I,J)%THNA
        THNB=>HYDRUSDAT(I,J)%THNB
      RETURN
      END
      
      SUBROUTINE HYDRUS1PSV(I,J)
      USE HYDRUS
      ! FOR QUASI-3D JCZENG 2018.4.7
      HYDRUSDAT(I,J)%THETA0=>THETA0
      HYDRUSDAT(I,J)%THETA1=>THETA1
      HYDRUSDAT(I,J)%HPILLAR=>HPILLAR
      HYDRUSDAT(I,J)%HPILLAR00=>HPILLAR00
      HYDRUSDAT(I,J)%HPILLAR0=>HPILLAR0
      HYDRUSDAT(I,J)%HPILLAR1N=>HPILLAR1N
      HYDRUSDAT(I,J)%KPILLAR=>KPILLAR
      HYDRUSDAT(I,J)%QS=>QS
      
        HYDRUSDAT(I,J)%THNA=>THNA
        HYDRUSDAT(I,J)%THNB=>THNB
        HYDRUSDAT(I,J)%INTERF=>INTERF
        HYDRUSDAT(I,J)%THTAB=>THTAB
        HYDRUSDAT(I,J)%DIFFTAB=>DIFFTAB
        HYDRUSDAT(I,J)%IEQ=>IEQ
        HYDRUSDAT(I,J)%IELE=>IELE
        HYDRUSDAT(I,J)%THRESH=>THRESH
        HYDRUSDAT(I,J)%icoup=>icoup
        HYDRUSDAT(I,J)%DIFF=>DIFF
        HYDRUSDAT(I,J)%A=>A
        HYDRUSDAT(I,J)%Ah=>Ah
        HYDRUSDAT(I,J)%AhW=>AhW
        HYDRUSDAT(I,J)%AK=>AK
        HYDRUSDAT(I,J)%AKS=>AKS
        HYDRUSDAT(I,J)%AKW=>AKW
        HYDRUSDAT(I,J)%Alpha=>Alpha
        HYDRUSDAT(I,J)%Ampl=>Ampl
        HYDRUSDAT(I,J)%ATh=>ATh
        HYDRUSDAT(I,J)%AThS=>AThS
        HYDRUSDAT(I,J)%AThW=>AThW
        HYDRUSDAT(I,J)%AtmBCF=>AtmBCF
        HYDRUSDAT(I,J)%Bet=>Bet
        HYDRUSDAT(I,J)%Beta=>Beta
        HYDRUSDAT(I,J)%CapS=>CapS
        HYDRUSDAT(I,J)%CAPTAB=>CAPTAB
        HYDRUSDAT(I,J)%cBot=>cBot
        HYDRUSDAT(I,J)%ChangF=>ChangF
        HYDRUSDAT(I,J)%CHPAR=>CHPAR
        HYDRUSDAT(I,J)%CAP=>CAP
        HYDRUSDAT(I,J)%CONO=>CONO
        HYDRUSDAT(I,J)%HTEMP=>HTEMP
        HYDRUSDAT(I,J)%HOLD=>HOLD
        HYDRUSDAT(I,J)%Con=>Con
        HYDRUSDAT(I,J)%Conc=>Conc
        HYDRUSDAT(I,J)%ConR=>ConR
        HYDRUSDAT(I,J)%ConSat=>ConSat
        HYDRUSDAT(I,J)%CONTAB=>CONTAB
        HYDRUSDAT(I,J)%ConvgF=>ConvgF
        HYDRUSDAT(I,J)%CosAlf=>CosAlf
        HYDRUSDAT(I,J)%Courant=>Courant
        HYDRUSDAT(I,J)%Cs=>Cs
        HYDRUSDAT(I,J)%Ctol=>Ctol
        HYDRUSDAT(I,J)%cTop=>cTop
        HYDRUSDAT(I,J)%DMul1=>DMul1
        HYDRUSDAT(I,J)%DMul2=>DMul2
        HYDRUSDAT(I,J)%dt=>dt
        HYDRUSDAT(I,J)%dtBACK=>dtBACK
        hydrusdat(i,j)%dtforward=>dtforward
        HYDRUSDAT(I,J)%dtH=>dtH
        HYDRUSDAT(I,J)%dtMax=>dtMax
        HYDRUSDAT(I,J)%dtMin=>dtMin
        HYDRUSDAT(I,J)%dtS=>dtS
        HYDRUSDAT(I,J)%dtW=>dtW
        HYDRUSDAT(I,J)%DTINIT=>DTINIT
        HYDRUSDAT(I,J)%Epsi=>Epsi
        HYDRUSDAT(I,J)%g0=>g0
        HYDRUSDAT(I,J)%g1=>g1
        HYDRUSDAT(I,J)%gT1=>gT1
        HYDRUSDAT(I,J)%H_weight=>H_weight
        HYDRUSDAT(I,J)%hBot=>hBot
        HYDRUSDAT(I,J)%hCritA=>hCritA
        HYDRUSDAT(I,J)%HeatF=>HeatF
        HYDRUSDAT(I,J)%hNew=>hNew
        HYDRUSDAT(I,J)%HPAR=>HPAR
        HYDRUSDAT(I,J)%HPeclet=>HPeclet
        HYDRUSDAT(I,J)%hRoot=>hRoot
        HYDRUSDAT(I,J)%hSat=>hSat
        HYDRUSDAT(I,J)%hTab=>hTab
        HYDRUSDAT(I,J)%hTabM=>hTabM
        HYDRUSDAT(I,J)%hTop=>hTop
        HYDRUSDAT(I,J)%IHys=>IHys
        HYDRUSDAT(I,J)%iObs=>iObs
        HYDRUSDAT(I,J)%iPlevel=>iPlevel
        HYDRUSDAT(I,J)%iPLEVELBACK=>iPLEVELBACK
        HYDRUSDAT(I,J)%iReg=>iReg
        HYDRUSDAT(I,J)%IRoot=>IRoot
        HYDRUSDAT(I,J)%ItCum=>ItCum
        HYDRUSDAT(I,J)%ItCumS=>ItCumS
        HYDRUSDAT(I,J)%Iter=>Iter
        HYDRUSDAT(I,J)%iTlevel=>iTlevel
        HYDRUSDAT(I,J)%Kappa=>Kappa
        HYDRUSDAT(I,J)%KappaO=>KappaO
        HYDRUSDAT(I,J)%KBotCh=>KBotCh
        HYDRUSDAT(I,J)%KBotH=>KBotH
        HYDRUSDAT(I,J)%KodBot=>KodBot
        HYDRUSDAT(I,J)%KodTop=>KodTop
        HYDRUSDAT(I,J)%KodTop0=>KodTop0
        HYDRUSDAT(I,J)%KTopCh=>KTopCh
        HYDRUSDAT(I,J)%KTopH=>KTopH
        HYDRUSDAT(I,J)%Linear=>Linear
        HYDRUSDAT(I,J)%MatNum=>MatNum
        HYDRUSDAT(I,J)%PLNMWF=>PLNMWF
        HYDRUSDAT(I,J)%BCKSPWF=>BCKSPWF
        HYDRUSDAT(I,J)%MaxIt=>MaxIt
        HYDRUSDAT(I,J)%Nit=>Nit
        HYDRUSDAT(I,J)%NItMax=>NItMax
        HYDRUSDAT(I,J)%NMat=>NMat
        HYDRUSDAT(I,J)%NMatD=>NMatD
        HYDRUSDAT(I,J)%NObs=>NObs
        HYDRUSDAT(I,J)%NParD=>NParD
        HYDRUSDAT(I,J)%NReg=>NReg
        HYDRUSDAT(I,J)%NTabD=>NTabD
        HYDRUSDAT(I,J)%NumNP=>NumNP
        HYDRUSDAT(I,J)%NUMNPD=>NUMNPD
        HYDRUSDAT(I,J)%Omega=>Omega
        HYDRUSDAT(I,J)%Omega_H=>Omega_H
        HYDRUSDAT(I,J)%Omega0=>Omega0
        HYDRUSDAT(I,J)%P=>P
        HYDRUSDAT(I,J)%Par=>Par
        HYDRUSDAT(I,J)%Peclet=>Peclet
        HYDRUSDAT(I,J)%phi=>phi
        HYDRUSDAT(I,J)%Picard=>Picard
        HYDRUSDAT(I,J)%qGWLF=>qGWLF
        HYDRUSDAT(I,J)%qt=>qt
        HYDRUSDAT(I,J)%qtOld=>qtOld
        HYDRUSDAT(I,J)%rBot=>rBot
        HYDRUSDAT(I,J)%RootF=>RootF
        HYDRUSDAT(I,J)%rRoot=>rRoot
        HYDRUSDAT(I,J)%RSPAR=>RSPAR
        HYDRUSDAT(I,J)%rTop=>rTop
        HYDRUSDAT(I,J)%Salt=>Salt
        HYDRUSDAT(I,J)%SaltO=>SaltO
        HYDRUSDAT(I,J)%SatF=>SatF
        HYDRUSDAT(I,J)%ScrnF=>ScrnF
        HYDRUSDAT(I,J)%SeepF=>SeepF
        HYDRUSDAT(I,J)%ShortF=>ShortF
        HYDRUSDAT(I,J)%Sink=>Sink
        HYDRUSDAT(I,J)%SolutF=>SolutF
        HYDRUSDAT(I,J)%SStrsF=>SStrsF
        HYDRUSDAT(I,J)%STAB=>STAB
        HYDRUSDAT(I,J)%SteadyF=>SteadyF
        HYDRUSDAT(I,J)%Sv0C=>Sv0C
        HYDRUSDAT(I,J)%Sv1C=>Sv1C
        HYDRUSDAT(I,J)%Sv1T=>Sv1T
        HYDRUSDAT(I,J)%SvBot=>SvBot
        HYDRUSDAT(I,J)%SvBotC=>SvBotC
        HYDRUSDAT(I,J)%SvBotH=>SvBotH
        HYDRUSDAT(I,J)%SvRoot=>SvRoot
        HYDRUSDAT(I,J)%SvTop=>SvTop
        HYDRUSDAT(I,J)%SvTopC=>SvTopC
        HYDRUSDAT(I,J)%SvTopH=>SvTopH
        HYDRUSDAT(I,J)%t=>t
        HYDRUSDAT(I,J)%tBC=>tBC
        HYDRUSDAT(I,J)%tBCH=>tBCH
        HYDRUSDAT(I,J)%tBCR=>tBCR
        HYDRUSDAT(I,J)%tBCS=>tBCS
        HYDRUSDAT(I,J)%Temp=>Temp
        HYDRUSDAT(I,J)%tEnd=>tEnd
        HYDRUSDAT(I,J)%ThN=>ThN
        HYDRUSDAT(I,J)%ThO=>ThO
        HYDRUSDAT(I,J)%ThR=>ThR
        HYDRUSDAT(I,J)%ThRR=>ThRR
        HYDRUSDAT(I,J)%ThS=>ThS
        HYDRUSDAT(I,J)%Tol=>Tol
        HYDRUSDAT(I,J)%tOld=>tOld
        HYDRUSDAT(I,J)%Tolh=>Tolh
        HYDRUSDAT(I,J)%TpBot=>TpBot
        HYDRUSDAT(I,J)%TPrint=>TPrint
        HYDRUSDAT(I,J)%TpTop=>TpTop
        HYDRUSDAT(I,J)%UserF=>UserF
        HYDRUSDAT(I,J)%v=>v
        HYDRUSDAT(I,J)%vBot=>vBot
        HYDRUSDAT(I,J)%vOld=>vOld
        HYDRUSDAT(I,J)%vRoot=>vRoot
        HYDRUSDAT(I,J)%vTop=>vTop
        HYDRUSDAT(I,J)%WaterF=>WaterF
        HYDRUSDAT(I,J)%weight=>weight
        HYDRUSDAT(I,J)%WLayrF=>WLayrF
        HYDRUSDAT(I,J)%x=>x
        HYDRUSDAT(I,J)%xObs=>xObs
        HYDRUSDAT(I,J)%z=>z
        HYDRUSDAT(I,J)%LUNIT=>LUNIT
        HYDRUSDAT(I,J)%TUNIT=>TUNIT
        HYDRUSDAT(I,J)%HEADING=>HEADING
        HYDRUSDAT(I,J)%TBC0=>TBC0
        HYDRUSDAT(I,J)%RTOP0=>RTOP0
        HYDRUSDAT(I,J)%RBOT0=>RBOT0
        HYDRUSDAT(I,J)%HTOP0=>HTOP0
        HYDRUSDAT(I,J)%HBOT0=>HBOT0
        HYDRUSDAT(I,J)%RTOP1=>RTOP1
        HYDRUSDAT(I,J)%RBOT1=>RBOT1
        HYDRUSDAT(I,J)%HTOP1=>HTOP1
        HYDRUSDAT(I,J)%HBOT1=>HBOT1
        HYDRUSDAT(I,J)%RTOP2=>RTOP2
        HYDRUSDAT(I,J)%RBOT2=>RBOT2
        HYDRUSDAT(I,J)%HTOP2=>HTOP2
        HYDRUSDAT(I,J)%HBOT2=>HBOT2
        HYDRUSDAT(I,J)%CTOP1=>CTOP1
        HYDRUSDAT(I,J)%CTOP2=>CTOP2
        HYDRUSDAT(I,J)%CBOT1=>CBOT1
        HYDRUSDAT(I,J)%CBOT2=>CBOT2
        HYDRUSDAT(I,J)%TPTOP1=>TPTOP1
        HYDRUSDAT(I,J)%TPTOP2=>TPTOP2
        HYDRUSDAT(I,J)%TPBOT1=>TPBOT1
        HYDRUSDAT(I,J)%TPBOT2=>TPBOT2
        HYDRUSDAT(I,J)%AMPL1=>AMPL1
        HYDRUSDAT(I,J)%AMPL2=>AMPL2
        HYDRUSDAT(I,J)%RROOT1=>RROOT1
        HYDRUSDAT(I,J)%RROOT2=>RROOT2
        HYDRUSDAT(I,J)%vinitW=>vinitW
        HYDRUSDAT(I,J)%vinitS=>vinitS
        HYDRUSDAT(I,J)%vinitH=>vinitH
        HYDRUSDAT(I,J)%CRROOT=>CRROOT
        HYDRUSDAT(I,J)%CVROOT=>CVROOT
        HYDRUSDAT(I,J)%SRTOP=>SRTOP
        HYDRUSDAT(I,J)%SvTop0 =>SvTop0 
        HYDRUSDAT(I,J)%SvBot0 =>SvBot0 
        HYDRUSDAT(I,J)%SvRoot0=>SvRoot0
        HYDRUSDAT(I,J)%TBC1=>TBC1
        HYDRUSDAT(I,J)%TBCS1=>TBCS1
        HYDRUSDAT(I,J)%plnmsF=>plnmsF
        HYDRUSDAT(I,J)%plnmhF=>plnmhF
        HYDRUSDAT(I,J)%TBCH1=>TBCH1
        HYDRUSDAT(I,J)%TBCR1=>TBCR1
        HYDRUSDAT(I,J)%plnmrF=>plnmrF
        HYDRUSDAT(I,J)%HBACK=>HBACK
      RETURN
      END
      subroutine Main_In(
     .Heading,WaterF,SteadyF,SolutF,HeatF,RootF,LUnit,CosAlf,NumNP,NMat,
     .NReg,iReg,TUnit,t,tEnd,dt,dtMin,dtMax,tBC,tBCS,tBCH,
     .dtW,dtS,dtH,TPrint,iPlevel,ShortF,Sink,SvTop,SvBot,SvRoot,vRoot,
     .SvTopC,SvBotC,Sv0C,Sv1C,Sv1T,Cs,xObs,iObs,NObs,ScrnF,tBCR,MaxIt,
     .IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:THRESH,icoup,HCRITA,X,Z,MATNUM,INTERF,DTINIT
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)

      DOUBLEPRECISION t,tBC,tBCS,tBCH,tBCR,tEnd,TPrint
      character*72 Heading
      character*7 LUnit,TUnit
      integer iReg,Reg,iPlevel
      logical StarF,WaterF,SteadyF,SolutF,HeatF,RootF,ShortF,ScrnF

      dimension iReg(*),TPrint(*),Sink(*),xObs(*),iObs(*)

*     Heading
      call SkipStars(idc+imain)
      read(idc+imain,*) Heading

*     Processes
      call SkipStars(idc+imain)
      read(idc+imain,*) WaterF,SteadyF,SolutF,HeatF,RootF

*     Geometry information
      call SkipStars(idc+imain)
      read(idc+imain,*) LUnit
      call SkipStars(idc+imain)
      read(idc+imain,*) CosAlf
      call SkipStars(idc+imain)
      read(idc+imain,*) Ndx
      call SkipStars(idc+imain)
      read(idc+imain,*) (z(i),i=1,Ndx)
      NumNP=Ndx+1
      NMat=1
      NReg=1
      call SkipStars(idc+imain)
      read(idc+imain,*) x(1),Depth,Mat,Reg
      !  MatNum(1)=Mat
      iReg(1)=Reg
      NMat=max(NMat,Mat)
      NReg=max(NReg,Reg)
      do 20 i=2,NumNP
        x(i)=x(i-1)+z(i-1)
   10   if(x(i).gt.Depth.AND.ABS(X(I)-DEPTH)>1D-3*Z(I-1)
     1          .and..not.StarF(idc+imain)) then
          read(idc+imain,*) Dummy,Depth,Mat,Reg
          goto 10
        endif
        MatNum(i-1)=Mat
        iReg(i)=Reg
        NMat=max(NMat,Mat)
        NReg=max(NReg,Reg)
   20 continue
      MATNUM(NUMNP)=MATNUM(NUMNP-1)
      x(NumNP)=Depth
      
      DO I=1,NUMNP
        IF(I>1 .AND.I<NUMNP)THEN
          M1=MATNUM(I-1)
          M2=MATNUM(I)
          IF(M1==M2)THEN
            INTERF(I)=0
          ELSE
            INTERF(I)=1
          ENDIF
        ELSE
          INTERF(I)=0
        ENDIF
      ENDDO
      call SkipStars(idc+imain)
      read(idc+imain,*) NObs
      call SkipStars(idc+imain)
      if(NObs.gt.0) then
        read(idc+imain,*) (xObs(i),i=1,NObs)
        do 40 i=1,NObs
          do 30 j=2,NumNP
            if(x(j).ge.xObs(i)) then
              iObs(i)=j
              goto 40
            endif
   30     continue
   40   continue
      endif

*     Time information
      call SkipStars(idc+imain)
      MaxIt=20
      read(idc+imain,*) TUnit,t,tEnd,dtINIT,dtMin,dtMax
      DT=DTINIT
      tBC=t
      tBCS=t
      tBCH=t
      tBCR=t
      if(.not.WaterF) tBC=tEnd
      if(.not.SolutF) tBCS=tEnd
      if(.not.HeatF)  tBCH=tEnd
      if(.not.RootF)  tBCR=tEnd
      dtW=(tEnd-t)/2.
      dtS=(tEnd-t)/2.
      dtH=(tEnd-t)/2.

*     Print information
      call SkipStars(idc+imain)
      read(idc+imain,*) NPrint
      call SkipStars(idc+imain)
      read(idc+imain,*) (TPrint(i),i=2,NPrint+1)
      call SkipStars(idc+imain)
      read(idc+imain,*) ii
      call SkipStars(idc+imain)
      read(idc+imain,*) jj
      call SkipStars(idc+imain)
      read(idc+imain,*) THRESH
      call SkipStars(idc+imain)
      read(idc+imain,*) icoup
      ShortF=.false.
      ScrnF=.false.
      if(ii.eq.1) ShortF=.true.
      if(jj.eq.1) ScrnF=.true.
      TPrint(1)=t
      TPrint(NPrint+2)=tEnd
      iPlevel=1
*     Zeroize
      vRoot=0.
      vTop=0.
      SvTop=0.
      SvBot=0.
      SvRoot=0.
      SvTopC=0.
      SvBotC=0.
      Sv0C=0.
      Sv1C=0.
      Sv1T=0.      
      Cs=0.
      FORALL(I=1:NUMNP)Sink(I)=0.
      return
      end
************************************************************************
      
      subroutine Water_In(IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:MATNUM,HNEW,NUMNP,HSAT,THN,THNA,THNB,INTERF,Z,
     1 HBACK,NMat,NMatD,NParD,hTabM,Par,x,Ah,AK,ATh,MaxIt,Tol,Tolh,
     1 ItCum,DMul1,DMul2,SatF,ChangF,IHys,AhW,AThW,AKW,ScrnF,dt,dtW,
     1 Kappa,AThS,ThRR,ConR,AKS,KappaO
      implicit doubleprecision(A-H,O-Z)
      parameter(NCol=4)
      dimension Aux1(NUMNP),MASK(NCOL)
      
*     Water flow parameters
      call SkipStars(idc+iwat)
      read(idc+iwat,*) ITab
      call SkipStars(idc+iwat)
      read(idc+iwat,*) IHys
*     Allowed maxium number of iterations and tolerances
      call SkipStars(idc+iwat)
      read(idc+iwat,*) MaxIt,Tol,Tolh
!	  write(*,*) MaxIt,Tol,Tolh
      call SkipStars(idc+iwat)
      hMin=+1e30
      hMax=-1e30
      do 5 m=1,NMat
        if(IHys.eq.0) then
          read(idc+iwat,*) (Par(i,m,1),i=1,NParD)
          Par(6,m,1)=max(Par(6,m,1),Par(2,m,1))
        else
          read(idc+iwat,*) (Par(i,m,1),i=1,NParD),Par(2,m,2),Par(3,m,2),
     .    Par(5,m,2)
          Par(6,m,1)=max(Par(6,m,1),Par(2,m,1))
          Par(1,m,2)=Par(1,m,1)
          Par(4,m,2)=Par(4,m,1)
          AhW(m)=Par(3,m,1)/Par(3,m,2)
          AThW(m)=(Par(2,m,2)-Par(1,m,2))/(Par(2,m,1)-Par(1,m,1))
          AKW(m)=Par(5,m,2)/Par(5,m,1)
          Par(6,m,2)=Par(1,m,2)+AThW(m)*(Par(6,m,1)-Par(1,m,1))
        endif
        hMin=min(hMin,FH(0.0001d0,m,1))
        hMax=max(hMax,FH(0.9999d0,m,1))
    5 continue
      hTabM=0.
      if(ITab.ne.0) hTabM=max(hMin,hMax*100000.D0)
*     Scaling factors table
      call ReadTable(idc+iwat,Mask,x,Ah,AK,ATh,NumNP,NCol,DBLE(1.))
*     Initial condition
      call SkipStars(idc+iwat)
      if(IHys.eq.1) then
        read(idc+iwat,*) IKappa
      else
        IKappa=-1
      endif
      do 20 i=1,NumNP
        Kappa(i)=IKappa
        KappaO(i)=IKappa
   20 continue
      
      call ReadTable(idc+iwat,Mask,x,hNew,Aux1,x,NumNP,2,DBLE(0.))
      HBACK=HNEW
      j=1
      if (IKappa.eq.1) j=2
      DO i=1,NumNP
        M2=MATNUM(I)
        HIM2=MIN(HNEW(I),HSAT(M2))
        IF(HIM2>=HSAT(M2))THEN
          THNB(I)=PAR(2,M2,1)
        ELSE
          THNB(I)=FQ(hiM2,M2,1)
        ENDIF
        IF(INTERF(I)==0)THEN
          THNA(I)=THNB(I)
          THN(I)=THNB(I)
        ELSE
          M1=MATNUM(I-1)
          HIM1=MIN(HNEW(I),HSAT(M1))
          IF(HIM1>=HSAT(M1))THEN
            THNA(I)=PAR(2,M1,1)
          ELSE
            THNA(I)=FQ(hiM1,M1,1)
          ENDIF
          THN(I)=(Z(I-1)*THNA(I)+Z(I)*THNB(I))/(Z(I-1)+Z(I))
        ENDIF
        AThS(i)=1.
        AKS(i) =1.
        ThRR(i)=Par(1,MATNUM(I),1)
        ConR(i)=0.
      ENDDO
 
      dtW    = dt
      DMul1  = 1.2
      DMul2  = 0.8
      CHANGF = .FALSE.
      return
      end
      
      subroutine Water_In_NULL(IDC)
      USE HYDRUSPARA,ONLY:IWAT
      USE HYDRUS,ONLY:HNEW,NUMNP,HBACK,NMAT,CHANGF,DTW,DT
      implicit doubleprecision(A-H,O-Z)
      parameter(NCol=4)
      dimension Aux1(NUMNP),HTEMP(NUMNP),MASK(NCOL),X(NUMNP),AH(NUMNP),
     1 AK(NUMNP),ATH(NUMNP)
      call SkipStars(idc+iwat)
      read(idc+iwat,*) 
      call SkipStars(idc+iwat)
      read(idc+iwat,*) IHys
      call SkipStars(idc+iwat)
      read(idc+iwat,*)
      call SkipStars(idc+iwat)
      DO m=1,NMat
        read(idc+iwat,*)
      ENDDO
      call ReadTable(idc+iwat,Mask,x,Ah,AK,ATh,NumNP,NCol,DBLE(1.))
      call SkipStars(idc+iwat)
      if(IHys.eq.1)read(idc+iwat,*)
      CALL READTABLE(idc+iwat,Mask,x,hTEMP,Aux1,x,NumNP,2,DBLE(0.))
      HNEW=HBACK
      CHANGF=.FALSE.
      DTW   = DT
      return
      end

************************************************************************

      subroutine Water_BC_In(IDC,ITERQ3D,T0)
      USE HYDRUSPARA,ONLY:IWAT
      USE HYDRUS,ONLY:tBC0,rTop0,rBot0,hTop0,hBot0,rTop1,rBot1,
     . hTop1,hBot1,rTop2,rBot2,hTop2,hBot2,iTlevel,t,dt,tBC1,tBC,
     1 tEnd,rTop,rBot,hTop,hBot,MatNum,KodTop,KodBot,hCritA,
     1 AtmBCF,WLayrF,SeepF,qGWLF,PlnmWF,BckspWF,HNEW!,KODTOP0
      implicit doubleprecision(A-H,O-Z)
      parameter(NCol=9)
      logical StarF,exsit,opd
      REAL T0
      dimension Col(NCol),MASKW(NCOL),MASKW1(NCOL)
      integer iostat,ierror,nr
	  character acc,fm,sequ
	  
!!	  write(*,*) iTlevel
      if(iTlevel.eq.0)then
        call SkipStars(idc+iwat)
        read(idc+iwat,*) i ! Top BC
        !IF(T0==0)THEN
        KodTop=2
        !ELSEIF(T0>0)THEN
        !  KODTOP=KODTOP0
        !ENDIF
!        write(*,*) iostat,(iTlevel.eq.0)
        AtmBCF=.false.
        WLayrF=.false.
        if(i.eq.1) KodTop=1
        if(i.eq.3.or.i.eq.4) AtmBCF=.true.
        
        if(i.eq.4) WLayrF=.true.
        call SkipStars(idc+iwat)
        read(idc+iwat,*) i ! Bottom BC
!		write(*,*) i,iostat
        KodBot=2
        SeepF=.false.
        qGWLF=.false.
        if(i.eq.1) KodBot=1
        if(i.eq.3) KodBot=3
        if(i.eq.4) qGWLF=.true.
        if(i.eq.5) SeepF=.true.
        call SkipStars(idc+iwat)
        read(idc+iwat,*) ii
		write(*,*) ii, PlnmWF
        if(ii.eq.0) PlnmWF=.false.
        call SkipStars(idc+iwat)
		
        read(idc+iwat,*,iostat=iostat) (MaskW(i),i=1,NCol) ! BC Table
        MaskW1(1)=MaskW(1)
		MaskW1(2)=MaskW(2)
		MaskW1(3)=MaskW(3)
		MaskW1(4)=MaskW(4)
		MaskW1(5)=MaskW(5)
		MaskW1(6)=MaskW(6)
		MaskW1(7)=MaskW(7)
		MaskW1(8)=MaskW(8)
		MaskW1(9)=MaskW(9)		
!		if (i.gt.NCol) then
!		   MaskW(i)=0
!           write(*,*) iostat, MaskW
!		endif
!		write(*,*) PlnmWF, NCol, i, MaskW(i), MaskW,iostat
        call SkipStars(idc+iwat)
!        write(*,*) PlnmWF, NCol, i, MaskW(i), MaskW,Col
        call ReadLine(idc+iwat,MaskW,Col,NCol,DBLE(0.))
! !       write(*,*) PlnmWF,iostat, NCol, i, MaskW, MaskW(1),Col
!!        write(*,*) t,dt,(Col(1).le.t+dt.and..not.StarF(idc+iwat))		
   10   if(Col(1).le.t+dt.and..not.StarF(idc+iwat))then
!!        write(*,*) PlnmWF, NCol, i, MaskW, MaskW(1),Col(1)   
          call ReadLine(idc+iwat,MaskW,Col,NCol,DBLE(0.))
          goto 10
        endif
!		INQUIRE(idc+iwat,ACCESS=acc,FORM=fm,IOSTAT=iostat,SEQUENTIAL=sequ)
!		INQUIRE (idc+iwat, OPENED=opd, EXIST=exsit, NEXTREC=nr)
!		write(*,*) exsit,acc,fm,iostat,nr,opd,sequ
!11111		write(*,*) (Col(1).gt.t+dt)
        if(Col(1).gt.t+dt) backspace (IDC+IWAT,iostat=ierror)
!		INQUIRE (idc+iwat, OPENED=opd, EXIST=exsit, NEXTREC=nr)
!		write(*,*) exsit,acc,fm,iostat,nr,opd,sequ
!!		write(*,*) ierror
!		if (ierror.eq.0) then
!		   write(*,*) t, dt, i, Col(1), PlnmWF,  MaskW
!		   stop
!		endif
        MaskW(1)=1
		MaskW(2)=0
		MaskW(3)=0
		MaskW(4)=1
		MaskW(5)=0
		MaskW(6)=0
		MaskW(7)=0
		MaskW(8)=0
		MaskW(9)=0
!        MaskW(1)=1
!		MaskW(2)=1
!		MaskW(3)=1
!		MaskW(4)=0
!		MaskW(5)=0
!		MaskW(6)=0
!		MaskW(7)=0
!		MaskW(8)=0
!		MaskW(9)=0		
!        MaskW(1)=MaskW1(1)
!		MaskW(2)=MaskW1(2)
!		MaskW(3)=MaskW1(3)
!		MaskW(4)=MaskW1(4)
!		MaskW(5)=MaskW1(5)
!		MaskW(6)=MaskW1(6)
!		MaskW(7)=MaskW1(7)
!		MaskW(8)=MaskW1(8)
!		MaskW(9)=MaskW1(9)			
        hCritA=FH(.002d0,MatNum(1),1)

!!		write(*,*) (Col(1).gt.t+dt),MaskW1
        tBC1=t
        rTop1=0.
        rBot1=0.
        hTop1=Col(6)
        hBot1=Col(7)
        tBC=t+dt
        rTop2=abs(Col(2))-abs(Col(3))
        if(.not.AtmBCF) rTop2=Col(4)
        rBot2=Col(5)
        hTop2=Col(6)
        hBot2=Col(7)
        if(MaskW(8).eq.1) KodTop=Col(8)
        if(MaskW(9).eq.1) KodBot=Col(9)
      endif

      if(BckspWF) then    ! BACKWARD
        backspace (IDC+IWAT)
        BckspWF=.false.
        tBC=tBC1
        rTop2=rTop1
        rBot2=rBot1
        hTop2=hTop1
        hBot2=hBot1
        tBC1=tBC0
        rTop1=rTop0
        rBot1=rBot0
        hTop1=hTop0
        hBot1=hBot0
      endif

      if(PlnmWF) then ! LINEAR INTERPOLATION
        ddt=(t-tBC1)/(tBC-tBC1)
        hTop=hTop1+(hTop2-hTop1)*ddt
        hBot=hBot1+(hBot2-hBot1)*ddt
        rTop=rTop1+(rTop2-rTop1)*ddt
        rBot=rBot1+(rBot2-rBot1)*ddt
      else           ! STEP-WISE INTERPOLATION
        hTop=hTop2
        hBot=hBot2
        rTop=rTop2
        rBot=rBot2
      endif
!	  do 110 ij=1,NCol

!   110 continue
!		if (i.gt.NCol) then
!		   i=10
!		   MaskW(i)=0
!           write(*,*) MaskW
!		endif
!	  write(*,*) PlnmWF, NCol, i, MaskW1
      if(iTlevel.ge.1.and.abs(t-tBC).le.0.001*dt) then !FORWARD
        tBC0=tBC1
        rTop0=rTop1
        rBot0=rBot1
        hTop0=hTop1
        hBot0=hBot1
        tBC1=tBC
        rTop1=rTop2
        rBot1=rBot2
        hTop1=hTop2
        hBot1=hBot2
!		write(*,*) PlnmWF, NCol, i
        MaskW(1)=1
		MaskW(2)=0
		MaskW(3)=0
		MaskW(4)=1
		MaskW(5)=0
		MaskW(6)=0
		MaskW(7)=0
		MaskW(8)=0
		MaskW(9)=0
!		MaskW(1)=1
!		MaskW(2)=1
!		MaskW(3)=1
!		MaskW(4)=0
!		MaskW(5)=0
!		MaskW(6)=0
!		MaskW(7)=0
!		MaskW(8)=0
!		MaskW(9)=0
!		MaskW(1)=MaskW1(1)
!		MaskW(2)=MaskW1(2)
!		MaskW(3)=MaskW1(3)
!		MaskW(4)=MaskW1(4)
!		MaskW(5)=MaskW1(5)
!		MaskW(6)=MaskW1(6)
!		MaskW(7)=MaskW1(7)
!		MaskW(8)=MaskW1(8)
!		MaskW(9)=MaskW1(9)	
!!		write(*,*) PlnmWF,MaskW

        if(StarF(idc+iwat)) then
          read(idc+iwat,*,iostat=iostat)
          tBC=tEnd
!		  write(*,*) iostat
          goto 20
        endif
!		write(*,*) PlnmWF, NCol, i
		if (i.gt.NCol) then
		   i=10
		   MaskW(i)=0
!           write(*,*) MaskW
		endif
		
!!		write(*,*) PlnmWF, NCol, i, MaskW
        call ReadLine(idc+iwat,MaskW,Col,NCol,DBLE(0.))
!		write(*,*) PlnmWF, NCol, i, MaskW(9), MaskW(1)		
        tBC=Col(1)
        rTop2=abs(Col(2))-abs(Col(3))
        if(.not.AtmBCF) rTop2=Col(4)
        rBot2=Col(5)
        hTop2=Col(6)
        hBot2=Col(7)
        if(MaskW(8).eq.1) KodTop=Col(8)
        if(MaskW(9).eq.1) KodBot=Col(9)
      endif
   20 continue
      
!       JCZENG 20180415 首次计算，判断是否转换为定水头上边界
      IF(ATMBCF)THEN
        IF(HNEW(1)<=(HCRITA+1).AND.RTOP<0)THEN
          HTOP=HCRITA
          KODTOP=1
        ELSEIF(HNEW(1)>0.AND..NOT.WLAYRF)THEN
          KODTOP=1
          HTOP=0.
        ENDIF
      ENDIF
      return
      end
***********************************************************************

      subroutine Solut_In(
     .NMat,ChPar,Linear,ScrnF,NumNP,x,Conc,ThN,ThO,v,Aux,WaterF,dt,
     .dtS,Epsi,weight,NItMax,CTol,Picard,UserF,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      logical Linear,ScrnF,WaterF,weight,Picard,UserF
      DOUBLEPRECISION ThN,ThO

      dimension ChPar(20,*),Conc(*),x(*),ThN(*),ThO(*),v(*),Aux(*),
     . Mask(3)

      if(ScrnF) write(*,*)'Reading SOLUTE'

*     Time difference scheme
      call SkipStars(idc+islt)
      read(idc+islt,*) ISchem
      if(ISchem.eq.2) then
        Epsi=0.5              ! Central
      else
        Epsi=1.0              ! Implicit
      endif

*     Upwind weighting implementation
      call SkipStars(idc+islt)
      read(idc+islt,*) weight

*     Solute transport parameters
      call SkipStars(idc+islt)
      read(idc+islt,*) UserF
      call SkipStars(idc+islt)
      Linear=.false.
      do 5 m=1,NMat
        read(idc+islt,*) (ChPar(i,m),i=1,10)
        if(UserF) goto 5
        if (abs(ChPar(5,m)-1.0) .le. 1.e-06.or.ChPar(4,m).le.0.)
     .    Linear=.true.
    5 continue
      Picard=.false.
      if(Linear) goto 6
*     Modified Picard iteration scheme (T); Standard scheme (F)
      call SkipStars(idc+islt)
      read(idc+islt,*) Picard

*     Allowed maxium number of iterations and tolerance
      call SkipStars(idc+islt)
      read(idc+islt,*) NItMax,CTol
*     Initial condition
   6  call READTABLE(idc+islt,Mask,x,Conc,x,x,NumNP,2,DBLE(0.))
      do 8 i=1,NumNP
        Conc(i)=max(Conc(i),1.E-20)
   8  continue

*     Initial water profile
      if(.not.WaterF) then
        call READTABLE(idc+islt,Mask,x,Aux,v,x,NumNP,3,DBLE(0.))
        do 10 i=1,NumNP
          ThN(i)=Aux(i)
          ThO(i)=ThN(i)
   10   continue
      else
        call READTABLE(idc+islt,Mask,x,x,x,x,NumNP,1,DBLE(0.))
      endif

      dtS=dt

      return
      end

************************************************************************

      subroutine Solut_BC_In(
     .iTlevel,t,dt,tBCS1,tBCS2,tEnd,cTop,cBot,KTopCh,KBotCh,PlnmF,IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:cTop1,cTop2,cBot1,cBot2
      implicit doubleprecision(A-H,O-Z)

      parameter(NCol=5)

      DOUBLEPRECISION t,tBCS1,tBCS2,tEnd
      logical StarF,PlnmF
      integer iTlevel

      dimension Mask(NCol),Col(NCol)

      data Mask/NCol*0/

      if(iTlevel.eq.0) then

*     Top boundary condition type
      call SkipStars(idc+islt)
      read(idc+islt,*) i
      KTopCh=-1
      if(i.eq.2) KTopCh=+1
*     Bottom boundary condition type
      call SkipStars(idc+islt)
      read(idc+islt,*) i
      KBotCh=-1
      if(i.eq.2) KBotCh=+1
      if(i.eq.3) KBotCh=0

*     Read time function type
      call SkipStars(idc+islt)
      read(idc+islt,*) ii
      if(ii.eq.0) PlnmF=.false.

*     Read first line(s) of BC table
      call SkipStars(idc+islt)
      read(idc+islt,*) (Mask(i),i=1,NCol)
      call SkipStars(idc+islt)
      call ReadLine(idc+islt,Mask,Col,NCol,DBLE(0.))
   10 if(Col(1).le.t+dt.and..not.StarF(idc+islt)) then
        call ReadLine(idc+islt,Mask,Col,NCol,DBLE(0.))
        goto 10
      endif
      if(Col(1).gt.t+dt) backspace (idc+islt)
      tBCS1=t
      cTop1=Col(2)
      cBot1=Col(3)
      tBCS2=t+dt
      cTop2=Col(2)
      cBot2=Col(3)

      endif

*     Interpolation
      if(PlnmF) then
        ddt=(t-tBCS1)/(tBCS2-tBCS1)
        cTop=cTop1+(cTop2-cTop1)*ddt
        cBot=cBot1+(cBot2-cBot1)*ddt
      else
        cTop=cTop2
        cBot=cBot2
      endif

*     Read BC table
      if(iTlevel.ge.1.and.abs(t-tBCS2).le.0.001*dt) then
        tBCS1=tBCS2
        cTop1=cTop2
        cBot1=cBot2
        tBCS2=tEnd
        if(StarF(idc+islt)) goto 20
        call ReadLine(idc+islt,Mask,Col,NCol,DBLE(0.))
        tBCS2=Col(1)
        cTop2=Col(2)
        cBot2=Col(3)
      if(Mask(4).eq.1) KTopCh=-1
      if(Mask(4).eq.2) KTopCh=1
      if(Mask(5).eq.1) KBotCh=-1
      if(Mask(5).eq.2) KBotCh=1
      if(Mask(5).eq.3) KBotCh=0
      endif
   20 continue
      return
      end
************************************************************************
      subroutine Heat_In(NMat,HPar,ScrnF,NumNP,
     . x,Temp,ThN,ThO,v,Aux,WaterF,H_weight,Omega_H,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      logical ScrnF,WaterF,H_weight
      DOUBLEPRECISION ThN,ThO

      dimension
     .HPar(20,*),Temp(*),x(*),ThN(*),ThO(*),v(*),Aux(*),Mask(3)

      if(ScrnF) write(*,*)'Reading HEAT'
                                                 
*     Numerical algorithm (Explicit 0 =< Omega_H <= 1 Implicit)
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) Omega_H
                                                       
*     Implement with upwind weighting technique ?
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) H_weight

*     Heat transport parameters
      call SkipStars(idc+iHEAT)
      do 5 m=1,NMat
        read(idc+iHEAT,*) (HPar(i,m),i=1,9)
    5 continue
*     Initial condition
      call READTABLE(idc+iHEAT,Mask,x,Temp,x,x,NumNP,2,DBLE(0.))
*     Initial water profile
      if(.not.WaterF) then
        call READTABLE(idc+iHEAT,Mask,x,Aux,v,x,NumNP,3,DBLE(0.))
        do 10 i=1,NumNP
          ThN(i)=Aux(i)
          ThO(i)=ThN(i)
   10   continue
      else
        call READTABLE(idc+iHEAT,Mask,x,x,x,x,NumNP,1,DBLE(0.))
      endif

      return
      end

************************************************************************

      subroutine Heat_BC_In(
     .iTlevel,t,dt,tBCH1,tBCH2,tEnd,TpTop,TpBot,Ampl,Omega,Omega0,
     .KTopH,KBotH,PlnmF,IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:TpTop1,TpTop2,TpBot1,TpBot2,Ampl1,Ampl2
      implicit doubleprecision(A-H,O-Z)

      parameter(NCol=6)

      DOUBLEPRECISION t,tBCH1,tBCH2,tEnd
      logical StarF,PlnmF
      integer iTlevel

      dimension Mask(NCol),Col(NCol)

      data Mask/NCol*0/

      if(iTlevel.eq.0) then

*     Top boundary condition type
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) i
      KTopH=-1
      if(i.eq.2) KTopH=+1

*     Bottom boundary condition type
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) i
      KBotH=-1
      if(i.eq.2) KBotH=+1
      if(i.eq.3) KBotH=0

*     Read time function type
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) ii
      if(ii.eq.0) PlnmF=.false.

*     Read first line(s) of BC table
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) Omega
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) Omega0
      call SkipStars(idc+iHEAT)
      read(idc+iHEAT,*) (Mask(i),i=1,NCol)
      call SkipStars(idc+iHEAT)
      call ReadLine(idc+iHEAT,Mask,Col,NCol,DBLE(0.))
   10 if(Col(1).le.t+dt.and..not.StarF(idc+iHEAT)) then
        call ReadLine(idc+iHEAT,Mask,Col,NCol,DBLE(0.))
        goto 10
      endif
      if(Col(1).gt.t+dt) backspace (IDC+IHEAT)
      tBCH1=t
      TpTop1=Col(2)
      TpBot1=Col(4)
      Ampl1= Col(3)
      tBCH2=t+dt
      TpTop2=Col(2)
      TpBot2=Col(4)
      Ampl2=Col(3)
      endif
*     Interpolation
      if(PlnmF) then
        ddt=(t-tBCH1)/(tBCH2-tBCH1)
        TpTop=TpTop1+(TpTop2-TpTop1)*ddt
        TpBot=TpBot1+(TpBot2-TpBot1)*ddt
        Ampl=Ampl1+(Ampl2-Ampl1)*ddt
      else
        TpTop=TpTop2
        TpBot=TpBot2
        Ampl=Ampl2
      endif

*     Read BC table
      if(iTlevel.ge.1.and.abs(t-tBCH2).le.0.001*dt) then
        tBCH1=tBCH2
        TpTop1=TpTop2
        TpBot1=TpBot2
        Ampl1=Ampl2
        tBCH2=tEnd
        if(StarF(idc+iHEAT)) goto 20
        call ReadLine(idc+iHEAT,Mask,Col,NCol,DBLE(0.))
        tBCH2=Col(1)
        TpTop2=Col(2)
        TpBot2=Col(4)
        Ampl2=Col(3)
      if(Mask(5).eq.1) KTopH=-1
      if(Mask(5).eq.2) KTopH=1
      if(Mask(6).eq.1) KBotH=-1
      if(Mask(6).eq.2) KBotH=1
      if(Mask(6).eq.3) KBotH=0
      endif
   20 continue

      return
      end
***********************************************************************
      subroutine Root_In(
     .NumNP,NMat,x,Beta,RSPar,Cs,ScrnF,hNew,Conc,IRoot,HTEMP,WaterF,
     .SolutF,SStrsF,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      logical ScrnF,WaterF,SolutF,SStrsF

      dimension x(*),Beta(*),RSPar(9,*),Mask(3),hNew(*),Conc(*),HTEMP(*)

      if(ScrnF) write(*,*)'Reading ROOT'

*     Water stress parameters
      call SkipStars(idc+iRT)
      read(idc+iRT,*) IRoot
      call SkipStars(idc+iRT)
      do 30 i=1,NMat
        If(IRoot.eq.1) read(idc+iRT,*) RSPar(1,i),RSPar(2,i)
        If(IRoot.eq.2) read(idc+iRT,*) RSPar(6,i),RSPar(7,i),
     .  (RSPar(j,i),j=1,5)
   30 continue

*     Solute stress parameters
      call SkipStars(idc+iRT)
      read(idc+iRT,*) i
      SStrsF=.false.
      if(i.eq.1) SStrsF=.true.
      if(SStrsF) then
        call SkipStars(idc+iRT)
        do 35 i=1,NMat
          read(idc+iRT,*) RSPar(8,i),RSPar(9,i)
   35   continue
      endif

*     Root uptake distribution
      call READTABLE(idc+iRT,Mask,x,Beta,x,x,NumNP,2,DBLE(0.))

*     Root uptake distribution normalization
      SBeta=0
      do 40 i=2,NumNP-1
        SBeta=SBeta+Beta(i)*(x(i+1)-x(i-1))/2
   40 continue
      do 50 i=2,NumNP-1
        Beta(i)=Beta(i)/SBeta
   50 continue
      Beta(1)=0.
      Beta(NumNP)=0.

*     Water & Solute profile
      if(.not.WaterF.and..not.SolutF) then
        call READTABLE(idc+iRT,Mask,x,hNew,Conc,HTEMP,NumNP,3,DBLE(0.))
      elseif(.not.WaterF) then
        call READTABLE(idc+iRT,Mask,x,hNew,HTEMP,HTEMP,NumNP,2,DBLE(0.))
      elseif(.not.SolutF) then
        call READTABLE(idc+iRT,Mask,x,HTEMP,Conc,HTEMP,NumNP,3,DBLE(0.))
      else
      call READTABLE(idc+iRT,Mask,x,HTEMP,HTEMP,HTEMP,NumNP,1,DBLE(0.))
      endif

*     Potential solute uptake
      call SkipStars(idc+iRT)
      read(idc+iRT,*) Cs

      return
      end

************************************************************************

      subroutine Root_BC_In (iTlevel,tBCR1,tBCR2,tEnd,t,dt,rRoot,PlnmF,
     1 IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:rRoot1,rRoot2
      implicit doubleprecision(A-H,O-Z)

      parameter(NCol=2)

      DOUBLEPRECISION t,tBCR1,tBCR2,tEnd
      logical StarF,PlnmF
      integer iTlevel

      dimension Mask(NCol),Col(NCol)

      data Mask/NCol*0/

      if(iTlevel.eq.0) then
        call SkipStars(idc+iRT)
        read(idc+iRT,*) ii
        if(ii.eq.0) PlnmF=.false.
        call SkipStars(idc+iRT)
        read(idc+iRT,*) (Mask(i),i=1,NCol)
        call SkipStars(idc+iRT)
        call ReadLine(idc+iRT,Mask,Col,NCol,DBLE(0.))
   10   if(Col(1).le.t+dt.and..not.StarF(idc+iRT)) then
          call ReadLine(idc+iRT,Mask,Col,NCol,DBLE(0.))
          goto 10
        endif
        if(Col(1).gt.t+dt) backspace (IDC+IRT)
        tBCR1=t
        tBCR2=t+dt
        rRoot1=abs(Col(2))
        rRoot2=abs(Col(2))
      endif

      if(PlnmF) then
        ddt=(t-tBCR1)/(tBCR2-tBCR1)
        rRoot=rRoot1+(rRoot2-rRoot1)*ddt
      else
        rRoot=rRoot2
      endif

      if(iTlevel.ge.1.and.abs(t-tBCR2).le..001*dt) then
        tBCR1=tBCR2
        rRoot1=rRoot2
        tBCR2=tEnd
        if(StarF(idc+iRT)) goto 20
        call ReadLine(idc+iRT,Mask,Col,NCol,DBLE(0.))
        tBCR2=Col(1)
        rRoot2=abs(Col(2))
      endif
   20 continue

      return
      end

***********************************************************************
      logical function StarF(Unit)
      integer Unit
      character*1 String
      read(Unit,*) String
      backspace Unit
      if(String.eq.'*') then
        StarF=.true.
      else
        StarF=.false.
      endif
  100 format(a1)
      return
      end
************************************************************************

      subroutine SkipStars(Unit)
      integer Unit
      character*1 String
   10 continue
      read(Unit,100) String
      if(String.eq.'*') then
        goto 10
      else
        backspace (Unit)
      endif
  100 format(a1)
      return
      end
************************************************************************
      subroutine ReadLine (Unit,Mask,Col,NCol,Dflt)
      implicit doubleprecision(A-H,O-Z)
      integer Unit, iostat
      dimension Mask(NCol),Col(NCol)
      MaskS=0
!	  do 110 i=1,NCol
!        MaskS=MaskS+Mask(i)
!		write(*,*) Mask(i)
!  110 continue
      do 10 i=1,NCol
        MaskS=MaskS+Mask(i)
!		write(*,*) Mask(i)
   10 continue
!      write(*,*) Mask(NCol),NCol,Dflt, MaskS,i,Mask(i)
      if (i .gt. NCol) then
         Mask(i)=0
      endif 	

!      write(*,*) Mask(NCol),NCol,Dflt, MaskS,i,Mask(i)	  
      read(Unit,*,iostat=iostat) (Col(jj),jj=1,MaskS)
      jj=MaskS
!	  write(*,*) iostat
      do 20 j=NCol,1,-1
        if(Mask(j).eq.1) then
          Col(j)=Col(jj)
          jj=jj-1
        else
          Col(j)=Dflt
        endif
!		write(*,*) Col(j)
   20 continue
      return
      end

************************************************************************

      subroutine ReadTable(
     .Unit,Mask,Col1,Col2,Col3,Col4,NLine,NCol,Dflt)
      implicit doubleprecision(A-H,O-Z)

      logical StarF
      integer Unit
      DOUBLEPRECISION Line1,Line2

      dimension
     .Mask(*),Col1(*),Col2(*),Col3(*),Col4(*),Line1(4),Line2(4)
      j=0
      call SkipStars(Unit)
      read(Unit,*) (Mask(i),i=1,NCol)
      do 5 i=1,NCol
        j=j+Mask(i)
    5 continue
      if(j.eq.0) then
        do 6 i=1,NLine
          if(NCol.ge.2) Col2(i)=Dflt
          if(NCol.ge.3) Col3(i)=Dflt
          if(NCol.ge.4) Col4(i)=Dflt
    6   continue
        return
      endif
      call SkipStars(Unit)
      if(Mask(1).eq.0) then
        do 8 i=1,NLine
          call ReadLine(Unit,Mask,Line1,NCol,Dflt)
          if(NCol.ge.2) Col2(i)=Line1(2)
          if(NCol.ge.3) Col3(i)=Line1(3)
          if(NCol.ge.4) Col4(i)=Line1(4)
    8   continue
        return
      endif
      call ReadLine(Unit,Mask,Line2,NCol,Dflt)
      call ReadLine(Unit,Mask,Line1,NCol,Dflt)
      do 20 i=1,NLine
   10   if(Col1(i).gt.Line1(1)) then
          if(StarF(Unit)) then
            Line1(1)=Col1(i)
          else
            do 15 j=1,NCol
              Line2(j)=Line1(j)
   15       continue
            call ReadLine(Unit,Mask,Line1,NCol,Dflt)
            goto 10
          endif
        endif
        xd=Col1(i)-Line1(1)
        dd=Line2(1)-Line1(1)
        if(NCol.ge.2) Col2(i)=Line1(2)+xd*(Line2(2)-Line1(2))/dd
        if(NCol.ge.3) Col3(i)=Line1(3)+xd*(Line2(3)-Line1(3))/dd
        if(NCol.ge.4) Col4(i)=Line1(4)+xd*(Line2(4)-Line1(4))/dd
   20 continue
      return
      end

************************************************************************
      
      SUBROUTINE ZEROIZE()
      USE HYDRUS
        WaterF=.FALSE.
        SolutF=.FALSE.
        HeatF=.FALSE.
        RootF=.FALSE.
        WLayrF=.FALSE.
        qGWLF=.FALSE.
        ShortF=.FALSE.
        H_weight=.FALSE.
        SeepF=.FALSE.
        AtmBCF=.FALSE.
        ConvgF=.FALSE.
        SatF=.FALSE.
        ChangF=.FALSE.
        Linear=.FALSE.
        ScrnF=.FALSE.
        weight=.FALSE.
        SStrsF=.FALSE.
        SteadyF=.FALSE.
        Picard=.FALSE.
        UserF=.FALSE.
        PLNMRF=.TRUE.
        BCKSPWF=.FALSE.
        PLNMWF=.FALSE.
        IHys=0
        iPlevel=0
        IRoot=0
        ItCum=0
        ItCumS=0
        Iter=0
        iTlevel=0
        KBotCh=0
        KBotH=0
        KodBot=0
        KodTop=0
        KodTop0=0
        KTopCh=0
        KTopH=0
        MaxIt=0
        Nit=0
        NItMax=0
        NMat=0
        NObs=0
        NReg=0
        NumNP=0
        Ampl=DBLE(0.)
        cBot=DBLE(0.)
        Courant=DBLE(0.)
        Cs=DBLE(0.)
        Ctol=DBLE(0.)
        cTop=DBLE(0.)
        CosAlf=DBLE(0.)
        DMul1=DBLE(0.)
        DMul2=DBLE(0.)
        dt=DBLE(0.)
        dtH=DBLE(0.)
        dtMax=DBLE(0.)
        dtMin=DBLE(0.)
        dtS=DBLE(0.)
        dtW=DBLE(0.)
        Epsi=DBLE(0.)
        hBot=DBLE(0.)
        hCritA=DBLE(0.)
        HPeclet=DBLE(0.)
        hRoot=DBLE(0.)
        hTabM=DBLE(0.)
        hTop=DBLE(0.)
        Omega=DBLE(0.)
        Omega_H=DBLE(0.)
        Omega0=DBLE(0.)
        Peclet=DBLE(0.)
        rBot=DBLE(0.)
        rRoot=DBLE(0.)
        rTop=DBLE(0.)
        Sv0C=DBLE(0.)
        Sv1C=DBLE(0.)
        Sv1T=DBLE(0.)
        SvBot=DBLE(0.)
        SvBotC=DBLE(0.)
        SvBotH=DBLE(0.)
        SvRoot=DBLE(0.)
        SvTop=DBLE(0.)
        SvTopC=DBLE(0.)
        SvTopH=DBLE(0.)
        t=DBLE(0.)
        tBC=DBLE(0.)
        tBCH=DBLE(0.)
        tBCR=DBLE(0.)
        tBCS=DBLE(0.)
        tEnd=DBLE(0.)
        Tol=DBLE(0.)
        tOld=DBLE(0.)
        Tolh=DBLE(0.)
        TpBot=DBLE(0.)
        TpTop=DBLE(0.)
        vBot=DBLE(0.)
        vRoot=DBLE(0.)
        vTop=DBLE(0.)
        iObs=DBLE(0.)
        iReg=DBLE(0.)
        Kappa=DBLE(0.)
        KappaO=DBLE(0.)
        MatNum=DBLE(0.)
        Ah=DBLE(0.)
        AhW=DBLE(0.)
        AK=DBLE(0.)
        AKS=DBLE(0.)
        AKW=DBLE(0.)
        Alpha=DBLE(0.)
        ATh=DBLE(0.)
        AThS=DBLE(0.)
        AThW=DBLE(0.)
        Bet=DBLE(0.)
        Beta=DBLE(0.)
        CapS=DBLE(0.)
        CAP=DBLE(0.)
        CONO=DBLE(0.)
        HTEMP=DBLE(0.)
        HOLD=DBLE(0.)
        Con=DBLE(0.)
        Conc=DBLE(0.)
        ConR=DBLE(0.)
        ConSat=DBLE(0.)
        g0=DBLE(0.)
        g1=DBLE(0.)
        gT1=DBLE(0.)
        hNew=DBLE(0.)
        hSat=DBLE(0.)
        hTab=DBLE(0.)
        P=DBLE(0.)
        phi=DBLE(0.)
        qt=DBLE(0.)
        qtOld=DBLE(0.)
        Salt=DBLE(0.)
        SaltO=DBLE(0.)
        Sink=DBLE(0.)
        Temp=DBLE(0.)
        ThN=DBLE(0.)
        ThO=DBLE(0.)
        ThR=DBLE(0.)
        ThRR=DBLE(0.)
        ThS=DBLE(0.)
        TPrint=DBLE(0.)
        v=DBLE(0.)
        vOld=DBLE(0.)
        x=DBLE(0.)
        xObs=DBLE(0.)
        z=DBLE(0.)
        A=DBLE(0.)
        CHPAR=DBLE(0.)
        RSPAR=DBLE(0.)
        HPAR=DBLE(0.)
        CONTAB=DBLE(0.)
        CAPTAB=DBLE(0.)
        STAB=DBLE(0.)
        Par=DBLE(0.)
        TBC0=DBLE(0.)
        RTOP0=DBLE(0.)
        RBOT0=DBLE(0.)
        HTOP0=DBLE(0.)
        HBOT0=DBLE(0.)
        RTOP1=DBLE(0.)
        RBOT1=DBLE(0.)
        HTOP1=DBLE(0.)
        HBOT1=DBLE(0.)
        RTOP2=DBLE(0.)
        RBOT2=DBLE(0.)
        HTOP2=DBLE(0.)
        HBOT2=DBLE(0.)
        CTOP1=DBLE(0.)
        CTOP2=DBLE(0.)
        CBOT1=DBLE(0.)
        CBOT2=DBLE(0.)
        TPTOP1=DBLE(0.)
        TPTOP2=DBLE(0.)
        TPBOT1=DBLE(0.)
        TPBOT2=DBLE(0.)
        AMPL1=DBLE(0.)
        AMPL2=DBLE(0.)
        RROOT1=DBLE(0.)
        RROOT2=DBLE(0.)
        vinitW=DBLE(0.)
        vinitS=DBLE(0.)
        vinitH=DBLE(0.)
        CRROOT=DBLE(0.)
        CVROOT=DBLE(0.)
        SRTOP=DBLE(0.)
        TBC1=DBLE(0.)
        TBCS1=DBLE(0.)
        plnmsF=.TRUE.
        plnmhF=.TRUE.
        TBCH1=DBLE(0.)
        TBCR1=DBLE(0.)
        PlnmrF=.TRUE.
        INTERF=0
        THNA=0.
        THNB=0.
      RETURN
      END
*     Source file WATER.FOR
      subroutine Water(
*     Geometry, time, iteration and print control parameters
     .NumNP,NMatD,NMat,MatNum,NReg,iReg,x,CosAlf,LUnit,TUnit,iTlevel,
     .t,tBC,tEnd,dt,dtMin,dtMax,tOld,dtW,Iter,ItCum,Tol,
     .Tolh,MaxIt,DMul1,DMul2,ConvgF,ChangF,iPlevel,TPrint,
     .ShortF,Heading,xObs,iObs,NObs,ScrnF,
*     Soil hydraulic properties
     .Par,NParD,ConSat,hSat,ThR,ThS,Ah,AK,ATh,NTabD,hTab,hTabM,ConTab,
     .CapTab,STab,IHys,Kappa,KappaO,AThS,ThRR,ConR,AKS,AhW,AThW,AKW,
*     Boundary condition variables
     .KodTop,KodBot,rTop,rBot,hTop,hBot,hCritA,SteadyF,AtmBCF,
     .SeepF,WLayrF,qGWLF,vRoot,SvTop,SvBot,SvRoot,SatF,
*     Main Richards equation variables
     .hNew,hOld,hTemp,ThN,ThO,Con,ConO,Cap,Sink,A,P,vTop,vBot,v,vOld,
     .qt,qtOld,IDC,IP,T0,ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:tBC1,IEQ,IELE,PlnmWF,BckspWF
      USE Q3DMODULE,ONLY:IBOT
      implicit doubleprecision(A-H,O-Z)
      character*72 Heading
      character*7 LUnit,TUnit
      integer iTlevel,iPlevel,iReg
      DOUBLEPRECISION ConTab,CapTab,STab,Con,Cap,ConO,ThN,ThO,RT,ST,
     1PT,A,P,t,
     1tOld,tBC,tEnd,TPrint
      logical ConvgF,qGWLF,AtmBCF,WLayrF,SeepF,ChangF,ShortF,
     .SatF,ScrnF,SteadyF
      REAL T0
      dimension
     .MatNum(*),x(NUMNP),Par(NParD,NMatD,2),Con(NUMNP),Cap(NUMNP),
     1ConSat(NUMNP),hSat(NUMNP),
     .ThR(NUMNP),ThS(NUMNP),Ah(*),AK(*),ATh(*),xObs(*),iObs(*),
     1hTab(*),vOld(NUMNP),ConTab(NTabD,*),CapTab(NTabD,*),
     .STab(NTabD,*),ConO(NUMNP),hNew(NUMNP),
     .hOld(NUMNP),hTemp(NUMNP),ThN(NUMNP),ThO(NUMNP),Sink(NUMNP),
     1A(NumNP,3),TPrint(*),v(NUMNP),iReg(*),P(NUMNP),Kappa(*),KappaO(*),
     .AThS(*),ThRR(*),ConR(*),AKS(*),
     .AhW(*),AThW(*),AKW(*),qt(NUMNP),qtOld(NUMNP)
       !DIMENSION B1D(NUMNP)
       
       DIMENSION::AA(IBOT(IP),3),PP(IBOT(IP)),BB(IBOT(IP))
       
      if(iTlevel.eq.0) then ! initialisation ----------------------------
        
        ITER=0
        
        IF(T0==0)call Water_In(IDC)
        
        IF(T0>0)CALL Water_In_NULL(IDC)
        
        call W_Check_Out(IDC,T0,ITERQ3D)
        
        call W_Mater_Out(IDC,T0,ITERQ3D)
        
        IF(T0==0)call Generate_Materials
        
        call Set_Coefficients_W(ITER)
        
        call Water_BC_In(IDC,ITERQ3D,T0)
        
      ELSEIF(ITLEVEL>0)THEN
  200   continue
        
        call Water_BC_In(IDC,ITERQ3D,T0)
        
        Iter=0
        
  250   continue
        
        CALL SET_COEFFICIENTS_W(ITER)
        
        IF(ITER.EQ.1.AND.IHYS.EQ.1)CALL HYSTERESIS
      
        CALL SET_RICHARDS(AA,PP,ST,SB,RT,RB,PT,PB,T,IBOT(IP))
        
        CALL HYDRUS1BOT(IP,AA,PP,IBOT(IP))
        
        CALL SOLVER(AA,PP,BB,IBOT(IP))
        
        CALL VARIABLE_SWITCH(BB,IBOT(IP),ST,RT,PT,PB,RB,SB)
        
        ITER =ITER+1
        ITCUM=ITCUM+1

        IF(ATMBCF.OR.SEEPF)CALL CHANGE_BC

        CALL TEST_CONVERGENCY(ITER,IGOTO)
        
        GOTO (200,250,460) IGOTO
  460   continue
      
      ENDIF
      
      call W_BC_Out(
     . t,dt,iTlevel,tBC1,tEnd,Iter,ItCum,ShortF,TPrint,iPlevel,rTop,
     . vRoot,SvTop,SvBot,SvRoot,hNew,NumNP,vTop,vBot,Heading,
     . LUnit,TUnit,KodTop,KodBot,ScrnF,IDC,T0,IP,ITERQ3D)
      if(iTlevel.eq.0) then
        call W_Flux(V)
      else
        VOLD=V
        call W_Flux_R(v)
        if(iTlevel.gt.2.and.SteadyF)call W_Flux(V)
        !CALL W_Flux(V)
        QTOLD=QT
        QT=(V-VOLD)/DT
      endif
      IF(NOBS>0)THEN
        
        P=DBLE(v)
        
        call X_Observ_Out(
     .   xObs,iObs,NObs,hNew,hNew,hNew,ThN,P,2,1,2,x,t,tEnd,dt,
     .   iTlevel,TPrint,iPlevel,ShortF,tBC1,idc+iwobs,IDC,
     1   T0,ITERQ3D)
        
      ENDIF
      if(abs(TPrint(iPlevel)-t).lt.0.001*dt.or.
     1 (SteadyF.and.iTlevel.gt.2))then
        call W_Nodes_Out(
     .   NumNP,x,TPrint,iPlevel,hNew,Cap,Con,t,iTlevel,Heading,LUnit,
     .   TUnit,ThN,v,STEADYF,IDC,ITERQ3D,T0)
        call W_Balanc_Out(
     .   NumNP,NReg,x,MatNum,iReg,t,iTlevel,ThN,ThR,SvTop,SvBot,
     1   SvRoot,IDC,ITERQ3D)
      endif
*     Time step as a function of the number of iterations
      if(iTlevel.gt.0) then
        if(Iter.le.3) dtW=min(dtMax,DMul1*dtW)
        if(Iter.ge.7) dtW=max(dtMin,DMul2*dtW)
      endif
      
      return
      end
************************************************************************
      SUBROUTINE VARIABLE_SWITCH(BB,NN,ST,RT,PT,PB,RB,SB)
      USE HYDRUS,ONLY:iEQ,NUMNP,HNEW,THN,ICOUP,ieq,X,THS,MATNUM,VTOP,
     1 VBOT
      IMPLICIT DOUBLEPRECISION (A-H,O-Z)
      DOUBLEPRECISION BB,ST,RT,PT,PB,RB,SB
      DIMENSION BB(NN)
      
      DO I=1,NN
        IF(IEQ(I)>0)THEN
          HNEW(I)=BB(I)
          CALL FINDTHN(I)
        ELSEIF(iEQ(I)<0)THEN
          THN(I)=BB(I)
          CALL FINDHNEW(I)
        ENDIF
      ENDDO
      
      IF(NN<NUMNP)THEN
        DO I=NN+1,NUMNP
          HNEW(I)=HNEW(I-1)+X(I)-X(I-1)
          M=MATNUM(I)
          THN(I)=THS(M)
        ENDDO
      ENDIF
      
      IF(IEQ(1)>0)THEN
          VTOP=ST*HNEW(2)+RT*HNEW(1)-PT
      ELSEIF(IEQ(1)<0)THEN
          VTOP=ST*THN(2)+RT*THN(1)-PT
      ENDIF
        
      IF(IEQ(NN)>0)THEN
        VBOT=PB-RB*HNEW(NN)-SB*HNEW(NN-1)
      ELSEIF(IEQ(NN)<0)THEN
        VBOT=PB-RB*THN(NN)-SB*THN(NN-1)
      ENDIF
      
      RETURN
      END
      
      SUBROUTINE FINDHNEW(I)
      USE HYDRUS,ONLY:THN,INTERF,MATNUM,HNEW,HSAT,Z,PAR
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      IF(INTERF(I)==0)THEN
        M2=MATNUM(I)
        QE=(THN(I)-PAR(1,M2,1))/(PAR(2,M2,1)-PAR(1,M2,1))
        HNEW(I)=FH(QE,M2,1)
      ELSE
        M1=MATNUM(I-1)
        M2=MATNUM(I)
        D1=Z(I)-Z(I-1)
        D2=Z(I+1)-Z(I)
        H0=HNEW(I-1)+D1*(HNEW(I+1)-HNEW(I-1))/(D1+D2)
        DTH=1.D0
        W1=Z(I-1)/(Z(I-1)+Z(I))
        W2=1.-W1
        it=0
        DO WHILE(ABS(DTH)>1.D-15)!Newton's iteration
          HIM1=MIN(H0,HSAT(M1))
          HIM2=MIN(H0,HSAT(M2))
          TH1 =FQ(HIM1,M1,1)
          TH2 =FQ(HIM2,M2,1)
          TH0 =W1*TH1+W2*TH2
          C1  =FC(HIM1,M1,1)
          C2  =FC(HIM2,M2,1)
          C0  =W1*C1+W2*C2
          DTH =TH0-THN(I)
          H0  =H0-DTH/C0
          IT=IT+1
          IF(IT>5000)THEN 
            WRITE(*,*)"Newton's iteration diverges!"
            exit
          ENDIF
        ENDDO
        HNEW(I)=H0
      ENDIF
      END
      subroutine Generate_Materials
      USE HYDRUS,ONLY:NMAT,CONSAT,THS,THR,HSAT,PAR
      implicit doubleprecision(A-H,O-Z)
      !JCZENG 20180415 只有初始时刻才处理土壤参数
      DO M=1,NMat
        ConSat(M)=Par(5,M,1)
        ThS(M)=Par(2,M,1)
        ThR(M)=Par(1,M,1)
        hSat(M)=FH(1.d0,M,1)
      ENDDO
      !hTab(1)=0.
      !hTab(NTabD)=hTabM
      !if(hTabM<0.)THEN
      !  a=-hTabM*.00001
      !  x0=log10(a)
      !  xN=log10(a-hTabM)
      !  dx=(xN-x0)/(NTabD-1)
      !  do i=2,NTabD-1
      !    hTab(i)=a-10**(x0+(i-1)*dx)
      !  enddo
      !  do M=1,NMat
      !    do i=1,NTabD
      !      ConTab(i,M) =FK(hTab(i),M,1)
      !      CapTab(i,M) =FC(hTab(i),M,1)
      !      STab(i,M)   =FS(hTab(i),M,1)
      !!      JCZENG 2017.12.2
      !      THTAB(I,M)  =FQ(HTAB(I),M,1)
      !      DIFFTAB(I,M)=FD(hTab(i),M,1)
      !    enddo
      !  enddo
      !ENDIF
      return
      end

************************************************************************

      subroutine Set_Coefficients_W(ITER)
      USE HYDRUS,ONLY:DIFF,NUMNP,THO,CON,CONO,HOLD,HTEMP,THN,HNEW,ieq,
     1 IELE
      implicit doubleprecision(A-H,O-Z)
      DO I=1,NUMNP
        CALL FINDCAP(I)  
        CALL FINDTHN(I)
        CALL FINDDIFF(I)
        CALL FINDCON(I)
        HTEMP(I)=HNEW(I)
        IF(ITER==0) then
          HOLD(I)=HNEW(I)
          CONO(I)=CON(I)
          THO(I)=THN(I)
          CALL EQUATION(I,IEQ)
        ENDIF
        IF(I>1)THEN
          IF(IEQ(I)==IEQ(I-1))THEN
            IELE(I-1)=0 !Non-mixed element
          ELSEIF(IEQ(I).NE.IEQ(I-1))THEN
            IELE(I-1)=1 !Mixed element
          ENDIF
        ENDIF
      ENDDO
      RETURN
      END
      SUBROUTINE EQUATION(I,IEQ)
      USE HYDRUS,ONLY:ICOUP,INTERF,NUMNP,MATNUM,
     1 THRESH,HSAT,PAR,Z,NMAT,HNEW
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      DIMENSION IEQ(NUMNP)
      IF(ICOUP==-1)THEN
        IEQ(I)=-1
      ELSEIF(ICOUP==1)THEN
        IEQ(I)=1
      ELSEIF(ICOUP==2 .OR. ICOUP==3)THEN
        M1=MATNUM(I)
        HIM1=MIN(HNEW(I),HSAT(M1))
        DEX=FS(HIM1,M1,1)
        IF(INTERF(I)>0)THEN
          M2=MATNUM(I-1)
          HIM2=MIN(HNEW(I),HSAT(M2))
          DEX2=FS(HIM2,M2,1)
          DEX=MAX(DEX,DEX2)
        ENDIF
        !em=1.d0-1.d0/Par(4,M1,1)
        !THRESH=(1+EM)**(-EM)
        IF(DEX>=THRESH)THEN
          IEQ(I)=1
        ELSE
          IEQ(I)=-1
        ENDIF
        
        IF(INTERF(I)>0)IEQ(I)=1 !JCZ 2018.1.9 Avoiding the divergence of Newton's method in heterogeneous soils WHEN USING COARSE GRIDS
        IF(I==NUMNP)IEQ(I-1)=IEQ(I)
        IF(I==2)IEQ(I)=IEQ(I-1)
      ENDIF
      RETURN
      END
      SUBROUTINE FINDCAP(I)
      USE HYDRUS,ONLY:MATNUM,INTERF,Z,CAP
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      IF(INTERF(I)==0)THEN
        CAP(I)=FFCAP(I,MATNUM(I))
      ELSE
        CAP1=FFCAP(I,MATNUM(I-1))
        CAP2=FFCAP(I,MATNUM(I))
        CAP(I)=(CAP1*Z(I-1)+CAP2*Z(I))/(Z(I-1)+Z(I))
      ENDIF
      RETURN
      END
      DOUBLEPRECISION FUNCTION FFCAP(I,M)
      USE HYDRUS,ONLY:HSAT,HTAB,NTABD,CAPTAB,NUMNP,NMAT,HNEW
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      HIM=MIN(HNEW(I),HSAT(M))
      if(hiM.ge.hSat(M)) then
        FFCap=0.
        
      !ELSEIF(hiM>hTab(NTabD).and.hiM<hTab(1))THEN
      !  FFCap=USETAB(hiM,CAPTAB,M)
      ELSE
        FFCap=FC(hiM,M,1)
      ENDIF
      RETURN
      END
      SUBROUTINE FINDTHN(I)
      USE HYDRUS,ONLY:MATNUM,INTERF,Z,THN,THNA,THNB
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      IF(INTERF(I)==0)THEN
        THN(I)=FFTHN(I,MATNUM(I))
        THNA(I)=THN(I)
        THNB(I)=THN(I)
      ELSE
        THNA(I)=FFTHN(I,MATNUM(I-1))
        THNB(I)=FFTHN(I,MATNUM(I))
        THN(I)=(THNA(I)*Z(I-1)+THNB(I)*Z(I))/(Z(I-1)+Z(I))
      ENDIF
      RETURN
      END
      DOUBLEPRECISION FUNCTION FFTHN(I,M)
      USE HYDRUS,ONLY:HSAT,HTAB,NTABD,THTAB,THS,PAR,NUMNP,NMAT,
     1 HNEW
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      HIM=MIN(HNEW(I),HSAT(M))
      if(hiM.ge.hSat(M)) then
        FFTHN=PAR(2,M,1)
      !elseif(hiM>hTab(NTabD).and.hiM<hTab(1)) then
      !  FFTHN=USETAB(hiM,THTAB,M)
      else
        FFTHN=FQ(hiM,M,1)
      endif
      END FUNCTION
      SUBROUTINE FINDDIFF(I)
      USE HYDRUS,ONLY:NUMNP,MATNUM,DIFF
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      IF(I==NUMNP)RETURN
      DIFF1=FFDIFF(I,MATNUM(I))
      DIFF2=FFDIFF(I+1,MATNUM(I))
      DIFF(I)=DIFF1*.5+DIFF2*.5
      
      RETURN
      END
      DOUBLEPRECISION FUNCTION FFDIFF(I,M)
      USE HYDRUS,ONLY:HTAB,NTABD,HSAT,PAR,DIFFTAB,HNEW
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      
      HIM=MIN(HNEW(I),HSAT(M))
      if(hiM.ge.hSat(M)) then
        FFDIFF=0.
      !elseif(hiM>hTab(NTabD).and.hiM<hTab(1)) then
      !  FFDIFF=USETAB(hiM,DIFFTAB,M)
      else
        FFDIFF=FD(hiM,M,1)
      endif
      END FUNCTION
      SUBROUTINE FINDCON(I)
      USE HYDRUS,ONLY:NUMNP,MATNUM,CON
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      IF(I==NUMNP)RETURN
      CON1=FFCON(I,MATNUM(I))*.5
      CON2=FFCON(I+1,MATNUM(I))*.5
      CON(I)=CON1+CON2
      RETURN
      END
      DOUBLEPRECISION FUNCTION FFCON(I,M)
      USE HYDRUS,ONLY:HTAB,NTABD,HSAT,CONSAT,PAR,NUMNP,NMAT,
     1 CONTAB,HNEW
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      
      HIM=MIN(HNEW(I),HSAT(M))
      if(hiM.ge.hSat(M))then
        FFCON=CONSAT(M)
      !elseif(hiM>hTab(NTabD).and.hiM<hTab(1)) then
      !  FFCON=USETAB(hiM,CONTAB,M)
      else
        FFCON=FK(hiM,M,1)
      endif
      END
      subroutine Set_Richards(A,P,ST,SB,RT,RB,PT,PB,TT,NN)
      USE HYDRUS,ONLY:IEQ,IELE,DIFF,ICOUP,HCRITA,Z,X,DT,STEADYF,
     1 THNA,THNB,MATNUM,SINK,WLAYRF,QGWLF,KODTOP,KODBOT,HNEW,HOLD,
     1 THN,THO,CAP,CON,CONO,SATF,RTOP,RBOT,HTOP,HBOT,ATMBCF,KODTOP0
      USE Q3DMODULE,ONLY:Q3DF !JCZENG 20180414
      implicit DOUBLEPRECISION(a-h,o-z)
      !DIMENSION P(NUMNP),A(NUMNP,3),S(NUMNP),F(NUMNP),T(NUMNP),E(NUMNP)
      DIMENSION P(NN),A(NN,3),S(NN),F(NN),T(NN),E(NN)
      N=NN
      S=0.
      F=0.
      T=0.
      A=0.
      E=0.
      P=0.
      ENTA=5.D-1
      ! 节点
      DO I=1,N
        IF(I==1)THEN
          DZ=0.5*Z(1)
        ELSEIF(I==N)THEN
          DZ=0.5*Z(N-1)
        ELSE
          DZ=0.5*(Z(I-1)+Z(I))
        ENDIF
        IF(IEQ(I)>0)THEN
          F(I)=-DZ*SINK(I)
          IF(.NOT.STEADYF)THEN
            S(I)=CAP(I)*DZ/DT
            F(I)=F(I)+(CAP(I)*HNEW(I)-(THN(I)-THO(I)))*DZ/DT
          ENDIF
        ELSEIF(IEQ(I)<0)THEN
          F(I)=-DZ*SINK(I)
          IF(.NOT.STEADYF)THEN
            S(I)=DZ/DT
            F(I)=F(I)+THO(I)*DZ/DT
          ENDIF
        ENDIF
      ENDDO
      ! 单元
      DO I=1,N-1
        DZ  =Z(I)
        CC  =CON(I)/DZ
        DD  =DIFF(I)/DZ
        BUFG=CON(I)
        IF(iELE(I)==0)THEN
          IF(iEQ(I)>0)THEN
            BUFT=0.
            BUFC=CC
          ELSEIF(iEQ(I)<0)THEN
            BUFT=DD*(THN(I+1)-THN(I)+THNB(I)-THNA(I+1))
            BUFC=DD
          ENDIF
          A(I,2)  =A(I,2)   +BUFC
          A(I,3)  =A(I,3)   -BUFC
          A(I+1,1)=A(I+1,1) -BUFC
          A(I+1,2)=A(I+1,2) +BUFC
          T(I)    =T(I)     -BUFG-BUFT
          T(I+1)  =T(I+1)   +BUFG+BUFT
        ELSEIF(iELE(I).NE.0)THEN
          IF(ICOUP==2)THEN
            BUFT1=ENTA*CC*(HNEW(I)-hNEW(I+1))
            BUFT2=(1.0D0-ENTA)*DD*(THNB(I)-THNA(I+1))
            Q=2*BUFT1+BUFG
            !Q=BUFT1+BUFT2+BUFG
            T(I)  =T(I)  -Q
            T(I+1)=T(I+1)+Q
          ELSEIF(ICOUP==3)THEN
            IF(IEQ(I)>0)THEN
              DTH =THN(I+1)+THNB(I)-THNA(I+1)
              BUFT=(1-ENTA)*DD*DTH-ENTA*CC*HNEW(I+1)
              A(I,2)  =A(I,2)  +ENTA*CC
              A(I,3)  =A(I,3)  -(1.D0-ENTA)*DD
              A(I+1,1)=A(I+1,1)-ENTA*CC
              A(I+1,2)=A(I+1,2)+(1.D0-ENTA)*DD
            ELSEIF(IEQ(I)<0)THEN
              DTH =THNB(I)-THNA(I+1)-THN(I)
              BUFT=ENTA*CC*HNEW(I)+(1.D0-ENTA)*DD*DTH
              A(I,2)  =A(I,2)  +(1.D0-ENTA)*DD
              A(I,3)  =A(I,3)  -ENTA*CC
              A(I+1,1)=A(I+1,1)-(1.D0-ENTA)*DD
              A(I+1,2)=A(I+1,2)+ENTA*CC
            ENDIF
            T(I)  =T(I)  -BUFT-BUFG
            T(I+1)=T(I+1)+BUFT+BUFG
          ENDIF
        ENDIF
      ENDDO
      DO I=1,N
        P(I)=F(I)+T(I)
        A(I,2)=A(I,2)+S(I)
      ENDDO
      ST=A(1,3)
      RT=A(1,2)
      PT=P(1)
      SB=A(N,1)
      RB=A(N,2)
      PB=P(N)
*     Upper boundary conditions
      if(KodTop.eq.2) then ! flux BC
        P(1)=P(1)+rTop
      endif
      if(WLayrF) then ! surface reservoir BC
        if(SatF) then
          A(1,2)=A(1,2)+1/dt
          P(1)=P(1)+rTop+max(hOld(1),0.)/dt
        else
          P(1)=P(1)+rTop+max(hOld(1),0.)/dt
        endif
      endif
      if(KodTop.eq.1) then ! pressure head BC
        !A(1,3)=0.
        A(1,2)=1.D30
        
        IF(ATMBCF.AND.HNEW(1)<=(HCRITA+0.5))HTOP=HCRITA !JCZENG 20180414 VERY IMPORTANT REVISION
        
        IF(IEQ(1)>0)THEN
          P(1)=hTOP*1.D+30
        ELSEIF(IEQ(1)<0)THEN
          P(1)=FQ(HTOP,MATNUM(1),1)*1.D30
        ENDIF
      endif
      !KODTOP0=KODTOP  
        
*     Lower boundary conditions
      IF(.NOT.Q3DF)THEN
        if(KodBot.eq.2) then ! flux BC
          P(N)=P(N)-rBot
        endif
        if(KodBot.eq.3) then ! free drainage BC
          A(N,1)=-1.D0
          A(N,2)=1.D0
          P(N)=0.D0
        endif
        if(qGWLF) then ! outflow function BC
          rBot=Fqh(hOld(N))
          P(N)=P(N)-rBot
        endif
        if (KodBot.eq.1) then ! Dirichlet BC
          A(N,2)=1.D+30
          !A(N,1)=0.
          IF(IEQ(N)>0)THEN
            P(N)=hBot*1.D+30
          ELSEIF(IEQ(N)<0)THEN
            P(N)=FQ(HBOT,MATNUM(N),1)*1.D+30
          ENDIF
        endif
      ENDIF
      return
      end
      subroutine Solver(A,P,H,N)
      implicit doubleprecision(A-H,O-Z)
      dimension A(N,3),P(N),H(N)
      do i=2,N
        R=A(i,1)/A(i-1,2)
        A(i,2)=A(i,2)-R*A(i-1,3)
        P(i)=P(i)-R*P(i-1)
        ENDDO
      H(N)=P(N)/A(N,2)
      do i=N-1,1,-1
        H(i)=(P(i)-A(i,3)*H(i+1))/A(i,2)
        ENDDO
      return
      end

************************************************************************

      subroutine Change_BC
      USE HYDRUS,ONLY:KodTop,KodBot,hTop,hBot,rTop,rBot,hNew,vTop,
     1 vBot,WLayrF,AtmBCF,SeepF,hCritA,ChangF,SatF,NUMNP
      implicit doubleprecision(A-H,O-Z)
      N=NUMNP
      ChangF=.false.

*     Seepage face at the bottom
      if(SeepF) then
        if(KodBot.eq.1) then
          if(vBot.gt.0) then
            ChangF=.true.
            KodBot=2
            rBot=0.
          endif
        else
          if(hNew(N).ge.0) then
            ChangF=.true.
            KodBot =1
            hBot=0.
          endif
        endif
      endif
*     Atmospheric boundary condition
      if(AtmBCF) then
        if(KodTop.eq.1) then
          if(abs(vTop).gt.abs(rTop).or.vTop*rTop.le.0) then
            ChangF=.true.
            KodTop=2
          endif
        else
          if(hNew(1).gt.0..and..not.WLayrF) then
            ChangF=.true.
            KodTop=1
            hTop=0.
          endif
          if (hNew(1).le.hCritA.and.rTop.lt.0) then
            ChangF=.true.
            KodTop=1
            hTop=hCritA
          endif
        endif
      endif

*     Water layer on the surface
      if(WLayrF) then
        if(hNew(1).ge.0.) then
          if(.not.SatF) ChangF=.true.
          SatF=.true.
        else
          if(SatF) ChangF=.true.
          SatF=.false.
        endif
      endif

      return
      end

************************************************************************

      subroutine Test_Convergency(Iter,IGoTo)
      USE HYDRUS,ONLY:IEQ,INTERF,THNA,THNB,Z,MaxIt,Tol,Tolh,t,tOld,dt,
     1 dtMin,dtW,NumNP,MatNum,Ah,hNew,hOld,hTemp,ATh,ThS,ThR,Cap,
     1 ConvgF,ChangF,ThN,ThO,hSat,IHys,Kappa,KappaO,tBC1,BckspWF
      implicit doubleprecision(A-H,O-Z)
      logical ItCrF

      ItCrF=.true.
      ConvgF=.true.
      do i=NumNP,1,-1
        m=MatNum(i)                                 
        Eps=0.0
        Eph=0.0
        if(hTemp(i).lt.hSat(m)) then
          Eps=abs(Cap(i)*(hNew(i)-hTemp(i))/(ThS(m)-ThR(m))/ATh(i))
        else
c         Eps=abs(FS(hNew(i)/Ah(i),Par(1,m))-
c    .    FS(hTemp(i)/Ah(i),Par(1,m)))
          Eph=abs(hNew(i)-hTemp(i))/Ah(i)
        endif
        if(Eps.gt.Tol.or.Eph.gt.Tolh) then
          ItCrF=.false.
          goto 420
        endif
        ENDDO
  420 continue

      if(ItCrF.and..not.ChangF) then
        IGoTo=3 !next time step
      else
        if(Iter.lt.MaxIt) then
          IGoTo=2 !new iteration
        else if(dt.le.dtMin) then
          ConvgF=.false.
          IGoTo=3 !give up
        else
          do 455 i=1,NumNP
            if(IHys.eq.1) Kappa(i)=KappaO(i)
            hNew(i)=hOld(i)
            ThN(i)=ThO(i)
  455     continue
          if(abs(t-tBC1).le..001*dt) BckspWF=.true.
          dt=MAX(dt/3,dtMin)
          dtW=dt
          t=tOld+dt
          IGoTo=1 !try smaller time step
        endif
      endif
      return
      end

************************************************************************

      subroutine W_Flux(v)
      USE HYDRUS,ONLY:NUMNP,HNEW,CON,X,COSALF
      implicit doubleprecision(A-H,O-Z)
      dimension v(NumNP)
      N=NumNP
      dxA=x(2)-x(1)
      ConDA=CON(1)
      v(1)=-ConDA*(hNew(2)-hNew(1))/dxA+ConDA*CosAlf
      do i=2,N-1
        dxB=x(i+1)-x(i)
        dxA=x(i)-x(i-1)
        ConDB=CON(I)
        ConDA=CON(I+1)
        vB=-ConDB*(hNew(i+1)-hNew(i))/dxB+ConDB*CosAlf
        vA=-ConDA*(hNew(i)-hNew(i-1))/dxA+ConDA*CosAlf
        v(i)=(vA*dxA+vB*dxB)/(dxA+dxB)
      ENDDO
      dxB=x(N)-x(N-1)
      ConDB=CON(N-1)
      v(N)=-ConDB*(hNew(N)-hNew(N-1))/dxB+ConDB*CosAlf

      return
      end

************************************************************************

      subroutine W_Flux_R(v)                                       
      USE HYDRUS,ONLY:MATNUM,NUMNP,HOLD,HNEW,X,SINK,DT,VTOP
      implicit doubleprecision(A-H,O-Z)
      DOUBLEPRECISION ThN0,THN1,THO0,THO1
      dimension v(NumNP)
      dV=0.
      SS=0.
      v(1)=vTop
      do i=2,NumNP
        dx=x(i)-x(i-1)
        M=MATNUM(I-1)
        THN0=FQ(HNEW(I-1),M,1)
        THN1=FQ(HNEW(I),M,1)
        THO0=FQ(HOLD(I-1),M,1)
        THO1=FQ(HOLD(I),M,1)
        dV=dV+dx*(ThN0+ThN1-ThO0-ThO1)/2.
        SS=SS+dx*(Sink(i)+Sink(i-1))/2.
        v(i)=vTop-dV/dt-SS
      ENDDO
      return
      end

***********************************************************************
      subroutine Hysteresis
      USE HYDRUS,ONLY:NumNP,NParD,NMatD,hOld,MatNum,Par,ThN,ThO,Kappa,
     1 AThS,ThRR,ConO,ConR,AKS,iTlevel,KappaO,Ah,AK
      implicit DOUBLEPRECISION(a-h,o-z)
      
      do 100 i=1,NumNP
*     Check for reversal
      KappaO(i)=Kappa(i)
      if((ThN(i)-ThO(i))*Kappa(i).ge.-.00001.and.iTlevel.ne.0) goto 100
      Kappa(i)=-1*Kappa(i)
      m=MatNum(i)
      Thr=Par(1,m,1)
      ThsD=Par(2,m,1)
      ThsW=Par(2,m,2)
      KsD=Par(5,m,1)
      KsW=Par(5,m,2)

*     Update Ths and Ks for wetting scanning curve
      if(Kappa(i).eq.1) then
        if(ThsW.ge.0.999*ThsD) then
          Ths=ThsD
        else
          RR=1./(ThsD-ThsW)-1./(ThsD-Thr)
          Ths=ThsD-(ThsD-ThO(i))/(1.+RR*(ThsD-ThO(i)))
        endif
        if(KsW.ge.0.999*KsD) then
          Ks=KsD
        else
          RR=1./(KsD-KsW)-1./KsD
          Ks=KsD-(KsD-ConO(i))/(1.+RR*(KsD-ConO(i)))
        endif
      endif

*     Update parameters for scanning curve
      if(Kappa(i).eq.1) then ! Wetting
        AThS(i)=1.
        SeW=FS(hOld(i)/Ah(i),M,2)
        if(SeW.lt.0.999) AThS(i)=(ThO(i)-Ths)/(1.-SeW)/(Thr-ThsW)
        ThRR(I)=Ths-AThS(i)*(ThsW-Thr)
        AKS(i)=1.
        KW=AK(i)*FK(hOld(i)/Ah(i),M,2)
        if(KW.lt.0.999*KsW) AKS(i)=(ConO(i)-Ks)/(KW-KsW)
        ConR(i)=Ks-AKS(i)*KsW
      else ! Drying
        AThS(i)=(ThO(i)-Thr)/FS(hOld(i)/Ah(i),m,1)/(ThsD-Thr)
        AKS(i)=ConO(i)/FK(hOld(i)/Ah(i),M,1)/AK(i)
        ThRR(i)=Thr
        ConR(i)=0.
      endif

  100 continue
      return
      end
************************************************************************
*     Source file SOLUTE.FOR
      subroutine Solute(
*     Geometry, time, iteration and print control parameters
     .NumNP,NMat,NReg,MatNum,iReg,x,LUnit,TUnit,iTlevel,t,tBCS2,tEnd,
     .dt,dtMax,TPrint,iPlevel,ShortF,dtS,xObs,iObs,NObs,ScrnF,Heading,
     .Linear,weight,Alpha,Nit,ItCumS,NItMax,Ctol,Epsi,

*     Transport parameters
     .ChPar,Peclet,Courant,

*     Boundary condition and interaction variables
     .KTopCh,KBotCh,cTop,cBot,SvTopC,SvBotC,Sv0C,Sv1C,Sink,
     .Cs,WaterF,

*     Main CD-equation arrays
     .Conc,ConcO,CTemp,R,Disp,v,vOld,g0,g1,A,F,ThN,ThO,qt,qtOld,phi,
     .Salt,SaltO,CapS,Picard,UserF,IDC,T0,ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:TBCS1,PLNMSF
      implicit doubleprecision(A-H,O-Z)
      REAL T0
      character*72 Heading
      character*7 LUnit,TUnit
      integer iTlevel,iPlevel,iReg
      logical WaterF,ShortF,Linear,ScrnF,weight,Picard,UserF
      DOUBLEPRECISION A,F,ThN,ThO,R,Disp,t,tBCS2,tEnd,TPrint,CapS

      dimension
     .x(NumNP),R(NUMNP),MatNum(NumNP),iReg(*),g1(NUMNP),
     1qtOld(NUMNP),ChPar(20,*),qt(NUMNP),
     .g0(NUMNP),Conc(NUMNP),ConcO(NUMNP),CTemp(NUMNP),A(NumNP,3),
     1v(NumNP),vOld(NUMNP),F(NUMNP),
     .Disp(*),TPrint(*),ThN(NumNP),ThO(*),Sink(*),
     1xObs(*),iObs(*),Alpha(NUMNP),
     .phi(NUMNP),Salt(NUMNP),SaltO(NUMNP),CapS(NUMNP)

      N=NumNP
      if(iTlevel.eq.0) then ! initialisation ----------------------------
*     Read Solute input files
        call Solut_In(
     .   NMat,ChPar,Linear,ScrnF,N,x,Conc,ThN,ThO,v,CTemp,WaterF,dt,
     .   dtS,Epsi,weight,NItMax,Ctol,Picard,UserF,IDC)
*       Initialize CD-equation coefficients
        
        G0=0.
        G1=0.
        CONCO=CONC
        IF(.NOT.WATERF)VOLD=V
        if((.not.Linear).and.Picard)
     .    call CapC(N,MatNum,ChPar,Conc,ThN,Salt,CapS,UserF)
        ItCumS=0
        call Solut_BC_In(iTlevel,t,dt,tBCS1,tBCS2,tEnd,cTop,cBot,
     .   KTopCh,KBotCh,PlnmSF,IDC)
        dz=0.0
        y=1.e+30
        DO I=2,N
          dz1=x(i)-x(i-1)
          if(dz1.gt.dz) dz=dz1
          MT=MATNum(I)
          if(ChPar(3,MT).lt.y) y=ChPar(3,MT)
        ENDDO
        Peclet=0.0
        if(y.gt.1.e-10) Peclet=dz/y
      else ! end of initialisation -------------------------------------

        if(weight)THEN
          DO  I=2,N
            MT=MATNum(I)
            dz1=x(i)-x(i-1)
            Pec=0.0
            v1=v(i-1)/ThN(i-1)
            v2=v(i)/ThN(i)
            y=v1+v2
            vv=abs(y)
            MT1=MatNum(i-1)
            v2=ChPar(3,MT1)*abs(v1)+ChPar(3,MT)*abs(v2)
            if(v2.gt.0.) Pec=DZ1*vv/v2
            Alpha(i)=0.0
            if(Pec.gt.2.0) then
              Alpha(i-1)=1./tanh(Pec/2.)-2./Pec
              if(y.lt.0.0) Alpha(i-1)=-Alpha(i-1)
            endif
            if(Pec<100.)CYCLE
            if(y.gt.0.) Alpha(i)=1.0
            if(y.lt.0.) Alpha(i)=-1.0
          ENDDO
          Alpha(1)=Alpha(2)
          goto 4
        ENDIF
    2   Do i=1,N
         Alpha(i)=0.0
        ENDDO
        
*       Update boundary conditions
                                 
    4   call Solut_BC_In(iTlevel,t,dt,tBCS1,tBCS2,tEnd,cTop,cBot,
     .   KTopCh,KBotCh,PlnmSF,IDC)
        Nit=0
        tfac=1./(6.*dt)
        do i=1,N
          ConcO(i)=Conc(i)
          if((.not.Linear).and.Picard) SaltO(i)=Salt(i)
        ENDDO
        
*       Start of iteration for nonlinear adsorption
   20   Nit=Nit+1
*       Construct rhs of matrix equation
        if(Nit<=1)THEN
          do i=1,N
            Mt=MatNum(i)
            g0(i)=ChPar(8,Mt)*(ThN(i)+ThO(i))*0.5
     .           +ChPar(1,Mt)*ChPar(9,Mt)-Sink(i)*Cs
          ENDDO
        ENDIF
        if (abs(Epsi-0.5) .le. 1.e-10) then!  Crank-Nicolson F.D.
          Sg=Epsi-1.
          call Set_Coefficients_S(N,MatNum,dt,ChPar,ThO,R,
     .    Disp,vOld,CTemp,ConcO,Sg,Sink,phi,qtOld,WaterF,UserF)
        !  if(Linear.or.(.not.Picard))
          IF(.NOT.LINEAR .AND.PICARD)THEN
            do  i=1,N
              R(i)=CapS(i)-CTemp(i)*dt
            ENDDO
          ENDIF
          call Assemble(N,A,x,dt,R,Disp,vOld,Sg,Alpha,DBLE(1.0),phi)
          dz1=x(2)-x(1)
          if(Linear.or.(.not.Picard)) then
            F(1)=A(1,2)*ConcO(1)+A(1,3)*ConcO(2)+dz1*(2.*g0(1)+g0(2))/6.
          else
            F(1)=A(1,2)*Conc(1)+A(1,3)*Conc(2)+dz1*(2.*g0(1)+g0(2))/6.
          endif
          do i=2,N-1
            dz1=x(i)-x(i-1)
            dz2=x(i+1)-x(i)
            if(Linear.or.(.not.Picard)) then
              F(i)=A(i,1)*ConcO(i-1)+A(i,2)*ConcO(i)+A(i,3)*ConcO(i+1)
            else
              F(i)=A(i,1)*Conc(i-1)+A(i,2)*Conc(i)+A(i,3)*Conc(i+1)
            endif
            F(i)=F(i)+(dz1*(2.*g0(i)+g0(i-1))+dz2*(2.*g0(i)+g0(i+1)))/6.
          ENDDO
          dz1=x(N)-x(N-1)
          if(Linear.or.(.not.Picard)) then
            F(N)=A(N,1)*ConcO(N-1)+A(N,2)*ConcO(N)
     1      +dz1*(2.*g0(N)+g0(N-1))/6.
          else
            F(N)=A(N,1)*Conc(N-1)+A(N,2)*Conc(N)
     1      +dz1*(2.*g0(N)+g0(N-1))/6.
          endif
        else  ! Implicit F.D.
          call Set_Coefficients_S(N,MatNum,dt,ChPar,ThO,R,
     .      Disp,v,g1,ConcO,DBLE(0.),Sink,phi,qt,WaterF,UserF)
          dz1=x(2)-x(1)
c         F(1)=tfac*dz1*(2.*R(1)+R(2))*ConcO(1)+dz1*(2.*g0(1)+g0(2))/6.
          y=R(1)*ConcO(1)
          if((.not.Linear).and.Picard) y=CapS(1)*Conc(1)
          F(1)=dz1*0.5*y/dt+dz1*(2.*g0(1)+g0(2))/6.
          do i=2,N-1
            dz1=x(i)-x(i-1)
            dz2=x(i+1)-x(i)
c           F(i)=tfac*(dz1*(R(i-1)+2.*R(i))+dz2*(2.*R(i)+R(i+1)))*ConcO(i)
            y=R(i)*ConcO(i)
            if((.not.Linear).and.Picard) y=CapS(i)*Conc(i)
            F(i)=(dz1+dz2)*0.5*y/dt
            F(i)=F(i)+(dz1*(2.*g0(i)+g0(i-1))
     1              +dz2*(2.*g0(i)+g0(i+1)))/6.
          ENDDO
          dz1=x(N)-x(N-1)
c         F(N)=tfac*dz1*(R(N-1)+2.*R(N))*ConcO(N)+dz1*(2.*g0(N)+g0(N-1))/6.
          y=R(N)*ConcO(N)
          if((.not.Linear).and.Picard) y=CapS(N)*Conc(N)
          F(N)=dz1*0.5*y/dt+dz1*(2.*g0(N)+g0(N-1))/6.

        endif
      
    !   if(Linear.or.(.not.Picard)) goto 9
        IF(.NOT.LINEAR .AND.PICARD)THEN
          do  i=1,N
            if(i.eq.1) then
              dz1=0.0
              dz2=x(i+1)-x(i)
                    
                   
            ELSEif(i.eq.N) then
              dz2=0.0
              dz1=x(i)-x(i-1)
            ELSE
                   
              dz1=x(i)-x(i-1)
              dz2=x(i+1)-x(i)
            ENDIF
            Mt=MatNum(i)
            F(i)=F(i)-(dz1+dz2)*0.5/dt*(Salt(i)-SaltO(i))
          ENDDO
        ENDIF
        F1=F(1)
        FN=F(N)

*         Construct lhs of matrix equation
        Sg=Epsi
        call Set_Coefficients_S(N,MatNum,dt,ChPar,ThN,R,
     .  Disp,v,g1,Conc,Sg,Sink,phi,qt,WaterF,UserF)
        !if(Linear.or.(.not.Picard)) goto 
        IF(.NOT.LINEAR .AND. PICARD)THEN
          do i=1,N
            R(i)=CapS(i)+g1(i)*dt
          ENDDO
        ENDIF
        call Assemble(N,A,x,dt,R,Disp,v,Sg,Alpha,DBLE(1.0),phi)
        BN=A(N,1)
        DN=A(N,2)
        E1=A(1,3)
        D1=A(1,2)
        call Bound_C(KTopCH,KBotCH,N,A,F,v,cTop,cBot)
        do i=1,N
          if(abs(Epsi-0.5).le.1.e-10) R(i)=CTemp(i)
          CTemp(i)=Conc(i)
        ENDDO
        call Solver(A,F,Conc,N)
                                                  
        if((.not.Linear).and.Picard)call CapC(N,MatNum,ChPar,Conc,
     .  ThN,Salt,CapS,UserF)
*     Check convergence for non-linear adsorption
        if(.NOT.Linear)THEN
          DO I=1,N
            y=ABS(Conc(I)-CTemp(I))
            IF(y.GT.CTOL) goto 60
          ENDDO
        ENDIF
      
        call Cu(
     .   N,MatNum,x,ChPar,dt,dtS,dtMax,Courant,v,Conc,
     .   ThN,Linear,UserF)
        goto 100
   60   if(Nit.gt.NItMax) stop 'No convergence in solute'
        GOTO 20
  100   continue
        ItCumS=ItCumS+Nit
        Do i=1,N
          if(abs(Epsi-0.5).gt.1.e-10) then
            g1(i)=g1(i)*Conc(i)
          else
            g1(i)=g1(i)*Conc(i)+R(i)*ConcO(i)
          endif
        ENDDO

      endif ! ----------------------------------------------------------

*     Output
      call S_BC_Out(
     . t,dt,iTlevel,tBCS1,tEnd,ShortF,TPrint,iPlevel,Heading,
     . LUnit,TUnit,
     . cvTop,cvBot,cvCh0,cvCh1,SvTopC,SvBotC,Sv0C,Sv1C,D1,E1,F1,BN,DN,
     . FN,Conc,g0,g1,x,N,WaterF,ItCumS,Peclet,Courant,ScrnF,IDC)
      if(NObs.NE.0)THEN
        call X_Observ_Out(
     .  xObs,iObs,NObs,Conc,Conc,v,ThN,ThN,2,1,1,x,t,tEnd,
     .  dt,iTlevel,TPrint,iPlevel,ShortF,tBCS1,idc+isobs,IDC,
     1  T0,ITERQ3D)
      ENDIF
      if(abs(TPrint(iPlevel)-t).lt.0.001*dt.or.iTlevel.eq.0) then
        call S_Balanc_Out(
     .  N,NReg,x,MatNum,iReg,ChPar,t,iTlevel,Conc,ThN,SvTopC,
     .  SvBotC,Sv0C,Sv1C,Linear,UserF,R,IDC)
        call S_Nodes_Out(N,x,TPrint,iPlevel,t,iTlevel,ThN,
     .  v,g0,g1,Conc,R,Heading,LUnit,TUnit,IDC)
      endif

      return
      end

************************************************************************
      subroutine CapC(N,MatNum,ChPar,Conc,ThN,Salt,CapS,UserF)
      implicit doubleprecision(A-H,O-Z)

      DOUBLEPRECISION ThN(*),CapS(*)
      logical UserF

      dimension MatNum(*),ChPar(20,*),Conc(*),Salt(*)

      Do 10 i=1, N
        Mt=MatNum(i)
        cmid=MAX(Conc(i),1.e-6)
        if(UserF) then
        call sorption(cmid,s,ds_dc,0,Mt)
        Salt(i)=ThN(i)*cmid+s*ChPar(1,Mt)
        CapS(i)=ThN(i)+ds_dc*ChPar(1,Mt)
        else
        rfcof=ChPar(1,Mt)*ChPar(4,Mt)
        Salt(i)=ThN(i)*cmid+rfcof*cmid**ChPar(5,Mt)
        CapS(i)=ThN(i)+rfcof*ChPar(5,Mt)*cmid**(ChPar(5,Mt)-1.0)
        endif
   10 continue

      return
      end
************************************************************************
      subroutine Cu(N,MatNum,x,ChPar,dt,dtS,dtmax,Courant,v,Conc,
     .ThN,Linear,UserF)
      implicit doubleprecision(A-H,O-Z)

      logical Linear,UserF
      DOUBLEPRECISION ThN(*)

      dimension
     .x(*),MatNum(*),ChPar(20,*),Conc(*),v(*)

      Courant=0.0
      dtS=1e30
      dtM=1e30
      Rfac1=1.0e30
      do 8 i=2,N
        Mt=MatNum(i)
        cmid=MAX(Conc(i),1.e-10)
        if(UserF) then
        call sorption(cmid,s,ds_dc,-1,Mt)
        rfac=1.+ChPar(1,Mt)*ds_dc/ThN(i)
        else
        rfcof=ChPar(1,Mt)*ChPar(4,Mt)
        ffac=rfcof
        if(.not.Linear) ffac=rfcof*cmid**(ChPar(5,Mt)-1.)
        rfac=1.+ChPar(5,Mt)*ffac/ThN(i)
        endif
        if(Rfac.lt.Rfac1) Rfac1=Rfac
        dx=x(i)-x(i-1)
        vMax=dmax1(abs(v(i)/ThN(i)),abs(v(i-1)/ThN(i-1)))
        Cour=vMax*dt/dx/Rfac1
        Courant=MAX(Courant,Cour)
c       if(abs(vMax).gt.0.0) dtM=dx*Rfac1*Courant/vMax
        if(abs(vMax).gt.0.0) dtM=dx*Rfac1/vMax
        dtS=min(dtS,dtM,dtMax)
    8 continue

      return
      end

************************************************************************

      subroutine Set_Coefficients_S(N,
     .MatNum,dt,ChPar,ThN,R,Disp,v,g1,Conc,Sg,Sink,phi,qt,WaterF,UserF)
      implicit doubleprecision(A-H,O-Z)

C    Evaluate dispersion (D), Retardation (R), and Decay Coeffients (g1)

      DOUBLEPRECISION Disp,R,ThN
      Logical WaterF,UserF

      dimension
     .Conc(*),R(*),MatNum(*),g1(*),ThN(*),ChPar(20,*),phi(*),qt(*),
     .v(*),Disp(*),Sink(*)

      do 8 i=1,N
        Mt=MatNum(i)
        cmid=MAX(Conc(i),1.e-8)
        if(UserF) then
        if(cmid.le.1.e-8) then
        ffac=0.0
        else
        call sorption(cmid,s,ds_dc,0,Mt)
        ffac=s/cmid*ChPar(1,Mt)
        endif
        else
        rfcof=ChPar(1,Mt)*ChPar(4,Mt)
        if(rfcof.le.0.) then
        ffac=0.0
        else
        ffac=rfcof
        power=ChPar(5,Mt)-1.
        if(abs(power).gt.0.) ffac=rfcof*cmid**power
        endif
        endif
        rfac=ThN(i)+ffac
        decay1=ChPar(6,Mt)*ThN(i)+ChPar(7,Mt)*ffac
        g1(i)=decay1*abs(Sg)
        effdif=ChPar(2,Mt)*ThN(i)**(7./3.)/(ChPar(10,Mt)*ChPar(10,Mt))
        power=ChPar(3,Mt)
        Disp(i)=effdif*ThN(i)+power*abs(v(i))
        R(i)=rfac+Sg*decay1*dt
        phi(i)=0.0
        if(abs(abs(sg)-0.5).gt.1.e-6) goto 8
        power=1.+(ChPar(5,Mt)-1.) *(1.-ThN(i)/rfac)
        if(UserF) power=1.+(ChPar(1,Mt)*ds_dc-ffac)/rfac
        power=v(i)*dt/(3.*rfac*power)
        Disp(i)=Disp(i)-sg*v(i)*power
        if(WaterF) phi(i)=power*Sink(i)/2.0+dt*qt(i)/6.0
    8 continue

      return
      end

************************************************************************

      subroutine Bound_C(KTopCH,KBotCH,N,A,F,v,cTop,cBot)
      implicit doubleprecision(A-H,O-Z)

      double precision A,F

      dimension A(N,3),F(*),v(*)

*     Upper boundary conditions
      if(KTopCH.gt.0) then ! concentration BC
        A(1,3)=0.
        A(1,2)=1.
        F(1)=cTop
      endif
      if(KTopCH.le.0) then ! flux BC
        F(1)=F(1)+v(1)*cTop
      endif

*     Lower boundary conditions
      if(KBotCh.eq.1) then ! concentration BC
        A(N,2)=1.
        A(N,1)=0.
        F(N)=cBot
      end if
      if(KBotCh.le. 0) then ! flux BC
         F(N)=F(N)-cBot*v(N)
      end if
      if(KBotCh.eq.0) then ! zero gradient BC
        A(N,1)=-1.
        A(N,2)=1.
        F(N)=0.
      end if

      return
      end

************************************************************************

      subroutine Assemble (N,A,x,dt,R,Disp,v,Sg,Alpha,Cw,phi)
      implicit doubleprecision(A-H,O-Z)

      double precision A,Disp,R

      dimension A(N,3),x(*),R(*),Disp(*),v(*),Alpha(*),phi(*)

      tfac=1./(6.*dt)
      signc=0.0
      if(abs(sg-0.5).le.1.e-8) signc=-1.
      if(abs(sg+0.5).le.1.e-8) signc=1.
      dz1=x(2)-x(1)
c     A(1,2)=Sg*0.5*(Disp(1)+Disp(2))/dz1+tfac*dz1*(2.*R(1)+R(2))
      A(1,2)=Sg*0.5*(Disp(1)+Disp(2))/dz1+0.5*dz1*R(1)/dt
     .+Sg*Cw*(2.*v(1)+v(2)+signc*(2.*phi(1)+phi(2)))/6.0
     .+Sg*Cw*Alpha(1)*(v(1)+signc*phi(1))/2.
c    .+Sg*Alpha(1)*(Disp(1)-Disp(2))/2./dz1
      A(1,3)=-Sg*0.5*(Disp(1)+Disp(2))/dz1+Sg*Cw*(v(1)+2.*v(2)+signc*
     .(phi(1)+2.*phi(2)))/6.
     .-Sg*Cw*Alpha(1)*(v(2)+signc*phi(2))/2.
c    .-Sg*Alpha(1)*(Disp(1)-Disp(2))/2./dz1
      do 16 i=2,N-1
        dz1=x(i)-x(i-1)
        dz2=x(i+1)-x(i)
        A(i,1)=-Sg*0.5*(Disp(i-1)+Disp(i))/dz1-Sg*Cw*(v(i)+2.*v(i-1)+
     .  signc*(phi(i)+2.*phi(i-1)))/6.
     .  -Sg*Cw*Alpha(i-1)*(v(i-1)+signc*phi(i-1))/2.
c    . -Sg*0.5*(Disp(i-1)-Disp(i))/dz1*Alpha(i-1)
        A(i,2)=Sg*0.5*((Disp(i-1)+Disp(i))/dz1+(Disp(i)+Disp(i+1))/dz2)
c    .     +tfac*(dz1*(R(i-1)+2.*R(i))+dz2*(2.*R(i)+R(i+1)))
     .     +0.5*(dz1+dz2)*R(i)/dt
     .     +Sg*Cw*(v(i+1)-v(i-1)+signc*(phi(i+1)-phi(i-1)))/6.
     .     +Sg*Cw*(Alpha(i-1)+Alpha(i))*(v(i)+signc*phi(i))/2.0
c    . +Sg*0.5*((Disp(i-1)-Disp(i))/dz1*Alpha(i-1)+
c    . (Disp(i)-Disp(i+1))/dz2*Alpha(i))
        A(i,3)=-Sg*0.5*(Disp(i)+Disp(i+1))/dz2+Sg*Cw*(v(i)+2.*v(i+1)+
     .  signc*(phi(i)+2.*phi(i+1)))/6.0
     . -Sg*Cw*Alpha(i)*(v(i+1)+signc*phi(i+1))/2.
c    . -Sg*0.5*(Disp(i)-Disp(i+1))/dz2*Alpha(i)
   16 Continue
      dz=x(N)-x(N-1)
      A(N,1)=-Sg*.5*(Disp(N-1)+Disp(N))/dz-Sg*Cw*(2.*v(N-1)+v(N)+signc*(
     . 2.*phi(N-1)+phi(N)))/6.
     . -Sg*Cw*Alpha(N)*(v(N-1)+signc*phi(N-1))/2.
c    .-Sg*Alpha(N)*(Disp(N-1)-Disp(N))/2./dz
c     A(N,2)=Sg*0.5*(Disp(N-1)+Disp(N))/dz+tfac*dz*(R(N-1)+2.*R(N))
      A(N,2)=Sg*0.5*(Disp(N-1)+Disp(N))/dz+0.5*dz*R(N)/dt
     . -Sg*Cw*(v(N-1)+2.*v(N)+signc*(phi(N-1)+2.*phi(N)))/6.
     . +Sg*Cw*Alpha(N)*(v(N)+signc*phi(N))/2.
c    . +Sg*Alpha(N)*(Disp(N-1)-Disp(N))/2./dz

      return
      end

************************************************************************

*     Source file HEAT.FOR

      subroutine Heat(

*     Geometry, time and print control parameters
     .NumNP,NMat,NReg,MatNum,iReg,x,LUnit,TUnit,iTlevel,t,tBCH2,tEnd,
     .dt,dtH,TPrint,iPlevel,ShortF,xObs,iObs,NObs,ScrnF,Heading,

*     Transport parameters
     .HPar,

*     Boundary condition and interaction variables
     .KTopH,KBotH,Ampl,Omega,Omega0,TpTop,TpBot,SvTopH,SvBotH,
     .WaterF,SolutF,HTEMP,

*     Main CD-equation arrays
     .Temp,R,Disp,v,vo,A,F,ThN,ThO,beta,H_weight,H_Pe,phi,Omega_H,Sink,
     .g1,Sv1T,IDC,T0,ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:PLNMHF,TBCH1
      implicit doubleprecision(A-H,O-Z)
      REAL T0
      character*72 Heading
      character*7 LUnit,TUnit
      integer iTlevel,iPlevel,iReg
      logical WaterF,SolutF,ShortF,ScrnF,H_weight
      DOUBLEPRECISION A,F,ThN,ThO,Disp,R,t,tBCH2,tEnd,TPrint

      dimension
     .x(*),R(*),MatNum(*),iReg(*),HPar(20,*),Temp(*),A(NumNP,3),
     .F(*),v(*),Disp(*),TPrint(*),ThN(*),ThO(*),vo(*),beta(*),
     .HTEMP(*),xObs(*),iObs(*),phi(*),Sink(*),g1(*)

      if(iTlevel.eq.0) then ! initialisation ----------------------------

*     Open Solute files
      

*     Read Solute input files
      N=NumNP
      call Heat_In(NMat,HPar,ScrnF,N,x,Temp,ThN,ThO,v,
     . HTEMP,WaterF,H_weight,Omega_H,IDC)
       do 5 i=1,N
        g1(i)=0.       
        if(.not.WaterF) vo(i)=v(i)
    5 continue
*     Initialize CD-equation coefficients
      call Heat_BC_In(
     . iTlevel,t,dt,tBCH1,tBCH2,tEnd,TpTop,TpBot,Ampl,Omega,Omega0,
     . KTopH,KBotH,PlnmHF,IDC)
      if(.not.WaterF.and..not.SolutF) dtH=dt

      else ! end of initialisation  ------------------------------------
      call Heat_BC_In(
     . iTlevel,t,dt,tBCH1,tBCH2,tEnd,TpTop,TpBot,Ampl,Omega,Omega0,
     . KTopH,KBotH,PlnmHF,IDC)
      N=NumNP
      tfac=1./(6.*dt)
*     Construct rhs of matrix equation
      do 6 i=1,N
      phi(i)=0.0
      g1(i)=Temp(i)
    6 continue                                                      
      sg=Omega_H-1.0
      call Set_Coefficients_H(N,MatNum,HPar,ThO,R,Disp,vO,Sink,sg,dt)
      call Assemble(N,A,x,dt,R,Disp,vO,sg,Beta,HPar(9,1),phi)
       dz1=x(2)-x(1)
       F(1)=A(1,2)*Temp(1)+A(1,3)*Temp(2)
c     F(1)=tfac*dz1*(2.*R(1)+R(2))*Temp(1)
c     F(1)=dz1*0.5*R(1)/dt*Temp(1)
      F1=F(1)       
       do 12 i=2,N-1
        dz1=x(i)-x(i-1)
        dz2=x(i+1)-x(i)
        F(i)=A(i,1)*Temp(i-1)+A(i,2)*Temp(i)+A(i,3)*Temp(i+1)
   12  continue
       dz1=x(N)-x(N-1)
       F(N)=A(N,1)*Temp(N-1)+A(N,2)*Temp(N)
c     F(N)=tfac*dz1*(R(N-1)+2.*R(N))*Temp(N)
c     F(N)=dz1*0.5*R(N)/dt*Temp(N)
      FN=F(N)             

*     Construct lhs of matrix equation
      call Set_Coefficients_H(N,MatNum,HPar,ThN,R,Disp,v,Sink,
     1  omega_H,dt)
      if(WaterF.or.iTlevel.eq.1) then
      H_Pe=0.0
      DO 1 I=2,N-1
      MT=MATNum(I)
      dz1=x(i)-x(i-1)
      dz2=x(i+1)-x(i)
      IF(.NOT.H_weight.or.abs(v(i)).le.1.e-20) then
      Beta(i)=0.0
      else
      Pec=(DZ1+DZ2)/2.*abs(v(i))/Disp(i)
      if(Pec.gt.H_Pe) H_Pe=Pec
      Beta(i)=0.0
      if(Pec.gt.2.) Beta(I)=1./tanh(Pec/2.)-2./Pec
      endif
    1 CONTINUE
      dz1=x(2)-x(1)
      IF(.NOT.H_weight.or.abs(v(1)).le.1.e-20) then
       Beta(1)=0.0
      else
      Pec=DZ1*(v(1)+v(2))/(Disp(1)+Disp(2))
      if(Pec.gt.H_Pe) H_Pe=Pec
      Beta(1)=0.0
      if(Pec.gt.2.) Beta(1)=1./tanh(Pec/2.)-2./Pec
      endif
      dz1=x(N)-x(N-1)
      IF(.NOT.H_weight.or.abs(v(N)).le.1.e-20) then
       Beta(N)=0.0
      else
      Pec=DZ1*(v(N-1)+v(N))/(Disp(N-1)+Disp(N))
      if(Pec.gt.H_Pe) H_Pe=Pec
      Beta(N)=0.0
      if(Pec.gt.2.) Beta(N)=1./tanh(Pec/2.)-2./Pec
      endif
      endif
      call Assemble(N,A,x,dt,R,Disp,v,Omega_H,Beta,HPar(9,1),phi)
      BN=A(N,1)
      DN=A(N,2)
      E1=A(1,3)
      D1=A(1,2)
      call Bound_H(
     . KTopH,KBotH,N,A,F,v,TpTop,TpBot,HPar(9,1),Ampl,Omega,Omega0,t)
      call Solver(A,F,Temp,N)
      Do 110 i=1,N
      g1(i)=HPar(9,1)*SinK(i)*(Omega_H*Temp(i)+(1.-Omega_H)*g1(i))
  110 continue                       
  
      endif ! ----------------------------------------------------------

*     Output
      call H_BC_Out(
     . t,dt,iTlevel,tBCH1,tEnd,ShortF,TPrint,iPlevel,Heading,
     1 LUnit,TUnit,hvTop,hvBot,SvTopH,SvBotH,D1,E1,F1,BN,DN,
     . FN,Temp,N,WaterF,SolutF,ScrnF,Sv1T,g1,x,IDC)
      if(NObs.eq.0) goto 10
      call X_Observ_Out(
     . xObs,iObs,NObs,Temp,Temp,v,ThN,ThN,2,1,1,x,t,tEnd,
     . dt,iTlevel,TPrint,iPlevel,ShortF,tBCH1,idc+ihobs,IDC,
     1 T0,ITERQ3D)
   10 if(abs(TPrint(iPlevel)-t).lt.0.001*dt) then
        call H_Nodes_Out(H_Pe,
     .   N,x,TPrint,iPlevel,t,iTlevel,ThN,v,Temp,Heading,LUnit,TUnit,
     1  IDC)
        call H_Balanc_Out(
     . N,NReg,x,MatNum,iReg,HPar,t,iTlevel,Temp,ThN,SvTopH,SvBotH,
     1Sv1T,IDC)
      endif

      return
      end

************************************************************************

      subroutine Set_Coefficients_H(N,MatNum,HPar,ThN,R,Disp,v,Sink,
     1 Omega_H,dt)
      implicit doubleprecision(A-H,O-Z)

      DOUBLEPRECISION Disp,R,ThN
                      
      dimension R(*),MatNum(*),ThN(*),HPar(20,*),v(*),Disp(*),Sink(*)
 
      do 8 i=1,N
        Mt=MatNum(i)
        R(i)=HPar(1,Mt)*HPar(7,Mt)+HPar(2,Mt)*HPar(8,Mt)+
     .  HPar(9,Mt)*ThN(i)+Omega_H*Sink(i)*Hpar(9,Mt)*dt
        effdif=HPar(4,Mt)+HPar(5,Mt)*ThN(i)+HPar(6,Mt)*ThN(i)**0.5
        Disp(i)=effdif+HPar(3,Mt)*HPar(9,Mt)*abs(v(i))
    8 continue

      return
      end

************************************************************************

      subroutine Bound_H(
     .KTopH,KBotH,N,A,F,v,TpTop,TpBot,Cw,Ampl,Omega,Omega0,t)
      implicit doubleprecision(A-H,O-Z)

      DOUBLEPRECISION t
      double precision A,F,PI

      dimension A(N,3),F(*),v(*)

*     Upper boundary conditions
      if(KTopH.eq.1) then ! First type BC
        A(1,3)=0.
        A(1,2)=1.
        PI=3.141592654D0
        F(1)=TpTop+Ampl*sin(2.*PI*t/Omega-Omega0)
      endif
      if(KTopH.le.0) F(1)=F(1)+Cw*v(1)*TpTop  ! flux BC

*     Lower boundary conditions
      if(KBotH.eq.1 .or. KBotH.eq.4) then ! First type BC
        A(N,2)=1.
        A(N,1)=0.
        F(N)=TpBot
      end if
      if(KBotH.le. 0) F(N)=F(N)-Cw*TpBot*v(N)  ! flux BC

      if(KBotH.eq.0) then ! zero gradient BC
        A(N,1)=-1.
        A(N,2)=1.
        F(N)=0.
      end if

      return
      end
***********************************************************************
*     Source file ROOT.FOR
      subroutine Root(
     .NumNP,NMat,x,Beta,RSPar,t,tBCR2,tEnd,dt,iTlevel,rRoot,vRoot,hRoot,
     .Cs,ScrnF,TPrint,iPlevel,ShortF,hNew,MatNum,Sink,Conc,IRoot,HTEMP,
     .WaterF,SolutF,xObs,iObs,NObs,CAP,SStrsF,IDC,T0,ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:TBCR1,PLNMRF
      implicit doubleprecision(A-H,O-Z)
      DOUBLEPRECISION CAP,t,tBCR2,tEnd,TPrint
      integer iTlevel,iPlevel
      REAL T0
      logical ScrnF,ShortF,WaterF,SolutF,SStrsF
      dimension
     .x(*),Beta(*),RSPar(9,*),TPrint(*),hNew(*),MatNum(*),Sink(*),
     .Conc(*),HTEMP(*),xObs(5),iObs(5),CAP(*)
*     Initialisation
      if(iTlevel.eq.0) then
        call Root_In (NumNP,NMat,x,Beta,RSPar,Cs,ScrnF,hNew,Conc,IRoot,
     .   HTEMP,WaterF,SolutF,SStrsF,IDC)
        !call R_Check_Out (NumNP,Beta,IDC)
      endif
*     Root growth model (not available for present version)
*     ...
*     Update sink term
      call Root_BC_In (iTlevel,tBCR1,tBCR2,tEnd,t,dt,rRoot,PlnmRF,IDC)
      call Set_Root_Sink(
     . NumNP,MatNum,x,hRoot,vRoot,Sink,rRoot,hNew,Beta,RSPar,Conc,IRoot,
     . SStrsF)

*     Output
      call R_BC_Out (t,tBCR1,tEnd,dt,iTlevel,rRoot,vRoot,hRoot,TPrint,
     . iPlevel,ShortF,IDC)
      if(NObs.eq.0) goto 10
      call X_Observ_Out(
     . xObs,iObs,NObs,Sink,hNew,Conc,CAP,CAP,1,1,1,x,t,tEnd,
     . dt,iTlevel,TPrint,iPlevel,ShortF,tBCR1,idc+irobs,IDC,
     1 T0,ITERQ3D)
10    if(abs(TPrint(iPlevel)-t).lt.0.001*dt)call R_Nodes_Out(
     . NumNP,x,TPrint,iPlevel,t,iTlevel,Sink,Conc,hNew,
     1IDC)

      return
      end

************************************************************************

      subroutine Set_Root_Sink(
     .NumNP,MatNum,x,hRoot,vRoot,Sink,rRoot,hNew,Beta,RSPar,Conc,IRoot,
     .SStrsF)
      implicit doubleprecision(A-H,O-Z)

      logical SStrsF

      dimension
     .x(*),MatNum(*),hNew(*),Beta(*),Sink(*),RSPar(9,*),Conc(*)

      vRoot=0.
      hRoot=0.
      ARoot=0.
      do 10 i=2,NumNP-1
        if(Beta(i).gt.0.) then
          dxM=(x(i+1)-x(i-1))/2
          M=MatNum(i)
          if(IRoot.eq.1) then
            Alfa=FWStrs(hNew(i),RSPar(1,M),RSPar(2,M))
          else
            Alfa=FAlfa(rRoot,hNew(i),RSPar(1,M))
          endif
          if(SStrsF) Alfa=Alfa*FSStrs(Conc(i),RSPar(8,M),RSPar(9,M))
          Sink(i)=Alfa*Beta(i)*rRoot
          vRoot=vRoot+Sink(i)*dxM
          hRoot=hRoot+hNew(i)*dxM
          ARoot=ARoot+dxM
        else
          Sink(i)=0.
        endif
   10 continue
      hRoot=hRoot/ARoot
      Sink(1)=0.
      Sink(NumNP)=0.

      return
      end

************************************************************************

      DOUBLE PRECISION FUNCTION FAlfa(rRoot,h,Par)
      implicit DOUBLEPRECISION(A-H,O-Z)
      
*     Feddes function (1978)

      dimension Par(*)

      P0=Par(5)
      P1=Par(4)
      P3=Par(1)
      if(rRoot.lt.Par(6)) P2=Par(2)
      if(rRoot.gt.Par(7)) P2=Par(3)
      if((rRoot.ge.Par(6)).and.(rRoot.le.Par(7))) then
        P2=Par(3)+(Par(7)-rRoot)/(Par(7)-Par(6))*(Par(2)-Par(3))
      endif
      FAlfa=0.0
      if((h.gt.P3).and.(h.lt.P2)) FAlfa=(h-P3)/(P2-P3)
      if((h.ge.P2).and.(h.le.P1)) FAlfa=1.0
      if((h.gt.P1).and.(h.lt.P0)) FAlfa=(h-P0)/(P1-P0)

      return
      end

************************************************************************

      DOUBLE PRECISION FUNCTION FWStrs (h,h50,P1)
      implicit DOUBLEPRECISION(A-H,O-Z)
*     van Genuchten function (1987)

      FWStrs=1./(1.+(min(h,-1.e-20)/h50)**P1)

      return
      end

************************************************************************

      DOUBLE PRECISION FUNCTION FSStrs (c,c50,P2)
      implicit DOUBLEPRECISION(A-H,O-Z)

      FSStrs=1./(1.+(max(c,1.e-20)/c50)**P2)

      return
      end

************************************************************************
      subroutine W_BC_Out(
     .t,dt,iTlevel,tBC,tEnd,Iter,ItCum,ShortF,TPrint,iPlevel,rTop,vRoot,
     .SvTop,SvBot,SvRoot,hNew,NumNP,vTop,vBot,Heading,LUnit,TUnit,
     .KodTop,KodBot,ScrnF,IDC,T0,IP,ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:SRTOP
      
      implicit doubleprecision(A-H,O-Z)
      REAL T0
      character*72 Heading
      character*7 LUnit,TUnit
      logical ShortF,ScrnF
      integer iTlevel,iPlevel
      DOUBLEPRECISION dt,rTop,vRoot,hNew,SvTop,SvBot,SvRoot,vTop,vBot

      dimension hNew(*),TPrint(*)
      if(iTlevel.eq.0)THEN
        IF(ITERQ3D<=1 .AND.T0<=0)THEN
          write(idc+iwbc,105)! 打印表头
          
        ENDIF
        return
      ENDIF
*     Boundary fluxes
      SrTop=SrTop+rTop*dt
      SvTop =SvTop+vTop*dt
      SvBot =SvBot+vBot*dt
      SvRoot=SvRoot+vRoot*dt
 
*     Print to screen
      if(ScrnF) then
        if(ABS(T-DT-T0)<=0.001*dt)THEN
          WRITE(*,*)'PILLAR=',IP
          write(*,705)
        ENDIF
        write(*,710) t,DT,Iter,ItCUM,vTop,SvTop,VBOT,SvBot,hNew(1),
     1  hNew(NumNP)
      endif

*     Print to W_BC.OUT file
      
      if(abs(TPrint(iPlevel)-t).lt.0.001*dt) then
        IF(ITERQ3D>1)BACKSPACE(IDC+IWBC)
        
        write(idc+iwbc,110)t,vTop,vBot,SvTop,SvBot,hNew(1),hNew(NumNP),
     .  KodTop,KodBot
        
      endif
  105 format(
     .'      Time        vTop     vBot    sum(vTop)  sum(vBot)      ',
     1'hTop       hBot      TypeT      TypeB')
  110 format(f22.3,3f22.3,3e11.3,2i22.2,2i5)
     
  705 format('     Time        dt    Iter     vTop      SvTop     ',
     1'VBOT      SvBot        hTop        hBot')
  710 format(f20.5,1X,F15.5,1X,i5,1X,I10,1X,f9.2,1X,F9.2,1X,f10.3,1X,
     1F10.3,1X,F10.3,1X,F10.3)

      return
      end

************************************************************************

      subroutine W_Nodes_Out(
     1 NumNP,x,TPrint,iPlevel,hNew,Cap,Con,t,iTlevel,Heading,LUnit,
     . TUnit,ThN,v,STEADYF,IDC,ITERQ3D,T0)
     
      USE HYDRUSPARA,ONLY:IWNOD
      implicit doubleprecision(A-H,O-Z)
      character*72 Heading
      character*7 LUnit,TUnit
      Logical SteadyF
      integer iPlevel,iTlevel
      DOUBLEPRECISION Con,Cap,ThN,t,TPrint
      REAL T0
      dimension
     . hNew(*),x(*),Con(*),Cap(*),TPrint(*),ThN(*),v(*)
      IF(ITERQ3D.NE.1)THEN
        DO I=1,NUMNP
          BACKSPACE(IDC+IWNOD)
        ENDDO
      ENDIF
      IF(ITERQ3D==1 .AND.T0<=0)WRITE(idc+iwnod,102)
      do i=1,NumNP
        write(idc+iwnod,110)T,i,x(i),hNew(i),ThN(i),v(i),Con(i),Cap(i)
      ENDDO
  102 format('      TIME Node     Depth         Head   Moisture',
     .'      Flux   Conductivity   Capacity')
  110 format(F21.4,1X,i5,1X,f22.5,1X,f23.5,1X,f21.4,1X,f11.4,1X,
     1F11.4,1x,e11.4)
      return
      end

************************************************************************

      subroutine W_Balanc_Out(
     .NumNP,NReg,x,MatNum,iReg,t,iTlevel,ThN,ThR,SvTop,SvBot,SvRoot,IDC,
     1 ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY: VINITW
      implicit doubleprecision(A-H,O-Z)
      DIMENSION THN(NUMNP),THR(NUMNP)
      integer iReg,iTlevel
      DOUBLEPRECISION x,ThR,SvTop,SvBot,SvRoot
      character*12 a
      dimension x(*),MatNum(*),iReg(*),SubVol(10)
      Volume=0.

      SubVol=0.

      Mi=MatNum(1)
      ti=ThN(1)-ThR(Mi)
      do i=2,NumNP
        Mi1=Mi
        Mi=MatNum(i)
        L=iReg(i)
        dx=x(i)-x(i-1)
        ti1=ti
        ti=ThN(i)-ThR(Mi)
        dV=dx*(ti+ti1)/2.
        Volume=Volume+dV
        SubVol(L)=SubVol(L)+dV
      ENDDO

      if(iTlevel.eq.0 .and.T<=0 .AND.ITERQ3D==1) then
        VInitW=Volume
        if(NReg.eq.1) then
          write(idc+iwbal,350)
        else
          write(idc+iwbal,350) (i,i=1,NReg)
        endif
      endif

      Err=0.0
      WATERLOSE=VInitW+SvTop-SvBot-SvRoot-Volume
      IF(Volume.gt.0.)Err=100.*WATERLOSE/Volume
      
      IF(ITERQ3D>1)BACKSPACE(IDC+IWBAL)
      if(NReg.eq.1)then
        write(idc+iwbal,370) t,WATERLOSE,Err,Volume
      else
        write(idc+iwbal,370) t,WATERLOSE,Err,Volume,(SubVol(i),i=1,NReg)
      endif
350   format('     Time[T] Waterlose[L]  Error[%]  "Total volume[L]"',:,
     1 5('   Sub-Reg',i1:)/)

370   format(f12.4,e12.4,f10.5,1x,(9f11.3))

      return
      end

***********************************************************************

      subroutine W_Mater_Out(IDC,T0,ITERQ3D)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:NPARD,NMAT,HTABM,NTABD,IHYS
      implicit doubleprecision(A-H,O-Z)
      REAL T0
      DOUBLEPRECISION FS,FK,FC,C,K,a10K

      IF(T0>0 .OR. ITERQ3D>1)RETURN
      write(idc+iwmat,230)
      write(idc+iwmat,240)
      if(hTabM.lt.0.) then
        hMin=hTabM
      else
        hMin=FH(1d-2,1,1)
      endif
      A0=-hMin*0.00001
      XTab0=log10(dble(A0))
      XTab9=log10(A0-HMin)
      DX=(XTab9-XTab0)/(NTabD-1)
      do 80 j=1,IHys+1
      do 70 M=1,NMat
        write(idc+iwmat,*)
        do 60 i=0,NTabD-1
          h=A0-10**(XTab0+i*DX)
          if(i.eq.0) h=0.d0
          K= FK(h,M,J)
          C= FC(h,M,j)
          Q= FQ(h,M,j)
          S= FS(h,M,j)
          a10h=log10(max(-h,1e-30))
          a10K=log10(K)
          write(idc+iwmat,250) Q,h,a10h,C,K,a10K,S,DD
   60   continue
        write(idc+iwmat,'(''end'')')
   70 continue
   80 continue

  230 format(7x,'Table of Hydraulic Properties which are interpolated in
     . simulation'/7x,65('=')/)
  240 format('  theta         h        log h        C             K',
     .'        log K          S')
  250 format(f8.4,e12.3,e12.4,e12.4,f12.4,e12.4,f10.4)

      return
      end

************************************************************************

      subroutine W_Check_Out(IDC,T0,ITERQ3D)
      USE HYDRUSPARA,ONLY:ICHECK
      USE HYDRUS,ONLY:NUMNP,AH,AK,ATH
      implicit doubleprecision(A-H,O-Z)
      REAL T0
      IF(T0>0.OR.ITERQ3D>1)RETURN
      write(idc+icheck,130)
      do n=1,NumNP
        write(idc+icheck,120) n,Ah(n),AK(n),ATh(n)
      ENDDO
  120 format (I4,3f9.3)
  130 format ('Node      Ah      AK     ATh')
      return
      end

************************************************************************

      subroutine X_Observ_Out(
     .xObs,iObs,NObs,Frst1,Scnd1,Thrd1,Frst2,Thrd2,IFrst,IScnd,
     .IThrd,x,t,tEnd,dt,iTlevel,TPrint,iPlevel,ShortF,tBCR,Unit,IDC,
     1 T0,ITERQ3D)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)
      REAL T0
      DOUBLEPRECISION Frst2,Thrd2,t,TPrint,tBCR,tEnd,TIME
      integer iTlevel,iPlevel,Unit
      logical ShortF
      character*90 A1,A2
      dimension
     .x(*),Frst1(*),Scnd1(*),Thrd1(*),xObs(*),iObs(*),TPrint(*),
     .AObs(5),BObs(5),CObs(5),Frst2(*),Thrd2(*)

      data AObs/5*0/,CObs/5*0/,BObs/5*0/

      if(iTlevel.eq.0 .AND. ITERQ3D<=1 .AND.T0<=0) then
        i=IFrst+IScnd+IThrd
        if(i-4) 2,4,6
2       a2='         S         h         C'
        goto 8
4       if(Unit.eq.idc+ihobs) then
          a2='      theta        T         q'
        else
          a2='      theta        C         q'
        endif
        goto 8
6         a2='      theta        h         q'
8       write(Unit,91)(a2,i=1,NObs)
        WRITE(UNIT,*)0  
      endif
      if(.not.ShortF.or.abs(TPrint(iPlevel)-t).lt.0.001*dt.or.
     .  abs(t-tBCR).le.0.001*dt) then
        do i=1,NObs
          j=iObs(i)
          xx=(xObs(i)-x(j-1))/(x(j)-x(j-1))
          if(IFrst.eq.1) then
            AObs(i)=Frst1(j-1)+(Frst1(j)-Frst1(j-1))*xx
          else
            AObs(i)=Frst2(j-1)+(Frst2(j)-Frst2(j-1))*xx
          endif
          BObs(i)=Scnd1(j-1)+(Scnd1(j)-Scnd1(j-1))*xx
          if(IThrd.eq.1) then
            CObs(i)=Thrd1(j-1)+(Thrd1(j)-Thrd1(j-1))*xx
          else
            CObs(i)=Thrd2(j-1)+(Thrd2(j)-Thrd2(j-1))*xx
          endif
        enddo
        
915     BACKSPACE(UNIT)
        READ(UNIT,*)TIME
        IF(T<TIME)THEN
          BACKSPACE(UNIT)
          GOTO 915
        ELSEIF(T==TIME)THEN
          BACKSPACE(UNIT)
        ENDIF
        write(Unit,92)t,(AObs(i),BObs(i),CObs(i),i=1,NObs)  
      endif
      
   91 format('     t',5(A30,:))
   92 format(f25.5,5(1X,f25.5,1X,f25.5,1X,f25.5))
      return
      end

************************************************************************

      subroutine S_BC_Out(
     .t,dt,iTlevel,tBCS,tEnd,ShortF,TPrint,iPlevel,Heading,LUnit,TUnit,
     .cvTop,cvBot,cvCh0,cvCh1,SvTopC,SvBotC,Sv0C,Sv1C,D1,E1,F1,BN,DN,FN,
     .Conc,g0,g1,x,N,WaterF,itCum,Peclet,Courant,ScrnF,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      logical ShortF,WaterF,ScrnF
      character*7 LUnit,TUnit
      character*72 Heading
      integer iTlevel,iPlevel
      DOUBLEPRECISION t,tBCS,tEnd,TPrint

      dimension TPrint(*),Conc(*),g0(*),g1(*),x(*)
      if(iTlevel.eq.0) then
        SvTopC=0.
        SvBotC=0.
        return
      endif

*     Mass transfer
      cvCh0=0.
      cvCh1=0.
      do 10 i=1,N-1
          dx=x(i+1)-x(i)
          cvCh0=cvCh0+dx*(g0(i)+g0(i+1))/2.
          cvCh1=cvCh1+dx*(g1(i)+g1(i+1))/2.
   10 continue
      Sv0C=Sv0C+cvCh0*dt
      Sv1C=Sv1C+cvCh1*dt

*     Boundary fluxes
      cvBot=FN-BN*Conc(N-1)-DN*Conc(N)
      cvTop=D1*Conc(1)+E1*Conc(2)-F1
      SvTopC=SvTopC+cvTop*dt
      SvBotC=SvBotC+cvBot*dt

*     Print to screen
      if(.not.WaterF.and.ScrnF) then
        if((iTlevel+19)/20*20.eq.iTlevel+19) write(*,705)
        write(*,710) t,ItCum,Conc(1),Conc(N),Peclet,Courant
      endif

*     Print to S_BC.OUT file
      if(iTlevel.eq.1) then
        write(idc+isbc,*)'              Solute Boundary Value Variations
     . with Time (t)'
        write(idc+isbc,*)
        write(idc+isbc,*)'                      ', Heading
        write(idc+isbc,*)
        write(idc+isbc,*)'                    Units: L = ',LUnit,' T = '
     1  ,TUnit
        write(idc+isbc,160)
      endif
      if((.not.ShortF.and.iTlevel/5*5.eq.iTlevel).or.
     1 abs(TPrint(iPlevel)-t)
     .  .lt.0.001*dt.or.abs(t-tBCS).le.0.001*dt) then
        write(idc+isbc,190)
     .  iTlevel,t,cvTop,cvBot,SvTopC,SvBotC,Sv0C,Sv1C,Conc(1),Conc(N)
      endif
      if(abs(t-tEnd).le.0.001*dt) then
        write(idc+isbc,'(''end'')')
      endif

  160 format(/'    iTlevel   Time      cvTop      cvBot    Sum(cvTop)'
     .,' Sum(cvBot)   cvCh0      cvCh1       cTop       cBot'/
     .'              [T]      [M/T]      [M/T]       [M]       [M] '
     .,'      [M/T]      [M/T]      [M/L]     [M/L]'/)
  190 format(i7,f20.3,8f20.3)
  705 format(/
     .'     Time     ItCum    cTop     cBot      Peclet   Courant '/)
  710 format(f20.4,i6,2f20.3,2f20.3)

      return
      end

************************************************************************

      subroutine S_Nodes_Out(NumNP,x,TPrint,iPlevel,t,iTlevel,ThN,v,
     1 g0,g1,Conc,Total,Heading,LUnit,TUnit,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      character*72 Heading
      character*7 LUnit,TUnit
      integer iPlevel,iTlevel
      DOUBLEPRECISION ThN,t,TPrint,Total

      dimension x(*),ThN(*),TPrint(*),v(*),g0(*),g1(*),Conc(*),Total(*)
      if(iTlevel.eq.0) then
        write(idc+isnod,*)'                     Solute Distributions vis
     1Depth(z)'
        write(idc+isnod,*)
        write(idc+isnod,*) Heading
        write(idc+isnod,*)
        write(idc+isnod,*)'Units: L = ',LUnit,' T = ',TUnit
        write(idc+isnod,100) t
      else
        write(idc+isnod,100) TPrint(iPlevel)
      endif

      do 10 i=1,NumNP
        write(idc+isnod,110) i,x(i),Conc(i),thN(i),v(i),g0(i),g1(i),
     1  Total(i)
   10 continue
      write(idc+isnod,'(''end'')')

  100 format(//' Time [T]:',f13.6//
     .'  Node       z         C      theta ',
     .'     Flux       g0        g1     Total C'/
     .'            [L]      [M/L]     [-] ',
     .'     [L/T]    [M/L/T]   [M/L/T] '/)
  110 format(1x,i5,f10.2,f11.3,f8.3,f11.3,3f10.3)

      return
      end

***********************************************************************

      subroutine S_Balanc_Out(
     .NumNP,NReg,x,MatNum,iReg,ChPar,t,iTlevel,Conc,ThN,SvTopC,
     .SvBotC,Sv0C,Sv1C,Linear,UserF,Total,IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:VINITS
      implicit doubleprecision(A-H,O-Z)

      logical Linear,UserF
      integer iReg,iTlevel
      DOUBLEPRECISION ThN,t,Total
      character*12 a

      dimension Total(*),
     .x(*),MatNum(*),iReg(*),ChPar(20,*),ThN(*),Conc(*),SubVol(10)

      Volume=0.
      do 5 L=1,NReg
        SubVol(L)=0.
    5 continue
      Mi=MatNum(1)
      if(Linear) then
        ci=Conc(1)*(ThN(1)+ChPar(1,Mi)*ChPar(4,Mi))
      else
        cmid=MAX(Conc(1),1.e-30)
        if(UserF) then
        call sorption(cmid,s,ds_dc,1,Mi)
        ci=ThN(1)*cmid+s*ChPar(1,Mi)
        else
        ci=Conc(1)*ThN(1)+ChPar(1,Mi)*ChPar(4,Mi)*cmid**ChPar(5,Mi)
        endif
      endif
      Total(1)=ci
      do 10 i=2,NumNP
        Mi1=Mi
        Mi=MatNum(i)
        L=iReg(i)
        dx=x(i)-x(i-1)
        ci1=ci
        if(Linear) then
          ci=Conc(i)*(ThN(i)+ChPar(1,Mi)*ChPar(4,Mi))
        else
          cmid=MAX(Conc(i),1.e-30)
          if(UserF) then
          call sorption(cmid,s,ds_dc,1,Mi)
          ci=ThN(i)*cmid+s*ChPar(1,Mi)
          else
          ci=Conc(i)*ThN(i)+ChPar(1,Mi)*ChPar(4,Mi)*cmid**ChPar(5,Mi)
          endif
        endif
        dV=dx*(ci+ci1)/2.
        Volume=Volume+dV
        SubVol(L)=SubVol(L)+dV
        Total(i)=ci
   10 continue
      if(iTlevel.eq.0) then
        VInitS=Volume
        if(NReg.eq.1) then
        write(idc+isbal,350)
        write(idc+isbal,360)
        else
        write(idc+isbal,350) (i,i=1,NReg)
        a='     [M]    '
        write(idc+isbal,360) (a,i=1,NReg)
        endif
      endif
      Err=0.
c     if(abs(Volume) .gt. 1.e-4)
c    .  Err=100.*(VInit+SvTopC-SvBotC+Sv0C-Sv1C-Volume)/Volume
      if(abs(Volume-VInitS).gt.1.e-4.or.abs(SvTopC-SvBotC+Sv0C-Sv1C).gt.
     .  1.e-4) Err=100.*(VInitS+SvTopC-SvBotC+Sv0C-Sv1C-Volume)/MAX(
     .  abs(Volume-VInitS),abs(SvTopC-SvBotC+Sv0C-Sv1C))
      if(NReg.eq.1) then
      write(idc+isbal,370) t,Err,Volume
      else
      write(idc+isbal,370) t,Err,Volume,(SubVol(i),i=1,NReg)
      endif
  350 format('                     Mass Balance Error Evaluation'//
     .'                               Mass in the Considered Region'/
     .'                        ======================================='/
     .'     Time       Error     Total',:,5('   Sub-Reg',i1:)/)
  360 format('     [T]        [%]        [M] ',:,5A,:/)
  370 format(f12.4,f8.2,1x,(9f11.3))

      return
      end

***********************************************************************

      subroutine H_BC_Out(
     .t,dt,iTlevel,tBCH,tEnd,ShortF,TPrint,iPlevel,Heading,LUnit,TUnit,
     .hvTop,hvBot,SvTopH,SvBotH,D1,E1,F1,BN,DN,FN,Temp,N,WaterF,SolutF,
     .ScrnF,Sv1T,g1,x,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      logical ShortF,WaterF,SolutF,ScrnF
      character*7 LUnit,TUnit
      character*72 Heading
      integer iTlevel,iPlevel
      DOUBLEPRECISION t,tBCH,tEnd,TPrint

      dimension TPrint(*),Temp(*),g1(*),x(*)

      if(iTlevel.eq.0) then
        SvTopH=0.
        SvBotH=0.
        return
      endif             
      
*     Sink term      
      TvS1=0.0
      do 10 i=1,N-1
          dx=x(i+1)-x(i)
          TvS1=TvS1+dx*(g1(i)+g1(i+1))/2.
   10 continue
      Sv1T=Sv1T+TvS1*dt      
      
*     Boundary fluxes
      hvTop=D1*Temp(1)+E1*Temp(2)-F1
      hvBot=FN-BN*Temp(N-1)-DN*Temp(N)
      SvTopH=SvTopH+hvTop*dt
      SvBotH=SvBotH+hvBot*dt

*     Print to screen
      if (.not.WaterF.and..not.SolutF.and.ScrnF) then
        if((iTlevel+19)/20*20.eq.iTlevel+19) write(*,705)
        write(*,710) t,hvTop,SvTopH,SvBotH,Temp(1),Temp(N)
      endif

*     Print H_BC.OUT file
      if(iTlevel.eq.1) then
        write(idc+ihbc,*)'                Heat Boundary Value Variations
     . with Time (t)'
        write(idc+ihbc,*)
        write(idc+ihbc,*)'                           ',Heading
        write(idc+ihbc,*)
        write(idc+ihbc,*)'                    Units: L = ',LUnit,
     1   ' T = ',TUnit
        write(idc+ihbc,160)
      endif
      if((.not.ShortF.and.iTlevel/5*5.eq.iTlevel).or.
     1 abs(TPrint(iPlevel)-t)
     .  .lt.0.001*dt.or.abs(t-tBCH).le.0.001*dt) then
        write(idc+ihbc,190)
     .  iTlevel,t,hvTop,hvBot,SvTopH,SvBotH,Temp(1),Temp(N)
      endif
      if(abs(t-tEnd).le.0.001*dt) then
        write(idc+ihbc,'(''end'')')
      endif

  160 format(/' iTlevel     Time       HvTop      HvBot    Sum(HvTop)'
     .,'    Sum(HvBot)   Ttop       Tbot'/
     .'             [T]       [M/T]      [M/T]       [M]           [M]'
     .,'       [M/L]      [M/L]'/)
  190 format(i8,f20.3,4e12.3,2f21.3)
  705 format(/
     .'     Time     HvTop      SHvTop     SHvBot     TTop     TBot'/)
  710 format(f20.3,3e20.3,2f21.3)

      return
      end

************************************************************************

      subroutine H_Nodes_Out(H_Peclet,
     .NumNP,x,TPrint,iPlevel,t,iTlevel,thN,v,Temp,Heading,LUnit,TUnit,
     1IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      character*72 Heading
      character*7 LUnit,TUnit
      integer iPlevel,iTlevel
      DOUBLEPRECISION ThN,t,TPrint

      dimension x(*),thN(*),TPrint(*),v(*),Temp(*)

      if(iTlevel.eq.0) then
        write(idc+ihnod,*)'                   Temperature Distributions
     . vis',' Depths (z)'
        write(idc+ihnod,*)
        write(idc+ihnod,*)'                          ', Heading
        write(idc+ihnod,*)
        write(idc+ihnod,*)'                  Units: L = ',LUnit,
     1   ' T = ',TUnit
        write(idc+ihnod,99) H_Peclet
        write(idc+ihnod,100) t
      else
        write(idc+ihnod,100) TPrint(iPlevel)
      endif

      do 10 i=1,NumNP
        write(idc+ihnod,110) i,x(i),Temp(i),thN(i),v(i)
   10 continue
      write(idc+ihnod,'(''end'')')

   99 format(/' Peclet Number for Heat Transfer:',f10.2)
  100 format(//' Time [T]:',f13.2//
     .'    Node       z       Temperature     Moisture    Flux'/
     .'              [L]         [C]            [-]       [L/T]'/)
  110 format(i8,f10.2,f12.3,5x,f10.4,f11.2)

      return
      end

***********************************************************************

      subroutine H_Balanc_Out(NumNP,NReg,x,MatNum,iReg,HPar,t,iTlevel,
     . Temp,ThN,SvTopH,SvBotH,Sv1T,IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:VINITH
      implicit doubleprecision(A-H,O-Z)

      integer iReg,iTlevel
      DOUBLEPRECISION ThN,t
      character*12 a

      dimension
     .x(*),MatNum(*),iReg(*),HPar(20,*),ThN(*),Temp(*),SubVol(10)

      Volume=0.
      do 5 L=1,NReg
        SubVol(L)=0.
    5 continue
      Mi=MatNum(1)
      Ri=HPar(1,Mi)*HPar(7,Mi)+HPar(2,Mi)*HPar(8,Mi)+
     .    HPar(9,Mi)*ThN(1)
      ci=Ri*Temp(1)
      do 10 i=2,NumNP
        Mi1=Mi
        Mi=MatNum(i)
        Ri=HPar(1,Mi)*HPar(7,Mi)+HPar(2,Mi)*HPar(8,Mi)+
     .    HPar(9,Mi)*ThN(i)
        L=iReg(i)
        dx=x(i)-x(i-1)
        ci1=ci
        ci=Ri*Temp(i)
        dV=dx*(ci+ci1)/2.
        Volume=Volume+dV
        SubVol(L)=SubVol(L)+dV
   10 continue

      if(iTlevel.eq.0) then
        VInitH=Volume
        if(NReg.eq.1) then
        write(idc+ihbal,350)
        write(idc+ihbal,360)
        else
        write(idc+ihbal,350) (i,i=1,NReg)
        a='     [M]    '
        write(idc+ihbal,360) (a,i=1,NReg)
        endif
      endif
      Err=0.
      if(abs(Volume) .gt. 0)
     .  Err=100.*(VInitH+SvTopH-SvBotH-Sv1T-Volume)/Volume
      if(NReg.eq.1) then
      write(idc+ihbal,370) t,Err,Volume
      else
      write(idc+ihbal,370) t,Err,Volume,(SubVol(i),i=1,NReg)
      endif
  350 format('                     Mass Balance Error Evaluation'//
     .'                               Heat in the Considered Region'/
     .'                        ======================================='/
     .'     Time       Error     Total',:,5('   Sub-Reg',i1:)/)
  360 format('     [T]        [%]        [M] ',:,5A,:/)
  370 format(f12.4,f8.2,1x,(9e11.3))

      return
      end

***********************************************************************

      subroutine R_BC_Out(
     .t,tBCR,tEnd,dt,iTlevel,rRoot,vRoot,hRoot,TPrint,iPlevel,ShortF,
     1IDC)
      USE HYDRUSPARA
      USE HYDRUS,ONLY:CRROOT,CVROOT
      implicit doubleprecision(A-H,O-Z)

      integer iTlevel,iPlevel
      logical ShortF
      DOUBLEPRECISION t,tBCR,tEnd,TPrint

      dimension TPrint(*)

      if(iTlevel.eq.0) then
        write(idc+irbc,*)'                 Root Boundary Value 
     .Variations with Time (t)'
        write(idc+irbc,*)
        write(idc+irbc,100)
        return
      endif
      CrRoot=CrRoot+rRoot*dt
      CvRoot=CvRoot+vRoot*dt

      if((.not.ShortF.and.iTlevel/5*5.eq.iTlevel).or.
     1 abs(TPrint(iPlevel)-t)
     .  .lt.0.001*dt.or.abs(t-tBCR).le.0.001*dt)
     .write(idc+irbc,110) t,rRoot,vRoot,CrRoot,CvRoot,hRoot
      if(abs(t-tEnd).le.0.001*dt)
     .write(idc+irbc,'(''end'')')

  100 format(//
     .'     Time         rRoot       vRoot   sum(rRoot) sum(vRoot)',
     .'    hRoot'/
     .'     [T]          [L/T]       [L/T]       [L]       [L]    ',
     .'     [L]'/)
  110 format(f12.5,5f11.3)

      return
      end

************************************************************************

      subroutine R_Nodes_Out(
     .NumNP,x,TPrint,iPlevel,t,iTlevel,Sink,Conc,hNew,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      DOUBLEPRECISION t,TPrint
      integer iPlevel,iTlevel

      dimension x(*),Sink(*),TPrint(*),Conc(*),hNew(*)

      if(iTlevel.eq.0) then
        write(idc+irnod,*)'         Pressure, Sink, and Concentration 
     .distributions in the Root Zone'
        write(idc+irnod,*)
        write(idc+irnod,100) t
      else
        write(idc+irnod,100) TPrint(iPlevel)
      endif

      do 10 i= 1,NumNP
        write(idc+irnod,110) i,x(i),hNew(i),Sink(i),Conc(i)
   10 continue
      write(idc+irnod,'(''end'')')

  100 format(//' Time [T]:',f13.4//
     .'       Node      Depth        hNew        Sink         Conc'/
     .'                  (L)          (L)        (1/T)        [M/L]')
  110 format(4x,i5,4f13.4)

      return
      end

***********************************************************************

      subroutine R_Check_Out(NumNP,Beta,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      dimension Beta(*)

      write(idc+icheck,130)
      do 110 n= 1,NumNP
        write(idc+icheck,120) n,Beta(n)
  110 continue
      write(idc+icheck,'(''end'')')

  120 format (I4,f11.3)
  130 format (/'Normalized root distribution function'//
     .'node      Beta'/)

      return
      end

************************************************************************

      subroutine Main_Check_Out(NumNP,x,MatNum,iReg,IDC)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)
      integer iReg
      dimension x(*),MatNum(*),iReg(*)
*     Print nodal point information
      write(idc+icheck,130)
      do 110 n= 1,NumNP
        write(idc+icheck,120) n,x(n),MatNum(n),iReg(n)
  110 continue
      write(idc+icheck,'(''end'')')

  120 format (I4,f11.3,2I5)
  130 format (/'Geometry information'//
     .'node      z       Mat   Reg'/)

      return
      end

************************************************************************
          
      subroutine Run_Out(
     .iTlevel,t,dt,Iter,ItCum,ItCumS,ConvgF,ShortF,WaterF,
     .TPrint,iPlevel,Nit,Peclet,Courant,SolutF,IDC,T0,ITERQ3D)
      USE HYDRUSPARA
      implicit doubleprecision(A-H,O-Z)

      logical ShortF,ConvgF,WaterF,SolutF
      integer iTlevel,iPlevel
      DOUBLEPRECISION t,TPrint,TIME

      dimension TPrint(*)
      REAL T0
      
      if(WaterF.or.SolutF) then
        if(iTlevel.eq.0 .AND.ITERQ3D<=1.AND.T0==0) then
          if(SolutF)THEN
            write(idc+irun,715) Peclet
          ENDIF
          if(.not.WaterF) then
            write(idc+irun,720)
          elseif(.not.SolutF) then
            write(idc+irun,725)
          else
            write(idc+irun,730)
          endif
          WRITE(IDC+IRUN,*)0.
        endif
        
915     BACKSPACE(idc+irun)
        READ(idc+irun,*)TIME
        IF(T<TIME)THEN
          BACKSPACE(idc+irun)
          GOTO 915
        ELSEIF(T==TIME)THEN
          BACKSPACE(idc+irun)
        ENDIF
        if(.not.ShortF.or.abs(TPrint(iPlevel)-t).lt.0.001*dt) then
          if(.not.WaterF) then
            write(idc+irun,690)t,dt,Nit,ItCumS,Courant
          elseif(.not.SolutF) then
            write(idc+irun,695)t,dt,Iter,ItCum,ConvgF
          else
            write(idc+irun,700)t,dt,Iter,Nit,ItCum,ItCumS,ConvgF,Courant
          endif
        endif
      endif

  690 format(E22.7,1X,E22.7,I6,1X,I6,1X,E22.7)
  695 format(E22.7,1X,E22.7,1X,I5,1X,I6,1X,l6)
  700 format(E22.7,1X,E22.7,I5,1X,I5,1X,I6,1X,I6,1X,l6,1X,E22.7)
 
  715 format(25x,'Maxium Peclet Number =',f8.2)
  720 format('   Time         dt      IterS  ItCumS  Courant'
     1)
  725 format('   Time         dt     IterW   ItCum   Convg')
  730 format('   Time         dt     IterW IterS ItCumW  
     1ItCumS  Convg  Courant')
      
      if(abs(t-TPrint(iPlevel)).lt.0.001*dt)
     1 iPlevel=iPlevel+1
      return
      end
************************************************************************
      subroutine TMCTRL(tSEC1,tSEC0,ITERQ3D)
      USE HYDRUS,ONLY:iTlevel,dt,dtW,dtS,dtH,TPrint,iPlevel,tBC,tBCS,
     . tBCH,tBCR,t,tOld,tEnd,dtback,dtforward
      USE GWFBASMODULE,ONLY:DELT
      USE HYDRUS,ONLY:DTINIT
      implicit doubleprecision(A-H,O-Z)
      DOUBLEPRECISION tFix
      REAL tSEC1,tSEC0
      IF(ITERQ3D==1.AND.ABS(T-DT-(tSEC0))<=0.001*dt)dtBACK=DT!记录每个DELT内第一个dt的大小，用于重启DELT的非饱和
      !if(iTlevel.gt.0 .AND.T<TSEC1) then
       
        tFix=min(TPrint(iPlevel),tBC,tBCS,tBCH,tBCR,(tSEC1))
        if(abs(tsec1-t)<=0.001*dt .AND.T<=TSEC1 .AND.T<tEND)
     1  tFix=min(TPrint(iPlevel),tBC,tBCS,tBCH,tBCR)
        IF(ABS(T-TEND)<=0.001*dt .AND.T<=TEND)tFix=t+dt
        tt=tFix-t
        dt=tt/anint(tt/min(dtW,dtS,dtH,tt,(DELT)))
        IF(DT<=0)DT=DTINIT
      
      tOld=t
      t=t+dt
      !IF(ABS(T-DT-tSEC1)<=0.001*dt)dtforward=dt     !记录下一个DELT中要使用的第一个dt
      iTlevel=iTlevel+1
      return
      end
*     Source file MATERIAL.FOR 
      DOUBLEPRECISION function FK(h,MAT,J) ! Hydraulic conductivity
      USE HYDRUS,ONLY:PAR,HSAT
      implicit DOUBLEPRECISION(A-H,O-Z)
      DOUBLEPRECISION n,m,Ks,Kr
      DOUBLEPRECISION h
      integer PPar
      data BPar/.5/,PPar/2/
      Qr=Par(1,MAT,J)
      Qs=Par(2,MAT,J)
      Alfa=Par(3,MAT,J)
      n=Par(4,MAT,J)
      Ks=Par(5,MAT,J)
      Qm=Par(6,MAT,J)
      m=1.D0-1.D0/n
      Qees=min((Qs-Qr)/(Qm-Qr),.999999999999999d0)
      !Hs=-1.D0/Alfa*(Qees**(-1.D0/m)-1.D0)**(1.D0/n) 
      if(h.lt.HSAT(MAT)) then
        HH=max(dble(h),-1d300**(1/n))
        Qee=(1+(-Alfa*HH)**n)**(-m)
        Qe=(Qm-Qr)/(Qs-Qr)*Qee
        FFQ =1-(1-Qee **(1/m))**m
        FFQs=1-(1-Qees**(1/m))**m
        if(FFQ.le.0d0) FFQ=m*Qee**(1/m)
        Kr=Qe**Bpar*(FFQ/FFQs)**PPar
        FK=max(Ks*Kr,1d-300)  
      else
        FK=Ks
      endif
      return
      end
      
************************************************************************
      DOUBLEPRECISION function FC(h,MAT,J) ! Soil water capacity
      USE HYDRUS,ONLY:PAR,HSAT
      implicit DOUBLEPRECISION(A-H,O-Z)
      DOUBLEPRECISION n,m
      DOUBLE PRECISION h
      
      Qr=Par(1,MAT,J)
      Qs=Par(2,MAT,J)
      Alfa=Par(3,MAT,J)
      n=Par(4,MAT,J)
      Qm=Par(6,MAT,J)
      m=1-1/n
      !Qees=min((Qs-Qr)/(Qm-Qr),.999999999999999d0)
      !Hs=-1/Alfa*(Qees**(-1/m)-1)**(1/n) 
      !HS=HSAT(MAT)
      if(h.lt.HSAT(MAT)) then
        HH=max(dble(h),-1d300**(1/n))
        !C1=(1+(-Alfa*HH)**n)**(-m-1)
        !C2=(Qm-Qr)*m*n*(Alfa**n)*(-HH)**(n-1)*C1
        !FC=max(C2,1d-300)
        SE=FS(HH,MAT,J)
        C1=-M*N*(QS-QR)*SE*(1-SE**(1/M))/HH
        FC=MAX(C1,1D-300)
      else
        FC=0.0D0
      endif  
      return 
      end
      
************************************************************************
      DOUBLEPRECISION function FQ(h,MAT,J) ! Water content
      USE HYDRUS,ONLY:PAR,HSAT
      implicit DOUBLEPRECISION(A-H,O-Z)
      DOUBLEPRECISION n,m
      DOUBLEPRECISION h

      Qr=Par(1,MAT,J)
      Qs=Par(2,MAT,J)
      Alfa=Par(3,MAT,J)
      n=Par(4,MAT,J)
      Qm=Par(6,MAT,J)
      !m=1.D0-1.D0/n
      !Qees=min((Qs-Qr)/(Qm-Qr),.999999999999999d0)
      !Hs=-1.D0/Alfa*(Qees**(-1.D0/m)-1.D0)**(1.D0/n) 
      if(h.lt.HSAT(MAT)) then
        HH=max(dble(h),-1d300**(1/n))
        Se=FS(HH,MAT,J)
        FQ=max(Qr+(Qm-Qr)*Se,1.d-37)
      else
        FQ=Qs
      endif
      return 
      end

************************************************************************
      DOUBLEPRECISION function FS(h,MAT,J) ! Effective water content 
      USE HYDRUS,ONLY:PAR,HSAT
      implicit DOUBLEPRECISION(A-H,O-Z)
      DOUBLEPRECISION n,m
      DOUBLEPRECISION h
      
      Qr=Par(1,MAT,J)
      Qs=Par(2,MAT,J)
      Alfa=Par(3,MAT,J)
      n=Par(4,MAT,J)
      Qm=Par(6,MAT,J)
      m=1.D0-1.D0/n
      !Qees=min((Qs-Qr)/(Qm-Qr),.999999999999999d0)
      !Hs=-1.D0/Alfa*(Qees**(-1.D0/m)-1.D0)**(1.D0/n) 
      if(h.lt.HSAT(MAT)) then
        HH=max(dble(h),-1d300**(1.D0/n))
        Qee=(1+(-Alfa*HH)**n)**(-m)
        Qe=Qee*(Qm-Qr)/(Qs-Qr)
        FS=max(Qe,1.d-300)
      else
        FS=1.D0
      endif  
      return 
      end
      
************************************************************************
      DOUBLE PRECISION FUNCTION FH(Qe,MAT,J) ! Pressure head 
      USE HYDRUS,ONLY:PAR
      implicit DOUBLEPRECISION(A-H,O-Z)
      DOUBLEPRECISION n,m
      Qr=Par(1,MAT,J)
      Qs=Par(2,MAT,J)
      Alfa=Par(3,MAT,J)
      n=Par(4,MAT,J)
      Qm=Par(6,MAT,J)
      m=1-1/n
      HMin=-1d300**(1/n)
      QeeM=(1+(-Alfa*HMin)**n)**(-m)
      Qee=min(max(Qe*(Qs-Qr)/(Qm-Qr),QeeM),.999999999999999d0)
      FH=max(-1/Alfa*(Qee**(-1/m)-1)**(1/n),-1d37)
      return
      end

      DOUBLEPRECISION FUNCTION FD(H,MAT,J)
      USE HYDRUS,ONLY:PAR
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      DOUBLEPRECISION n,m,SE,ALFA,QR,QS,KS,HMIN
      INTEGER MAT,J
                              
      QR=PAR(1,MAT,J)
      QS=PAR(2,MAT,J)
      ALFA=PAR(3,MAT,J)
      N=PAR(4,MAT,J)
      M=1-1/N
      !KS=PAR(5,MAT,J)
      SE=FS(H,MAT,J)
      
      FD=ALFA*(n-1)*(QS-QR)
      FD=1.d0/FD
      
      S1=SE**(1.D0/M)
      S2=(1-S1)**(-M)
      FD=FK(H,MAT,J)*FD*S2/S1
      
      RETURN
      END
      
      DOUBLEPRECISION FUNCTION USETAB(hiM,tabin,M)
      USE HYDRUS,ONLY:NTABD,HTAB,NMATD

      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      DIMENSION tabin(NtabD,NMATD) !传导度等参数
      a=-hTab(NTabD)*.00001
      x0=log10(a)
      xN=log10(a-hTab(NTabD))
      dx=(xN-x0)/(NTabD-1)
      iT=int((log10(a-hiM)-x0)/dx)+1 !插值点的位置
      dh=(hiM-hTab(iT))/(hTab(iT+1)-hTab(iT))
      USETAB=TABIN(IT,M)+(TabIN(iT+1,M)-TabIN(iT,M))*dh
      return
      end

      function Fqh(hNewN) ! Outflow function
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)
      data A/0.1687/,B/-0.02674/,C/230/   ! problem specific

      GWL=hNewN-C
      Fqh=A*exp(B*abs(GWL))
      return
      end

************************************************************************
      subroutine sorption(c,s,ds_dc,Index,Mt)
      IMPLICIT DOUBLEPRECISION(A-H,O-Z)

c     Calculate adsorption concentration and slope of isotherm
c       User must give explicit equation of isotherm and its derivative
c       with respect to c (slope).  The parameters must also be given
c       directly in the equations rather than read them via input file.

      goto (1,2,3,4,5) Mt

    1 if(Index.ge.0) then            ! Layer 1
*  Evaluate adsorption concentration s
      s=0.5*(0.12*c)**0.8/(1.0+(0.12*c)**0.8)
      endif
      if(Index.le.0) then
*  Evaluate the slope of isotherm
      ds_dc=0.5*0.12*0.8*(0.12*c)**(-0.2)/(1.0+(0.12*c)**0.8)**2
      endif
      goto 10
    2 if(Index.ge.0) then            ! Layer 2
*  Evaluate adsorption concentration s
      s=0.015*c/(1.0+0.0015*c)
      endif
      if(Index.le.0) then
*  Evaluate the slope of isotherm
      ds_dc=0.015/(1.0+0.0015*c)**2
      endif
      goto 10
    3 if(Index.ge.0) then            ! Layer 3
*  Evaluate adsorption concentration s
      s=0.015*c/(1.0+0.0125*c)
      endif
      if(Index.le.0) then
*  Evaluate the slope of isotherm
      ds_dc=0.015/(1.0+0.0125*c)**2
      endif
      goto 10
    4 if(Index.ge.0) then            ! Layer 4
*  Evaluate adsorption concentration s
      s=0.015*c/(1.0+0.0125*c)
      endif
      if(Index.le.0) then
*  Evaluate the slope of isotherm
      ds_dc=0.015/(1.0+0.0125*c)**2
      endif
      goto 10
    5 if(Index.ge.0) then            ! Layer 5
*  Evaluate adsorption concentration s
      s=0.015*c/(1.0+0.0125*c)
      endif
      if(Index.le.0) then
*  Evaluate the slope of isotherm
      ds_dc=0.015/(1.0+0.0125*c)**2
      endif

   10 return
      end
************************************************************************
