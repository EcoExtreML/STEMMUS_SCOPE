function InitialValues = defineInitialValues(Dur_tot, ModelSettings)
    %{

    %}
    % get model settings
    NN = ModelSettings.NN; % Number of nodes;
    mN = ModelSettings.mN;
    mL = ModelSettings.mL; % Number of elements. Prevending the exceeds of size of arraies;
    nD = ModelSettings.nD;
    ML = ModelSettings.ML;

    structures = {};
    %% Structure 1: variables with zeros(mL, nD)
    % alpha_h = root water uptake
    % bx
    % Srt
    % DTheta_LLh
    % DTheta_UUh
    % SAVEDTheta_UUh
    % SAVEDTheta_LLh
    % Ratio_ice
    % KL_h = The hydraulic conductivity(m/s^-1);
    % KfL_h = The hydraulic conductivity considering ice blockking effect(m/s^-1);
    % KfL_T = The depression temperature controlled by ice(m^2/Cels^-1/s^-1);
    % KL_T = The conductivity controlled by thermal gradient(m^2/Cels^-1/s^-1);
    % D_Ta = The thermal dispersivity for soil water (m^2/Cels^-1/s^-1);
    % Theta_L = The soil moisture at the start of current time step;
    % Theta_LL = The soil moisture at the end of current time step;
    % Theta_U = The total soil moisture(water+ice) at the start of current time step;
    % Theta_UU = The total soil moisture at the end of current time step;
    % Theta_I = The soil ice water content at the start of current time step;
    % Theta_II = The soil ice water content at the end of current time step;
    % Se = The saturation degree of soil moisture;
    % Theta_V = Volumetric gas content;
    % W = Differential heat of wetting at the start of current time step(J/kg^-1);
    % WW = Differential heat of wetting at the end of current time step(J/kg^-1);
    % MU_W = Visocity of water(kg/m^?6?1/s^?6?1);
    % f0 = Tortusity factor [Millington and Quirk (1961)];                   kg.m^2.s^-2.m^-2.kg.m^-3
    % L_WT = Liquid dispersion factor in Thermal dispersivity(kg/m^-1/s^-1)=-------------------------- m^2 (1.5548e-013 m^2);
    % EHCAP = Effective heat capacity;
    % Chh = Storage coefficients in moisture mass conservation equation related to matric head;
    % ChT = Storage coefficients in moisture mass conservation equation related to temperature;
    % Khh = Conduction coefficients in moisture mass conservation equation related to matric head;
    % KhT = Conduction coefficients in moisture mass conservation equation related to temperature;
    % Kha = Conduction coefficients in moisture mass conservation equation related to soil air pressure;
    % Vvh = Conduction coefficients in moisture mass conservation equation related to matric head;
    % VvT = Conduction coefficients in moisture mass conservation equation related tempearture;
    % Chg = Gravity coefficients in moisture mass conservation equation;
    % C1 = The coefficients for storage term related to matric head;
    % C2 = The coefficients for storage term related to tempearture;
    % C3 = Storage term coefficients related to soil air pressure;
    % C4 = Conductivity term coefficients related to matric head;
    % C5 = Conductivity term coefficients related to temperature;
    % C6 = Conductivity term coefficients related to soil air pressure;
    % QL = Soil moisture mass flux (kg/m^-2/s^-1);
    % QL_h = potential driven moisture mass flux (kg/m^-2/s^-1);
    % QL_T = temperature driven moisture mass flux (kg/m^-2/s^-1);
    % D_V = Molecular diffusivity of water vapor in soil(m^2/s^-1);
    % k_g = Intrinsic air permeability (m^2);
    % Sa = Saturation degree of gas in soil pores;
    % V_A = Soil air velocity (m/s^-1);
    % Alpha_Lg = Longitudinal dispersivity in gas phase (m);
    % Eta = Enhancement factor for thermal vapor transport in soil.
    % Theta_g = Volumetric gas content;
    % Beta_g = The simplified coefficient for the soil air pressure linearization equation;
    % Cah = Storage coefficients in dry air mass conservation equation related to matric head;
    % CaT = Storage coefficients in dry air mass conservation equation related to temperature;
    % Caa = Storage coefficients in dry air mass conservation equation related to soil air pressure;
    % Kah = Conduction coefficients in dry air mass conservation equation related to matric head;
    % KaT = Conduction coefficients in dry air mass conservation equation related to temperature;
    % Kaa = Conduction coefficients in dry air mass conservation equation related to soil air pressure;
    % Vah = Conduction coefficients in dry air mass conservation equation related to matric head;
    % VaT = Conduction coefficients in dry air mass conservation equation related to temperature;
    % Vaa = Conduction coefficients in dry air mass conservation equation related to soil air pressure;
    % Cag = Gravity coefficients in dry air mass conservation equation;
    % Lambda_eff = Effective heat conductivity;
    % c_unsat= Effective heat capacity;
    % CTT_PH = Storage coefficient in energy conservation equation related to phase change;
    % CTT_Lg = Storage coefficient in energy conservation equation related to liquid and gas;
    % CTT_g  = Storage coefficient in energy conservation equation related to air;
    % CTT_LT = Storage coefficient in energy conservation equation related to liquid and temperature;
    % EfTCON = Effective heat conductivity Johansen method;
    % TETCON = Effective heat conductivity Johansen method;
    % CTh = Storage coefficient in energy conservation equation related to matric head;
    % CTT = Storage coefficient in energy conservation equation related to temperature;
    % CTa = Storage coefficient in energy conservation equation related to soil air pressure;
    % KTh = Conduction coefficient in energy conservation equation related to matric head;
    % KTT = Conduction coefficient in energy conservation equation related to temperature;
    % KTa = Conduction coefficient in energy conservation equation related to soil air pressure;
    % VTT = Conduction coefficient in energy conservation equation related to matric head;
    % VTh = Conduction coefficient in energy conservation equation related to temperature;
    % VTa = Conduction coefficient in energy conservation equation related to soil air pressure;
    % CTg = Gravity coefficient in energy conservation equation;
    % Kcva = Conduction coefficient of vapor transport in energy conservation equation related to soil air pressure;
    % Kcah = Conduction coefficient of dry air transport in energy conservation equation related to matric head;
    % KcaT = Conduction coefficient of dry air transport in energy conservation equation related to temperature;
    % Kcaa = Conduction coefficient of dry air transport in energy conservation equation related to soil air pressure;
    % Ccah = Storage coefficient of dry air transport in energy conservation equation related to matric head;
    % CcaT = Storage coefficient of dry air transport in energy conservation equation related to temperature;
    % Ccaa = Storage coefficient of dry air transport in energy conservation equation related to soil air pressure;

    fields = {
              'alpha_h', 'bx', 'Srt', 'DTheta_LLh', 'DTheta_UUh', ...
              'SAVEDTheta_UUh', 'SAVEDTheta_LLh', 'Lambda_eff', ...
              'Ratio_ice', 'KL_h', 'KfL_h', 'KfL_T', 'KL_T', 'D_Ta', 'Theta_L', ...
              'Theta_LL', 'Theta_U', 'Theta_UU', 'Theta_I', 'Theta_II', 'Se', ...
              'Theta_V', 'W', 'WW', 'MU_W', 'f0', 'L_WT', 'EHCAP', 'Chh', 'ChT', ...
              'Khh', 'KhT', 'Kha', 'Vvh', 'VvT', 'Chg', 'C1', 'C2', 'C3', 'C4', ...
              'C5', 'C6', 'QL', 'QL_h', 'QL_T', 'D_V', 'k_g', ...
              'Sa', 'V_A', 'Alpha_Lg', 'Eta', 'Theta_g', 'Beta_g', 'Cah', ...
              'CaT', 'Caa', 'Kah', 'KaT', 'Kaa', 'Vah', 'VaT', 'Vaa', 'Cag', 'c_unsat', ...
              'CTT_PH', 'CTT_Lg', 'CTT_g', 'CTT_LT', 'CTh', 'CTT', 'CTa', 'KTh', 'KTT', ...
              'KTa', 'VTT', 'VTh', 'VTa', 'CTg', 'Kcva', ...
              'Kcah', 'KcaT', 'Kcaa', 'Ccah', 'CcaT', 'Ccaa'
             };
    structures{1} = helpers.createStructure(zeros(mL, nD), fields);

    %% Structure 2: variables with zeros(mL, 1)
    % DTDZ
    % DRHOVZ
    % D_Vg = Gas phase longitudinal dispersion coefficient (m^2/s^-1);
    % QL_dispts = Dispersive moisture mass flux in one time step;
    % DRHOVhDz
    % EtaBAR
    % DRHOVTDz
    % KLhBAR
    % DEhBAR
    % KLTBAR
    % DTDBAR
    % QLH
    % QLT
    % DVH
    % DVT
    % QVH
    % QVT
    % QV
    % QVa
    % Qa
    % DPgDZ
    % QL_a

    fields = {
              'DhDZ', 'DTDZ', 'DRHOVZ', 'D_Vg', ...
              'DRHOVhDz', 'EtaBAR', 'DRHOVTDz', 'KLhBAR', 'DEhBAR', ...
              'KLTBAR', 'DTDBAR', 'QLH', 'QLT', 'DVH', 'DVT', 'QVH', 'QVT', 'QV', ...
              'QVa', 'Qa', 'DPgDZ', 'QL_a'
             };
    structures{2} = helpers.createStructure(zeros(mL, 1), fields);

    %% Structure 3: variables with zeros(ML, 1)
    fields = {
              'Ksoil', 'SMC', 'bbx', 'frac', 'wfrac'
             };
    % TODO issue: ML is index
    structures{3} = helpers.createStructure(zeros(ML, 1), fields);

    %% Structure 4: variables with zeros(Nmsrmn, 1)
    % Precip = Precipitation(m.s^-1);
    % Ta = Air temperature;
    % Ts = Surface temperature;
    % U = Wind speed (m.s^-1);
    % HR_a = Air relative humidity;
    % Rns = Net shortwave radiation(W/m^-2);
    % Rnl = Net longwave radiation(W/m^-2);
    % Rn
    % h_SUR = Observed matric potential at surface;
    % SH = Sensible heat (W/m^-2);
    % MO = Monin-Obukhov's stability parameter (MO Length);
    % Zeta_MO = Atmospheric stability parameter;
    % TopPg = Atmospheric pressure above the surface as the boundary condition (Pa);

    Nmsrmn = Dur_tot * 10; % Here, it is made as big as possible, in case a long simulation period containing many time step is defined.
    fields = {
              'Ta', 'Ts', 'U', 'HR_a', 'Rns', 'Rnl', 'Rn', ...
              'h_SUR', 'SH', 'MO', 'Zeta_MO', 'TopPg'
             };
    structures{4} = helpers.createStructure(zeros(Nmsrmn, 1), fields);

    %% Structure 5: variables with zeros(Nmsrmn / 10, 1)
    fields = {
              'Tbtm', 'r_a_SOIL', 'Rn_SOIL', 'PSItot', 'sfactortot', 'Tsur'
             };
    structures{5} = helpers.createStructure(zeros(Dur_tot, 1), fields);

    %% Structure 6: variables with zeros(mN, 1)
    % P_g = Soil air pressure at the start of current time step;
    % P_gg = Soil air pressure at the end of current time step;
    % h = The matric head at the start of current time step;
    % h_frez = The freeze depression head at the start of current time step;
    % hh_frez = The freeze depression head at the end of current time step;
    % XCAP
    % T = The soil temperature at the start of current time step;
    % TT = The soil temperature at the end of current time step;
    % T_CRIT = The soil ice critical temperature at the start of current time step;
    % TT_CRIT = The soil ice critical temperature at the start of current time step;
    % EPCT
    % DhT = Difference of matric head with respect to temperature; m. kg.m^-1.s^-1
    % RHS = The right hand side part of equations in '*_EQ' subroutine;
    % C7 = Gravity term coefficients;
    % C9 = root water uptake coefficients;
    % HR = The relative humidity in soil pores, used for calculatin the vapor density;
    % RHOV_s = Saturated vapor density in soil pores (kg/m^-3);
    % RHOV = Vapor density in soil pores (kg/m^-3);
    % DRHOV_sT = Derivative of saturated vapor density with respect to temperature;
    % DRHOVh = Derivative of vapor density with respect to matric head;
    % DRHOVT = Derivative of vapor density with respect to temperature;
    % RHODA = Dry air density in soil pores(kg/m^-3);
    % DRHODAt = Derivative of dry air density with respect to time;
    % DRHODAz = Derivative of dry air density with respect to distance;
    % Xaa = Coefficients of derivative of dry air density with respect to temperature and matric head;
    % XaT = Coefficients of derivative of dry air density with respect to temperature and matric head;
    % Xah = Coefficients of derivative of dry air density with respect to temperature and matric head;
    % D_A = Diffusivity of water vapor in air (m^2/s^-1);
    % L = The latent heat of vaporization at the beginning of the time step;
    % LL = The latent heat of vaporization at the end of the time step;
    % hOLD = Array used to get the matric head at the end of last time step and extraplot the matric head at the start of current time step;
    % TOLD = The same meanings of hOLD,but for temperature;
    % P_gOLD = The same meanins of TOLD,but for soil air pressure;

    fields = {
              'P_g', 'P_gg', 'h', 'h_frez', 'hh_frez', 'XCAP', ...
              'T', 'TT', 'T_CRIT', 'TT_CRIT', 'EPCT', 'DhT', 'RHS', ...
              'C7', 'C9', 'HR', 'RHOV_s', 'RHOV', 'DRHOV_sT', 'DRHOVh', ...
              'DRHOVT', 'RHODA', 'DRHODAt', 'DRHODAz', 'Xaa', 'XaT', ...
              'Xah', 'D_A', 'L', 'LL', 'hOLD', 'TOLD', 'P_gOLD'
             };
    structures{6} = helpers.createStructure(zeros(mN, 1), fields);

    % merge all structures
    InitialValues = struct();
    for i = 1:numel(structures)
        structure = structures{i};
        for field = fieldnames(structure)'
            InitialValues.(field{1}) = structure.(field{1});
        end
    end

    % Arraies for calculating boundary flux;
    InitialValues.SAVE = zeros(3, 3, 3);
end
