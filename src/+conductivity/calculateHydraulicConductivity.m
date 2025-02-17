function SoilVariables = calculateHydraulicConductivity(SoilVariables, VanGenuchten, KIT, L_f, ModelSettings)
    %{
        This is to calculate the hydraulic conductivity of soil, based on
        hydraulic conductivity models (like VG and others).
        van Genuchten, M. T. (1980), A closed-form equation for predicting the
        hydraulic conductivity of unsaturated soils, Soil Sci. Soc. Am. J., 44,
        892-898,
        Zeng, Y., Su, Z., Wan, L. and Wen, J.: Numerical analysis of
        air-water-heat flow in unsaturated soil: Is it necessary to consider
        airflow in land surface models?, J. Geophys. Res. Atmos., 116(D20),
        20107, doi:10.1029/2011JD015835, 2011.
    %}

    % load Constants
    Constants = io.define_constants();

    function [sliced] = sliceVector(structure, lengthX, ix)
        %{
            slice fields of a structure if they are vectors.
        %}

        for fieldName = fieldnames(structure)'
            fieldData = structure.(fieldName{1});
            if isvector(fieldData) && length(fieldData) >= (lengthX)
                sliced.(fieldName{1}) = fieldData(ix);
            else
                sliced.(fieldName{1}) = fieldData;
            end
        end
    end

    function [sliced] = sliceMatrix(structure, lengthX, lengthY, ix, iy)
        %{
            slice fields of a structure if they are matrices.
        %}

        for fieldName = fieldnames(structure)'
            fieldData = structure.(fieldName{1});
            fieldDataSize = size(fieldData);
            if ismatrix(fieldData)
                if fieldDataSize(1) >= lengthX && fieldDataSize(2) >= lengthY
                    sliced.(fieldName{1}) = fieldData(ix, iy);
                elseif fieldDataSize(1) >= lengthY && fieldDataSize(2) >= lengthX
                    sliced.(fieldName{1}) = fieldData(iy, ix);
                else
                    sliced.(fieldName{1}) = fieldData;
                end
            else
                sliced.(fieldName{1}) = fieldData;
            end
        end
    end

    for i = 1:ModelSettings.NL
        % slice vectors
        VG = sliceVector(VanGenuchten, ModelSettings.NL, i);

        for j = 1:ModelSettings.nD
            MN = i + j - 1;

            SV = SoilVariables;

            % slice
            % only for these variables, i is used, for the rest MN.
            SV.POR = SoilVariables.POR(i);
            SV.XCAP = SoilVariables.XCAP(i);
            SV.Ks = SoilVariables.Ks(i);

            lengthX = ModelSettings.NL + j - 1;
            SV = sliceVector(SV, lengthX, MN);
            SV = sliceMatrix(SV, lengthX, ModelSettings.nD, MN, j);

            [hh, hh_frez] = conductivity.hydraulicConductivity.fixHeat(SV.hh, SV.hh_frez, SV.Phi_s, ModelSettings);
            SV.hh = hh;
            SV.hh_frez = hh_frez;

            Gamma_hh = conductivity.hydraulicConductivity.calculateGamma_hh(SV.hh);
            Theta_m = conductivity.hydraulicConductivity.calculateTheta_m(Gamma_hh, VG, SV.POR);
            Theta_UU = conductivity.hydraulicConductivity.calculateTheta_UU(Theta_m, Gamma_hh, SV, VG, ModelSettings);

            % circular calculation of Theta_II! See issue 181, item 3
            % Theta_II is soil ice content,
            % Theta_LL is liquid water content,
            % Theta_UU is the total water content before soil freezing. The
            % 'Theta_UU' is set as saturation.
            Theta_II = conductivity.hydraulicConductivity.calculateTheta_II(SV.TT, SV.XCAP, SV.hh, SV.Theta_II, ModelSettings);
            Theta_LL = conductivity.hydraulicConductivity.calculateTheta_LL(Theta_UU, Theta_II, Theta_m, Gamma_hh, SV, VG, ModelSettings);
            Theta_II = (Theta_UU - Theta_LL) * Constants.RHOL / Constants.RHOI;  % ice water contentTheta_II

            DTheta_UUh = conductivity.hydraulicConductivity.calculateDTheta_UUh(Theta_UU, Theta_m, Theta_LL, Gamma_hh, SV, VG, ModelSettings);
            DTheta_LLh = conductivity.hydraulicConductivity.calculateDTheta_LLh(DTheta_UUh, Theta_m, Theta_UU, Theta_LL, Gamma_hh, SV, VG, ModelSettings);
            Se = conductivity.hydraulicConductivity.calculateSe(Theta_LL, Gamma_hh, SV, ModelSettings);

            % Ratio_ice used in Condg_k_g.m
            if Theta_UU ~= 0
                Ratio_ice = Constants.RHOI * Theta_II / (Constants.RHOL * Theta_UU); % ice ratio
            else
                Ratio_ice = 0;
            end
            if KIT
                % The calculation of MU_W repeated in CondL_Tdisp and used in Condg_k_g
                if SV.TT < -20
                    MU_W = 3.71e-2;
                elseif SV.TT > 150
                    MU_W = 1.81e-3;
                else
                    MU_W = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (SV.TT + 133.3)));
                end

                KL_h = conductivity.hydraulicConductivity.calculateKL_h(MU_W, Se, SV.Ks, VG.m);

                if Gamma_hh ~= 1
                    KfL_h = KL_h * 10^(-1 * SV.Imped * Ratio_ice);  % hydraulic conductivity for freezing soil
                else
                    KfL_h = KL_h * 10^(-1 * SV.Imped * Ratio_ice);  % hydraulic conductivity for freezing soil
                end
                KfL_T = helpers.heaviside1(SV.TT_CRIT - (SV.TT + ModelSettings.T0)) * L_f * 1e4 / (Constants.g * (ModelSettings.T0));   % thermal consider for freezing soil
            else
                KL_h = 0;
                KfL_h = 0;
                KfL_T = 0;
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
            SoilVariables.Ratio_ice(i, j) = Ratio_ice;
            SoilVariables.Gamma_hh(MN) = Gamma_hh;
        end
    end
end
