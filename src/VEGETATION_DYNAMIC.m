%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction  VEGETATION_DYNAMIC       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% References [Cox 2001] Bonan et al., 2003 Krinner et al.,  2005 Ivanov
%%% et al., 2008  Sitch et al 2003 White et al 2000  Knorr 2000  Arora and
%%% Boer 2003
function[dB]= VEGETATION_DYNAMIC(t,B,Tam,Tsm,An,Rdark,Bfac,Bfac_alloc,FNC,Se_bio,Tdp_bio,dtd,GF,...
    Sl,mSl,St,r,rNc,gR,aSE,Trr,dd_max,dc_C,Tcold,drn,dsn,age_cr,PHE_S,AgeL,AgeDL,LtR,eps_ac,...
    Mf,Wm,fab,fbe,Klf,ff_r,Rexmy,NBLeaf,dflo,Nreserve,Preserve,Kreserve,TBio,OPT_EnvLimitGrowth)
%%%% INPUT
%%% OUTPUT
%%% dB [gC/m^2 d]
%%% B = [gC/m^2]
%Nreserve  = Actually this is Nitrogen Available [gN/m^2]
%Preserve  = Actually this is Phosporus Available [gN/m^2]
%Kreserve  = Actually this is Potassium Available [gN/m^2]
%%%%%%%%%%%%%%%%%%%%%%%%%
% Tam [°C]  Mean Daily Temperature
% Tsm [°C]  Soil Daily Temperature
% An  [umolCO2/ s m^2]  Net Assimilation Rate
% Rdark  % [umolCO2/ s m^2]  Leaf Maintenace Respiration / Dark Respiration
% Om [] Daily Water Content in the Root Zone
% Osm [] Daily Water Content in the Surface Layer
% ke Light extinction Coefficient
%%%% PARAMETERS
%%%%%%% CARBON POOL %%%%%%%%%%%
%%% B1 Leaves - Grass
%%% B2 Sapwood
%%% B3 Fine Root
%%% B4 Carbohydrate Reserve
%%% B5 Fruit and Flower
%%% B6 Heartwood - Dead Sapwood
%%% B7 Leaves - Grass -- Standing Dead
%%% B8 Idling Respiration 
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Stochiometry  - Concentration -
Nl = St.Nl;  %%%  [gC/gN]
Ns = St.Ns;  %%%  [gC/gN]
Nr = St.Nr ; %%%  [gC/gN]
Nc= Ns; %%%  [gC/gN] Carbohydrate Reserve Carbon Nitrogen
Nf = St.Nf; %%%  [gC/gN]
Nh = St.Nh;  %%%  [gC/gN]
%%%
Phol = St.Phol;  %%%  [gC/gP]
Phos = St.Phos;  %%%  [gC/gP]
Phor = St.Phor ; %%%  [gC/gP]
Phoc= Phos; %%%  [gC/gP] Carbohydrate Reserve Carbon Phosophorus
Phof = St.Phof; %%%  [gC/gP]
Phoh = St.Phoh;  %%%  [gC/gP]
%%%
Kpotl = St.Kpotl;  %%%  [gC/gK]
Kpots = St.Kpots;  %%%  [gC/gK]
Kpotr = St.Kpotr ; %%%  [gC/gK]
Kpotc= Kpots; %%%  [gC/gK] Carbohydrate Reserve Carbon Potassium
Kpotf = St.Kpotf; %%%  [gC/gK]
Kpoth = St.Kpoth;  %%%  [gC/gK]
ftransL = St.ftransL;
ftransR = St.ftransR;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% No Negative Pool
B(B<0)=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sl specific leaf area of  biomass [m^2 / gC]
if mSl==0
    LAI = Sl*B(1); %% Leaf area index for green biomass
else
    LAI = Sl*((exp(mSl*B(1))-1)/mSl);
end
%%%%%%%%%%%%%% Maintenance and Growth Respiration
GPP = 1.0368*(An + Rdark); %% [gC / m^2 d]  Gross Primary Productivty  --> A
% gR growth respiration  [] -- [Rg/(GPP-Rm)]
% r respiration rate at 10° [gC/gN d ]
% Ns [gC/gN] Sapwood
% Nr  [gC/gN] Fine root
%%%%Ref--  Sitch 2003 Ivanov 2008 Ruimy 1996 Ryan 1991
gTam = exp(308.56*(1/56.02 - 1/(Tam+46.02)));
gTsm = exp(308.56*(1/56.02 - 1/(Tsm+46.02)));
Rms = fab*r*B(2)*gTam/Ns +  fbe*r*B(2)*gTsm/Ns; %%% [gC / m^2 d]
Rmr = rNc*r*B(3)*gTsm/Nr; %%% [gC / m^2 d]
if aSE == 2
    Rmc =  rNc*r*B(4)*gTsm/Nc; %%% [gC / m^2 d]
