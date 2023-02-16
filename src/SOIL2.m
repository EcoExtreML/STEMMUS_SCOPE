function [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(SoilConstants, SoilVariables, hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se)

if hThmrl==1

    for MN=1:NN
    CORh(MN)=0.0068;
    COR(MN)=exp(-1*CORh(MN)*(TT(MN)-Tr));%*COR21(MN)

        if COR(MN)==0
            COR(MN)=1;
        end
    end
else
    for MN=1:NN
        COR(MN)=1;
    end
end

for MN=1:NN
   hhU(MN)=COR(MN)*hh(MN);
   hh(MN)=hhU(MN);
end
[Theta_LL,Se,KfL_h,KfL_T,DTheta_LLh,hh,hh_frez,Theta_UU,DTheta_UUh,Theta_II,KL_h]=CondL_h(SoilConstants, SoilVariables, Theta_r,Theta_s,Alpha,hh,hh_frez,h_frez,n,m,Ks,NL,Theta_L,h,KIT,TT,Thmrlefc,POR,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,Theta_II,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
for MN=1:NN
   hhU(MN)=hh(MN);
   hh(MN)=hhU(MN)/COR(MN);
end

if Hystrs==0
    for ML=1:NL
        J=ML;
%         J=IS(ML);
        for ND=1:2
            Theta_V(ML,ND)=POR(J)-Theta_UU(ML,ND);%-Theta_II(ML,ND); % Theta_LL==>Theta_UU
            if Theta_V(ML,ND)<=1e-14
                Theta_V(ML,ND)=1e-14;
            end
            Theta_g(ML,ND)=Theta_V(ML,ND);
        end
    end
else
    for ML=1:NL
        J=ML;
%         J=IS(ML);
        for ND=1:2
            if IH(ML)==2
                if XWRE(ML,ND)<Theta_LL(ML,ND)
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND)-Theta_II(ML,ND);
                else
                    XSAVE=Theta_LL(ML,ND);
                    Theta_LL(ML,ND)=XSAVE*(1+(XWRE(ML,ND)-Theta_LL(ML,ND))/Theta_s(J));
                    if KIT>0
                        DTheta_LLh(ML,ND)=DTheta_LLh(ML,ND)*(Theta_LL(ML,ND)/XSAVE-XSAVE/Theta_s(J));
                    end
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND)-Theta_II(ML,ND);
                end
            end
            if IH(ML)==1
                if XWRE(ML,ND)>Theta_LL(ML,ND)
                    XSAVE=Theta_LL(ML,ND);
                    Theta_LL(ML,ND)=(2-XSAVE/Theta_s(J))*XSAVE;
                    if KIT>0
                        DTheta_LLh(ML,ND)=2*DTheta_LLh(ML,ND)*(1-XSAVE/Theta_s(J));
                    end
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND)-Theta_II(ML,ND);
                else
                    Theta_LL(ML,ND)=Theta_LL(ML,ND)+XWRE(ML,ND)*(1-Theta_LL(ML,ND)/Theta_s(J));
                    if KIT>0
                        DTheta_LLh(ML,ND)=DTheta_LLh(ML,ND)*(1-XWRE(ML,ND)/Theta_s(J));
                    end
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND)-Theta_II(ML,ND);
                end
            end
            if Theta_V(ML,ND)<=1e-14    % consider the negative conditions?
                Theta_V(ML,ND)=1e-14;
            end
            Theta_g(ML,ND)=Theta_V(ML,ND);
        end
    end
end
