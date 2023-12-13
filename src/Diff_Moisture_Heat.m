function [BCh,SAVEhh,SAVETT,TQL,CHK,CHK1,h_frez,hh_frez,KL_h,QLH,QLT,Chh,QL,Theta_LL,Theta_L,Theta_UU,Theta_U,Theta_II,DTheta_LLh,DTheta_UUh,AVAIL0,RHS,Rn_SOIL,Evap,EVAP,...
    Trap,r_a_SOIL,Resis_a,Srt,Precip,TT,T,hh,h,QMT]=Diff_Moisture_Heat(DTheta_UUh,Theta_U,hh_frez,h_frez,hBOT,IBOT,L_f,SAVE,RHS,Precip,...
    NBCTB,NBCT,BCT,BCTB,Delt_t,EVAP,r_a_SOIL,Tbtm,Rn_SOIL,KL_h,DeltZ,Ta,HR_a,U,Ts,Rv,g,rwuef,Theta_UU,Rn,Gvc,Rns,Srt,...
    Precip_msr,SUMTIME,NBCh,NBChB,BCh,BChB,KT,DSTOR0,NBChh,TIME,h_SUR,Theta_L,hh,h,T,m,n,Theta_r,Theta_s,Alpha,XElemnt,NN,Theta_LL,...
    Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,ThermCond,HCAP,SF,TCA,GA1,GA2,GB1,GB2,HCD,ZETA0,CON0,...
    PS1,PS2,XWILT,XK,TT,POR,DRHOVT,D_A,Theta_V,Theta_II,TCON_dry,XSOC,TPS1,TPS2,TCON0,TCON_s,RHOI,RHOL,c_unsat,Lambda_eff,ETCON,EHCAP,FEHCAP,TETCON,EfTCON,ZETA,...
    KfL_h,DTheta_LLh,hN,KL_T,Chh,IP0STm,EVAP_PT,TRAP_PT,BOTm,hOLD)
Q3DF=1;
HPUNIT=100;

INBT=NN-IBOT+1; % index of STEMMUS bottom soil layer

hd=-1e7;hm=-9899;
hRHS=zeros(NN,1);hdry(1:NN)=-0.75e3;hwet(1:NN)=-1;
SAVETT=TT;
Thmrlefct=0;
%%%%%%%%%%%%%%%%%
%   Soil Moisture Part
%%%%%%%%%%%%%%%%%
% run  Latent
% run  CondT_coeff
[L]= Latent(TT,NN);
[c_unsat,Lambda_eff,ZETA,ETCON,EHCAP,TETCON,EfTCON]=CondT_coeffUncp(Theta_LL,Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,ThermCond,HCAP,SF,TCA,GA1,GA2,GB1,GB2,HCD,ZETA0,CON0,PS1,PS2,XWILT,XK,TT,POR,DRHOVT,L,D_A,Theta_V,Theta_II,TCON_dry,Theta_s,XSOC,TPS1,TPS2,TCON0,TCON_s,FEHCAP,RHOI,RHOL,c_unsat,Lambda_eff,ETCON,EHCAP,TETCON,EfTCON,ZETA);

for ML=1:NL
    J=ML;
    VGm(J)=m(J);VGn(J)=n(J);
