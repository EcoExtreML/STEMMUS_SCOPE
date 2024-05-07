function EnergyVariables = calculateEnergyParameters(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, AirVariabes, ...
                                                     VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                     DRHOVh, DRHOVT, KL_T, Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L, GroundwaterSettings)
    %{
        Calculate all the parameters related to energy balance equation e.Constants.g.,
        Equation 3.65-3.73, STEMMUS Technical Notes, page 29-32.
    %}

    ModelSettings = io.getModelSettings();
    Constants = io.define_constants();

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
		indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
	else % Groundwater Coupling is activated, added by Mostafa
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)	
	end
	
    % input
    Kcva = InitialValues.Kcva;
    Kcah = InitialValues.Kcah;
    KcaT = InitialValues.KcaT;
    Kcaa = InitialValues.Kcaa;
    Ccah = InitialValues.Ccah;
    CcaT = InitialValues.CcaT;
    Ccaa = InitialValues.Ccaa;
    CTT_PH = InitialValues.CTT_PH;
    CTT_LT = InitialValues.CTT_LT;
    CTT_Lg = InitialValues.CTT_Lg;
    CTT_g = InitialValues.CTT_g;
    KLhBAR = AirVariabes.KLhBAR;
    KLTBAR = AirVariabes.KLTBAR;
    DDhDZ = AirVariabes.DDhDZ;
    DhDZ = AirVariabes.DhDZ;
    DTDZ = AirVariabes.DTDZ;
    Kaa = AirVariabes.Kaa;
    Vaa = AirVariabes.Vaa;
    QL = AirVariabes.QL;
	
	if ModelSettings.Soilairefc
		QL_h = AirVariabes.QL_h; % added by Mostafa
		QL_T = AirVariabes.QL_T; % added by Mostafa
		QL_a = AirVariabes.QL_a; % added by Mostafa
	end
	
    % output
    EnergyVariables.CTh = InitialValues.CTh;
    EnergyVariables.CTa = InitialValues.CTa;
    EnergyVariables.KTh = InitialValues.KTh;
    EnergyVariables.KTT = InitialValues.KTT;
    EnergyVariables.KTa = InitialValues.KTa;
    EnergyVariables.VTT = InitialValues.VTT;
    EnergyVariables.VTh = InitialValues.VTh;
    EnergyVariables.VTa = InitialValues.VTa;
    EnergyVariables.CTg = InitialValues.CTg;
    EnergyVariables.CTT = InitialValues.CTT;

    for i = indxBotm:ModelSettings.NL
        if ~ModelSettings.Soilairefc
            KLhBAR(i) = (SoilVariables.KfL_h(i, 1) + SoilVariables.KfL_h(i, 2)) / 2;
            KLTBAR(i) = (KL_T(i, 1) + KL_T(i, 2)) / 2;
            DDhDZ(i) = (SoilVariables.hh(i + 1) - SoilVariables.hh(i)) / ModelSettings.DeltZ(i);
            DhDZ(i) = (SoilVariables.hh(i + 1) + SoilVariables.hh_frez(i + 1) - SoilVariables.hh(i) - SoilVariables.hh_frez(i)) / ModelSettings.DeltZ(i);
            DTDZ(i) = (SoilVariables.TT(i + 1) - SoilVariables.TT(i)) / ModelSettings.DeltZ(i);
        end
        DTDBAR(i) = (TransportCoefficient.D_Ta(i, 1) + TransportCoefficient.D_Ta(i, 2)) / 2;
        DEhBAR = (VaporVariables.D_V(i, 1) + VaporVariables.D_V(i, 2)) / 2;
        DRHOVhDz(i) = (DRHOVh(i + 1) + DRHOVh(i)) / 2;
        DRHOVTDz(i) = (DRHOVT(i + 1) + DRHOVT(i)) / 2;
        RHOVBAR = (RHOV(i + 1) + RHOV(i)) / 2;
        EtaBAR = (VaporVariables.Eta(i, 1) + VaporVariables.Eta(i, 2)) / 2;

        % The soil air gas in soil-pore is considered with Xah and XaT
        % terms.(0.0003,volumetric heat capacity)
        if ~ModelSettings.Soilairefc
            QL(i) = -(KLhBAR(i) * DhDZ(i) + (KLTBAR(i) + DTDBAR(i)) * DTDZ(i) + KLhBAR(i));
            QL_h(i) = -(KLhBAR(i) * DhDZ(i) + KLhBAR(i)); % added by Mostafa
			QL_T(i) = -((KLTBAR(i) + DTDBAR(i)) * DTDZ(i)); % added by Mostafa
			QL_a(i) = 0; % added by Mostafa
			Qa = 0;
        else
            Qa = -((DEhBAR + GasDispersivity.D_Vg(i)) * DRHODAz(i) - RHODA(i) * (GasDispersivity.V_A(i) + Constants.Hc * QL(i) / Constants.RHOL));
        end

        if SoilVariables.DVa_Switch == 1
            QV = -(DEhBAR + GasDispersivity.D_Vg(i)) * DRHOVhDz(i) * DDhDZ(i) - (DEhBAR * EtaBAR + GasDispersivity.D_Vg(i)) * DRHOVTDz(i) * DTDZ(i) + RHOVBAR * GasDispersivity.V_A(i);
			QVH(i) = -(DEhBAR + GasDispersivity.D_Vg(i)) * DRHOVhDz(i) * DDhDZ(i); % activated by Mostafa
			QVT(i) = -(DEhBAR * EtaBAR + GasDispersivity.D_Vg(i)) * DRHOVTDz(i) * DTDZ(i); % activated by Mostafa
			QVa(i) = RHOVBAR * GasDispersivity.V_A(i); % added by Mostafa
		else
            QV = -(DEhBAR + GasDispersivity.D_Vg(i)) * DRHOVhDz(i) * DDhDZ(i) - (DEhBAR * EtaBAR + GasDispersivity.D_Vg(i)) * DRHOVTDz(i) * DTDZ(i);
 			QVH(i) = -(DEhBAR + GasDispersivity.D_Vg(i)) * DRHOVhDz(i) * DDhDZ(i); % activated by Mostafa
			QVT(i) = -(DEhBAR * EtaBAR + GasDispersivity.D_Vg(i)) * DRHOVTDz(i) * DTDZ(i); % activated by Mostafa
			VT1 = -(DEhBAR * EtaBAR + GasDispersivity.D_Vg(i));
			QVa(i) = 0; % added by Mostafa       
		end

        % These are unused vars, but I comment them for future reference,
        % See issue 100, item 1
        % DVH(i) = (DEhBAR) * DRHOVhDz(i);
        % DVT(i) = (DEhBAR * EtaBAR) * DRHOVTDz(i);
        % QVH(i) = -(DEhBAR + GasDispersivity.D_Vg(i)) * DRHOVhDz(i) * DDhDZ(i);
        % QVT(i) = -(DEhBAR * EtaBAR + GasDispersivity.D_Vg(i)) * DRHOVTDz(i) * DTDZ(i);
		for j = 1:ModelSettings.nD
            MN = i + j - 1;
            if ModelSettings.Soilairefc == 1
                Kcah(i, j) = Constants.c_a * SoilVariables.TT(MN) * ((VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) * Xah(MN) + Constants.Hc * RHODA(MN) * SoilVariables.KfL_h(i, j));
                KcaT(i, j) = Constants.c_a * SoilVariables.TT(MN) * ((VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) * XaT(MN) + Constants.Hc * RHODA(MN) * (KL_T(i, j) + TransportCoefficient.D_Ta(i, j))); %
                Kcaa(i, j) = Constants.c_a * SoilVariables.TT(MN) * Kaa(i, j);
                if SoilVariables.DVa_Switch == 1
                    Kcva(i, j) = L(MN) * RHOV(MN) * GasDispersivity.Beta_g(i, j);
                else
                    Kcva(i, j) = 0;
                end
                Ccah(i, j) = Constants.c_a * SoilVariables.TT(MN) * (-GasDispersivity.V_A(i) - Constants.Hc * QL(i) / Constants.RHOL) * Xah(MN);
                CcaT(i, j) = Constants.c_a * SoilVariables.TT(MN) * (-GasDispersivity.V_A(i) - Constants.Hc * QL(i) / Constants.RHOL) * XaT(MN);
                Ccaa(i, j) = Constants.c_a * SoilVariables.TT(MN) * Vaa(i, j);
            end

            if abs(SoilVariables.SAVEDTheta_LLh(i, j) - SoilVariables.SAVEDTheta_UUh(i, j)) ~= 0
                CTT_PH(i, j) = (10 * L_f^2 * Constants.RHOI / (Constants.g * (ModelSettings.T0 + SoilVariables.TT(MN)))) * SoilVariables.DTheta_UUh(i, j);
                CTT_Lg(i, j) = (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * SoilVariables.Theta_g(i, j) * DRHOVT(MN);
                CTT_g(i, j) = Constants.c_a * SoilVariables.TT(MN) * SoilVariables.Theta_g(i, j) * XaT(MN);

                CTT_LT(i, j) = (((Constants.c_L * SoilVariables.TT(MN) - TransportCoefficient.WW(i, j)) * Constants.RHOL - ((Constants.c_L * SoilVariables.TT(MN) + L(MN)) * RHOV(MN) + Constants.c_a * RHODA(MN) * SoilVariables.TT(MN))) * (1 - Constants.RHOI / Constants.RHOL) - Constants.RHOI * Constants.c_i * SoilVariables.TT(MN)) * 1e4 * L_f / (Constants.g * (ModelSettings.T0 + SoilVariables.TT(MN))) * SoilVariables.DTheta_UUh(i, j);
                if CTT_PH(i, j) < 0
                    CTT_PH(i, j) = 0;
                end
                EnergyVariables.CTT(i, j) = ThermalConductivityCapacity.c_unsat(i, j) + CTT_Lg(i, j) + CTT_g(i, j) + CTT_LT(i, j) + CTT_PH(i, j);
                EnergyVariables.CTh(i, j) = (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * SoilVariables.Theta_g(i, j) * DRHOVh(MN) + Constants.c_a * SoilVariables.TT(MN) * SoilVariables.Theta_g(i, j) * Xah(MN);
                EnergyVariables.CTa(i, j) = SoilVariables.TT(MN) * SoilVariables.Theta_V(i, j) * Constants.c_a * Xaa(MN);  % This term isnot in Milly's work.

            else
                % Main coefficients for energy transport is here
                CTT_Lg(i, j) = 0;
                CTT_g(i, j) = 0;
                CTT_LT(i, j) = 0;
                CTT_PH(i, j) = 0;
                EnergyVariables.CTh(i, j) = ((Constants.c_L * SoilVariables.TT(MN) - TransportCoefficient.WW(i, j)) * Constants.RHOL - (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * RHOV(MN) - Constants.c_a * RHODA(MN) * SoilVariables.TT(MN)) * SoilVariables.DTheta_LLh(i, j);
                +(Constants.c_L * SoilVariables.TT(MN) + L(MN)) * SoilVariables.Theta_g(i, j) * DRHOVh(MN) + Constants.c_a * SoilVariables.TT(MN) * SoilVariables.Theta_g(i, j) * Xah(MN);
                EnergyVariables.CTT(i, j) = ThermalConductivityCapacity.c_unsat(i, j) + (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * SoilVariables.Theta_g(i, j) * DRHOVT(MN) + Constants.c_a * SoilVariables.TT(MN) * SoilVariables.Theta_g(i, j) * XaT(MN) ...
                    + ((Constants.c_L * SoilVariables.TT(MN) - TransportCoefficient.WW(i, j)) * Constants.RHOL - (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * RHOV(MN) - Constants.c_a * RHODA(MN) * SoilVariables.TT(MN)) * SoilVariables.DTheta_LLT(i, j);
                EnergyVariables.CTa(i, j) = SoilVariables.TT(MN) * SoilVariables.Theta_V(i, j) * Constants.c_a * Xaa(MN);  % This term isnot in Milly's work.
            end
            if ModelSettings.SFCC == 0  % ice calculation use Sin function
                if SoilVariables.TT(MN) + 273.15 > Tf1
                    CTT_PH(i, j) = 0;
                elseif SoilVariables.TT(MN) + 273.15 >= Tf2
                    CTT_PH(i, j) = L_f * 10^(-3) * 0.5 * cos(pi() * (SoilVariables.TT(MN) + 273.15 - 0.5 * Tf1 - 0.5 * Tf2) / (Tf1 - Tf2)) * pi() / (Tf1 - Tf2);
                else
                    CTT_PH(i, j) = 0;
                end
                CTT_Lg(i, j) = (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * SoilVariables.Theta_g(i, j) * DRHOVT(MN);
                CTT_g(i, j) = Constants.c_a * SoilVariables.TT(MN) * SoilVariables.Theta_g(i, j) * XaT(MN);
                CTT_LT(i, j) = ((Constants.c_L * SoilVariables.TT(MN) - Constants.c_i * SoilVariables.TT(MN) - TransportCoefficient.WW(i, j)) * Constants.RHOL + ((Constants.c_L * SoilVariables.TT(MN) + L(MN)) * RHOV(MN) + Constants.c_a * RHODA(MN) * SoilVariables.TT(MN)) * (Constants.RHOL / Constants.RHOI - 1)) * 1e4 * L_f / (Constants.g * (ModelSettings.T0 + SoilVariables.TT(MN))) * SoilVariables.DTheta_UUh(i, j);

                EnergyVariables.CTT(i, j) = ThermalConductivityCapacity.c_unsat(i, j) + CTT_Lg(i, j) + CTT_g(i, j) + CTT_LT(i, j) + CTT_PH(i, j);
                EnergyVariables.CTh(i, j) = (Constants.c_L * SoilVariables.TT(MN) + L(MN)) * SoilVariables.Theta_g(i, j) * DRHOVh(MN) + Constants.c_a * SoilVariables.TT(MN) * SoilVariables.Theta_g(i, j) * Xah(MN);
                EnergyVariables.CTa(i, j) = SoilVariables.TT(MN) * SoilVariables.Theta_V(i, j) * Constants.c_a * Xaa(MN);  % This term isnot in Milly's work.
            end
            EnergyVariables.KTh(i, j) = L(MN) * (VaporVariables.D_V(i, j) + GasDispersivity.D_Vg(i)) * DRHOVh(MN) + Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.Khh(i, j) + Kcah(i, j);
            EnergyVariables.KTT(i, j) = ThermalConductivityCapacity.Lambda_eff(i, j) + Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.KhT(i, j) + KcaT(i, j) + L(MN) * (VaporVariables.D_V(i, j) * VaporVariables.Eta(i, j) + GasDispersivity.D_Vg(i)) * DRHOVT(MN);
            EnergyVariables.KTa(i, j) = Kcva(i, j) + Kcaa(i, j) + Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.Kha(i, j);  % This term isnot in Milly's work.

            if SoilVariables.DVa_Switch == 1
                EnergyVariables.VTh(i, j) = Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.Vvh(i, j) + Ccah(i, j) - L(MN) * GasDispersivity.V_A(i) * DRHOVh(MN);
                EnergyVariables.VTT(i, j) = Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.VvT(i, j) + CcaT(i, j) - L(MN) * GasDispersivity.V_A(i) * DRHOVT(MN) - (Constants.c_L * (QL(i) + QV) + Constants.c_a * Qa - 2.369 * QV);
            else
                EnergyVariables.VTh(i, j) = Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.Vvh(i, j) + Ccah(i, j);
                EnergyVariables.VTT(i, j) = Constants.c_L * SoilVariables.TT(MN) * Constants.RHOL * HeatVariables.VvT(i, j) + CcaT(i, j) - (Constants.c_L * (QL(i) + QV) + Constants.c_a * Qa - 2.369 * QV);
            end

            EnergyVariables.VTa(i, j) = Ccaa(i, j);
            EnergyVariables.CTg(i, j) = (Constants.c_L * Constants.RHOL + Constants.c_a * Constants.Hc * RHODA(MN)) * SoilVariables.KfL_h(i, j) * SoilVariables.TT(MN) - Constants.c_L * Srt(i, j) * SoilVariables.TT(MN);
        end
    end

    % output to be used in other functions
    EnergyVariables.QL = QL; % added by Mostafa, 
	EnergyVariables.QV = QV; % added by Mostafa,
	EnergyVariables.QVH = QVH; % added by Mostafa,
	EnergyVariables.QVT = QVT; % added by Mostafa,
	VEta = VaporVariables.Eta;
	QVT = QVT;
	EnergyVariables.QVa = QVa; % added by Mostafa,	
	EnergyVariables.QL_h = QL_h; % added by Mostafa,
	EnergyVariables.QL_T = QL_T; % added by Mostafa,
	EnergyVariables.QL_a = QL_a; % added by Mostafa,
	EnergyVariables.Qa = Qa; % added by Mostafa,	

end
