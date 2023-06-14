function [ScopeParameters] = setTempParameters(ScopeParameters, siteName, landcoverClass)
    %{
        %Determine temperature parameters for the different landcover types of this location.
    %}
    siteName = cellstr(siteName);
    % where landcoverClass is an array like {"forest", "forest", "forest", "shrubland", ...}
    landcovers = unique(landcoverClass, 'stable');
    for landcoverIndex = 1:length(landcovers)
        [Vcmo, Tparam, m, Type, Rdparam, leafwidth] = landcover_variables(landcovers(landcoverIndex), siteName);
        % The lc... parameters are intermediate values. The timeseries are generated in
        #   io.loadTimeSeries.m.
        ScopeParameters.lcVcmo(landcoverIndex, 1) = Vcmo;
        ScopeParameters.lcTparam(landcoverIndex, :) = Tparam;
        ScopeParameters.lcm(landcoverIndex, 1) = m;
        ScopeParameters.lcType(landcoverIndex, 1) = Type;
        ScopeParameters.lcRdparam(landcoverIndex, 1) = Rdparam;
        ScopeParameters.lcleafwidth(landcoverIndex, 1) = leafwidth;
    end
end

%% lookup table for Vcmo, Tparam, m, Type, Rdparam, and leafwidth

function [Vcmo, Tparam, m, Type, Rdparam, leafwidth] = landcover_variables(landCoverType, siteName)
    Rdparam = [0.015]; % NOTE: Rdparam IS MISSING FOR MOST DEFINTIONS:
    if startsWith(landCoverType, 'Permanent Wetlands')
        Tparam = [0.2 0.3 288 313 328]; % These are five parameters specifying the temperature response.
        Vcmo = [120]; % Vcmax, maximum carboxylation capacity (at optimum temperature)
        m = [9]; % Ball-Berry stomatal conductance parameter
        Type = [0]; % Photochemical pathway: 0=C3, 1=C4
        leafwidth = [0.05]; % leaf width
    elseif startsWith(landCoverType, 'Evergreen Broadleaf')
        Tparam = [0.2 0.3 283 311 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif startsWith(landCoverType, 'Deciduous Broadleaf')
        Tparam = [0.2 0.3 283 311 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif startsWith(landCoverType, 'Mixed Forests')
        Tparam = [0.2 0.3 281 307 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.04];
    elseif startsWith(landCoverType, 'Evergreen Needleleaf')
        Tparam = [0.2 0.3 278 303 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.01];
    elseif startsWith(landCoverType, 'Croplands')
        if isequal(siteName, {'ES-ES2'}) || isequal(siteName, {'FR-Gri'}) || isequal(siteName, {'US-ARM'}) || isequal(siteName, {'US-Ne1'})
            Tparam = [0.2 0.3 278 303 328];
            Vcmo = [50];
            m = [4];
            Type = [1];
            Rdparam = [0.025]; % Respiration = Rdparam*Vcmcax
            leafwidth = [0.03];
        else
            Tparam = [0.2 0.3 278 303 328];
            Vcmo = [120];
            m = [9];
            Type = [0];
            leafwidth = [0.03];
        end
    elseif startsWith(landCoverType, 'Open Shrublands')
        Tparam = [0.2 0.3 288 313 328];
        Vcmo = [120];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif startsWith(landCoverType, 'Closed Shrublands')
        Tparam = [0.2 0.3 288 313 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif startsWith(landCoverType, 'Savannas')
        Tparam = [0.2 0.3 278 313 328];
        Vcmo = [120];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif startsWith(landCoverType, 'Woody Savannas')
        Tparam = [0.2 0.3 278 313 328];
        Vcmo = [120];
        m = [9];
        Type = [0];
        leafwidth = [0.03];
    elseif startsWith(landCoverType, 'Grassland')
        Tparam = [0.2 0.3 288 303 328];
        if isequal(siteName, {'AR-SLu'}) || isequal(siteName, {'AU-Ync'}) || isequal(siteName, {'CH-Oe1'}) || isequal(siteName, {'DK-Lva'}) || isequal(siteName, {'US-AR1'}) || isequal(siteName, {'US-AR2'}) || isequal(siteName, {'US-Aud'}) || isequal(siteName, {'US-SRG'})
            Vcmo = [120];
            m = [4];
            Type = [1];
            Rdparam = [0.025];
        else
            Vcmo = [120];
            m = [9];
            Type = [0];
        end
        leafwidth = [0.02];
    else
        Tparam = [0.2 0.3 288 313 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
        warning('landCover name unknown, "%s" is not recognized. ', landCoverType);
    end
end
