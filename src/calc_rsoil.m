function [PSIs, rsss, rrr, rxx, psiSoilTemp, Ksoil] = calc_rsoil(Rl, ModelSettings, SoilVariables, VanGenuchten, bbx, GroundwaterSettings)
    % load Constants
    Constants = io.define_constants();

    SMC = SoilVariables.Theta_LL(1:end - 1, 2);
    Se  = (SMC - VanGenuchten.Theta_r') ./ (VanGenuchten.Theta_s' - VanGenuchten.Theta_r');
    if any(Se<0)
        Se(Se<0)=0;
    end

    Ksoil = SoilVariables.Ks' .* Se.^Constants.l .* (1 - (1 - Se.^(1 ./ VanGenuchten.m')).^(VanGenuchten.m')).^2;

    if ~GroundwaterSettings.GroundwaterCoupling % no Groundwater coupling
        psiSoilTemp = -((Se.^(-1 ./ VanGenuchten.m') - 1).^(1 ./ VanGenuchten.n')) ./ (VanGenuchten.Alpha * 100)';
        psiSoilTemp = max(psiSoilTemp, -5e3);
        PSIs = psiSoilTemp.* bbx;
    else % Groundwater coupling is activated, added by Mostafa (see https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/231)
        % Change PSIs with SoilVariables.hh to correct hydraulic head (matric potential + gravity) of the saturated layers
        for i = 1:ModelSettings.NL
            hh_lay(i) = mean([SoilVariables.hh(i), SoilVariables.hh(i + 1)]);
        end
        hh_lay = transpose(hh_lay);
        PSIs = hh_lay / 100 .* bbx; % unit conversion from cm to m (needed in the ebal calculations)
    end

    rsss = 1 ./ Ksoil ./ Rl ./ ModelSettings.DeltZ' / 2 / pi .* log((pi * Rl).^(-0.5) / (0.5 * 1e-3)) * 100 .* bbx;
    rxx  = 1 * 1e10 * ModelSettings.DeltZ' / 0.5 / 0.22 ./ Rl / 100 .* bbx; % Delta_z*j is the depth of the layer
    rrr  = 4 * 1e11 * (VanGenuchten.Theta_s' ./ SMC) ./ Rl ./ (ModelSettings.DeltZ' / 100) .* bbx;
