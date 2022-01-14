function [k_g]=Condg_k_g(POR,NL,m,Theta_g,g,MU_W,Ks,RHOL,SWCC,Imped,Ratio_ice,Soilairefc,MN)

for ML=1:NL
    J=ML;
    for ND=1:2
        Sa(ML,ND)=Theta_g(ML,ND)/POR(J);
            if SWCC==1
        k_g(ML,ND)=Ks(J)*MU_W(ML,ND)*(1-Sa(ML,ND)^0.5)*(1-(1-(1-Sa(ML,ND)^(1/m(J))))^m(J))^2/(g*RHOL); 
            else
        k_g(ML,ND)=0; 
            end
            if Soilairefc==1
        k_g(ML,ND)=(Ks(J)*MU_W(ML,ND)*(1-Sa(ML,ND)^0.5)*(1-(1-(1-Sa(ML,ND)^(1/m(J))))^m(J))^2/(g*RHOL))*10^(-1*Imped(MN)*Ratio_ice(ML,ND)); 
            else
                k_g(ML,ND)=0;
            end
    end
end


%%%%%% Unit of k_g is m^2 , with UnitC^2, unit has been converted as cm^2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% 10^(-12)is used to convert the micrometer(¦Ìm) to meter(m)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
