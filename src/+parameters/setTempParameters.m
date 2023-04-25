function [ScopeParameters] = setTempParameters(ScopeParameters, siteName, landcoverClass)
    %{
        %Set temperature parameters for different landcover type.
    %}
    siteName = cellstr(siteName);
    landcovers = unique(landcoverClass) % where landcoverClass is an array like ["forest", "forest", "forest", "shrubland", ...]
    for ii=(1:length(landcovers)
        Vcmo, Tparam, m, Type, Rdparam, leafwidth = landcover_variables(landcovers(ii));
        ScopeParameters.lcVcmo(ii) = Vcmo;
        ScopeParameters.lcTparam(ii) = Tparam;
        ScopeParameters.lcm(ii) = m;
        ScopeParameters.lcType(ii) = Type;
        ScopeParameters.lcRdparam(ii) = Rdparam;
        ScopeParameters.lcleafwidth(ii) = leafwidth;
    end
    
end

%% lookup table for Vcmo, Tparam, m, Type, Rdparam, and leafwidth

function [Vcmo, Tparam, m, Type, Rdparam, leafwidth] = landcover_variables(landCoverType)
    if strcmp(landCoverType(1:18)', 'Permanent Wetlands')
        Tparam = [0.2 0.3 288 313 328]; % These are five parameters specifying the temperature response.
        Vcmo = [120]; % Vcmax, maximum carboxylation capacity (at optimum temperature)
        m = [9]; % Ball-Berry stomatal conductance parameter
        Type = [0]; % Photochemical pathway: 0=C3, 1=C4
        leafwidth = [0.05]; % leaf width
    elseif strcmp(landCoverType(1:19)', 'Evergreen Broadleaf')
        Tparam = [0.2 0.3 283 311 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif strcmp(landCoverType(1:19)', 'Deciduous Broadleaf')
        Tparam = [0.2 0.3 283 311 328];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif strcmp(landCoverType(1:13)', 'Mixed Forests')
        Tparam = [0.2 0.3 281 307 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.04];
    elseif strcmp(landCoverType(1:20)', 'Evergreen Needleleaf')
        Tparam = [0.2 0.3 278 303 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.01];
    elseif strcmp(landCoverType(1:9)', 'Croplands')
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
    elseif strcmp(landCoverType(1:15)', 'Open Shrublands')
        Tparam = [0.2 0.3 288 313 328];
        Vcmo = [120];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif strcmp(landCoverType(1:17)', 'Closed Shrublands')
        Tparam = [0.2 0.3 288 313 328];
        Vcmo = [80];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif strcmp(landCoverType(1:8)', 'Savannas')
        Tparam = [0.2 0.3 278 313 328];
        Vcmo = [120];
        m = [9];
        Type = [0];
        leafwidth = [0.05];
    elseif strcmp(landCoverType(1:14)', 'Woody Savannas')
        Tparam = [0.2 0.3 278 313 328];
        Vcmo = [120];
        m = [9];
        Type = [0];
        leafwidth = [0.03];
    elseif strcmp(landCoverType(1:9)', 'Grassland')
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