else
    Rmc =  fab*rNc*r*B(4)*gTam/Nc + fbe*rNc*r*B(4)*gTsm/Nc; %%% [gC / m^2 d]
end
Rm = Rms + Rmr + Rmc + 1.0368*Rdark; %%% [gC / m^2 d] Maintenance Respiration
%Rg = max(0,gR*GPP); %%%   Growth Respiration  [gC / m^2 d] only for GPP>0
Rg = max(0,gR*(GPP-Rm)); %%%   Growth Respiration  [gC / m^2 d] only for GPP>0
RA = Rg + Rm; %% Autotrphic Respiration  [gC / m^2 d]
NPP = GPP-RA; %% Net Primary Productivity [gC / m^2 d]  NPP = An - Rg -Rmr -Rms -Rmc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Preliminsary fractions 
%%%% ALLOCATION %%% Friedlingstein et al 1998
%%% Krinner et al., 2005
%%% fr allocation to root
%%% fs allocation to sapwood
%%% fl allocation to leaf
%%% fc allocation to carbohydrate reserve
%%% ff allocation to flower and fruit to reproduction
[fs1,fr1,fl1]= Allocation_Coefficients(TBio,LAI,Bfac_alloc,Se_bio,Tdp_bio,FNC,aSE,age_cr,dflo); 
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Maximum Growth %%%%%
if (PHE_S == 2)
    fl1 = fr1 + fs1 + fl1;  %%% Partial Allocation to Leaves
    fs1=0; fr1=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% PHE_S -->  DORMANT 1 - MAX GROWTH 2 - NORMAL GROWTH 3 - SENESCENCE 4 -
%%% aSE  %%% PHENOLOGY KIND -- 1 Seasonal Plant --  0 Evergreen  -- 2 Grass species
if (aSE == 1 || aSE == 2 ) && ((PHE_S == 4) ||  (PHE_S == 1)) %% Decidous  dormant or senescente
    %%%%%%%%%% Constrain Reserve
    if (B(4)< 0.67*B(2))  %%%  [2/3 of Sapwood for reserve Friend et al., 1997]
        fc = 1;
        fs = 0; fl = 0; fr = 0;  ff = 0;
    else
        fl = 0; ff = 0;
        if aSE == 2
            if (B(4)< 0.67*B(3)) %  [2/3 of Root for reserve in Grasses Species]
                fc = 1; fr = 0; fs = 0;
            else
                fr= 1; fs=0;  fc = 0;
            end
        else
            fr=0;  fs=1;  fc = 0;
        end
    end
    %%%
else
    %%%
    if ((aSE == 0) || (aSE == 3)) && ((PHE_S == 4) || (PHE_S == 1))
        if (aSE == 0)
            ff = 0;  C = 1/(1+eps_ac*(fl1+fr1));
        end
        if (aSE == 3)
            ff = ff_r;  C = 1/(1+eps_ac*(fl1+fr1));  
        end
    else
        ff = ff_r;
        if (PHE_S == 3) %% During normal growth
            C = 1/(1+eps_ac*(fl1+fr1));
        else
            C=1;
        end
    end
    %%%%%%%%%% Constrain Reserve
    if (B(4) >= 0.67*B(2)) && (aSE == 0 || aSE == 1 || aSE ==3) %%%  [2/3 of Sapwood for reserve Friend et al., 1997]
        C = 1;
    end
    if (B(4) >= 0.67*B(3)) && (aSE == 2)%%%  [2/3 of Root for reserve in Grasses)
        C = 1;
    end
    %%%%%%%%%%%%%%%%%%%%%
    fc = (1-C)*(1-ff);
    %%%%%%%%%%%%%%%%%%%%%%%
    fl = fl1*(1- ff)*C;
    fr = fr1*(1- ff)*C;
    fs = fs1*(1- ff)*C;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constrain Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if B(1) >= LtR*B(3) %%% Leaf-Root ratio
    if (aSE == 1) || (aSE == 0) || (aSE == 3) %% Woody Species
        if (fr + fs) == 0
            fls  = 0.5*fl;
        else
            fls = fl*(fs/(fr+fs));
        end
        fs = fs + fls;
        fr = fr + (fl-fls);
        fl=0;
    else
        fr = fr+ fl;
        fl = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Constrain sapwood - leaf area ---
