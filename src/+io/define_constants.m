function [const] = define_constants()

    const.A = 6.02214E23; % [mol-1] Constant of Avogadro
    const.h = 6.6262E-34; % [J s] Planck's constant
    const.c = 299792458; % [m s-1] Speed of light
    const.cp = 1004; % [J kg-1 K-1] Specific heat of dry air
    const.cp_specific =  1.013E-3; % specific heat at cte pressure [MJ.kg-1.?C-1] FAO56 p26 box6
    const.R = 8.314; % [J mol-1K-1] Molar gas constant
    const.R_specific = 0.287; % specific gas [kJ.kg-1.K-1]    FAO56 p26 box6
    const.rhoa = 1.2047; % [kg m-3] Specific mass of air
    const.kappa = 0.4; % [] Von Karman constant
    const.MH2O = 18; % [g mol-1] Molecular mass of water
    const.Mair = 28.96; % [g mol-1] Molecular mass of dry air
    const.MCO2 = 44; % [g mol-1] Molecular mass of carbon dioxide
    const.sigmaSB = 5.67E-8; % [W m-2 K-4] Stefan Boltzman constant
    const.deg2rad = pi / 180; % [rad] Conversion from deg to rad
    const.C2K = 273.15; % [K] Melting point of water
    const.CKTN = (50 + 2.575 * 20); % [] Constant used in calculating viscosity factor for hydraulic conductivity
    const.l = 0.5; % Coefficient in VG model
    const.g = 981; % [cm s-2] Gravity acceleration
    const.RHOL = 1; % [g cm-3] Water density
    const.RHOI = 0.92; % [g cm-3] Ice density
    const.Rv = 461.5 * 1e4; % [cm2 s-2 Cels-1] Gas constant for vapor (original J.kg^-1.Cels^-1)
    const.RDA = 287.1 * 1e4; % [cm2 s-2 Cels-1] Gas constant for dry air (original J.kg^-1.Cels^-1)
    const.RHO_bulk = 1.25; % [g cm-3] Bulk density of sand
    const.Hc = 0.02; % Henry's constant;
    const.GWT = 7; % The gain factor(dimensionless),which assesses the temperature % dependence of the soil water retention curve is set as 7 for % sand (Noborio et al, 1996)
    const.MU_a = 1.846 * 10^(-4); % [g cm-1 s-1] Viscosity of air (original 1.846*10^(-5)kg.m^-1.s^-1)
    const.Gamma0 = 71.89; % [g s-2] The surface tension of soil water at 25 Cels degree
    const.Gamma_w = const.RHOL * const.g; % [g cm-2 s-2] Specific weight of water
    const.Lambda1 = 0.228 / 100; % Coefficients in thermal conductivity
    const.Lambda2 = -2.406 / 100; % [W m-1 Cels-1] (1 W.s=J) From HYDRUS1D heat transport parameter (Chung Hortan 1987 WRR)
    const.Lambda3 = 4.909 / 100; %
    const.MU_W0 = 2.4152 * 10^(-4); % [g cm-1 s-1] Viscosity of water at reference temperature(original 2.4152*10^(-5)kg.m^-1.s^-1)
    const.MU1 = 4742.8; % [J mol-1] Coefficient for calculating viscosity of water
    const.b = 4 * 10^(-6); % [cm] Coefficient for calculating viscosity of water
    const.W0 = 1.001 * 10^3; % Coefficient for calculating differential heat of wetting by Milly's method
    const.c_L = 4.186; % [J/g-1/Cels-1] Specific heat capacity of liquid water, Notice the original unit is 4186kg^-1
    const.c_V = 1.870; % [J/g-1/Cels-1] Specific heat capacity of vapor
    const.c_a = 1.005; % [J/g-1/Cels-1] Specific heat capacity of dry air
    const.c_i = 2.0455; % [J/g-1/Cels-1] Specific heat capacity of ice
    const.lambdav = 2.45; % latent heat of evaporation [MJ.kg-1] FAO56 pag 31
    const.k = 0.41; % karman's cte   []  FAO 56 Eq4
    const.kB = 1.380649E-23; % [J k-1] Boltzmann constant
    const.F = 96485.3321233100184; % [C mol-1] Faraday constant
end
