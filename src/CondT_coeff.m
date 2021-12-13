function [c_unsat,Lambda_eff]=CondT_coeff(Theta_LL,Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,~,~)

global HCAP TCON SF TCA GA1 GA2 GB1 GB2 HCD
global ZETA0 CON0 PS1 PS2 ETCON EHCAP ZETA XWILT XK TT
global MN ML ND IS J POR DRHOVT L D_A Theta_V

if ThmrlCondCap==1

    [ETCON,EHCAP,ZETA,J]=EfeCapCond(HCAP,TCON,SF,TCA,GA1,GA2,GB1,GB2,HCD,ZETA0,CON0,PS1,PS2,XWILT,XK,TT,NL,IS,J,POR,Theta_LL,DRHOVT,L,D_A,RHOV,Theta_V);
    for ML=1:NL
        for ND=1:nD        
            Lambda_eff(ML,ND)=ETCON(ML,ND);
            c_unsat(ML,ND)=EHCAP(ML,ND);
        end
    end
else
   MN=0;
    for ML=1:NL
        for ND=1:nD        
            MN=ML+ND-1;
            Lambda_eff(ML,ND)=Lambda1+Lambda2*Theta_LL(ML,ND)+Lambda3*Theta_LL(ML,ND)^0.5; %3.6*0.001*4.182; % It is possible to add the dispersion effect here to consider the heat dispersion.

            c_unsat(ML,ND)= 837*RHO_bulk/1000+Theta_LL(ML,ND)*c_L+Theta_g(ML,ND)*(RHODA(MN)*c_a+RHOV(MN)*c_V);%9.79*0.1*4.182;%
        end
    end 
end

        
%%%%% Unit of Lambda_eff is (J.m^-1.s^-1.Cels^-1), While c_unsat is (J.m^-3.Cels^-1)
%%%%% UnitC needs to be used here to convert 'm' to 'cm' . 837 in J.kg^-1.Cels^-1. RHO_bulk in kg.m^-3 %%%%% 
%%%%% c_a, c_v,would be in J.g^-1.Cels^-1 as showed in
%%%%% globalization.  RHOV and RHODA would be in g.cm^-3