end
Cpcty_Eqn=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Cpcty_Eqn==1 %&& Delt_t>1E-5
    MN=0;
    for ML=1:NL
        J=ML;
        for ND=1:2
            MN=ML+ND-1;
            if ND==1
                Dth1=(hh(MN)-h(MN))/Delt_t;
                DthU1=(hh(MN)+hh_frez(MN)-h_frez(MN)-h(MN))/Delt_t;
            else
                Dth2=(hh(MN)-h(MN))/Delt_t;
                DthU2=(hh(MN)+hh_frez(MN)-h_frez(MN)-h(MN))/Delt_t;
            end

            if abs(hh(MN)-h(MN))<1e-6
                if abs(hh(MN))>=abs(hd)
                    Gama_hh(MN)=0;
                elseif abs(hh(MN))>=abs(hm)
                    Gama_hh(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
                else
                    Gama_hh(MN)=1;
                end
                Theta_m(ML)=Gama_hh(MN)*Theta_r(J)+(Theta_s(J)-Gama_hh(MN)*Theta_r(J))*(1+abs(Alpha(J)*(-2))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
                if Theta_m(ML)>=POR(J)
                    Theta_m(ML)=POR(J);
                elseif Theta_m(ML)<=Theta_s(J)
                    Theta_m(ML)=Theta_s(J);
                end
                if hh(MN)>=-2
                    DTheta_LLh(ML,ND)=0;%
                    if (hh_frez(MN))>=0
                        DTheta_UUh(ML,ND)=0;
                    else
                        if (hh(MN)+hh_frez(MN))<=hd
                            DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        else
                            DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));
                        end
                    end
                else
                    if Gama_hh(MN)==0
                        DTheta_LLh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        if (hh(MN)+hh_frez(MN))<=hd
                            DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        else
                            DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        end
                    else
                        DTheta_LLh(ML,ND)=(-Theta_r(J))/(abs(hh(MN))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1))*(abs(Alpha(J)*hh(MN))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        if (hh(MN)+hh_frez(MN))<=hd
                            DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        else
                            DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        end
                    end
                end
            elseif ND==2
                DtTheta1=(Theta_UU(ML,1)-Theta_U(ML,1))/Delt_t;
                DtTheta2=(Theta_UU(ML,2)-Theta_U(ML,2))/Delt_t;
                DtThetaU1=(Theta_LL(ML,1)-Theta_L(ML,1))/Delt_t;
                DtThetaU2=(Theta_LL(ML,2)-Theta_L(ML,2))/Delt_t;
                if Cpcty_Eqn==1
                    DTheta_LLh(ML,1)=(DtTheta1*(Dth1+5*Dth2)+DtTheta2*(Dth2-Dth1))*(Dth1^2+4*Dth1*Dth2+Dth2^2)^-1;
                    DTheta_LLh(ML,2)=(DtTheta1*(Dth1-Dth2)+DtTheta2*(5*Dth1+Dth2))*(Dth1^2+4*Dth1*Dth2+Dth2^2)^-1;
                    DTheta_UUh(ML,1)=(DtThetaU1*(DthU1+5*DthU2)+DtThetaU2*(DthU2-DthU1))*(DthU1^2+4*DthU1*DthU2+DthU2^2)^-1;
                    DTheta_UUh(ML,2)=(DtThetaU1*(DthU1-DthU2)+DtThetaU2*(5*DthU1+DthU2))*(DthU1^2+4*DthU1*DthU2+DthU2^2)^-1;
                else
                    DTheta_LLh(ML,1)=2*DtTheta1/Dth1-DtTheta2/Dth2;
                    DTheta_LLh(ML,2)=2*DtTheta2/Dth2-DtTheta1/Dth1;
                    DTheta_UUh(ML,1)=2*DtThetaU1/DthU1-DtThetaU2/DthU2;
                    DTheta_UUh(ML,2)=2*DtThetaU2/DthU2-DtThetaU1/DthU1;
                end
            end
        end
    end
else
    MN=0;
    for ML=1:NL
        J=ML;
        for ND=1:2
            MN=ML+ND-1;
            if abs(hh(MN)-h(MN))<1e-3

                if abs(hh(MN))>=abs(hd)
                    Gama_hh(MN)=0;
                elseif abs(hh(MN))>=abs(hm)
                    Gama_hh(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
                else
                    Gama_hh(MN)=1;
                end
                Theta_m(ML)=Gama_hh(MN)*Theta_r(J)+(Theta_s(J)-Gama_hh(MN)*Theta_r(J))*(1+abs(Alpha(J)*(-2))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
                if Theta_m(ML)>=POR(J)
                    Theta_m(ML)=POR(J);
                elseif Theta_m(ML)<=Theta_s(J)
                    Theta_m(ML)=Theta_s(J);
                end
                if hh(MN)>=-2
                    DTheta_LLh(ML,ND)=0;%hh_frez(MN)=h_frez(MN);
                    if (hh_frez(MN))>=0
                        DTheta_UUh(ML,ND)=0;%Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                    else
                        if (hh(MN)+hh_frez(MN))<=hd
                            DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        else
                            DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));
                        end
                    end
                else
                    if Gama_hh(MN)==0
                        DTheta_LLh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        if (hh(MN)+hh_frez(MN))<=hd
                            DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        else
                            DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        end
                    else
                        DTheta_LLh(ML,ND)=(-Theta_r(J))/(abs(hh(MN))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1))*(abs(Alpha(J)*hh(MN))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        if (hh(MN)+hh_frez(MN))<=hd
                            DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        else
                            DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                        end
                    end
                end
            else
                DTheta_LLh(ML,ND)=(Theta_UU(ML,ND)-Theta_U(ML,ND))/(hh(MN)-h(MN));
                DTheta_UUh(ML,ND)=(Theta_LL(ML,ND)-Theta_L(ML,ND))/(hh(MN)+hh_frez(MN)-h(MN)-+h_frez(MN));
            end
        end
    end

    if any(isnan(DTheta_LLh))
        save('errDTheta_LLh.mat')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ML=1:NL              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files,
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        Chh(ML,ND)=0;
        Khh(ML,ND)=0;
        Chg(ML,ND)=0;
    end
end
for ML=INBT:NL
    for ND=1:nD
        Chh(ML,ND)=DTheta_LLh(ML,ND);
        Khh(ML,ND)=KfL_h(ML,ND); %
        Chg(ML,ND)=KfL_h(ML,ND);
    end
end

for MN=1:NN              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files,
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        C1(MN,ND)=0;
        C7(MN)=0;
        C4(MN,ND)=0;C4_a(MN,ND)=0;
        C9(MN)=0; % C9 is the matrix coefficient of root water uptake;
    end
end

for ML=INBT:NL
    C1(ML,1)=C1(ML,1)+Chh(ML,1)*DeltZ(ML)/2;
    C1(ML+1,1)=C1(ML+1,1)+Chh(ML,2)*DeltZ(ML)/2;%

    C4ARG1=(Khh(ML,1)+Khh(ML,2))/(2*DeltZ(ML));%sqrt(Khh(ML,1)*Khh(ML,2))/(DeltZ(ML));%
    C4(ML,1)=C4(ML,1)+C4ARG1;
    C4(ML,2)=C4(ML,2)-C4ARG1;
    C4(ML+1,1)=C4(ML+1,1)+C4ARG1;

    C7ARG=(Chg(ML,1)+Chg(ML,2))/2;%sqrt(Chg(ML,1)*Chg(ML,2));%
    C7(ML)=C7(ML)-C7ARG;
    C7(ML+1)=C7(ML+1)+C7ARG;

    % Srt, root water uptake;
    if rwuef==1
        C9ARG1=(2*Srt(ML,1)+Srt(ML,2))*DeltZ(ML)/6;%sqrt(Chg(ML,1)*Chg(ML,2));%
        C9ARG2=(Srt(ML,1)+2*Srt(ML,2))*DeltZ(ML)/6;
        C9(ML)=C9(ML)+C9ARG1;
        C9(ML+1)=C9(ML+1)+C9ARG2;
    end
end
RHS(INBT)=-C9(INBT)-C7(INBT)+(C1(INBT,1)*h(INBT)+C1(INBT,2)*h(INBT+1))/Delt_t;
for ML=INBT+1:NL
    RHS(ML)=-C9(ML)-C7(ML)+(C1(ML-1,2)*h(ML-1)+C1(ML,1)*h(ML)+C1(ML,2)*h(ML+1))/Delt_t;
end
RHS(NN)=-C9(NN)-C7(NN)+(C1(NN-1,2)*h(NN-1)+C1(NN,1)*h(NN))/Delt_t;

for MN=INBT:NN
    for ND=1:2
        C4(MN,ND)=C1(MN,ND)/Delt_t+C4(MN,ND);
    end
end

SAVE(1,1,1)=RHS(INBT);
SAVE(1,2,1)=C4(INBT,1);
SAVE(1,3,1)=C4(INBT,2);
SAVE(2,1,1)=RHS(NN);
SAVE(2,2,1)=C4(NN-1,2);
SAVE(2,3,1)=C4(NN,1);

% run h_BC
[BCh,AVAIL0,RHS,C4,C4_a,Rn_SOIL,Evap,EVAP,Trap,r_a_SOIL,Resis_a,Srt,Precip]=h_BC(XElemnt,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,TIME,h_SUR,C4,KL_h,NN,C4_a,DeltZ,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,hh,rwuef,Theta_UU,Rn,T,TT,Gvc,Rns,Srt,Precip_msr,SUMTIME,n,Alpha,Theta_s,Theta_r,EVAP_PT,TRAP_PT);% h_BC;

BOTMm=BOTm(1,IP0STm)*HPUNIT;%BOTm=XElemnt(NN);
if Q3DF && INBT>1
    %     if NBChB==1            %-----> Specify matric head at bottom to be ---BChB;
    RHS(INBT)=(hBOT-BOTMm+XElemnt(IBOT));
    C4(INBT,1)=1;
    RHS(INBT+1)=RHS(INBT+1)-C4(INBT,2)*RHS(INBT);
    C4(INBT,2)=0;
    C4_a(INBT)=0;
end
RHS(INBT)=RHS(INBT)/C4(INBT,1);

for ML=INBT+1:NN
    C4(ML,1)=C4(ML,1)-C4(ML-1,2)*C4(ML-1,2)/C4(ML-1,1);
    RHS(ML)=(RHS(ML)-C4(ML-1,2)*RHS(ML-1))/C4(ML,1);
end

for ML=NL:-1:INBT
    RHS(ML)=RHS(ML)-C4(ML,2)*RHS(ML+1)/C4(ML,1);
end

J=1;
f=@(hhRHS)((Theta_s(J)-Theta_r(J))*Alpha(J)*n(J)*abs(Alpha(J)*hhRHS)^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hhRHS)^n(J))^(-m(J)-1));
x0=-1000;
hmin=fminsearch(f,x0);
hmin=-1*abs(hmin);
hRHS(1:NN)=hh(1:NN); %hj+1,k; RHS, hj+1,k+1
% RTheta_LL=Theta_LL; %thetaj+1,k;
MN=0;
for MN=1:NN
    %     for ND=1:2
    %         MN=ML+ND-1;
    if hRHS(MN)<=hdry(MN) && RHS(MN)>=hwet(MN)
        RHS(MN)=(hRHS(MN)+hmin)/2;
    elseif RHS(MN)<=hdry(MN)*3 && hRHS(MN)>=hwet(MN)
        RHS(MN)=(hRHS(MN))/2;
    end
    %     end
