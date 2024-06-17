function HeatMatrices = assembleCoefficientMatrices(HeatVariables, InitialValues, Srt)
    %{
        Assemble the coefficient matrices of Equation 4.32 (STEMMUS Technical
        Notes, page 44).
    %}
    ModelSettings = io.getModelSettings();

    % Define HeatMatrices structure
    HeatMatrices.C1 = InitialValues.C1;
    HeatMatrices.C2 = InitialValues.C2;
    HeatMatrices.C3 = InitialValues.C3;
    HeatMatrices.C4 = InitialValues.C4;
    HeatMatrices.C5 = InitialValues.C5;
    HeatMatrices.C6 = InitialValues.C6;
    HeatMatrices.C7 = InitialValues.C7;
    % C9 is the matrix coefficient of root water uptake
    HeatMatrices.C9 = InitialValues.C9;
    HeatMatrices.C4_a = [];
    HeatMatrices.C5_a = [];

    for i = 1:ModelSettings.NL
        HeatMatrices.C1(i, 1) = HeatMatrices.C1(i, 1) + HeatVariables.Chh(i, 1) * ModelSettings.DeltZ(i) / 2;
        HeatMatrices.C1(i + 1, 1) = HeatMatrices.C1(i + 1, 1) + HeatVariables.Chh(i, 2) * ModelSettings.DeltZ(i) / 2;

        HeatMatrices.C2(i, 1) = HeatMatrices.C2(i, 1) + HeatVariables.ChT(i, 1) * ModelSettings.DeltZ(i) / 2;
        HeatMatrices.C2(i + 1, 1) = HeatMatrices.C2(i + 1, 1) + HeatVariables.ChT(i, 2) * ModelSettings.DeltZ(i) / 2;

        C4ARG1 = (HeatVariables.Khh(i, 1) + HeatVariables.Khh(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C4ARG2_1 = HeatVariables.Vvh(i, 1) / 3 + HeatVariables.Vvh(i, 2) / 6;
        C4ARG2_2 = HeatVariables.Vvh(i, 1) / 6 + HeatVariables.Vvh(i, 2) / 3;
        HeatMatrices.C4(i, 1) = HeatMatrices.C4(i, 1) + C4ARG1 - C4ARG2_1;
        HeatMatrices.C4(i, 2) = HeatMatrices.C4(i, 2) - C4ARG1 - C4ARG2_2;
        HeatMatrices.C4(i + 1, 1) = HeatMatrices.C4(i + 1, 1) + C4ARG1 + C4ARG2_2;
        HeatMatrices.C4_a(i) = -C4ARG1 + C4ARG2_1;

        C5ARG1 = (HeatVariables.KhT(i, 1) + HeatVariables.KhT(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C5ARG2_1 = HeatVariables.VvT(i, 1) / 3 + HeatVariables.VvT(i, 2) / 6;
        C5ARG2_2 = HeatVariables.VvT(i, 1) / 6 + HeatVariables.VvT(i, 2) / 3;
        HeatMatrices.C5(i, 1) = HeatMatrices.C5(i, 1) + C5ARG1 - C5ARG2_1;
        HeatMatrices.C5(i, 2) = HeatMatrices.C5(i, 2) - C5ARG1 - C5ARG2_2;
        HeatMatrices.C5(i + 1, 1) = HeatMatrices.C5(i + 1, 1) + C5ARG1 + C5ARG2_2;
        HeatMatrices.C5_a(i) = -C5ARG1 + C5ARG2_1;

        C6ARG = (HeatVariables.Kha(i, 1) + HeatVariables.Kha(i, 2)) / (2 * ModelSettings.DeltZ(i));
        HeatMatrices.C6(i, 1) = HeatMatrices.C6(i, 1) + C6ARG;
        HeatMatrices.C6(i, 2) = HeatMatrices.C6(i, 2) - C6ARG;
        HeatMatrices.C6(i + 1, 1) = HeatMatrices.C6(i + 1, 1) + C6ARG;

        C7ARG = (HeatVariables.Chg(i, 1) + HeatVariables.Chg(i, 2)) / 2;
        HeatMatrices.C7(i) = HeatMatrices.C7(i) - C7ARG;
        HeatMatrices.C7(i + 1) = HeatMatrices.C7(i + 1) + C7ARG;

        C9ARG1 = (2 * Srt(i, 1) + Srt(i, 2)) * ModelSettings.DeltZ(i) / 6;
        C9ARG2 = (Srt(i, 1) + 2 * Srt(i, 2)) * ModelSettings.DeltZ(i) / 6;
        HeatMatrices.C9(i) = HeatMatrices.C9(i) + C9ARG1;
        HeatMatrices.C9(i + 1) = HeatMatrices.C9(i + 1) + C9ARG2;
    end
end
