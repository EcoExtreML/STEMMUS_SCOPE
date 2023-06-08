function [Rl, Ztot] = Initial_root_biomass(...
    RTB, DeltZ_R, rroot, ML, initialLandcoverClass ...
)
    root_den = 250 * 1000; %% [gDM / m^3] Root density  Jackson et al., 1997
    R_C = 0.488; %% [gC/gDM] Ratio Carbon-Dry Matter in root   Jackson et al.,  1997
    %% beta is a plant-dependent root distribution parameter adopted from
    %% Jackson et al. (1996), it is refered to CLM5.0 document.
    if startsWith(initialLandcoverClass, 'Permanent Wetlands')
        beta = 0.993;
    elseif startsWith(initialLandcoverClass, 'Evergreen Broadleaf')
        beta = 0.993;
    elseif startsWith(initialLandcoverClass, 'Deciduous Broadleaf')
        beta = 0.993;
    elseif startsWith(initialLandcoverClass, 'Mixed Forests')
        beta = 0.993;
    elseif startsWith(initialLandcoverClass, 'Evergreen Needleleaf')
        beta = 0.993;
    elseif startsWith(initialLandcoverClass, 'Croplands')
        beta = 0.943;
    elseif startsWith(initialLandcoverClass, 'Open Shrublands')
        beta = 0.966;
    elseif startsWith(initialLandcoverClass, 'Closed Shrublands')
        beta = 0.966;
    elseif startsWith(initialLandcoverClass, 'Savannas')
        beta = 0.943;
    elseif startsWith(initialLandcoverClass, 'Woody Savannas')
        beta = 0.943;
    elseif startsWith(initialLandcoverClass, 'Grassland')
        beta = 0.943;
    else
        beta = 0.943;
        warning('Landcover class name unknown, "%s" is not recognized. Falling back to default value for beta', initialLandcoverClass);
    end

    Rltot = RTB / R_C / root_den / (pi * (rroot^2)); %% %% root length index [m root / m^2 PFT]
    Ztot = cumsum(DeltZ_R', 1);

    for i = 1:ML
        if i == 1
            ri(i) = (1 - beta.^(Ztot(i) / 2));
        else
            ri(i) = beta.^(Ztot(i - 1) - (DeltZ_R(i - 1) / 2)) - beta.^(Ztot(i - 1) + (DeltZ_R(i) / 2));
        end
    end

    Rl = (ri .* Rltot ./ (DeltZ_R ./ 100))';
    Rl = flipud(Rl);
end
