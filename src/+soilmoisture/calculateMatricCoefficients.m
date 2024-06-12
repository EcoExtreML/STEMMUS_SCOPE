function [HeatVariables, SoilVariables] = calculateMatricCoefficients(SoilVariables, VaporVariables, GasDispersivity, InitialValues, ...
                                                                      RHOV, DRHOVh, DRHOVT, D_Ta, GroundwaterSettings)
    %{
        Calculate all the parameters related to matric coefficients (e.g.,
        c1-c8) as in Equation 4.32 (STEMMUS Technical Notes, page 44).
    %}

    ModelSettings = io.getModelSettings();
    Constants = io.define_constants();

    % Add a new variables to SoilVariables
    SoilVariables.DTheta_LLT = [];
    SoilVariables.SAVEDTheta_LLh = InitialValues.SAVEDTheta_LLh;
    SoilVariables.SAVEDTheta_UUh = InitialValues.SAVEDTheta_UUh;

    % Define new HeatVariables structure
    HeatVariables.Chh = InitialValues.Chh;
    HeatVariables.ChT = InitialValues.ChT;
    HeatVariables.Khh = InitialValues.Khh;
    HeatVariables.KhT = InitialValues.KhT;
    HeatVariables.Kha = InitialValues.Kha;
    HeatVariables.Vvh = InitialValues.Vvh;
    HeatVariables.VvT = InitialValues.VvT;
    HeatVariables.Chg = InitialValues.Chg;

    % Make SV as an alias of SoilVariables to make codes shorter
    SV = SoilVariables;

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
        indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
    else % Groundwater Coupling is activated, added by Mostafa
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)
    end

    for i = indxBotm:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            if ModelSettings.hThmrl
                CORhh = -1 * SV.CORh(MN);
                DhUU = SV.COR(MN) * (SV.hh(MN) + SV.hh_frez(MN) - SV.h(MN) - SV.h_frez(MN) + (SV.hh(MN) + SV.hh_frez(MN)) * CORhh * (SV.TT(MN) - SV.T(MN)));
                DhU = SV.COR(MN) * (SV.hh(MN) - SV.h(MN) + SV.hh(MN) * CORhh * (SV.TT(MN) - SV.T(MN)));

                if DhU ~= 0 && DhUU ~= 0 && abs(SV.Theta_LL(i, j) - SV.Theta_L(i, j)) > 1e-6 && SV.DTheta_UUh(i, j) ~= 0
                    SV.DTheta_UUh(i, j) = (SV.Theta_LL(i, j) - SV.Theta_L(i, j)) * SV.COR(MN) / DhUU;
                end
                if DhU ~= 0 && DhUU ~= 0 && abs(SV.Theta_LL(i, j) - SV.Theta_L(i, j)) > 1e-6 && SV.DTheta_LLh(i, j) ~= 0
                    SV.DTheta_LLh(i, j) = (SV.Theta_UU(i, j) - SV.Theta_U(i, j)) * SV.COR(MN) / DhU;
                end

                SV.DTheta_LLT(i, j) = SV.DTheta_LLh(i, j) * (SV.hh(MN) * CORhh);

                SV.SAVEDTheta_LLh(i, j) = SV.DTheta_LLh(i, j);
                SV.SAVEDTheta_UUh(i, j) = SV.DTheta_UUh(i, j);
            else
                if abs(SV.TT(MN) - SV.T(MN)) > 1e-6
                    SV.DTheta_LLT(i, j) = SV.DTheta_LLh(i, j) * (SV.hh(MN) / Constants.Gamma0) * (0.1425 + 4.76 * 10^(-4) * SV.TT(MN));
                else
                    SV.DTheta_LLT(i, j) = (SV.Theta_LL(i, j) - SV.Theta_L(i, j)) / (SV.TT(MN) - SV.T(MN));
                end
            end

            HeatVariables.Chh(i, j) = (1 - RHOV(MN) / Constants.RHOL) * SV.DTheta_LLh(i, j) + SV.Theta_V(i, j) * DRHOVh(MN) / Constants.RHOL;
            HeatVariables.Khh(i, j) = (VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) * DRHOVh(MN) / Constants.RHOL + SV.KfL_h(i, j);
            HeatVariables.Chg(i, j) = SV.KfL_h(i, j);

            if ModelSettings.Thmrlefc == 1
                HeatVariables.ChT(i, j) = (1 - RHOV(MN) / Constants.RHOL) * SV.DTheta_LLT(i, j) + SV.Theta_V(i, j) * DRHOVT(MN) / Constants.RHOL;
                HeatVariables.KhT(i, j) = (VaporVariables.D_V(i, j) * VaporVariables.Eta(i, j) + GasDispersivity.D_Vg(i)) * DRHOVT(MN) / Constants.RHOL + InitialValues.KL_T(i, j) + D_Ta(i, j);
            end

            if SV.KLa_Switch == 1
                HeatVariables.Kha(i, j) = RHOV(MN) * GasDispersivity.Beta_g(i, j) / Constants.RHOL + SV.KfL_h(i, j) / Constants.Gamma_w;
            else
                HeatVariables.Kha(i, j) = 0;
            end

            if SV.DVa_Switch == 1
                HeatVariables.Vvh(i, j) = -GasDispersivity.V_A(i) * DRHOVh(MN) / Constants.RHOL;
                HeatVariables.VvT(i, j) = -GasDispersivity.V_A(i) * DRHOVT(MN) / Constants.RHOL;
            else
                HeatVariables.Vvh(i, j) = 0;
                HeatVariables.VvT(i, j) = 0;
            end
            warningMsg = '%s is nan or not real';
            if isnan(HeatVariables.Chh(i, j)) || ~isreal(HeatVariables.Chh(i, j))
                warning(warningMsg, 'Chh(i, j)');
            end
            if isnan(HeatVariables.Khh(i, j)) || ~isreal(HeatVariables.Khh(i, j))
                warning(warningMsg, 'Khh(i, j)');
            end
            if isnan(HeatVariables.Chg(i, j)) || ~isreal(HeatVariables.Chg(i, j))
                warning(warningMsg, 'Chg(i, j)');
            end
            if isnan(HeatVariables.ChT(i, j)) || ~isreal(HeatVariables.ChT(i, j))
                warning(warningMsg, 'ChT(i, j)');
            end
            if isnan(HeatVariables.KhT(i, j)) || ~isreal(HeatVariables.KhT(i, j))
                warning(warningMsg, 'KhT(i, j)');
            end
        end
    end
    % Update SoilVariables using alias SV
    SoilVariables = SV;
end
