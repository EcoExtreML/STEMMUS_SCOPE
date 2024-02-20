function Condg_k_g
global ML ND k_g POR NL J m Sa Theta_g g MU_W Ks RHOL


for ML=1:NL
    for ND=1:2
        Sa(ML,ND)=Theta_g(ML,ND)/POR(J);
        k_g(ML,ND)=Ks(J)*MU_W(ML,ND)*(1-Sa(ML,ND)^0.5)*(1-(1-(1-Sa(ML,ND)^(1/m(J))))^m(J))^2/(g*RHOL); 
    end
end


%%%%%% Unit of k_g is m^2 , with UnitC^2, unit has been converted as cm^2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% 10^(-12)is used to convert the micrometer(¦Ìm) to meter(m)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