end
if(INBT>1)
    for I=INBT:-1:2
        RHS(I-1)=RHS(I)+XElemnt(NN-I+2)-XElemnt(NN-I+1);
    end
end
for MN=1:NN
    CHK(MN)=0;
    CHK1(MN)=0;
end
for MN=1:NN
    CHK1(MN)=abs(RHS(MN)-hh(MN));
    SAVEhh(MN)=RHS(MN);
    if isnan(RHS(MN))
        RHS(MN)=h(MN);
        CHK1(MN)=0;
    end
    hh(MN)=RHS(MN);
end
if(INBT>1)
    for I=INBT:-1:1
        CHK1(I)=0;
    end
end
%% 20200324
for ML=1:NL
    DTheta_LLhBAR(ML)=(DTheta_UUh(ML,1)+DTheta_UUh(ML,2))/2;
end
for ML=1:NL
    LHS(ML)= DTheta_LLhBAR(ML)*(hh(ML)-h(ML))/Delt_t;
end

for MN=1:NN
    if hh(MN)>=-1e-6
        hh(MN)=-1e-6;
    end
end
if(INBT>1)
    for I=INBT:-1:1
        hh(I)=RHS(I);%+XElemnt(NN-I+2)-XElemnt(NN-I+1);
    end
end
[QMT,QMB]=h_Bndry_Flux(SAVE,hh,NN,KT);
% run h_Bndry_Flux;
PrecipO(KT)=Precip(KT);
QMTT(KT)=QMT(KT);
QMBB(KT)=QMB(KT);
Evapo(KT)=Evap(KT);
trap(KT)=Trap(KT);
%% calculate QL
for ML=INBT:NL
    KLhBAR(ML)=(KfL_h(ML,1)+KfL_h(ML,2))/2;
    KLTBAR(ML)=(KL_T(ML,1)+KL_T(ML,2))/2;
    DhDZ(ML)=(hh(ML+1)-hh(ML))/DeltZ(ML);
    DTDZ(ML)=(TT(ML+1)-TT(ML))/DeltZ(ML);
    DTDBAR(ML)=0;%(D_Ta(ML,1)+D_Ta(ML,2))/2;
    DTheta_LLhBAR(ML)=(DTheta_LLh(ML,1)+DTheta_LLh(ML,2))/2;
