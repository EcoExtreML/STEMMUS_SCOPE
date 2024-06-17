function [bbx] = Max_Rootdepth(bbx)

%{
The function identify if there is root in certain layer, bbx=0 indicates no
roots while bbx=1 indicates roots existing
%}

    % get model settings
    ModelSettings = io.getModelSettings();

    % BR = 10:1:650; %% [gC /m^2 PFT]
    % rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius

    R_depth = ModelSettings.R_depth; % User-defined for different PFTs: maximum rooting depth [cm]
    Tot_Depth = ModelSettings.Tot_Depth;
    DeltZ = ModelSettings.DeltZ;
    Elmn_Lnth = 0; % Rooting depth of each layer
    for ML = 1:ModelSettings.NL
        Elmn_Lnth = Elmn_Lnth + DeltZ(ML);
        if Elmn_Lnth < Tot_Depth - R_depth
            bbx(ML) = 0; % bbx = indicate if there is root exist in this layer
        elseif Elmn_Lnth >= Tot_Depth - R_depth && Elmn_Lnth <= Tot_Depth - 5; % 5 is the depths of shallow roots (user-defined)

            bbx(ML) = 1;
        else
            bbx(ML) = 0;
        end
    end
end
