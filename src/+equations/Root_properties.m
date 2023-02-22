%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Properties         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFERENCES
function [Rl] = Root_properties(Rl, rroot, frac, BR)
    %%% INPUTS
    % BR = 10:1:650; %% [gC /m^2 PFT]
    % rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius
    %%% OUTPUTS
    root_den = 250 * 1000; %% [gDM / m^3] Root density  Jackson et al., 1997
    R_C = 0.488; %% [gC/gDM] Ratio Carbon-Dry Matter in root   Jackson et al.,  1997
    Delta_Rltot = BR / R_C / root_den / (pi * (rroot^2)); %% %% root length index [m root / m^2 PFT]
    Delta_Rl = Delta_Rltot * frac;
    Rl = Rl + Delta_Rl;
end
