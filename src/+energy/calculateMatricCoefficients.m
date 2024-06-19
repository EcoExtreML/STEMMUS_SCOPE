function EnergyMatrices = calculateMatricCoefficients(EnergyVariables, InitialValues, GroundwaterSettings)
    %{
        Calculate all the parameters related to matric coefficients e.g., c1-c7
        as in Equation 4.32 STEMMUS Technical Notes, page 44, which is an
        example for soil moisture equation, but here it is for energy equation.
    %}
    ModelSettings = io.getModelSettings();

    EnergyMatrices.C1 = InitialValues.C1;
    EnergyMatrices.C2 = InitialValues.C2;
    EnergyMatrices.C3 = InitialValues.C3;
    EnergyMatrices.C4 = InitialValues.C4;
    EnergyMatrices.C5 = InitialValues.C5;
    EnergyMatrices.C6 = InitialValues.C6;
    EnergyMatrices.C7 = zeros(ModelSettings.NN);

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    for i = indxBotm:ModelSettings.NL
        EnergyMatrices.C1(i, 1) = EnergyMatrices.C1(i, 1) + EnergyVariables.CTh(i, 1) * ModelSettings.DeltZ(i) / 2;
        EnergyMatrices.C1(i + 1, 1) = EnergyMatrices.C1(i + 1, 1) + EnergyVariables.CTh(i, 2) * ModelSettings.DeltZ(i) / 2;

        EnergyMatrices.C2(i, 1) = EnergyMatrices.C2(i, 1) + EnergyVariables.CTT(i, 1) * ModelSettings.DeltZ(i) / 2;
        EnergyMatrices.C2(i + 1, 1) = EnergyMatrices.C2(i + 1, 1) + EnergyVariables.CTT(i, 2) * ModelSettings.DeltZ(i) / 2;

        C4ARG1 = (EnergyVariables.KTh(i, 1) + EnergyVariables.KTh(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C4ARG2_1 = EnergyVariables.VTh(i, 1) / 3 + EnergyVariables.VTh(i, 2) / 6;
        C4ARG2_2 = EnergyVariables.VTh(i, 1) / 6 + EnergyVariables.VTh(i, 2) / 3;
        EnergyMatrices.C4(i, 1) = EnergyMatrices.C4(i, 1) + C4ARG1 - C4ARG2_1;
        EnergyMatrices.C4(i, 2) = EnergyMatrices.C4(i, 2) - C4ARG1 - C4ARG2_2;
        EnergyMatrices.C4(i + 1, 1) = EnergyMatrices.C4(i + 1, 1) + C4ARG1 + C4ARG2_2;
        EnergyMatrices.C4_a(i) = -C4ARG1 + C4ARG2_1;

        C5ARG1 = (EnergyVariables.KTT(i, 1) + EnergyVariables.KTT(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C5ARG2_1 = EnergyVariables.VTT(i, 1) / 3 + EnergyVariables.VTT(i, 2) / 6;
        C5ARG2_2 = EnergyVariables.VTT(i, 1) / 6 + EnergyVariables.VTT(i, 2) / 3;
        EnergyMatrices.C5(i, 1) = EnergyMatrices.C5(i, 1) + C5ARG1 - C5ARG2_1;
        EnergyMatrices.C5(i, 2) = EnergyMatrices.C5(i, 2) - C5ARG1 - C5ARG2_2;
        EnergyMatrices.C5(i + 1, 1) = EnergyMatrices.C5(i + 1, 1) + C5ARG1 + C5ARG2_2;
        EnergyMatrices.C5_a(i) = -C5ARG1 + C5ARG2_1;

        if ModelSettings.Soilairefc == 1
            EnergyMatrices.C3(i, 1) = EnergyMatrices.C3(i, 1) + EnergyVariables.CTa(i, 1) * ModelSettings.DeltZ(i) / 2;
            EnergyMatrices.C3(i + 1, 1) = EnergyMatrices.C3(i + 1, 1) + EnergyVariables.CTa(i, 2) * ModelSettings.DeltZ(i) / 2;

            C6ARG1 = (EnergyVariables.KTa(i, 1) + EnergyVariables.KTa(i, 2)) / (2 * ModelSettings.DeltZ(i));
            C6ARG2_1 = EnergyVariables.VTa(i, 1) / 3 + EnergyVariables.VTa(i, 2) / 6;
            C6ARG2_2 = EnergyVariables.VTa(i, 1) / 6 + EnergyVariables.VTa(i, 2) / 3;
            EnergyMatrices.C6(i, 1) = EnergyMatrices.C6(i, 1) + C6ARG1 - C6ARG2_1;
            EnergyMatrices.C6(i, 2) = EnergyMatrices.C6(i, 2) - C6ARG1 - C6ARG2_2;
            EnergyMatrices.C6(i + 1, 1) = EnergyMatrices.C6(i + 1, 1) + C6ARG1 + C6ARG2_2;
            EnergyMatrices.C6_a(i) = -C6ARG1 + C6ARG2_1;
        end

        C7ARG = (EnergyVariables.CTg(i, 1) + EnergyVariables.CTg(i, 2)) / 2;
        EnergyMatrices.C7(i) = EnergyMatrices.C7(i) - C7ARG;
        EnergyMatrices.C7(i + 1) = EnergyMatrices.C7(i + 1) + C7ARG;
    end
end
