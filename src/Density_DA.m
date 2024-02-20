function Density_DA
global Xaa XaT Xah MN T RDA P_g Rv 
global DeltZ h hh TT P_gg Delt_t ML NL NN
global DRHOVT DRHOVh DRHODAt DRHODAz RHODA RHOV
global XaaBAR XahBAR XaTBAR 

for MN=1:NN
    Xaa(MN)=1/(RDA*(TT(MN)+273.15));
    XaT(MN)=-(P_gg(MN)/(RDA*(TT(MN)+273.15)^2)+Rv*DRHOVT(MN)/RDA);
    Xah(MN)=-Rv*DRHOVh(MN)/RDA;

    DRHODAt(MN)=Xaa(MN)*(P_gg(MN)-P_g(MN))/Delt_t+XaT(MN)*(TT(MN)-T(MN))/Delt_t+Xah(MN)*(hh(MN)-h(MN))/Delt_t;

    RHODA(MN)=P_gg(MN)/(RDA*(TT(MN)+273.15))-RHOV(MN)*Rv/RDA;  
end
%%%%%%% Pa=kg.m^-1.s^-2=10g.cm^-1.s^-2 %%%%%%%%

for ML=1:NL
    XaaBAR(ML)=(Xaa(ML+1)+Xaa(ML))/2;
    XahBAR(ML)=(Xah(ML+1)+Xah(ML))/2;
    XaTBAR(ML)=(XaT(ML+1)+XaT(ML))/2;
    DRHODAz(ML)=XaaBAR(ML)*(P_gg(ML+1)-P_gg(ML))/DeltZ(ML)+XaTBAR(ML)*(TT(ML+1)-TT(ML))/DeltZ(ML)+XahBAR(ML)*(hh(ML+1)-hh(ML))/DeltZ(ML);
end
