function EnrgyPARM
global MN ML ND NL hh TT DeltZ P_gg
global CTh CTT CTa KTh KTT KTa VTT VTh VTa CTg Vvh VvT Vaa
global Kcva Kcah KcaT Kcaa Ccah CcaT Ccaa Kaa 
global c_a c_L RHOL DRHOVT DRHOVh RHOV Hc RHODA DRHODAz L WW DRHOVhDz DRHOVTDz
global Theta_V Theta_g QL V_A 
global KL_h KL_T D_Ta Lambda_eff c_unsat D_V Eta D_Vg Xah XaT Xaa DTheta_LLT Soilairefc
global DTheta_LLh DVa_Switch
global Khh KhT Kha KLhBAR KLTBAR DTDBAR DhDZ DTDZ DPgDZ Beta_g DEhBAR DETBAR QV Qa RHOVBAR EtaBAR

for ML=1:NL
    if ~Soilairefc
        KLhBAR(ML)=(KL_h(ML,1)+KL_h(ML,2))/2;
        KLTBAR(ML)=(KL_T(ML,1)+KL_T(ML,2))/2;
        DETBAR(ML)=(D_V(ML,1)*Eta(ML,1)+D_V(ML,2)*Eta(ML,2))/2;
        DhDZ(ML)=(hh(ML+1)-hh(ML))/DeltZ(ML);
        DTDZ(ML)=(TT(ML+1)-TT(ML))/DeltZ(ML);
        DPgDZ(ML)=(P_gg(ML+1)-P_gg(ML))/DeltZ(ML);
    end
    DTDBAR(ML)=(D_Ta(ML,1)+D_Ta(ML,2))/2;
    DEhBAR(ML)=(D_V(ML,1)+D_V(ML,2))/2;
    DRHOVhDz(ML)=(DRHOVh(ML+1)+DRHOVh(ML))/2;
    DRHOVTDz(ML)=(DRHOVT(ML+1)+DRHOVT(ML))/2;
    RHOVBAR(ML)=(RHOV(ML+1)+RHOV(ML))/2;
    EtaBAR(ML)=(Eta(ML,1)+Eta(ML,2))/2;
end