%%%%%%%%%%%%%%%  Check !! %%%%%%%%%%%%
if  (fl+fr+fs+ff+fc > 1.001) || (fl+fr+fs+ff+fc < 0.999)
    disp('ERROR IN ALLOCATION')
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%
%%% Traslocation to carbohydrate to leaf in the growing season
if (PHE_S == 2) &&  (B(1) < LtR*B(3))
    Tr = min(B(4),Trr); %%%   [gC /m^2 d]
    Tr_r = Tr*B(1)/(B(3)+B(1)+0.001); %% Translocation to root  [gC /m^2 d]
    Tr_l = Tr - Tr_r; %% Translocation to leaf [gC /m^2 d]
else
    Tr = 0;
    Tr_r = 0;
    Tr_l = 0;
end
%%% Mf = Fruit and Flower Maturation
%%% Wm = Dead wood mortality
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Leaf Phenology
% dl  normal death rate of aboveground biomass Leaf Grass [1/d]
% dc cold death rate [1/d]
% dd draught death rate
% ds death rate of sapwood [1/d]
% dr death rate of fine root biomass [1/d]
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Leaf Shed whit Age
switch aSE
    case 0
        dla= AgeL/((age_cr)^2); %% [1/d] Mortality for normal leaf age
    case 1
        dla= min(0.99,(1/age_cr)*(AgeL/age_cr).^4); %% [1/d] Mortality for normal leaf age
    case 2
        dla= min(1/age_cr,AgeL/((age_cr)^2)); %% [1/d] Mortality for normal grass age
    case 3
        if NPP > 0
            dlaK=(NBLeaf)/B(1)*age_cr; %% [-]
        else
            dlaK=1;
        end
        %%%%
        dla= dlaK*AgeL/((age_cr)^2); %% [1/d] Mortality for normal leaf age
end
%%%%%%
%%% Leaf Mortality to Cold Stress  Linear [Cox 2001]
dc= (dc_C*(Tcold - Tam))*(Tam<Tcold); %% [1/d]
%%% Leaf Mortality to Drought  [Arora and Boer 2005]
dd = dd_max*(1-Bfac)^3;  %% [1/d]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dl = dla +dc +dd; %%% % [1/d] Leaf Mortality Senescence Cold Drought
if (aSE == 1) && (PHE_S == 1)
    dl = 1;  %% [1/d]
end
%%%%%%%%%%
dr = drn; %% [1/d] Fine root Turnover
ds = dsn; %%% [1/d]  Sapwood Conversion to Heartwood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rexmy=Rexmy; %% %%% Root Exudation and transfer to Mychorriza [gC / m^2 d]  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sll= dl*B(1); % Sll Mortality factor for leaves
Ss= ds*B(2); % Ss Converted factor for sapwood
Sr= dr*B(3); % Sr Mortality factor for fine roots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Standing Dead Biomass
%%% Montaldo et al 2004 ;
%Klf = [ 0.05 -0.15 ]
%%% Nouvellon et al 2000 ; Hanson et al., 1988 ;
%k1 = 0.025; %% [0.00002 - 0.0005]
%k2 = 0.025; %% [0.25 0.65]
%Klf = 0.25*(1 -exp(-k1*Ws) + 1-exp(-k2*Pr));  %% Litterfall Turnover [1/d]  %% [0.05 0.35]
if aSE == 2
    %%% Lazzarotto et al., 2009
    %%% Klf =0.012
    fT = 2.0^(0.1*(Tam-20));
    Klf= Klf*fT;
end
dld= min(0.99,(Klf)*(AgeDL*Klf).^4); %% [1/d] 
Slf= dld*B(7); % Litterfall factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Environemtnal Constraints Growth  GF  [gC /m2 day]
if OPT_EnvLimitGrowth == 1
    if NPP > GF ; %% [gC /m^2 d]
        f_red = (GF/NPP); %%% [-]
        Add_AR=(1-f_red)*NPP;% Additional Allocation to Reserve -- [gC /m^2 d]
        NPP=f_red*NPP;
    else
        Add_AR = 0;
    end
else
    Add_AR = 0;
