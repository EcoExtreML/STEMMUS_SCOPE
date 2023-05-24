%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Depth         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFERENCES

function [bbx] = Max_Rootdepth(bbx, NL, KT, TT, DeltZ, Tot_Depth)

%{
The function identify if there is root in certain layer, bbx=0 indicates no
roots while bbx=1 indicates roots existing
%}
    %%% INPUTS
    % DeltZ: gaps between the upper and lower layers
    % Tot_Depth: total depth of the soil column (500 cm in current version)
    % R_depth: Maximum rooting depth [cm]
    
    %%% OUTPUTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root existence checking %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    R_depth = 350; % User-defined for different PFTs: maximum rooting depth [cm]
    Elmn_Lnth = 0; %Rooting depth of each layer
    for ML = 1:NL
        Elmn_Lnth = Elmn_Lnth + DeltZ(ML);
        if Elmn_Lnth < Tot_Depth - R_depth %
            bbx(ML) = 0; % bbx = indicate if there is root exist in this layer    
        elseif Elmn_Lnth >= Tot_Depth - R_depth && Elmn_Lnth <= Tot_Depth - 5 % 5 is the depths of shallow roots (user-defined)
            bbx(ML) = 1;
        else
            bbx(ML) = 0;
        end
    end
end
