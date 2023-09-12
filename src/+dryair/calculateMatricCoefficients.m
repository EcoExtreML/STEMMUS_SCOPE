function AirMatrices = Air_MAT(AirVariabes, InitialValues)

    AirMatrices.C1 = InitialValues.C1;
    AirMatrices.C2 = InitialValues.C2;
    AirMatrices.C3 = InitialValues.C3;
    AirMatrices.C4 = InitialValues.C4;
    AirMatrices.C5 = InitialValues.C5;
    AirMatrices.C6 = InitialValues.C6;

    ModelSettings = io.getModelSettings();

    for i = 1:ModelSettings.NL
        AirMatrices.C1(i, 1) = AirMatrices.C1(i, 1) + AirVariabes.Cah(i, 1) * ModelSettings.DeltZ(i) / 2;
        AirMatrices.C1(i + 1, 1) = AirMatrices.C1(i + 1, 1) + AirVariabes.Cah(i, 2) * ModelSettings.DeltZ(i) / 2;

        AirMatrices.C2(i, 1) = AirMatrices.C2(i, 1) + AirVariabes.CaT(i, 1) * ModelSettings.DeltZ(i) / 2;
        AirMatrices.C2(i + 1, 1) = AirMatrices.C2(i + 1, 1) + AirVariabes.CaT(i, 2) * ModelSettings.DeltZ(i) / 2;

        AirMatrices.C3(i, 1) = AirMatrices.C3(i, 1) + AirVariabes.Caa(i, 1) * ModelSettings.DeltZ(i) / 2;
        AirMatrices.C3(i + 1, 1) = AirMatrices.C3(i + 1, 1) + AirVariabes.Caa(i, 2) * ModelSettings.DeltZ(i) / 2;

        C4ARG1 = (AirVariabes.Kah(i, 1) + AirVariabes.Kah(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C4ARG2_1 = AirVariabes.Vah(i, 1) / 3 + AirVariabes.Vah(i, 2) / 6;
        C4ARG2_2 = AirVariabes.Vah(i, 1) / 6 + AirVariabes.Vah(i, 2) / 3;
        AirMatrices.C4(i, 1) = AirMatrices.C4(i, 1) + C4ARG1 - C4ARG2_1;
        AirMatrices.C4(i, 2) = AirMatrices.C4(i, 2) - C4ARG1 - C4ARG2_2;
        AirMatrices.C4(i + 1, 1) = AirMatrices.C4(i + 1, 1) + C4ARG1 + C4ARG2_2;
        AirMatrices.C4_a(i) = -C4ARG1 + C4ARG2_1;

        C5ARG1 = (AirVariabes.KaT(i, 1) + AirVariabes.KaT(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C5ARG2_1 = AirVariabes.VaT(i, 1) / 3 + AirVariabes.VaT(i, 2) / 6;
        C5ARG2_2 = AirVariabes.VaT(i, 1) / 6 + AirVariabes.VaT(i, 2) / 3;
        AirMatrices.C5(i, 1) = AirMatrices.C5(i, 1) + C5ARG1 - C5ARG2_1;
        AirMatrices.C5(i, 2) = AirMatrices.C5(i, 2) - C5ARG1 - C5ARG2_2;
        AirMatrices.C5(i + 1, 1) = AirMatrices.C5(i + 1, 1) + C5ARG1 + C5ARG2_2;
        AirMatrices.C5_a(i) = -C5ARG1 + C5ARG2_1;

        C6ARG1 = (AirVariabes.Kaa(i, 1) + AirVariabes.Kaa(i, 2)) / (2 * ModelSettings.DeltZ(i));
        C6ARG2_1 = AirVariabes.Vaa(i, 1) / 3 + AirVariabes.Vaa(i, 2) / 6;
        C6ARG2_2 = AirVariabes.Vaa(i, 1) / 6 + AirVariabes.Vaa(i, 2) / 3;
        AirMatrices.C6(i, 1) = AirMatrices.C6(i, 1) + C6ARG1 - C6ARG2_1;
        AirMatrices.C6(i, 2) = AirMatrices.C6(i, 2) - C6ARG1 - C6ARG2_2;
        AirMatrices.C6(i + 1, 1) = AirMatrices.C6(i + 1, 1) + C6ARG1 + C6ARG2_2;
        AirMatrices.C6_a(i) = -C6ARG1 + C6ARG2_1;

        C7ARG = (AirVariabes.Cag(i, 1) + AirVariabes.Cag(i, 2)) / 2;
        AirMatrices.C7(i) = AirMatrices.C7(i) - C7ARG;
        AirMatrices.C7(i + 1) = AirMatrices.C7(i + 1) + C7ARG;
    end