end

%%%%%% NOTE: The soil air gas in soil-pore is considered with Xah and XaT terms.(0.0003,volumetric heat capacity)%%%%%%
MN=0;
for ML=INBT:NL
    %             for ND=1:2
    %                 MN=ML+ND-1;
    QL(ML)=-(KLhBAR(ML)*DhDZ(ML)+(KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML)+KLhBAR(ML));
    QLT(ML)=-((KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML));
    QLH(ML)=-(KLhBAR(ML)*DhDZ(ML)+KLhBAR(ML));
    %             end
end
QL(NN)=QMT(KT);

TQL=flip(QL)*(86400);
%%%%%%%%%%%%%%%%%%
% Heat Transport Part
%%%%%%%%%%%%%%%%%%
if Thmrlefct==1
    CTg=zeros(NL,nD);
    for ML=1:NL
        for ND=1:2
            CTT(ML,ND)=0;
            KTT(ML,ND)=0;
            CTT_PH(ML,ND)=0;
        end
    end
    %% calculate QL
    for ML=1:NL
        KLhBAR(ML)=(KfL_h(ML,1)+KfL_h(ML,2))/2;
        KLTBAR(ML)=(KL_T(ML,1)+KL_T(ML,2))/2;
        DhDZ(ML)=(hh(ML+1)-hh(ML))/DeltZ(ML);
        %         DhDZ(ML)=(hh(ML+1)+hh_frez(ML+1)-hh(ML)-hh_frez(ML))/DeltZ(ML);
        DTDZ(ML)=(TT(ML+1)-TT(ML))/DeltZ(ML);
        DTDBAR(ML)=0;
        DTheta_LLhBAR(ML)=(DTheta_LLh(ML,1)+DTheta_LLh(ML,2))/2;
    end

    %%%%%% NOTE: The soil air gas in soil-pore is considered with Xah and XaT terms.(0.0003,volumetric heat capacity)%%%%%%
    MN=0;
    for ML=1:NL
        QL(ML)=-(KLhBAR(ML)*DhDZ(ML)+(KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML)+KLhBAR(ML));
        QLT(ML)=-((KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML));
        QLH(ML)=-(KLhBAR(ML)*DhDZ(ML)+KLhBAR(ML));
    end
    %%
    MN=0;
    for ML=1:NL
        for ND=1:2
            MN=ML+ND-1;
            CTT(ML,ND)=c_unsat(ML,ND);
            KTT(ML,ND)=Lambda_eff(ML,ND);
            if abs(DTheta_LLh(ML,ND)-DTheta_UUh(ML,ND))>0 %max(EPCT(MN),heaviside(TT_CRIT(MN)-(TT(MN)+T0)))>0  %
                CTT_PH(ML,ND)=(10*L_f^2*RHOI/(g*(T0+TT(MN))))*DTheta_UUh(ML,ND);%*max(EPCT(MN),heaviside(TT_CRIT(MN)-(TT(MN)+T0)));%*max(EPCT(ML),heaviside(TT_CRIT(MN)-(TT(MN)+T0)))3.85*1e6*DTheta_LLh(ML,ND)*max(EPCT(MN),heaviside(TT_CRIT(MN)-(TT(MN)+T0)));%(10*L_f^2*RHOI/(g*(T0+TT(MN)))-1e4*c_i*(TT(MN))*L_f*RHOI/(g*(T0+TT(MN))))*DTheta_LLh(ML,ND)*max(EPCT(MN),heaviside(TT_CRIT(MN)-(TT(MN)+T0)));

                if CTT_PH(ML,ND)<0 %|| Delt_t<1.0e-6
                    CTT_PH(ML,ND)=0;
                else
                    CTT_PH(ML,ND)=CTT_PH(ML,ND);
                end
                CTT(ML,ND)=c_unsat(ML,ND)+CTT_PH(ML,ND);
            else
                CTT_PH(ML,ND)=0;
                CTT(ML,ND)=c_unsat(ML,ND);
            end
            if rwuef==1
                CTg(ML,ND)=-c_L*Srt(ML,ND)*TT(MN);
            end
        end
    end

    if any(imag(TT))
        keyboard
    end
    % EnrgyMAT Sub
    for MN=1:NN              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files,
        for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
            C2(MN,ND)=0;
            C5(MN,ND)=0;
            C7(MN,ND)=0;
        end
        RHS(MN)=0;
    end

    for ML=1:NL
        C2(ML,1)=C2(ML,1)+CTT(ML,1)*DeltZ(ML)/2;
        C2(ML+1,1)=C2(ML+1,1)+CTT(ML,2)*DeltZ(ML)/2;

        C5ARG1=(KTT(ML,1)+KTT(ML,2))/(2*DeltZ(ML)); %sqrt(KTT(ML,1)*KTT(ML,2))/(DeltZ(ML));%
        C5(ML,1)=C5(ML,1)+C5ARG1;
        C5(ML,2)=C5(ML,2)-C5ARG1;
        C5(ML+1,1)=C5(ML+1,1)+C5ARG1;
        %% RWU root water uptake
        C7ARG=(CTg(ML,1)+CTg(ML,2))/2; %sqrt(CTg(ML,1)*CTg(ML,2));%
        C7(ML)=C7(ML)-C7ARG;
        C7(ML+1)=C7(ML+1)+C7ARG;
    end

    % EnrgyEQ_Sub
    RHS(1)=-C7(1)+(C2(1,1)*T(1)+C2(1,2)*T(1+1))/Delt_t;
    for ML=1+1:NL
        RHS(ML)=-C7(ML)+(C2(ML-1,2)*T(ML-1)+C2(ML,1)*T(ML)+C2(ML,2)*T(ML+1))/Delt_t;
    end
    RHS(NN)=-C7(NN)+(C2(NN-1,2)*T(NN-1)+C2(NN,1)*T(NN))/Delt_t;

    for MN=1:NN
        for ND=1:2
            C5(MN,ND)=C2(MN,ND)/Delt_t+C5(MN,ND);
        end
    end

    SAVE(1,1,2)=RHS(1);
    SAVE(1,2,2)=C5(1,1);
    SAVE(1,3,2)=C5(1,2);
    SAVE(2,1,2)=RHS(NN);
    SAVE(2,2,2)=C5(NN-1,2);
    SAVE(2,3,2)=C5(NN,1);

    %     run Enrgy_BC;
    [RHS,C5,C5_a]=Enrgy_BC(RHS,KT,NN,c_L,RHOL,QMB,SH,Precip,L,L_ts,NBCTB,NBCT,BCT,BCTB,DSTOR0,Delt_t,T,Ts,Ta,EVAP,C5,C5_a,r_a_SOIL,Resis_a,Tbtm,c_a,Rn_SOIL,TT);

    RHS(1)=RHS(1)/C5(1,1);
    for ML=1+1:NN
        C5(ML,1)=C5(ML,1)-C5(ML-1,2)*C5(ML-1,2)/C5(ML-1,1);
        RHS(ML)=(RHS(ML)-C5(ML-1,2)*RHS(ML-1))/C5(ML,1);
    end
    for ML=NL:-1:1
        RHS(ML)=RHS(ML)-C5(ML,2)*RHS(ML+1)/C5(ML,1);
    end
    for MN=1:NN
        CHK(MN)=abs(RHS(MN)-TT(MN)); %abs((RHS(MN)-TT(MN))/TT(MN)); %
        SAVETT(MN)=RHS(MN);
        if isnan(RHS(MN))
            RHS(MN)=T(MN);
            CHK(MN)=0;
        end
        TT(MN)=RHS(MN);
    end

    if any(imag(TT)) || any(isnan(TT))
        keyboard
    end

    if any(isnan(TT)) || any(abs(TT(1:NN))>=100)%isnan(TT)==1
        for MN=1:NN
            TT(MN)=TOLD(MN);
        end
    end

    [QET,QEB]=Enrgy_Bndry_Flux(SAVE,TT,NN);
    %     run Enrgy_Bndry_Flux;
end
end