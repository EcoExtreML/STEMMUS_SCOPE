%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Properties         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFERENCES
%{
    This function is used to calculate the dynamic growth of root
    This part can refer to Wang et al. (2021) "Intergrated modelling of photosynthesis and transfer of energy, mass, and momentum in the SPAC system"
%}

function [Rl] = Root_properties(Rl, Ac, rroot, frac, bbx, KT, DeltZ, sfactor, LAI_msr)
%     %%% INPUTS
%     global DeltZ sfactor LAI_msr

    fr = calculateRootfraction(KT);

    DeltZ0 = DeltZ' / 100;
    BR = Ac * fr * 1800 * 12 / 1000000;
    root_den = 250 * 1000; %% [gDM / m^3] Root density  Jackson et al., 1997
    R_C = 0.488; %% [gC/gDM] Ratio Carbon-Dry Matter in root   Jackson et al.,  1997
    nn = numel(Rl);
    
    % This is used to simulate the root growth
    if (~isnan(Ac)) || (Ac > 0)
        Rl = Rl .* DeltZ0;
        Delta_Rltot = BR / R_C / root_den / (pi * (rroot^2)); %% %% root length index [m root / m^2 PFT]
        if ~isnan(frac)
            frac = frac / sum(sum(frac));
        else
            frac = Rl ./ sum(sum(Rl));
        end
        Delta_Rl = frac .* bbx * Delta_Rltot;
        Rl = Rl + Delta_Rl;
        Rl = Rl ./ DeltZ0;
    end

end

function fr = calculateRootfraction(KT)
    % this function is used to calculate the root fraction
    if KT < 2880 %2880 means the time step when the root stops growing
        fr = 0.3 * 3 * exp(-0.15 * LAI_msr(KT)) / (exp(-0.15 * LAI_msr(KT)) + 2 * sfactor);
        if fr < 0.15
            fr = 0.15;
        end
    else
        fr = 0.001;
    end
end
