function CondL_Tdisp
global MU_W0 MU1 b W0 W WW H_W MU_W f0 L_WT D_Ta POR Theta_LL Theta_L SSUR RHO_bulk RHOL WARG
global MN ND ML TT Theta_s h hh W_Chg NL nD J Delt_t Theta_g
global KLT_Switch

MU_W0=2.4152*10^(-4);   %(g.cm^-1.s^-1)
MU1=4742.8;                   %(J.mol^-1)
b=4*10^(-6);                  %(cm)
W0=10^3;                      %(J.g^-1)
%%
MN=0;
for ML=1:NL
    for ND=1:nD        
        MN=ML+ND-1;
        if W_Chg==0
            W(ML,ND)=0;
            WW(ML,ND)=0;
            WARG=Theta_LL(ML,ND)*10^7/SSUR;
            if WARG<80
                W(ML,ND)=W0*exp(-WARG);  
                WW(ML,ND)=W0*exp(-WARG);
            end
        else
            W(ML,ND)=-0.2932*h(MN)/1000;%0;%    %%% J.g^-1---Original J.Kg^-1, now is divided by 1000.
            WW(ML,ND)=-0.2932*hh(MN)/1000;%0;%
        end
        f0(ML,ND)=Theta_g(ML,ND)^(7/3)/Theta_s(J)^2; %Theta_g(ML,ND)^0.67;
        H_W(ML,ND)=RHOL*WW(ML,ND)*(Theta_LL(ML,ND)-Theta_L(ML,ND))/((SSUR/RHO_bulk)*Delt_t);  %1e3; % 1e-4J cm-2---> g s-2 ; SSUR and RHO_bulk could also be set as an array to consider more than one soil type;
        MU_W(ML,ND)=MU_W0*exp(MU1/(8.31441*(TT(MN)+133.3)));
        L_WT(ML,ND)=f0(ML,ND)*1e7*1.5550e-13*POR(J)*H_W(ML,ND)/(b*MU_W(ML,ND));   % kg，m^-1，s^-1 --> 10 g.cm^-1.s^-1; J.cm^-2---> kg.m^2.s^-2.cm^-2--> 1e7g.cm^2.s^-2.cm^-2
        if KLT_Switch==1
            D_Ta(ML,ND)=L_WT(ML,ND)/(RHOL*(TT(MN)+273.15));%0; %0;%0; % 
        else
            D_Ta(ML,ND)=0;
        end
    end
end
%% Tortuosity Factor is a reverse of the tortuosity. In "L_WT", tortuosity should be used. That is why "f0" is in the numerator.%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NOTICE: f0 in L_WT has been changed as 1.5 %%%%%%%%%%% 
%%%%%%                                   kg.m^2.s^-2.cm^-2.kg.m^-3 --> 1e7g.cm^2.s^-2.cm^-2.g.cm^-3
%%%%%% Unit of L_WT IS (kg，m^-1，s^-1)=-------------------------- cm^2=;(1.5548e-013 cm^2); Converting meter to centimeter here by multipling UnitC
%%%%%%                                        m. kg.m^-1.s^-1  -->       cm. g.cm^-1.s^-1 
%%%%%% Please note that the Rv in MU_W should be 8.31441 J/mol.K. %%%%%%%%