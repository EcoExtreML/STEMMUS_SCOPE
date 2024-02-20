function CondV_DVg
global D_Vg ML ND P_gg Theta_g Sa V_A k_g MU_a DeltZ Alpha_Lg
global NL MN J Beta_g f0 KaT_Switch Theta_s
global Beta_gBAR DPgDZ Alpha_LgBAR Se

MN=0;
for ML=1:NL   
    for ND=1:2
        MN=ML+ND-1;
        Sa(ML,ND)=1-Se(ML,ND);
        f0(ML,ND)=Theta_g(ML,ND)^(7/3)/Theta_s(J)^2; %Theta_g(ML,ND)^0.67;  
        Beta_g(ML,ND)=(k_g(ML,ND)/MU_a); 
        Alpha_Lg(ML,ND)=0.078*(13.6-16*Sa(ML,ND)+3.4*Sa(ML,ND)^5)*100; %
    end        
end

for ML=1:NL
    Beta_gBAR(ML)=(Beta_g(ML,1)+Beta_g(ML,2))/2;
    DPgDZ(ML)=(P_gg(ML+1)-P_gg(ML))/DeltZ(ML);
    Alpha_LgBAR(ML)=(Alpha_Lg(ML,1)+Alpha_Lg(ML,2))/2;
end

for ML=1:NL   
        V_A(ML)=-Beta_gBAR(ML)*DPgDZ(ML); %0; %
        if KaT_Switch==1
            D_Vg(ML)=Alpha_LgBAR(ML)*abs(V_A(ML)); %0; %0; %
        else
            D_Vg(ML)=0;
        end
end

%%%%%%%%%%%% Unit of kg is cm^2, MU_a is g.cm^-1.s^-1,V_A is cm.s^-1, D_Vg
%%%%%%%%%%%% is cm^2.s^-1, The unit of soil air pressure should be Pa=kg.m^-1.s^-2=10g.cm^-1.s^-2 %%%%%%%%%%%%%
%%%%%%%%%%%% Notice that '10'in V_A is because Pa needs to be converted as10g.cm^-1.s^-2; has been done in the StarInit subroutine %%%%%%%%%%%%%
%%%%%%%%%%%% MU_a's unit has been changed %%%%%%%%%