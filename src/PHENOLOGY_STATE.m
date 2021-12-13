%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction  PHENOLOGY_STATE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[PHE_S,dflo,AgeL,AgeDL]= PHENOLOGY_STATE(NLeaf,AgeLtm1,dtd,...
    LAIdead,NLeafdead,AgeDLtm1,...
    PHE_Stm1,LAI,aSE,age_cr,jDay,Tsmm,Bfac,NPPm,PAR_Im,L_day,Bfac_lo,Bfac_ls,Tlo,Tls,mjDay,LDay_min,LDay_cr,dflotm1,dmg,PAR_th,LAI_min,jDay_dist)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% INPUT
%%% NLeaf [] New Leaf [LAI]
%%% LAI [] Leaf Area Index
%%% AgeLtm1 [day] Age(t-1)
%%% dtd daily time step
%%% PHE_Stm1  [#] Phenology State(t-1)
%%%%% DORMANT 1 - MAX GROWTH 2 - NORMAL GROWTH 3 - SENESCENCE 4
%%%% Tsmm last 30 days  mean Soil Temperature
%%%% Omm last 7 day mean Soil Moisture
%%%% NPPm last 7 days mean NPP
%%% L_day length of the day [h]
%%% Bfac_lo [0-1] Critical Value Relative Moisture Leaf Onset
%%% Bfac_ls [0-1] Critical Value Relative Moisture Leaf shed
%%% Tlo [°C] Critical Temperature Value Leaf Onset
%%% Tls [°C] Critical Temperature Value Leaf Shed
%%% dmg [day] Length Period Days of maximum Growth
%%% LDay_cr length of the day  critical for senescence passage [h]
%%% Minimum LAI to pass in Dormant Phenology
%%% aSE  %%% PHENOLOGY KIND
%%% -- 1 Seasonal Plant --  0 Evergreen  -- 2 Grass species -- 3 Crops
%%% mjDay maximum julian day
%%%%%% OUTPUT
%%% dflo [day] from Leaf onset
%%% AgeL [day] Average Age of Leaf
%%% PHE_S [#] Phenology State
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (aSE == 0) || (aSE == 1) || (aSE == 2)
    PAR_th = -Inf;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bfac = %% Moisture Stress
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ALL THE CASES Decidous - Grass -  Crop - Evergreen %%%%%%%
%%%%% DORMANT 1 - MAX GROWTH 2 - NORMAL GROWTH 3 - SENESCENCE 4
switch PHE_Stm1
    case 1
        if mjDay > 0
            if (Tsmm >= Tlo) && (Bfac >= Bfac_lo) && (jDay <= mjDay) && (L_day >= LDay_min ) && (PAR_Im>PAR_th)   %% Criteria Leaf onset
                PHE_S = 2;
                dflo = 1;
            else
                PHE_S = 1;
                if (aSE == 3)
                    dflo = dflotm1 - 365/(365-age_cr); dflo(dflo<0)=0; 
                else
                    dflo  = 0;
                end
            end
        else
            if (Tsmm >= Tlo) && (Bfac >= Bfac_lo) && (jDay >= -mjDay) && (L_day >= LDay_min ) && (PAR_Im>PAR_th) %% Criteria Leaf onset
                PHE_S = 2;
                dflo = 1;
            else
                PHE_S = 1;
                if (aSE == 3)
                    dflo = dflotm1 - 365/(365-age_cr); dflo(dflo<0)=0; 
                else
                    dflo  = 0;
                end
            end
        end
    case 2
        dflo = dflotm1 +1;
        if dflo <= dmg
            PHE_S= 2;
        else
            PHE_S= 3;
        end
        if (LAI <= LAI_min)  &&  isempty(intersect(jDay,jDay_dist)) && (dflo>=5)
            PHE_S=1;
        end
    case 3
        dflo = dflotm1 + 1;
        if (L_day <= LDay_cr ) %% || (Tsmm < Tls) || (Bfac < Bfac_ls) %% || (NPPm < 0) %% Criteria Leaf senescense begin
            PHE_S = 4;
        else
            PHE_S = 3;
        end
        if (aSE == 3) &&  (dflo >= age_cr) %%%%  (AgeLtm1 >= age_cr)   (PAR_Im<-PAR_th)
            PHE_S = 4;
        end
        if (LAI <= LAI_min)  &&  isempty(intersect(jDay,jDay_dist)) %%
            PHE_S=1;
        end
    case 4
        dflo = dflotm1 + 1;
        if LAI <= LAI_min || (aSE == 0) || (aSE == 2) || (aSE == 3)
            PHE_S = 1;
        else
            PHE_S = 4;
        end
end
%%%%%%%% LEAF AGE UPDATE %%%%%%%%%%%%%%%%
if LAI > LAI_min
    AgeL = ((LAI-NLeaf)*(AgeLtm1+dtd) + NLeaf*(0+dtd))/(LAI);
else
    AgeL = 0;
end
if LAIdead > LAI_min
    AgeDL = ((LAIdead-NLeafdead)*(AgeDLtm1+dtd) + NLeafdead*(0+dtd))/(LAIdead);
else
    AgeDL = 0;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%
