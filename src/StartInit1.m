function StartInit1

global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX Btmh% Preset the measured depth to get the initial T, h by interpolation method.
global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 Dmark
global T MN ML NL NN DeltZ Elmn_Lnth Tot_Depth InitLnth
global InitX1 InitX2 InitX3 InitX4 InitX5 Inith1 Inith2 Inith3 Inith4 Inith5
global h Theta_s Theta_r m n Alpha Theta_L Theta_LL hh TT P_g P_gg Ks 
global XOLD XWRE NS J POR Thmrlefc IH IS Eqlspace FACc
global porosity SaturatedMC ResidualMC SaturatedK Coefficient_n Coefficient_Alpha
global NBCh NBCT NBCP NBChB NBCTB NBCPB BChB BCTB BCPB BCh BCT BCP BtmPg 
global DSTOR DSTOR0 RS NBChh DSTMAX IRPT1 IRPT2 Soilairefc XK XWILT 
global HCAP TCON SF TCA GA1 GA2 GB1 GB2 S1 S2 HCD TARG1 TARG2 GRAT VPER 
global TERM ZETA0 CON0 PS1 PS2 i KLT_Switch DVT_Switch KaT_Switch
global Kaa_Switch DVa_Switch KLa_Switch
global h0 hh0 XElemnt Gama_hh Gama_h
hd=-1e12;hm=-9899;

h0=zeros(NN+1,1);
hh0=zeros(NN+1,1);
Elmn_Lnth=0;
Dmark=0;

for J=1:NS
    POR(J)=porosity(J);
    Theta_s(J)=SaturatedMC(J);
    Theta_r(J)=ResidualMC(J);
    n(J)=Coefficient_n(J);
    Ks(J)=SaturatedK(J);
    Alpha(J)=Coefficient_Alpha(J);
    m(J)=1-1/n(J);
    XK(J)=0.095; %0.11 This is for silt loam; For sand XK=0.025
    XWILT(J)=Theta_r(J)+(Theta_s(J)-Theta_r(J))/(1+abs(Alpha(J)*(-1.5e4))^n(J))^m(J);
