function [RRrN,RrO,ZTB1]=HYDRUS1RECHARGE(T1,T0,ITERQ3D,IP,IGRID,Q3DF,THETA0,ICTRL0,THN,T,QS,DT,DELT,ZTB0,HNEW,KPILLAR,BOT,RrN,SY,SS,X,KTN)
%       USE HYDRUS,      ONLY:CON,HNEW,X,NUMNP,T,DT,THN,Z,v,THO,iTlevel,
%      1                      KPILLAR,QS,THETA0,THETA0,THETA1
%       USE GWFBASMODULE,ONLY:DELT
%       USE Q3DMODULE,   ONLY:RrN,RrO,BOT,MXQ3DITER,RELAXF,SY,SS,
%      1                      ICTRL0,ICTRL1,ZTB0,ZTB1,Q3DF
%       REAL T1,T0,SC2
global QQS DDW dMODQ RRRrN KT ITCTRL1 ITCTRL0 HPUNIT%
% if KTN==1

% end
Q3DF=1;    
      if(~Q3DF),return;end %JCZENG 20180414
      
      %????T0???????
%       if(iTlevel==0)
%         THETA0(:)=THN0(:);
%         QS(:)=0;    
        NN=length(X);
%         QS=zeros(NN,1);

%         DW=0;QS=0;dMOD=0;  
%         [ICTRL0]=FINDTABLE(ZTB0,IP,HNEW);
%         return
%       end
      %??T1????????
%       if(abs(T-T1)<=0.001*DT && T<=T1)
        THETA1(:)=THN(:);
%       end
    
      %DELT??????????Qs(NumNP,NPillar)
%       if(ITLEVEL>0),end 
%       QS(:)=QS(:)+V(:)*DT;
      
%          RrO=RrN;
%         RRrN=RrN;
%       if(abs(T-T1)<=0.001*DT && T<=T1)

        [ZTB1,ICTRL1]=FINDTABLE(IP,HNEW,X,NN);
%         [ICTRL1]=FINDTABLE(ZTB1,IP,HNEW);%%???????????????????????N????????
        QS(:)=QS(:)/DELT;
        
%       ??ictrl0?ictrl1???is?imax
        IS=min(ICTRL0,ICTRL1)-3;

        IMAX=max(ICTRL0,ICTRL1)+2;
%         IMAX=min(IMAX,NN);%Prevent the out of bound
%       ?????
        DW=0;
        for I=IS:IMAX-1
          DW=DW+0.5*(X(I+1)-X(I))*(THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1));
        end
        DW=DW/DELT;
      
%       ???
        KKT=KPILLAR(ICTRL1);
        THK=BOT(1,IP)-BOT(KKT,IP)-ZTB1; %BOT(KKT,IP)
        dMOD=(SY(KKT,IP)-SS(KKT,IP)*THK)*(ZTB0-ZTB1)/DELT;%(IP,KKT)(IP,KKT)
%       DMOD=SY*(ZTB0-ZTB1)/DELT
        RrO=RrN;
        RRrN=(DW+QS(IS)+dMOD)/HPUNIT;

%       RRN=QS(IMAX-1)+DMOD
        QQS(KTN)= QS(IS);
        DDW(KTN)= DW;
        dMODQ(KTN)= dMOD;
        RRRrN(KTN)=RRrN;
        ITCTRL1(KTN)=ICTRL1;
        ITCTRL0(KTN)=ICTRL0;
%     ***************************************************
%     CALCULATE SMALL-SCALE SPECifIC YIELDS JCZENG 20180423
        SC2=0;
        for I=IS+3:IMAX-1
          SC2=SC2+0.5*(X(I+1)-X(I))*(THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1));
        end
        SC2=abs(SC2/(DELT*(ZTB0-ZTB1)));
        %SC2=ABS(DW/((ZTB0-ZTB1)))
%     ***************************************************
        if(ITERQ3D>1)%BACKSPACE(9999)
            disp('t='),T,RrN,SC2; %write(9999,'(100f20.10)')
        end
%       end
%       return
end
      