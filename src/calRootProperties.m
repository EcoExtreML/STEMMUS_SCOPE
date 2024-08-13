function [RootProperties, soilDepth] = calRootProperties(SiteProperties, ParaPlant, numSoilLayer, soilThickness, RTB)
% This function is used to calculate root properties.
% Input:
%     SiteProperties: A structure contains site properties. In this function, vegetation type (igbpVegLong) is needed.
%     ParaPlant     : A structure contains plant parameters
%     numSoilLayer  : The number of soil layers
%     soilTickness  : soil thickness [cm]
%     RTB           : root to biomass [g m-2]. This parameter is defined in
%                     Constants.m with the value of 1000.
%     
% Output:
%     RootProperties: A structure contains root properties.

 
    %% ============= define plant parameters ==============
    B2C = ParaPlant.B2C; %[g C / g biomass]
    rootRadius = ParaPlant.rootRadius; %[m]
    rootDensity = ParaPlant.rootDensity; %[gDM / m^3]
    igbpVegLong = SiteProperties.landcoverClass;
    
    %% Jackson et al. (1996), it is refered to CLM5.0 document. 
    if strcmp(igbpVegLong(1:18), 'Permanent Wetlands')
        beta = 0.993; 
    elseif strcmp(igbpVegLong(1:19)', 'Evergreen Broadleaf') 
        beta = 0.993; 
    elseif strcmp(igbpVegLong(1:19)', 'Deciduous Broadleaf') 
        beta = 0.993; 
    elseif strcmp(igbpVegLong(1:13)', 'Mixed Forests') 
        beta = 0.993; 
    elseif strcmp(igbpVegLong(1:20)', 'Evergreen Needleleaf') 
        beta = 0.993; 
    elseif strcmp(igbpVegLong(1:9)', 'Croplands') 
        beta = 0.943; 
    elseif strcmp(igbpVegLong(1:15)', 'Open Shrublands')
        beta = 0.966; 
    elseif strcmp(igbpVegLong(1:17)', 'Closed Shrublands') 
        beta = 0.966; 
    elseif strcmp(igbpVegLong(1:8)', 'Savannas') 
        beta = 0.943; 
    elseif strcmp(igbpVegLong(1:14)', 'Woody Savannas') 
        beta = 0.943; 
    elseif strcmp(igbpVegLong(1:9)', 'Grassland') 
        beta = 0.943; 
    else 
        beta = 0.943; 
        warning('IGBP vegetation name unknown, "%s" is not recognized. Falling back to default value for beta', IGBP_veg_long)
    end

    %% ======= calculate the depth of each soil layer to land surface =====
    % change the unit from cm to m
    soilDepth=cumsum(soilThickness,1);  % [unit: cm]

    %% ============= calculate root distribution ==================
    for i=1:numSoilLayer
        if i==1
            rootFrac(i)=(1-beta.^(soilDepth(i)/2)); % root fraction in each soil layer
        else
            rootFrac(i)=beta.^(soilDepth(i-1)-(soilThickness(i-1)/2))-beta.^(soilDepth(i-1)+(soilThickness(i)/2));
        end
    end
    rootFrac = rootFrac';
    
    %% ================ root cross area ===========================
    rootCrossArea = pi .* rootRadius^2; % [m^2]
    
    %% =============== root length density ======================
    % RTB = 1000, gC/m2 or g biomass/ m2? I think the unit is gC/m2.
    Rltot = RTB/B2C/rootDensity/rootCrossArea; % root length index [m root / m^2 PFT]
    rootLengthDensity = (Rltot .* rootFrac) ./ (soilThickness./100);  % [m/m3]; 100 is scale factor from cm to m.
    
    %% ==================== root spacing =======================
    % root spacing is same with CLM5 based on eq.11.12 in CLM5 tech notes.
    rootSpac = sqrt(1./(pi.* rootLengthDensity));
    
    %% ================ output ===============
    RootProperties.frac = flipud(rootFrac);% [unitless]
    RootProperties.crossArea = rootCrossArea;   %[m2]
    RootProperties.spac = flipud(rootSpac);             % [m]
    RootProperties.lengthDensity = flipud(rootLengthDensity); %[m/m3]
    
end