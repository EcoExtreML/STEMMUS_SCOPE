function [SoilVariables] = calculateHydraulicConductivity(SoilVariables, VanGenuchten, KIT, L_f)
    % get model settings
    ModelSettings = io.getModelSettings();

    % load Constants
    Constants = io.define_constants();

    % TODO issue  Phi_s and Lamda are empty
    % TODO issue FILM = 1 not used

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
            if ismatrix(fieldData)
                if size(fieldData)(1) >= lengthX && size(fieldData)(2) >= lengthY
                    sliced.(fieldName{1}) = fieldData(ix, iy);
                elseif size(fieldData)(1) >= lengthY && size(fieldData)(2) >= lengthX
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
        SV = sliceVector(SoilVariables, ModelSettings.NL, i);
        for j = 1:ModelSettings.nD
            MN = i + j - 1;

            % slice matrices
            lengthX = ModelSettings.NL + j - 1;
            SV = sliceMatrix(SV, lengthX, ModelSettings.nD, MN, j);

            Gama_hh = conductivity.hydraulicConductivity.calculateGama_hh(SV.hh);
            Theta_m = conductivity.hydraulicConductivity.calculateTheta_m(Gama_hh, VG);

            Theta_UU = conductivity.hydraulicConductivity.calculateTheta_UU(Theta_m, Gama_hh, SV, VG);
            Theta_II = conductivity.hydraulicConductivity.calculateTheta_II(SV.TT, SV.XCAP, SV.hh, SV.Theta_II);
            Theta_LL = conductivity.hydraulicConductivity.calculateTheta_LL(Theta_UU, Theta_II, Theta_m, SV, VG);
            % TODO issue circular calculation
            Theta_II = (Theta_UU - Theta_LL) * Constants.RHOL / Constants.RHOI;  % ice water content

            DTheta_UUh = conductivity.hydraulicConductivity.calculateDTheta_UUh(Theta_UU, Theta_m, Theta_LL, Gama_hh, SV, VG);
            DTheta_LLh = conductivity.hydraulicConductivity.calcuulateDTheta_LLh(DTheta_UUh, Theta_m, Theta_UU, Theta_LL, Gama_hh, SV, VG);
            Se = conductivity.hydraulicConductivity.calculateSe(Theta_LL, Gama_hh, SV);

            % TODO issue Ratio_ice not global but used in Condg_k_g.m
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

                KL_h = conductivity.hydraulicConductivity.calculateKL_h(MU_W, Se, SV.Ks, VG.m);

                if Gama_hh ~= 1
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
end
