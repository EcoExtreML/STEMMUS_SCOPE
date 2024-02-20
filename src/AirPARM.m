function AirPARM
global Cah CaT Caa Kah KaT Kaa Vah VaT Vaa Cag Xah XaT Xaa RHODA Hc
global POR D_V D_Ta D_Vg KL_T KL_h Gamma_w V_A RHOL
global QL Theta_LL hh TT DeltZ DTheta_LLT QL_h QL_T
global MN ML NL ND DTheta_LLh P_gg Beta_g J 
global KLhBAR KLTBAR DhDZ DTDZ DPgDZ DTDBAR KLa_Switch

for ML=1:NL
    KLhBAR(ML)=(KL_h(ML,1)+KL_h(ML,2))/2;
    KLTBAR(ML)=(KL_T(ML,1)+KL_T(ML,2))/2;
    DhDZ(ML)=(hh(ML+1)-hh(ML))/DeltZ(ML);
    DTDZ(ML)=(TT(ML+1)-TT(ML))/DeltZ(ML);
    DPgDZ(ML)=(P_gg(ML+1)-P_gg(ML))/DeltZ(ML);
    DTDBAR(ML)=(D_Ta(ML,1)+D_Ta(ML,2))/2;
end

MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        
        if KLa_Switch==1
            QL(ML)=-(KLhBAR(ML)*(DhDZ(ML)+DPgDZ(ML)/Gamma_w)+(KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML)+KLhBAR(ML));
            QL_h(ML)=-(KLhBAR(ML)*(DhDZ(ML)+DPgDZ(ML)/Gamma_w)+KLhBAR(ML));
            QL_T(ML)=-((KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML));           
        else
            QL(ML)=-(KLhBAR(ML)*DhDZ(ML)+(KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML)+KLhBAR(ML));
            QL_h(ML)=-(KLhBAR(ML)*DhDZ(ML)+KLhBAR(ML));
            QL_T(ML)=-((KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML));
            
        end
        
        Cah(ML,ND)=Xah(MN)*(POR(J)+(Hc-1)*Theta_LL(ML,ND))+(Hc-1)*RHODA(MN)*DTheta_LLh(ML,ND);
        CaT(ML,ND)=XaT(MN)*(POR(J)+(Hc-1)*Theta_LL(ML,ND))+(Hc-1)*RHODA(MN)*DTheta_LLT(ML,ND);
        Caa(ML,ND)=Xaa(MN)*(POR(J)+(Hc-1)*Theta_LL(ML,ND));    
        
        Kah(ML,ND)=Xah(MN)*(D_V(ML,ND)+D_Vg(ML))+Hc*RHODA(MN)*KL_h(ML,ND);
        KaT(ML,ND)=XaT(MN)*(D_V(ML,ND)+D_Vg(ML))+Hc*RHODA(MN)*(KL_T(ML,ND)+D_Ta(ML,ND));
        Kaa(ML,ND)=Xaa(MN)*(D_V(ML,ND)+D_Vg(ML))+RHODA(MN)*(Beta_g(ML,ND)+Hc*KL_h(ML,ND)/Gamma_w);%
        
        Cag(ML,ND)=Hc*RHODA(MN)*KL_h(ML,ND);
        
        Vah(ML,ND)=-(V_A(ML)+Hc*QL(ML)/RHOL)*Xah(MN); %0;%
        VaT(ML,ND)=-(V_A(ML)+Hc*QL(ML)/RHOL)*XaT(MN); %0;%
        Vaa(ML,ND)=-(V_A(ML)+Hc*QL(ML)/RHOL)*Xaa(MN); %0;%
    end
end