end
%%%%%%%%%%%%%%%%% STOICHIOMETRIC Constraints Growth
if NPP > 0
    %%%% NITROGEN
    Ncons= fl*(NPP)/Nl+ ff*(NPP)/Nf + fc*(NPP)/Nc + fr*(NPP)/Nr +  fs*(NPP)/Ns + Tr_l/Nl + Tr_r/Nr + Ss/Nh ...
        - Sll*ftransL/Nl - Sr*ftransR/Nr - Tr./Nc  -Ss./Ns -Rexmy/Nc + Add_AR/Nc; %% [gN /m^2 d]
    %%%%
    if (Ncons) >  Nreserve/dtd
        f_red = (Nreserve/dtd)/Ncons; %%% [-]
    else
        f_red = 1;
    end
    AddRA=(1-f_red)*NPP;% Additional Respiration/Allocation [gC /m^2 d]
    NPP=f_red*NPP;
    %%%%%
    WResp = AddRA; %% [gC /m^2 d]
    %%%%%%
    %%%% PHOSPHORUS
    Pcons= fl*(NPP)/Phol+ ff*(NPP)/Phof + fc*(NPP)/Phoc + fr*(NPP)/Phor +  fs*(NPP)/Phos + Tr_l/Phol + Tr_r/Phor + Ss/Phoh ...
        - Sll*ftransL/Phol - Sr*ftransR/Phor - Tr./Phoc  -Ss./Phos -Rexmy/Phoc + Add_AR/Phoc ; %% [gP/m^2 d]
    %%%%
    if (Pcons) >  Preserve/dtd
        f_red = (Preserve/dtd)/Pcons; %%% [-]
    else
        f_red = 1;
    end
    AddRA=(1-f_red)*NPP;% Additional Respiration [gC /m^2 d]
    NPP=f_red*NPP;
    WResp = WResp + AddRA; %% [gC /m^2 d]
    %%%%%
    %%%% POTASSIUM
    Kcons= fl*(NPP)/Kpotl+ ff*(NPP)/Kpotf + fc*(NPP)/Kpotc + fr*(NPP)/Kpotr +  fs*(NPP)/Kpots + Tr_l/Kpotl + Tr_r/Kpotr - Tr./Kpotc ... 
         - Sll*ftransL/Kpotl - Sr*ftransR/Kpotr -Rexmy/Kpotc + Add_AR/Kpotc + Ss/Kpoth  -Ss./Kpots ; %% [gK/m^2 d]
    %%%%
    if (Kcons) >  Kreserve/dtd
        f_red = (Kreserve/dtd)/Kcons; %%% [-]
    else
        f_red = 1;
    end
    AddRA=(1-f_red)*NPP;% Additional Respiration [gC /m^2 d]
    NPP=f_red*NPP;
    WResp = WResp + AddRA; %% [gC /m^2 d]
    %%%%%
else
    WResp = 0; %% [gC /m^2 d]
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stop translocation if completely nutrient deprived 
if  Nreserve == 0 || Preserve ==0 || Kreserve == 0
Tr = 0; Tr_r = 0; Tr_l = 0;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NPP > 0
    dB(1)= fl*(NPP) - Sll + Tr_l;  %%% Bl Green aboveground -- Leaves / Grass
    dB(2)= fs*(NPP) - Ss; %%% Bs Living - Stem -Sapwood
    dB(3)= fr*(NPP) - Sr + Tr_r;  %% Br Living Root - Fine Root
    dB(4)= fc*(NPP) + Add_AR - Tr - Rexmy;  %% Bc Carobhydrate Reserve
    dB(5) = ff*(NPP)- Mf*B(5) ; %% Fruit and Flower
    dB(6) = Ss - Wm*B(6) ;%;  Heartwood
    dB(7) = Sll - Slf; %%Leaves - Grass -- Standing Dead
    dB(8)= WResp;
    %%%%%%%%%%%%%%%%%%%%%%%%%
else
    %%% dB [gC/m^2 d]
    if (fl*(GPP-Rg) <  1.0368*Rdark) && ((PHE_S == 2) ||  (PHE_S == 3))
        fl = 1 ;
        fs = 0; fr = 0; fc = 0; ff = 0;
        %%%%%%%%%
        Tr_l = 1.0368*Rdark - fl*(GPP-Rg);
        Tr_l = min(Tr_l,B(4));
        Tr = Tr_l ;
    end
    %if fr*(GPP-Rg) < Rmr && ((PHE_S == 2) ||  (PHE_S == 3))
    %    Tr_r = Rmr - fr*(GPP-Rg); 
    %    Tr_r = max(0,min(Tr_r,B(4)-Tr_l)); 
    %    Tr = Tr+Tr_r; 
    %end 
    %%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%
    dB(1)= fl*(GPP-Rg-WResp) - 1.0368*Rdark - Sll + Tr_l;  %%% Bl Green aboveground -- Leaves / Grass
    dB(2)= fs*(GPP-Rg-WResp) -Rms  -Ss ; %%% Bs Living - Stem -Sapwood
    dB(3)= fr*(GPP-Rg-WResp) -Rmr  -Sr + Tr_r;  %% Br Living Root - Fine Root
    dB(4)= fc*(GPP-Rg-WResp) -Rmc  -Tr -Rexmy ;  %% Bc Carobhydrate Reserve
    dB(5) = ff*(GPP-Rg-WResp)- Mf*B(5) ; %% Fruit and Flower
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dB(6) = Ss - Wm*B(6) ;%+ Rms +Rmc + Rmr;  Heartwood
    dB(7) = Sll - Slf; %%Leaves - Grass -- Standing Dead
    dB(8) = WResp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dB=dB';
end