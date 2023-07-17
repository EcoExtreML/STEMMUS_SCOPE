function [SoilVariables] = calculateHydraulicConductivity(SoilVariables, VanGenuchten, InitialValues, KIT, L_f)
    % get model settings
    ModelSettings = io.getModelSettings();

    % load Constants
    Constants = io.define_constants();

    MU_W = InitialValues.MU_W;
    KL_h = SoilVariables.KL_h;
    KfL_h = SoilVariables.KfL_h;
    KfL_T = SoilVariables.KfL_T;

    Theta_LL = SoilVariables.Theta_LL;
    DTheta_LLh = SoilVariables.DTheta_LLh;
    Theta_II = SoilVariables.Theta_II;
    Theta_UU = SoilVariables.Theta_UU;
    DTheta_UUh = SoilVariables.DTheta_UUh;
    Se = SoilVariables.Se;

    % TODO move to settings
    SFCC = 1;
    % TODO issue not used
    % FILM = 1;   % indicator for film flow parameterization; =1, Zhang (2010); =2, Lebeau and Konrad (2010)

    function [sliced] = slice(structure, ix, iy)
        %{
            slice a structure.
        %}
        for fieldName = fieldnames(structure)'
            fieldSize = size(structure.(fieldName{1}));
            numDimensions = numel(fieldSize);
            if numDimensions == 1
                sliced.(fieldName{1}) = structure.(fieldName{1})(ix);
            elseif numDimensions == 2
                sliced.(fieldName{1}) = structure.(fieldName{1})(ix, iy);
            end
        end
    end

    for i = 1:ModelSettings.NL
        for j = 1:2 % ND
            i = i + j - 1;

            % slice
            SV = slice(SoilVariables, i, j);
            VG = slice(VanGenuchten, i, j);

            Gama_hh = conductivity.hydraulicConductivity.calculateGamma_hh(SV.hh);
            Theta_m = conductivity.hydraulicConductivity.calculateTheta_m(Gama_hh, VG);

            Theta_UU = conductivity.hydraulicConductivity.calculateTheta_UU(Theta_m, Gama_hh, SV, VG);
            Theta_II = conductivity.hydraulicConductivity.calculateTheta_II(SV.TT, SV.XCAP);
            Theta_LL = conductivity.hydraulicConductivity.calculateTheta_LL(Theta_UU, Theta_II, Theta_m, SV, VG);
            % TODO issue circular calculation
            Theta_II = (Theta_UU - Theta_LL) * Constants.RHOL / Constants.RHOI;  % ice water content

            DTheta_UUh = conductivity.hydraulicConductivity.calculate_DTheta_UUh(Theta_UU, Theta_m, Theta_LL, Theta_L, Gama_hh, SV, VG);
            DTheta_LLh = conductivity.hydraulicConductivity.calcuulate_DTheta_LLh(DTheta_UUh, Theta_m, Theta_UU, Theta_LL, Gama_hh, SV, VG);
            Se = conductivity.hydraulicConductivity.calculateSe(Theta_LL, Gama_hh, SV);

            if Theta_UU ~= 0
                Ratio_ice = Constants.RHOI * Theta_II / (Constants.RHOL * Theta_UU); % ice ratio
            else
                Ratio_ice = 0;
            end
            if KIT
                % TODO exact calculation of MU_W happens in CondL_Tdisp
                if SV.TT < -20
                    MU_W = 3.71e-2;
                elseif SV.TT > 150
                    MU_W = 1.81e-3;
                else
                    MU_W = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (SV.TT + 133.3)));
                end

                KL_h = calculateKL_h(MU_W, Se, VG.m);

                if Gama_hh ~= 1
                    KfL_h = KL_h * 10^(-1 * Imped(i) * Ratio_ice);  % hydraulic conductivity for freezing soil
                else
                    KfL_h = KL_h * 10^(-1 * Imped(i) * Ratio_ice);  % hydraulic conductivity for freezing soil
                end
                KfL_T = helpers.heaviside1(SV.TT_CRIT - (SV.TT + ModelSettings.T0)) * L_f * 1e4 / (Constants.g * (ModelSettings.T0));   % thermal consider for freezing soil
            else
                KL_h = 0;
                KfL_h = 0;
                KfL_T = 0;
            end
        end

    SoilVariables.KL_h(i, j) = KL_h;
    SoilVariables.KfL_h(i, j) = KfL_h;
    SoilVariables.KfL_T(i, j) = KfL_T;
    SoilVariables.Theta_LL(i, j) = Theta_LL;
    SoilVariables.DTheta_LLh(i, j) = DTheta_LLh;
    SoilVariables.Theta_II(i, j) = Theta_II;
    SoilVariables.Theta_UU(i, j) = Theta_UU;
    SoilVariables.DTheta_UUh(i, j) = DTheta_UUh;
    SoilVariables.Se(i, j) = Se;
    SoilVariables.Gama_hh(i) = Gama_hh;
    end
