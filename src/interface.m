function TIME_INTERPOLATION(T1,T0,IP)
      % PREDICTING THE LOWER BOUNDARY OF THE SOIL COLUMNS
      USE Q3DMODULE,ONLY:DELT0,IBOT,BOT,Q3DF,ADAPTF
      USE HYDRUS,ONLY:T,NUMNP,HPILLAR00,HPILLAR0,HPILLAR1N,HPILLAR,X
      USE GWFBASMODULE,ONLY:DELT
      
      A=zeros(NUMNP,1);B=zeros(NUMNP,1);C=zeros(NUMNP,1);
      REAL T1,T0
      DOUBLEPRECISION XTABLE,XMID
      if(Q3DF)
        %if(T0<=0)
        
        HPILLAR=HPILLAR0+(HPILLAR1N-HPILLAR0)*(T-T0)/DELT
          
%        elseif(T0>0) %SECOND ORDER INTERPOLATION
%         A=((HPILLAR1N-HPILLAR0)/DELT-(HPILLAR0-HPILLAR00)/DELT0)
%       1  /(DELT+DELT0)
%         B=(HPILLAR0-HPILLAR00)/DELT0
%         C=HPILLAR1N-A*T1*T1-B*T1
%         HPILLAR=A*T*T+B*T+C
%        end
        if(ADAPTF)
          XTABLE=BOT(0,IP)-HPILLAR
          for I=1:NUMNP-1
            XMID=(X(I)+X(I+1))/2
            
            if(XTABLE>=X(I) && XTABLE<X(I+1))
              if(XTABLE<XMID)
                IBOT(IP)=I
              elseif(XTABLE>=XMID)
                IBOT(IP)=I+1
              end
              exit
            elseif(XTABLE>=X(I+1))
              continue%CYCLE
            end
            CALL USTOP('NO TABLE FOUND FOR MOVING LOWER BOUNDARY')
          end
          IBOT(IP)=IBOT(IP)+3
          
        else
          IBOT(IP)=NUMNP
        end
      else
        IBOT(IP)=NUMNP
        return
      end
      return
      end
      
      
      
function HYDRUS1RECHARGE(T1,T0,ITERQ3D,IP,IGRID)
      USE HYDRUS,      ONLY:CON,HNEW,X,NUMNP,T,DT,THN,Z,v,THO,iTlevel,
     1                      KPILLAR,QS,THETA0,THETA0,THETA1
      USE GWFBASMODULE,ONLY:DELT
      USE Q3DMODULE,   ONLY:RrN,RrO,BOT,MXQ3DITER,RELAXF,SY,SS,
     1                      ICTRL0,ICTRL1,ZTB0,ZTB1,Q3DF
      REAL T1,T0,SC2
      
      if(~Q3DF),return;end %JCZENG 20180414
      
      %????T0???????
      if(iTlevel==0)
        THETA0(:)=THN(:)
        QS(:)=0
        call FINDTABLE(ICTRL0(IP),ZTB0(IP),IP,HNEW)
        return
      end
      %??T1????????
      if(ABS(T-T1)<=0.001*dt && T<=T1)
        THETA1(:)=THN(:)
      end
      
      %DELT??????????Qs(NumNP,NPillar)
      if(ITLEVEL>0),QS(:)=QS(:)+V(:)*DT;end 
      
      if(abs(T-T1)<=0.001*dt && T<=T1)
        call FINDTABLE(ICTRL1(IP),ZTB1(IP),IP,HNEW)%%???????????????????????N????????
        QS(:)=QS(:)/DELT
        
%       ??ictrl0?ictrl1???is?imax
        IS=MIN(ICTRL0(IP),ICTRL1(IP))-3

        IMAX=MAX(ICTRL0(IP),ICTRL1(IP))+2
%       ?????
        DW=0
        for I=IS:IMAX-1
          DW=DW+0.5*(X(I+1)-X(I))*(THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1))
        end
        DW=DW/DELT
        
%       ???
        KT=KPILLAR(ICTRL1(IP))
        THK=BOT(0,IP)-BOT(KT,IP)-ZTB1(IP)
        dMOD=(SY(IP,KT)-SS(IP,KT)*THK)*(ZTB0(IP)-ZTB1(IP))/DELT
%       DMOD=SY(IP)*(ZTB0(IP)-ZTB1(IP))/DELT
        RrO(IP)=RrN(IP)
        RrN(IP)=DW+QS(IS)+dMOD
%       RRN(IP)=QS(IMAX-1)+DMOD
        
