function [SoilVariables] = calculateHydraulicConductivity(SoilVariables, VanGenuchten, InitialValues, KIT, L_f)
    % get model settings
    ModelSettings = io.getModelSettings();

    % load Constants
    Constants = io.define_constants();

    TT = SoilVariables.TT;
    MU_W = InitialValues.MU_W;
    KL_h = SoilVariables.KL_h;
    KfL_h = SoilVariables.KfL_h;
    KfL_T = SoilVariables.KfL_T;
    TT_CRIT = SoilVariables.TT_CRIT;

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
        for ND = 1:2
            i = i + ND - 1;

            % slice
            SV = slice(SoilVariables, i, ND);
            VG = slice(VanGenuchten, i, ND);

            Gama_hh(i) = conductivity.hydraulicConductivity.calculateGamma_hh(SV.hh);
            Theta_m(i) = conductivity.hydraulicConductivity.calculateTheta_m(Gama_hh(i), VG);

            Theta_UU(i, ND) = conductivity.hydraulicConductivity.calculateTheta_UU(Theta_m(i), Gama_hh(i), SV, VG);
            Theta_II(i, ND) = conductivity.hydraulicConductivity.calculateTheta_II(SV.TT, SV.XCAP);
            Theta_LL(i, ND) = conductivity.hydraulicConductivity.calculateTheta_LL(Theta_UU(i, ND), Theta_II(i, ND), Theta_m(i), SV, VG);
            % TODO issue circular calculation
            Theta_II(i, ND) = (Theta_UU(i, ND) - Theta_LL(i, ND)) * Constants.RHOL / Constants.RHOI;  % ice water content

            DTheta_UUh(i, ND) = conductivity.hydraulicConductivity.calculate_DTheta_UUh(Theta_UU(i, ND), Theta_m(i), Theta_LL(i, ND), Theta_L(i, ND), Gama_hh(i), SV, VG);
            DTheta_LLh(i, ND) = conductivity.hydraulicConductivity.calcuulate_DTheta_LLh(DTheta_UUh(i, ND), Theta_m(i), Theta_UU(i, ND), Theta_LL(i, ND), Gama_hh(i), SV, VG);
            Se(i, ND) = conductivity.hydraulicConductivity.calculateSe(Theta_LL(i, ND), Gama_hh(i), SV);

            if Theta_UU(i, ND) ~= 0
                Ratio_ice(i, ND) = Constants.RHOI * Theta_II(i, ND) / (Constants.RHOL * Theta_UU(i, ND)); % ice ratio
            else
                Ratio_ice(i, ND) = 0;
            end
            if KIT
                if TT(i) < -20
                    MU_W(i, ND) = 3.71e-2;
                elseif TT(i) > 150
                    MU_W(i, ND) = 1.81e-3;
                else
                    MU_W(i, ND) = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (TT(i) + 133.3)));
                end

                KL_h(i, ND) = calculateKL_h(MU_W(i, ND), Se(i, ND), m(i));

                if Gama_hh(i) ~= 1
                    KfL_h(i, ND) = KL_h(i, ND) * 10^(-1 * Imped(i) * Ratio_ice(i, ND));  % hydraulic conductivity for freezing soil
                else
                    KfL_h(i, ND) = KL_h(i, ND) * 10^(-1 * Imped(i) * Ratio_ice(i, ND));  % hydraulic conductivity for freezing soil
                end
                KfL_T(i, ND) = helpers.heaviside1(TT_CRIT(i) - (TT(i) + ModelSettings.T0)) * L_f * 1e4 / (Constants.g * (ModelSettings.T0));   % thermal consider for freezing soil
            else
                KL_h(i, ND) = 0;
                KfL_h(i, ND) = 0;
                KfL_T(i, ND) = 0;
            end
        end
    end
