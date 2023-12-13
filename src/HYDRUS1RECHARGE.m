function [dMOD,QQS,DW,RRrN,RrO,ZTB1]=HYDRUS1RECHARGE(T1,T0,ITERQ3D,IP,IGRID,Q3DF,THETA0,ICTRL0,THN,T,QS,DT,DELT,ZTB0,HNEW,KPILLAR,BOT,RrN,SY,SS,X,KTN)
% calculate the water flux from STEMMUS, which will be the recharge water flux
% for MODFLOW, added by LY
HPUNIT=100;

Q3DF=1;    
      if(~Q3DF),return;end %JCZENG 20180414
        NN=length(X);
        THETA1(:)=THN(:);

        [ZTB1,ICTRL1]=FINDTABLE(IP,HNEW,X,NN);
        QS(:)=QS(:)/DELT;
        
%       use ictrl0 and ictrl1 to determine is and imax
        IS=min(ICTRL0,ICTRL1)-3;
%         IS=max(IS,1);
        IMAX=max(ICTRL0,ICTRL1)+2;
        IMAX=min(IMAX,NN);% Prevent the out of bound
        DW=0;
        if IS<=1 || min(HNEW)>=-1E-6
            RRrN=0;
            RrO=RrN;
            QQS=0;
            dMOD=0;
            DW=0;
            DDW(KTN)= 0;
            dMODQ(KTN)= 0;
        else
            for I=IS:IMAX-1
                DW=DW+0.5*(X(I+1)-X(I))*(THETA0(I)+THETA0(I+1)-THETA1(I)-THETA1(I+1));
            end
            DW=DW/DELT;

            %  correction term
            KKT=KPILLAR(ICTRL1);
            if KKT<=1
                RRrN=0;
                RrO=RrN;
                QQS=0;
                dMOD=0;
                DW=0;
                DDW(KTN)= 0;
                dMODQ(KTN)= 0;
            else
                THK=BOT(1,IP)-BOT(KKT,IP)-ZTB1; % BOT(KKT,IP)
                dMOD=(SY(KKT-1,IP)-SS(KKT-1,IP)*THK)*(ZTB0-ZTB1)/DELT;%(IP,KKT)(IP,KKT)
                %         end
                % %       DMOD=SY*(ZTB0-ZTB1)/DELT
                RrO=RrN;
%                 RRrN=(QS(IS))/HPUNIT/86400; %unit conversion
                        RRrN=(DW+QS(IS)+dMOD)/HPUNIT/86400; %unit conversion
                QQS=(DW+QS(IS)*HPUNIT+dMOD)/86400/HPUNIT; %unit conversion; m/d-->m/s
                QQS0= QS(IS);
                DDW(KTN)= DW;
                dMODQ(KTN)= dMOD;
            end
        end

        RRRrN(KTN)=RRrN;
        ITCTRL1(KTN)=ICTRL1;
        ITCTRL0(KTN)=ICTRL0;
        save('stemmus2022.mat');
%     ***************************************************
        if(ITERQ3D>1)%BACKSPACE(9999)
            disp('t='),T,RrN,SC2; %write(9999,'(100f20.10)')
        end
end
      