%%%%%% NOTE: The soil air gas in soil-pore is considered with Xah and XaT terms.(0.0003,volumetric heat capacity)%%%%%% 
MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        if ~Soilairefc
            QL(ML)=-(KLhBAR(ML)*DhDZ(ML)+(KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML)+KLhBAR(ML));
            Qa(ML)=0;
        else            
            Qa(ML)=-((DEhBAR(ML)+D_Vg(ML))*DRHODAz(ML)-RHODA(ML)*(V_A(ML)+Hc*QL(ML)/RHOL));
        end
        
        if DVa_Switch==1
            QV(ML)=-(DEhBAR(ML)+D_Vg(ML))*DRHOVhDz(ML)*DhDZ(ML)-(DEhBAR(ML)*EtaBAR(ML)+D_Vg(ML))*DRHOVTDz(ML)*DTDZ(ML)+RHOVBAR(ML)*V_A(ML);
        else
            QV(ML)=-(DEhBAR(ML)+D_Vg(ML))*DRHOVhDz(ML)*DhDZ(ML)-(DEhBAR(ML)*EtaBAR(ML)+D_Vg(ML))*DRHOVTDz(ML)*DTDZ(ML);
        end
                    
        if Soilairefc==1
            Kcah(ML,ND)=c_a*TT(MN)*((D_V(ML,ND)+D_Vg(ML))*Xah(MN)+Hc*RHODA(MN)*KL_h(ML,ND));
            KcaT(ML,ND)=c_a*TT(MN)*((D_V(ML,ND)+D_Vg(ML))*XaT(MN)+Hc*RHODA(MN)*(KL_T(ML,ND)+D_Ta(ML,ND))); %
            Kcaa(ML,ND)=c_a*TT(MN)*Kaa(ML,ND); %((D_V(ML,ND)+D_Vg(ML))*Xaa(MN)+RHODA(MN)*(Beta_g(ML,ND)+Hc*KL_h(ML,ND)/Gamma_w)); %
            if DVa_Switch==1
                Kcva(ML,ND)=L(MN)*RHOV(MN)*Beta_g(ML,ND);  %(c_V*TT(MN)+L(MN))--->(c_L*TT(MN)+L(MN))
            else
                Kcva(ML,ND)=0;
            end
            Ccah(ML,ND)=c_a*TT(MN)*(-V_A(ML)-Hc*QL(ML)/RHOL)*Xah(MN);
            CcaT(ML,ND)=c_a*TT(MN)*(-V_A(ML)-Hc*QL(ML)/RHOL)*XaT(MN);
            Ccaa(ML,ND)=c_a*TT(MN)*Vaa(ML,ND); %*(-V_A(ML)-Hc*QL(ML)/RHOL)*Xaa(MN); %
        end
        %  Main coefficients for energy transport is here:
        CTh(ML,ND)=((c_L*TT(MN)-WW(ML,ND))*RHOL-(c_L*TT(MN)+L(MN))*RHOV(MN)-c_a*RHODA(MN)*TT(MN))*DTheta_LLh(ML,ND) ...
            +(c_L*TT(MN)+L(MN))*Theta_g(ML,ND)*DRHOVh(MN)+c_a*TT(MN)*Theta_g(ML,ND)*Xah(MN);%;%+c_a*TT(MN)*Theta_g(ML,ND)*Xah(MN)
        CTT(ML,ND)=c_unsat(ML,ND)+(c_L*TT(MN)+L(MN))*Theta_g(ML,ND)*DRHOVT(MN)+c_a*TT(MN)*Theta_g(ML,ND)*XaT(MN) ...
            +((c_L*TT(MN)-WW(ML,ND))*RHOL-(c_L*TT(MN)+L(MN))*RHOV(MN)-c_a*RHODA(MN)*TT(MN))*DTheta_LLT(ML,ND); % %+c_a*TT(MN)*Theta_g(ML,ND)*XaT(MN)"+"
        CTa(ML,ND)=TT(MN)*Theta_V(ML,ND)*c_a*Xaa(MN);% There is not this term in Milly's work.
        
        KTh(ML,ND)=L(MN)*(D_V(ML,ND)+D_Vg(ML))*DRHOVh(MN)+c_L*TT(MN)*RHOL*Khh(ML,ND)+Kcah(ML,ND); %; %+Kcah(ML,ND)
        KTT(ML,ND)=Lambda_eff(ML,ND)+c_L*TT(MN)*RHOL*KhT(ML,ND)+KcaT(ML,ND)+L(MN)*(D_V(ML,ND)*Eta(ML,ND)+D_Vg(ML))*DRHOVT(MN);  %;%;  % Revised from: "Lambda_eff(ML,ND)+c_L*TT(MN)*RHOL*KhT(ML,ND);"
        KTa(ML,ND)=Kcva(ML,ND)+Kcaa(ML,ND)+c_L*TT(MN)*RHOL*Kha(ML,ND); % There is not this term in Milly's work.
      
        if DVa_Switch==1
            VTh(ML,ND)=c_L*TT(MN)*RHOL*Vvh(ML,ND)+Ccah(ML,ND)-L(MN)*V_A(ML)*DRHOVh(MN); 
            VTT(ML,ND)=c_L*TT(MN)*RHOL*VvT(ML,ND)+CcaT(ML,ND)-L(MN)*V_A(ML)*DRHOVT(MN)-(c_L*(QL(ML)+QV(ML))+c_a*Qa(ML)-2.369*QV(ML)); 
        else
            VTh(ML,ND)=c_L*TT(MN)*RHOL*Vvh(ML,ND)+Ccah(ML,ND); 
            VTT(ML,ND)=c_L*TT(MN)*RHOL*VvT(ML,ND)+CcaT(ML,ND)-(c_L*(QL(ML)+QV(ML))+c_a*Qa(ML)-2.369*QV(ML)); 
        end
        
        VTa(ML,ND)=Ccaa(ML,ND); %c_a*TT(MN)*Vaa(ML,ND);
        
        CTg(ML,ND)=(c_L*RHOL+c_a*Hc*RHODA(MN))*KL_h(ML,ND)*TT(MN); %;;% % Revised from "c_L*T(MN)*KL_h(ML,ND)"
    end
end
