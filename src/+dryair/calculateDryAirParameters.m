function AirVariabes = calculateDryAirParameters(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, GasDispersivity, ...
                                                 P_gg, Xah, XaT, Xaa, RHODA)
    %{
        Calculate all the parameters related to dry air equation e.g., Equation
        3.59-3.64, STEMMUS Technical Notes, page 27-28.
    %}
    ModelSettings = io.getModelSettings();
    Constants = io.define_constants();

    AirVariabes.Cah = InitialValues.Cah;
    AirVariabes.CaT = InitialValues.CaT;
    AirVariabes.Caa = InitialValues.Caa;
    AirVariabes.Kah = InitialValues.Kah;
    AirVariabes.KaT = InitialValues.KaT;
    AirVariabes.Kaa = InitialValues.Kaa;
    AirVariabes.Vah = InitialValues.Vah;
    AirVariabes.VaT = InitialValues.VaT;
    AirVariabes.Vaa = InitialValues.Vaa;
    AirVariabes.Cag = InitialValues.Cag;

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD

            KLhBAR = (SoilVariables.KfL_h(i, 1) + SoilVariables.KfL_h(i, 2)) / 2;
            KLTBAR = (InitialValues.KL_T(i, 1) + InitialValues.KL_T(i, 2)) / 2;
            DhDZ = (SoilVariables.hh(i + 1) + SoilVariables.hh_frez(i + 1) - SoilVariables.hh(i) - SoilVariables.hh_frez(i)) / ModelSettings.DeltZ(i);
            DTDZ = (SoilVariables.TT(i + 1) - SoilVariables.TT(i)) / ModelSettings.DeltZ(i);
            DPgDZ = (P_gg(i + 1) - P_gg(i)) / ModelSettings.DeltZ(i);
            DTDBAR = (TransportCoefficient.D_Ta(i, 1) + TransportCoefficient.D_Ta(i, 2)) / 2;

            if SoilVariables.KLa_Switch == 1
                QL(i) = -(KLhBAR * (DhDZ + DPgDZ / Constants.Gamma_w) + (KLTBAR + DTDBAR) * DTDZ + KLhBAR);
                QL_h(i) = -(KLhBAR * (DhDZ + DPgDZ / Constants.Gamma_w) + KLhBAR);
                QL_a(i) = -(KLhBAR * (DPgDZ / Constants.Gamma_w));
                QL_T(i) = -((KLTBAR + DTDBAR) * DTDZ);
            else
                QL(i) = -(KLhBAR * DhDZ + (KLTBAR + DTDBAR) * DTDZ + KLhBAR);
                QL_h(i) = -(KLhBAR * DhDZ + KLhBAR);
                QL_T(i) = -((KLTBAR + DTDBAR) * DTDZ);

            end
            MN = i + j - 1;

            AirVariabes.Cah(i, j) = Xah(MN) * (SoilVariables.POR(i) + (Constants.Hc - 1) * SoilVariables.Theta_LL(i, j)) + (Constants.Hc - 1) * RHODA(MN) * SoilVariables.DTheta_LLh(i, j);
            AirVariabes.CaT(i, j) = XaT(MN) * (SoilVariables.POR(i) + (Constants.Hc - 1) * SoilVariables.Theta_LL(i, j)) + (Constants.Hc - 1) * RHODA(MN) * SoilVariables.DTheta_LLT(i, j);
            AirVariabes.Caa(i, j) = Xaa(MN) * (SoilVariables.POR(i) + (Constants.Hc - 1) * SoilVariables.Theta_LL(i, j));

            AirVariabes.Kah(i, j) = Xah(MN) * (VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) + Constants.Hc * RHODA(MN) * SoilVariables.KfL_h(i, j);
            AirVariabes.KaT(i, j) = XaT(MN) * (VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) + Constants.Hc * RHODA(MN) * (InitialValues.KL_T(i, j) + TransportCoefficient.D_Ta(i, j));
            AirVariabes.Kaa(i, j) = Xaa(MN) * (VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) + RHODA(MN) * (GasDispersivity.Beta_g(i, j) + Constants.Hc * SoilVariables.KfL_h(i, j) / Constants.Gamma_w);

            AirVariabes.Cag(i, j) = Constants.Hc * RHODA(MN) * SoilVariables.KfL_h(i, j);

            AirVariabes.Vah(i, j) = -(GasDispersivity.V_A(i) + Constants.Hc * QL(i) / Constants.RHOL) * Xah(MN);
            AirVariabes.VaT(i, j) = -(GasDispersivity.V_A(i) + Constants.Hc * QL(i) / Constants.RHOL) * XaT(MN);
            AirVariabes.Vaa(i, j) = -(GasDispersivity.V_A(i) + Constants.Hc * QL(i) / Constants.RHOL) * Xaa(MN);
        end
    end
