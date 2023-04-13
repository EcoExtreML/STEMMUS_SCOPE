 function [ScopeParameters] = setTempParameters(ScopeParameters, siteName, vegetationType)
    %{
        %Set temperature parameters for different vegetation type.
    %}
    for TimeDur = 1: size(vegetationType,2)
    siteName=cellstr(siteName);
    vegetationTypesub=vegetationType(:,TimeDur);
    if strcmp(vegetationTypesub(1:18)', 'Permanent Wetlands') 
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 288 313 328]; % These are five parameters specifying the temperature response.
        ScopeParameters.Vcmo1 (TimeDur,:) = [120]; % Vcmax, maximum carboxylation capacity (at optimum temperature)
        ScopeParameters.m1 (TimeDur,:) = [9]; % Ball-Berry stomatal conductance parameter
        ScopeParameters.Type1 (TimeDur,:) = [0]; % Photochemical pathway: 0=C3, 1=C4
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05]; % leaf width
    elseif strcmp(vegetationTypesub(1:19)', 'Evergreen Broadleaf')  
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 283 311 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [80];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05];
    elseif strcmp(vegetationTypesub(1:19)', 'Deciduous Broadleaf') 
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 283 311 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [80];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];
        ScopeParameters.Rdparam1(TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05];
    elseif strcmp(vegetationTypesub(1:13)', 'Mixed Forests') 
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 281 307 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [80];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0]; 
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.04];
    elseif strcmp(vegetationTypesub(1:20)', 'Evergreen Needleleaf') 
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 278 303 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [80];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0]; 
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.01];
    elseif strcmp(vegetationTypesub(1:9)', 'Croplands')    
        if isequal(siteName,{'ES-ES2'})||isequal(siteName,{'FR-Gri'})||isequal(siteName,{'US-ARM'})||isequal(siteName,{'US-Ne1'})
            ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 278 303 328];
            ScopeParameters.Vcmo1 (TimeDur,:) = [50];
            ScopeParameters.m1 (TimeDur,:) = [4];
            ScopeParameters.Type1 (TimeDur,:) = [1]; 
            ScopeParameters.Rdparam1 (TimeDur,:) = [0.025]; % Respiration = Rdparam*Vcmcax
            ScopeParameters.leafwidth1 (TimeDur,:) = [0.03];
        else 
            ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 278 303 328];
            ScopeParameters.Vcmo1 (TimeDur,:) = [120];
            ScopeParameters.m1 (TimeDur,:) = [9];
            ScopeParameters.Type1 (TimeDur,:) = [0]; 
            ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
            ScopeParameters.leafwidth1 (TimeDur,:) = [0.03];    
        end
    elseif strcmp(vegetationTypesub(1:15)', 'Open Shrublands')
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 288 313 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [120];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];  
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05];
    elseif strcmp(vegetationTypesub(1:17)', 'Closed Shrublands') 
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 288 313 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [80];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05];
    elseif strcmp(vegetationTypesub(1:8)', 'Savannas')  
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 278 313 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [120];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05];
    elseif strcmp(vegetationTypesub(1:14)', 'Woody Savannas')
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 278 313 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [120];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.03];
    elseif strcmp(vegetationTypesub(1:9)', 'Grassland')  
        ScopeParameters.Tparam1 (TimeDur,:)  = [0.2 0.3 288 303 328];
        if isequal(siteName,{'AR-SLu'})||isequal(siteName,{'AU-Ync'})||isequal(siteName,{'CH-Oe1'})||isequal(siteName,{'DK-Lva'})||isequal(siteName,{'US-AR1'})||isequal(siteName,{'US-AR2'})||isequal(siteName,{'US-Aud'})||isequal(siteName,{'US-SRG'})
            ScopeParameters.Vcmo1 (TimeDur,:)  = [120];
            ScopeParameters.m1 (TimeDur,:)  = [4];
            ScopeParameters.Type1 (TimeDur,:)  = [1];
            ScopeParameters.Rdparam1 (TimeDur,:)  = [0.025]; 
        else
            ScopeParameters.Vcmo1 (TimeDur,:)  = [120];
            ScopeParameters.m1 (TimeDur,:)  = [9];
            ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015]; 
            ScopeParameters.Type1 (TimeDur,:)  = [0];
        end
        ScopeParameters.leafwidth1 (TimeDur,:)  = [0.02];
    else
        ScopeParameters.Tparam1 (TimeDur,:) = [0.2 0.3 288 313 328];
        ScopeParameters.Vcmo1 (TimeDur,:) = [80];
        ScopeParameters.m1 (TimeDur,:) = [9];
        ScopeParameters.Type1 (TimeDur,:) = [0];
        ScopeParameters.Rdparam1 (TimeDur,:)  = [0.015];
        ScopeParameters.leafwidth1 (TimeDur,:) = [0.05];
        warning('IGBP vegetation name unknown, "%s" is not recognized. ', vegetationType)
    end
    end
end