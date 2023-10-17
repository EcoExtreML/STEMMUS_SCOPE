%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Depth         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFERENCES
function [bbx] = Max_Rootdepth(bbx)

    % get model settings
    ModelSettings = io.getModelSettings();

    % BR = 10:1:650; %% [gC /m^2 PFT]
    % rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius
    %%% OUTPUTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root lenth distribution %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    R_depth = ModelSettings.R_depth;
    Tot_Depth = ModelSettings.Tot_Depth;
    DeltZ = ModelSettings.DeltZ;
    Elmn_Lnth = 0;
    for ML = 1:ModelSettings.NL
        Elmn_Lnth = Elmn_Lnth + DeltZ(ML);
        if Elmn_Lnth < Tot_Depth - R_depth
            bbx(ML) = 0;
        elseif Elmn_Lnth >= Tot_Depth - R_depth && Elmn_Lnth <= Tot_Depth - 5
            bbx(ML) = 1;
        else
            bbx(ML) = 0;
        end
    end
end
