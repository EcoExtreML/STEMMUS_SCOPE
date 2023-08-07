function [C1, C2, C4, C3, C4_a, C5, C6, C7, C5_a, C9] = h_MAT(Chh, ChT, Khh, KhT, Kha, Vvh, VvT, Chg, Srt)

    ModelSettings = io.getModelSettings();
    DeltZ = ModelSettings.DeltZ;

    for i = 1:ModelSettings.NN
        for j = 1:ModelSettings.nD
            C1(i, j) = 0;
            C7(i) = 0;
            % C9 is the matrix coefficient of root water uptake
            C9(i) = 0;
            C4(i, j) = 0;
            C4_a(i) = 0;
            C5_a(i) = 0;
            C2(i, j) = 0;
            C3(i, j) = 0;
            C5(i, j) = 0;
            C6(i, j) = 0;
        end
    end
    for i = 1:ModelSettings.NL
        C1(i, 1) = C1(i, 1) + Chh(i, 1) * DeltZ(i) / 2;
        C1(i + 1, 1) = C1(i + 1, 1) + Chh(i, 2) * DeltZ(i) / 2;

        C2(i, 1) = C2(i, 1) + ChT(i, 1) * DeltZ(i) / 2;
        C2(i + 1, 1) = C2(i + 1, 1) + ChT(i, 2) * DeltZ(i) / 2;

        C4ARG1 = (Khh(i, 1) + Khh(i, 2)) / (2 * DeltZ(i));
        C4ARG2_1 = Vvh(i, 1) / 3 + Vvh(i, 2) / 6;
        C4ARG2_2 = Vvh(i, 1) / 6 + Vvh(i, 2) / 3;
        C4(i, 1) = C4(i, 1) + C4ARG1 - C4ARG2_1;
        C4(i, 2) = C4(i, 2) - C4ARG1 - C4ARG2_2;
        C4(i + 1, 1) = C4(i + 1, 1) + C4ARG1 + C4ARG2_2;
        C4_a(i) = -C4ARG1 + C4ARG2_1;

        C5ARG1 = (KhT(i, 1) + KhT(i, 2)) / (2 * DeltZ(i));
        C5ARG2_1 = VvT(i, 1) / 3 + VvT(i, 2) / 6;
        C5ARG2_2 = VvT(i, 1) / 6 + VvT(i, 2) / 3;
        C5(i, 1) = C5(i, 1) + C5ARG1 - C5ARG2_1;
        C5(i, 2) = C5(i, 2) - C5ARG1 - C5ARG2_2;
        C5(i + 1, 1) = C5(i + 1, 1) + C5ARG1 + C5ARG2_2;
        C5_a(i) = -C5ARG1 + C5ARG2_1;

        C6ARG = (Kha(i, 1) + Kha(i, 2)) / (2 * DeltZ(i));
        C6(i, 1) = C6(i, 1) + C6ARG;
        C6(i, 2) = C6(i, 2) - C6ARG;
        C6(i + 1, 1) = C6(i + 1, 1) + C6ARG;

        C7ARG = (Chg(i, 1) + Chg(i, 2)) / 2;
        C7(i) = C7(i) - C7ARG;
        C7(i + 1) = C7(i + 1) + C7ARG;

        C9ARG1 = (2 * Srt(i, 1) + Srt(i, 2)) * DeltZ(i) / 6;
        C9ARG2 = (Srt(i, 1) + 2 * Srt(i, 2)) * DeltZ(i) / 6;
        C9(i) = C9(i) + C9ARG1;
        C9(i + 1) = C9(i + 1) + C9ARG2;
    end
end