end
%     if ~Eqlspace
%         Inith1=-(((Theta_s(J)-Theta_r(J))/(InitX1-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
%         Inith2=-(((Theta_s(J)-Theta_r(J))/(InitX2-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
%         Inith3=-(((Theta_s(J)-Theta_r(J))/(InitX3-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
%         Inith4=-(((Theta_s(J)-Theta_r(J))/(InitX4-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
%         Inith5=-(((Theta_s(J)-Theta_r(J))/(InitX5-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
%         Btmh=-(((Theta_s(J)-Theta_r(J))/(BtmX-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
% 
%         if Btmh==-inf
%             Btmh=-1e6;
%         end
%         
%         for ML=1:NL
%             Elmn_Lnth=Elmn_Lnth+DeltZ(ML);
%             InitLnth(ML)=Tot_Depth-Elmn_Lnth;    
%             if abs(InitLnth(ML)-InitND5)<1e-10
%                 for MN=1:(ML+1)
%                     T(MN)=BtmT+(MN-1)*(InitT5-BtmT)/ML;
%                     h(MN)=(Btmh+(MN-1)*(Inith5-Btmh)/ML);
%                     IS(MN)=1;   %%%%%% Index of soil type %%%%%%%
%                     IH(MN)=1;   %%%%%% Index of wetting history of soil which would be assumed as dry at the first with the value of 1 %%%%%%%
%                 end
%                 Dmark=ML+2;
%             end    
%             if abs(InitLnth(ML)-InitND4)<1e-10
%                 for MN=Dmark:(ML+1)
%                     T(MN)=InitT5+(MN-Dmark+1)*(InitT4-InitT5)/(ML+2-Dmark);
%                     h(MN)=(Inith5+(MN-Dmark+1)*(Inith4-Inith5)/(ML+2-Dmark));
%                     IS(MN-1)=1;
%                     IH(MN-1)=1;
%                 end
%                 Dmark=ML+2;
%             end    
%             if abs(InitLnth(ML)-InitND3)<1e-10
%                 for MN=Dmark:(ML+1)
%                     T(MN)=InitT4+(MN-Dmark+1)*(InitT3-InitT4)/(ML+2-Dmark);
%                     h(MN)=(Inith4+(MN-Dmark+1)*(Inith3-Inith4)/(ML+2-Dmark));
%                     IS(MN-1)=1;
%                     IH(MN-1)=1;
%                 end
%                 Dmark=ML+2;
%             end
%             if abs(InitLnth(ML)-InitND2)<1e-10
%                 for MN=Dmark:(ML+1)
%                     T(MN)=InitT3+(MN-Dmark+1)*(InitT2-InitT3)/(ML+2-Dmark); 
%                     h(MN)=(Inith3+(MN-Dmark+1)*(Inith2-Inith3)/(ML+2-Dmark));
%                     IS(MN-1)=1;
%                     IH(MN-1)=1;
%                 end
%                 Dmark=ML+2;
%             end    
%             if abs(InitLnth(ML)-InitND1)<1e-10
%                 for MN=Dmark:(ML+1)
%                     T(MN)=InitT2+(MN-Dmark+1)*(InitT1-InitT2)/(ML+2-Dmark);
%                     h(MN)=(Inith2+(MN-Dmark+1)*(Inith1-Inith2)/(ML+2-Dmark));
%                     IS(MN-1)=1;
%                     IH(MN-1)=1;
%                 end
%                 Dmark=ML+2;
%             end
%             if abs(InitLnth(ML))<1e-10
%                 for MN=Dmark:(NL+1)
%                     T(MN)=InitT1+(MN-Dmark+1)*(InitT0-InitT1)/(NL+2-Dmark);
%                     h(MN)=Inith1;
%                     IS(MN-1)=1;
%                     IH(MN-1)=1;
%                 end
%             end
%         end
%     else
        h(NN-1)=-200;h(NN)=-200;h(1)=300;XElemnt1=max(XElemnt);
        for MN=2:NN-1
            h(MN)=h(MN-1)-DeltZ(MN-1)/XElemnt1*(h(1)-h(NN-1));%(h(1)+(MN-1)*(h(NN)-h(1))/(NN-1));
%             h(MN)=(h(1)+(MN-1)*(h(NN)-h(1))/(NN-1));
            T(MN)=26;
            TT(MN)=T(MN);
            IS(MN)=1;
            IH(MN)=1;
        end
        for MN=1:NN
            IS(MN)=1;
            IH(MN)=1;
            XK(MN)=0.095;
        end
%     end    

for MN=1:NN
    hh(MN)=h(MN);
    h0(MN)=h(MN);
    hh0(MN)=hh(MN);
    if abs(hh(MN))>=abs(hd)
        Gama_h(MN)=0;
        Gama_hh(MN)=Gama_h(MN);
    elseif abs(hh(MN))>=abs(hm)
        %                 Gama_h(MN)=1-log(abs(hh(MN)))/log(abs(hm));
        Gama_h(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
        Gama_hh(MN)=Gama_h(MN);
    else
        Gama_h(MN)=1;
        Gama_hh(MN)=Gama_h(MN);
    end
    
    if Thmrlefc==1
        TT(MN)=T(MN);
    end
    if Soilairefc==1
        P_g(MN)=82402.5288*10;  
        P_gg(MN)=P_g(MN); 
    end
    if MN<NN
    XWRE(MN,1)=0;
    XWRE(MN,2)=0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HCAP(1)=0.998*4.182;HCAP(2)=0.0003*4.182;HCAP(3)=0.46*4.182;HCAP(4)=0.46*4.182;HCAP(5)=0.6*4.182;    % J cm^-3 Cels^-1  /  g.cm-3---> J g-1 Cels-1;                     %
TCON(1)=1.37e-3*4.182;TCON(2)=6e-5*4.182;TCON(3)=2.1e-2*4.182;TCON(4)=7e-3*4.182;TCON(5)=6e-4*4.182; % J cm^-1 s^-1 Cels^-1;                %
SF(1)=0;SF(2)=0;SF(3)=0.125;SF(4)=0.125;SF(5)=0.5;                                                                                          %
TCA=6e-5*4.182;GA1=0.035;GA2=0.013;                                                                                                           %
VPER(1)=0.65;VPER(2)=0;VPER(3)=0;% VPER(1)=0.16;VPER(2)=0.33;VPER(3)=0.05;   %  For Silt Loam; % VPER(1)=0.16;VPER(2)=0.33;VPER(3)=0.05;  %
                                                                                                                                                %
%%%%% Perform initial thermal calculations for each soil type. %%%%                                                                             %        
for J=1:NS   %--------------> Sum over all phases of dry porous media to find the dry heat capacity                                             %
    S1=POR(J)*TCA;  %-------> and the sums in the dry thermal conductivity;                                                                     %
    S2=POR(J);                                                                                                                                  %
    HCD(J)=0;                                                                                                                                   %
    for i=3:5                                                                                                                                   %
        TARG1=TCON(i)/TCA-1;                                                                                                                    %
        GRAT=0.667/(1+TARG1*SF(i))+0.333/(1+TARG1*(1-2*SF(i)));                                                                                 %
        S1=S1+GRAT*TCON(i)*VPER(i-2);                                                                                                           %
        S2=S2+GRAT*VPER(i-2);                                                                                                                   %
        HCD(J)=HCD(J)+HCAP(i)*VPER(i-2);                                                                                                        %
    end                                                                                                                                         %
    ZETA0(J)=1/S2;                                                                                                                              %
    CON0(J)=1.25*S1/S2;                                                                                                                         %
    PS1(J)=0;                                                                                                                                   %
    PS2(J)=0;                                                                                                                                   %
    for i=3:5                                                                                                                                   %
        TARG2=TCON(i)/TCON(1)-1;                                                                                                                %
        GRAT=0.667/(1+TARG2*SF(i))+0.333/(1+TARG2*(1-2*SF(i)));                                                                                 %
        TERM=GRAT*VPER(i-2);                                                                                                                    %
        PS1(J)=PS1(J)+TERM*TCON(i);                                                                                                             %
        PS2(J)=PS2(J)+TERM;                                                                                                                     %
    end                                                                                                                                         %
    GB1(J)=0.298/POR(J);                                                                                                                        %
    GB2(J)=(GA1-GA2)/XWILT(J)+GB1(J);                                                                                                           %
end                                                                                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% According to hh value get the Theta_LL
run SOIL2;   % For calculating Theta_LL,used in first Balance calculation.

for ML=1:NL
        Theta_L(ML,1)=Theta_LL(ML,1);
        Theta_L(ML,2)=Theta_LL(ML,2);
        XOLD(ML)=(Theta_L(ML,1)+Theta_L(ML,2))/2;
end
% Using the initial condition to get the initial balance
% information---Initial heat storage and initial moisture storage.
KLT_Switch=1;
DVT_Switch=1;
if Soilairefc
    KaT_Switch=1;
    Kaa_Switch=1;
    DVa_Switch=1;
    KLa_Switch=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% The boundary condition information settings.%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IRPT1=0;
IRPT2=0;
NBCh=2;      % Moisture Surface B.C.: 1 --> Specified matric head(BCh); 2 --> Specified flux(BCh); 3 --> Atmospheric forcing;
BCh=-0.3/86400;
NBChB=2;    % Moisture Bottom B.C.: 1 --> Specified matric head (BChB); 2 --> Specified flux(BChB); 3 --> Zero matric head gradient (Gravitiy drainage);
BChB=0/86400; 
if Thmrlefc==1
    NBCT=1;  % Energy Surface B.C.: 1 --> Specified temperature (BCT); 2 --> Specified heat flux (BCT); 3 --> Atmospheric forcing;
    BCT=50;     
    NBCTB=1;% Energy Bottom B.C.: 1 --> Specified temperature (BCTB); 2 --> Specified heat flux (BCTB); 3 --> Zero temperature gradient;
    BCTB=29; 
end
if Soilairefc==1
    NBCP=3; % Soil air pressure B.C.: 1 --> Ponded infiltration caused a specified pressure value; 
                % 2 --> The soil air pressure is allowed to escape after beyond the threshold value;
                % 3 --> The atmospheric forcing;
    BCP=0;  
    NBCPB=2;  % Soil air Bottom B.C.: 1 --> Bounded bottom with specified air pressure; 2 --> Soil air is allowed to escape from bottom;
    BCPB=0;  
end

if NBCh~=1
    NBChh=2;                    % Assume the NBChh=2 firstly;
end

FACc=0;                         % Used in MeteoDataCHG for check is FAC changed?
BtmPg=82402.5288*10;     % Atmospheric pressure at the bottom (Pa), set fixed
                                     % with the value of mean atmospheric pressure;
DSTOR=0;                        % Depth of depression storage at end of current time step;
DSTOR0=DSTOR;              % Dept of depression storage at start of current time step;
RS=0;                             % Rate of surface runoff;
DSTMAX=0;                     % Depression storage capacity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



