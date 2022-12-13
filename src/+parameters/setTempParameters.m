function [ScopeParameters] = setTempParameters(ScopeParameters, siteName, vegetationType)
    %{
        %Set temperature parameters for different vegetation type.
    %}
    siteName=cellstr(siteName);
    if strcmp(vegetationType(1:18)', 'Permanent Wetlands') 
        ScopeParameters.Tparam = [0.2 0.3 288 313 328]; % These are five parameters specifying the temperature response.
        ScopeParameters.Vcmo = [120]; % Vcmax, maximum carboxylation capacity (at optimum temperature)
        ScopeParameters.m = [9]; % Ball-Berry stomatal conductance parameter
        ScopeParameters.Type = [0]; % Photochemical pathway: 0=C3, 1=C4
        ScopeParameters.leafwidth = [0.05]; % leaf width
    elseif strcmp(vegetationType(1:19)', 'Evergreen Broadleaf')  
        ScopeParameters.Tparam = [0.2 0.3 283 311 328];
        ScopeParameters.Vcmo = [80];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];
        ScopeParameters.leafwidth = [0.05];
    elseif strcmp(vegetationType(1:19)', 'Deciduous Broadleaf') 
        ScopeParameters.Tparam = [0.2 0.3 283 311 328];
        ScopeParameters.Vcmo = [80];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];  
        ScopeParameters.leafwidth = [0.05];
    elseif strcmp(vegetationType(1:13)', 'Mixed Forests') 
        ScopeParameters.Tparam = [0.2 0.3 281 307 328];
        ScopeParameters.Vcmo = [80];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0]; 
        ScopeParameters.leafwidth = [0.04];
    elseif strcmp(vegetationType(1:20)', 'Evergreen Needleleaf') 
        ScopeParameters.Tparam = [0.2 0.3 278 303 328];
        ScopeParameters.Vcmo = [80];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];   
        ScopeParameters.leafwidth = [0.01];
    elseif strcmp(vegetationType(1:9)', 'Croplands')    
        if isequal(siteName,{'ES-ES2'})||isequal(siteName,{'FR-Gri'})||isequal(siteName,{'US-ARM'})||isequal(siteName,{'US-Ne1'})
            ScopeParameters.Tparam = [0.2 0.3 278 303 328];
            ScopeParameters.Vcmo = [50];
            ScopeParameters.m = [4];
            ScopeParameters.Type = [1]; 
            ScopeParameters.Rdparam = [0.025]; % Respiration = Rdparam*Vcmcax
            ScopeParameters.leafwidth = [0.03];
        else 
            ScopeParameters.Tparam = [0.2 0.3 278 303 328];
            ScopeParameters.Vcmo = [120];
            ScopeParameters.m = [9];
            ScopeParameters.Type = [0]; 
            ScopeParameters.leafwidth = [0.03];    
        end
    elseif strcmp(vegetationType(1:15)', 'Open Shrublands')
        ScopeParameters.Tparam = [0.2 0.3 288 313 328];
        ScopeParameters.Vcmo = [120];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];  
        ScopeParameters.leafwidth = [0.05];
    elseif strcmp(vegetationType(1:17)', 'Closed Shrublands') 
        ScopeParameters.Tparam = [0.2 0.3 288 313 328];
        ScopeParameters.Vcmo = [80];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];
        ScopeParameters.leafwidth = [0.05];
    elseif strcmp(vegetationType(1:8)', 'Savannas')  
        ScopeParameters.Tparam = [0.2 0.3 278 313 328];
        ScopeParameters.Vcmo = [120];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];
        ScopeParameters.leafwidth = [0.05];
    elseif strcmp(vegetationType(1:14)', 'Woody Savannas')
        ScopeParameters.Tparam = [0.2 0.3 278 313 328];
        ScopeParameters.Vcmo = [120];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];
        ScopeParameters.leafwidth = [0.03];
    elseif strcmp(vegetationType(1:9)', 'Grassland')  
        ScopeParameters.Tparam = [0.2 0.3 288 303 328];
        if isequal(siteName,{'AR-SLu'})||isequal(siteName,{'AU-Ync'})||isequal(siteName,{'CH-Oe1'})||isequal(siteName,{'DK-Lva'})||isequal(siteName,{'US-AR1'})||isequal(siteName,{'US-AR2'})||isequal(siteName,{'US-Aud'})||isequal(siteName,{'US-SRG'})
            ScopeParameters.Vcmo = [120];
            ScopeParameters.m = [4];
            ScopeParameters.Type = [1];
            ScopeParameters.Rdparam = [0.025]; 
        else
            ScopeParameters.Vcmo = [120];
            ScopeParameters.m = [9];
            ScopeParameters.Type = [0];
        end
        ScopeParameters.leafwidth = [0.02];
    else
        ScopeParameters.Tparam = [0.2 0.3 288 313 328];
        ScopeParameters.Vcmo = [80];
        ScopeParameters.m = [9];
        ScopeParameters.Type = [0];
        ScopeParameters.leafwidth = [0.05];
        warning('IGBP vegetation name unknown, "%s" is not recognized. ', vegetationType)
    end
end