%     ***************************************************
%     CALCULATE SMALL-SCALE SPECifIC YIELDS JCZENG 20180423
        SC2=0;
        for I=IS+3:IMAX-1
          SC2=SC2+0.5*(X(I+1)-X(I))*(THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1))
        end
        SC2=abs(SC2/(DELT*(ZTB0(IP)-ZTB1(IP))))
        %SC2=ABS(DW/((ZTB0(IP)-ZTB1(IP))))
%     ***************************************************
        if(ITERQ3D>1)BACKSPACE(9999)
            write(9999,'(100f20.10)')t,RRN(IP),SC2
        end
      end
      return
end
      
function FINDTABLE(ICTRL,ZTB,IP,HC)
USE Q3DMODULE,ONLY:BOT
USE HYDRUS,ONLY:X,NUMNP
INTEGER ICTRL,IP
DOUBLEPRECISION HEAD1,HEAD0,XMID,HCHILD,X0,X1
DOUBLEPRECISION ZTB, HC
DIMENSION HC(NUMNP)
ZTB=0.
for I=NUMNP:2:-1%找到各个虚拟柱子控制潜水面的非饱和节点编号
    HEAD1=HC(I)
    X1=X(I)
    HEAD0=HC(I-1)
    X0=X(I-1)
    if(HEAD1>0 && HEAD0<=0)
        ZTB=(HEAD1*X0-HEAD0*X1)/(HEAD1-HEAD0)
        XMID=(X(I)+X(I-1))/2.
        if(ZTB>=XMID)
            ICTRL=I
        elseif(ZTB<XMID)
            ICTRL=I-1
        end
        EXIT
    end
end
if(ZTB<=0),disp('NO GROUNDWATER TABLE FOUND IN MODFLOW!');end

return
end
      
      
      function TMCTRL(tSEC1,tSEC0,ITERQ3D)
      USE HYDRUS,ONLY:iTlevel,dt,dtW,dtS,dtH,TPrint,iPlevel,tBC,tBCS,
     . tBCH,tBCR,t,tOld,tEnd,dtback,dtforward
      USE GWFBASMODULE,ONLY:DELT
      USE HYDRUS,ONLY:DTINIT
      implicit doubleprecision(A-H,O-Z)
      DOUBLEPRECISION tFix
      REAL tSEC1,tSEC0
      if(ITERQ3D==1 && abs(T-DT-(tSEC0))<=0.001*dt),dtBACK=DT;end%????DELT????dt????????DELT????
      %if(iTlevel.gt.0 .AND.T<TSEC1) then
       
        tFix=min(TPrint(iPlevel),tBC,tBCS,tBCH,tBCR,(tSEC1))
        if(abs(tsec1-t)<=0.001*dt && T<=TSEC1 && T<tEND)
     1  tFix=min(TPrint(iPlevel),tBC,tBCS,tBCH,tBCR)
        if(abs(T-TEND)<=0.001*dt  && T<=TEND)tFix=t+dt
        tt=tFix-t
        dt=tt/anint(tt/min(dtW,dtS,dtH,tt,(DELT)))
        if(DT<=0)DT=DTINIT
      
      tOld=t
      t=t+dt
      %if(ABS(T-DT-tSEC1)<=0.001*dt)dtforward=dt     %?????DELT????????dt
      iTlevel=iTlevel+1
      return
        end
      
% *     Source file MATERIAL.FOR 
%       DOUBLEPRECISION function FK(h,MAT,J) % Hydraulic conductivity
%       USE HYDRUS,ONLY:PAR,HSAT
%       implicit DOUBLEPRECISION(A-H,O-Z)
%       DOUBLEPRECISION n,m,Ks,Kr
%       DOUBLEPRECISION h
%       integer PPar
%       data BPar/.5/,PPar/2/
%       Qr=Par(1,MAT,J)
%       Qs=Par(2,MAT,J)
%       Alfa=Par(3,MAT,J)
%       n=Par(4,MAT,J)
%       Ks=Par(5,MAT,J)
%       Qm=Par(6,MAT,J)
%       m=1.D0-1.D0/n
%       Qees=min((Qs-Qr)/(Qm-Qr),.999999999999999d0)
%       %Hs=-1.D0/Alfa*(Qees**(-1.D0/m)-1.D0)**(1.D0/n) 
%       if(h.lt.HSAT(MAT)) then
%         HH=max(dble(h),-1d300**(1/n))
%         Qee=(1+(-Alfa*HH)**n)**(-m)
%         Qe=(Qm-Qr)/(Qs-Qr)*Qee
%         FFQ =1-(1-Qee **(1/m))**m
%         FFQs=1-(1-Qees**(1/m))**m
%         if(FFQ.le.0d0) FFQ=m*Qee**(1/m)
%         Kr=Qe**Bpar*(FFQ/FFQs)**PPar
%         FK=max(Ks*Kr,1d-300)  
%       else
%         FK=Ks
%       endif
%       return
%       end