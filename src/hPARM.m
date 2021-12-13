function [Chh,ChT,Khh,KhT,Kha,Vvh,VvT,Chg,DTheta_LLh,DTheta_LLT]=hPARM(NL,hh,...
h,TT,T,Theta_LL,Theta_L,DTheta_LLh,DTheta_LLT,RHOV,RHOL,Theta_V,V_A,Eta,DRHOVh,...
DRHOVT,KL_h,D_Ta,KL_T,D_V,D_Vg,COR,Beta_g,Gamma0,Gamma_w,KLa_Switch,DVa_Switch,hThmrl,Thmrlefc,nD)

% piecewise linear reduction function parameters of h;(Wesseling
% 1991,Veenhof and McBride 1994)

MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        if hThmrl
            DhU=COR(MN)*(hh(MN)-h(MN)+hh(MN)*0.0068*(TT(MN)-T(MN)));
            if DhU~=0 && abs(Theta_LL(ML,ND)-Theta_L(ML,ND))>1e-6
                DTheta_LLh(ML,ND)=(Theta_LL(ML,ND)-Theta_L(ML,ND))*COR(MN)/DhU;
            end
            DTheta_LLT(ML,ND)=DTheta_LLh(ML,ND)*hh(MN)*0.0068;
        else
            if abs(TT(MN)-T(MN))<1e-6
                DTheta_LLT(ML,ND)=DTheta_LLh(ML,ND)*(hh(MN)/Gamma0)*(-0.1425-4.76*10^(-4)*TT(MN));
            else
                DTheta_LLT(ML,ND)=(Theta_LL(ML,ND)-Theta_L(ML,ND))/(TT(MN)-T(MN));
            end
        end
    end
end

MN=0;
for ML=1:NL
    for ND=1:nD        
        MN=ML+ND-1;
        Chh(ML,ND)=(1-RHOV(MN)/RHOL)*DTheta_LLh(ML,ND)+Theta_V(ML,ND)*DRHOVh(MN)/RHOL;
        Khh(ML,ND)=(D_V(ML,ND)+D_Vg(ML))*DRHOVh(MN)/RHOL+KL_h(ML,ND); %
        Chg(ML,ND)=KL_h(ML,ND);
        %root zone water uptake 
      
        
        if Thmrlefc==1
            ChT(ML,ND)=(1-RHOV(MN)/RHOL)*DTheta_LLT(ML,ND)+Theta_V(ML,ND)*DRHOVT(MN)/RHOL;        
            KhT(ML,ND)=(D_V(ML,ND)*Eta(ML,ND)+D_Vg(ML))*DRHOVT(MN)/RHOL+KL_T(ML,ND)+D_Ta(ML,ND);%();%
        end

        if KLa_Switch==1
            Kha(ML,ND)=RHOV(MN)*Beta_g(ML,ND)/RHOL+KL_h(ML,ND)/Gamma_w;
        else
            Kha(ML,ND)=0;
        end
        
        if DVa_Switch==1
            Vvh(ML,ND)=-V_A(ML)*DRHOVh(MN)/RHOL;
            VvT(ML,ND)=-V_A(ML)*DRHOVT(MN)/RHOL;       
        else
            Vvh(ML,ND)=0;
            VvT(ML,ND)=0;
        end
    end   
end     
