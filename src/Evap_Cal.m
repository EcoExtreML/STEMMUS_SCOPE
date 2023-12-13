function [Rn_SOIL,Evap,EVAP,Trap,r_a_SOIL,Resis_a,Srt]= Evap_Cal(DeltZ,TIME,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,NN,KT,hh,rwuef,Theta_UU,Rn,T,TT,Gvcc,Rns,Srt,Coefficient_n,Coefficient_Alpha,Theta_s,Theta_r,EVAP_PT,TRAP_PT)
global bx EVAP_msr Precip_msr TRAP_msr evapo TRAP %EVAP_PT TRAP_PT
r_a_SOIL=nan; Resis_a=nan; Rn_SOIL=nan;
J=1;
n(J)=Coefficient_n(J);
Alpha(J)=Coefficient_Alpha(J);
m(J)=1-1/n(J);
Theta_LL_sur1(KT)=Theta_LL(NL,2);
Theta_LL_sur2(KT)=Theta_LL(NL-1,2);
Theta_LL_sat(KT)=Theta_r(J)+(Theta_s(J)-Theta_r(J))/(1+abs(Alpha(J)*200)^n(J))^m(J);
coef_e=0.9/864000; % 0.8-1.0 Johns 1982, Kemp 1997; cm/s
coef_p=2.15;  %2-2.3

if hh(NN)>-1e5
    if (Theta_LL_sur1(KT)/Theta_LL_sat(KT))>((EVAP_PT(KT)/coef_e)^0.5)
        Evap(KT)=EVAP_PT(KT);
    else
        Evap(KT)=coef_e*(Theta_LL_sur1(KT)/Theta_LL_sat(KT))^coef_p;
    end
else
    Evap(KT)=coef_e*((Theta_LL_sur1(KT)+Theta_LL_sur1(KT))/2/Theta_LL_sat(KT))^coef_p;
end
if Evap(KT)>EVAP_PT(KT)
    Evap(KT)=EVAP_PT(KT);
end
EVAP(KT,1)=Evap(KT);
Tp_t(KT)= TRAP_PT(KT); %transfer to second value
TP_t(KT,1)=Tp_t(KT);

if rwuef==1
    if KT<=3288+1103
        H1=0;H2=-31;H4=-8000;H3L=-600;H3H=-300;
        if Tp_t(KT)<0.02/3600
            H3=H3L;
        elseif Tp_t(KT)>0.05/3600
            H3=H3H;
        else
            H3=H3H+(H3L-H3H)/(0.03/3600)*(0.05/3600-Tp_t(KT));
        end
    else
        H1=-1;H2=-5;H4=-16000;H3L=-600;H3H=-300;
        if Tp_t(KT)<0.02/3600
            H3=H3L;
        elseif Tp_t(KT)>0.05/3600
            H3=H3H;
        else
            H3=H3H+(H3L-H3H)/(0.03/3600)*(0.05/3600-Tp_t(KT));
        end
    end
    % piecewise linear reduction function
    MN=0;
    for ML=1:NL
        for ND=1:2
            MN=ML+ND-1;
            if hh(MN) >=H1
                alpha_h(ML,ND) = 0;
            elseif  hh(MN) >=H2
                alpha_h(ML,ND) = (H1-hh(MN))/(H1-H2);
            elseif  hh(MN) >=H3
                alpha_h(ML,ND) = 1;
            elseif  hh(MN) >=H4
                alpha_h(ML,ND) = (hh(MN)-H4)/(H3-H4);
            else
                alpha_h(ML,ND) = 0;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root lenth distribution %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Elmn_Lnth=0;
    RL=sum(DeltZ);
    Elmn_Lnth(1)=0;
    RB=0.9;
    LR=log(0.01)/log(RB);
    RY=1-RB^(LR);

    if LR<=1
        for ML=1:NL-1      % ignore the surface root water uptake 1cm
            for ND=1:2
                MN=ML+ND-1;
                bx(ML,ND)=0;
            end
        end
    else
        FRY=zeros(NL,1);bx=zeros(NL,2);
        for ML=2:NL
            Elmn_Lnth(ML)=Elmn_Lnth(ML-1)+DeltZ(ML-1);
            if Elmn_Lnth<RL-LR      %(KT)
                %                 bx(ML)=0;
                FRY(ML)=1;
                %             elseif Elmn_Lnth>=RL-LR(KT) && Elmn_Lnth<RL-0.2*LR(KT)
                %                 bx(ML)=2.0833*(1-(RL-Elmn_Lnth)/LR(KT))/LR(KT);
            else
                FRY(ML)=(1-RB^(RL-Elmn_Lnth(ML)))/RY;
            end
        end
        for ML=1:NL-1
            bx(ML)=FRY(ML)-FRY(ML+1);
            if bx(ML)<0
                bx(ML)=0;
            end
            bx(NL)=FRY(NL);
        end
        for ML=1:NL
            for ND=1:2
                MN=ML+ND-1;
                bx(ML,ND)=bx(MN);
            end
        end
    end
    %root zone water uptake
    Trap_1(KT)=0;
    for ML=1:NL
        for ND=1:2
            MN=ML+ND-1;
            Srt_1(ML,ND)=alpha_h(ML,ND)*bx(ML,ND)*Tp_t(KT);
            if TT(ML)<0
                Srt_1(ML:NL,ND)=0;
            end
        end
        Trap_1(KT)=Trap_1(KT)+(Srt_1(ML,1)+Srt_1(ML,2))/2*DeltZ(ML);   % root water uptake integration by DeltZ;
    end

    %     % consideration of water compensation effect
    if Tp_t(KT)==0
        Trap(KT)=0;
    else
        wt(KT)=Trap_1(KT)/Tp_t(KT);
        wc=1; % compensation coefficient
        Trap(KT)=0;
        if wt(KT)<wc
            for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Srt(ML,ND)=alpha_h(ML,ND)*bx(ML,ND)*Tp_t(KT)/wc;
                    if TT(ML)<0
                        Srt(ML:NL,ND)=0;
                    end
                end
                Trap(KT)=Trap(KT)+(Srt(ML,1)+Srt(ML,2))/2*DeltZ(ML);   % root water uptake integration by DeltZ;
            end
        else
            for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Srt(ML,ND)=alpha_h(ML,ND)*bx(ML,ND)*Tp_t(KT)/wt(KT);
                end
                Trap(KT)=Trap(KT)+(Srt(ML,1)+Srt(ML,2))/2*DeltZ(ML);   % root water uptake integration by DeltZ;
            end
        end
        if Trap(KT)>1E-4
            keyboard
        end
    end
end