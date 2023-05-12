function [SoilProperties, leafbio, canopy, meteo, angles, SpaceTimeInfo] = select_input(ScopeParameters, Theta_LL, kappa, digitsVector, canopy, options, SpaceTimeInfo, SoilProperties)

    SoilProperties.spectrum      = ScopeParameters.spectrum(digitsVector(16));
    SoilProperties.rss           = ScopeParameters.rss(digitsVector(17));
    SoilProperties.rs_thermal    = ScopeParameters.rs_thermal(digitsVector(18));
    SoilProperties.cs            = ScopeParameters.cs(digitsVector(19));
    SoilProperties.rhos          = ScopeParameters.rhos(digitsVector(20));
    SoilProperties.CSSOIL        = ScopeParameters.CSSOIL(digitsVector(43));
    SoilProperties.lambdas       = ScopeParameters.lambdas(digitsVector(21));
    SoilProperties.rbs           = ScopeParameters.rbs(digitsVector(44));
    SoilProperties.SMC           = Theta_LL(54, 1);
    SoilProperties.BSMBrightness = ScopeParameters.BSMBrightness(digitsVector(61));
    SoilProperties.BSMlat          = ScopeParameters.BSMlat(digitsVector(62));
    SoilProperties.BSMlon          = ScopeParameters.BSMlon(digitsVector(63));

    leafbio.Cab     = ScopeParameters.Cab(digitsVector(1));
    leafbio.Cca     = ScopeParameters.Cca(digitsVector(2));
    if options.Cca_function_of_Cab
        leafbio.Cca = 0.25 * ScopeParameters.Cab(digitsVector(1));
    end
    leafbio.Cdm     = ScopeParameters.Cdm(digitsVector(3));
    leafbio.Cw      = ScopeParameters.Cw(digitsVector(4));
    leafbio.Cs      = ScopeParameters.Cs(digitsVector(5));
    leafbio.Cant    = ScopeParameters.Cant(digitsVector(60));
    leafbio.N       = ScopeParameters.N(digitsVector(6));
    leafbio.Vcmo    = ScopeParameters.Vcmo(digitsVector(9));
    leafbio.m       = ScopeParameters.m(digitsVector(10));
    leafbio.BallBerry0 = ScopeParameters.BallBerry0(digitsVector(64)); % JAK 2016-10. Accidentally left out of v1.70
    leafbio.Type    = ScopeParameters.Type(digitsVector(11));
    leafbio.Tparam  = ScopeParameters.Tparam; % this is correct (: instead of 14)
    fqe             = ScopeParameters.fqe(digitsVector(15));
    leafbio.Rdparam = ScopeParameters.Rdparam(digitsVector(13));

    leafbio.rho_thermal = ScopeParameters.rho_thermal(digitsVector(7));
    leafbio.tau_thermal = ScopeParameters.tau_thermal(digitsVector(8));

    leafbio.Tyear         = ScopeParameters.Tyear(digitsVector(55));
    leafbio.beta          = ScopeParameters.beta(digitsVector(56));
    leafbio.kNPQs         = ScopeParameters.kNPQs(digitsVector(57));
    leafbio.qLs           = ScopeParameters.qLs(digitsVector(58));
    leafbio.stressfactor  = ScopeParameters.stressfactor(digitsVector(59));

    canopy.LAI  = ScopeParameters.LAI(digitsVector(22));
    canopy.hc  = ScopeParameters.hc(digitsVector(23));
    canopy.LIDFa = ScopeParameters.LIDFa(digitsVector(26));
    canopy.LIDFb  = ScopeParameters.LIDFb(digitsVector(26)); % this is correct (26 instead of 27)
    canopy.leafwidth  = ScopeParameters.leafwidth(digitsVector(28));
    canopy.rb   = ScopeParameters.rb(digitsVector(38));
    canopy.Cd  = ScopeParameters.Cd(digitsVector(39));
    canopy.CR = ScopeParameters.CR(digitsVector(40));
    canopy.CD1  = ScopeParameters.CD1(digitsVector(41));
    canopy.Psicor  = ScopeParameters.Psicor(digitsVector(42));
    canopy.rwc  = ScopeParameters.rwc(digitsVector(45));
    canopy.kV = ScopeParameters.kV(digitsVector(12));
    canopy.zo  = ScopeParameters.zo(digitsVector(24));
    canopy.d = ScopeParameters.d(digitsVector(25));

    meteo.z  = ScopeParameters.z(digitsVector(29));
    meteo.Rin   = ScopeParameters.Rin(digitsVector(30));
    meteo.Ta = ScopeParameters.Ta(digitsVector(31));
    meteo.Rli  = ScopeParameters.Rli(digitsVector(32));
    meteo.p  = ScopeParameters.p(digitsVector(33));
    meteo.ea  = ScopeParameters.ea(digitsVector(34));
    meteo.u   = ScopeParameters.u(digitsVector(35));
    meteo.Ca = ScopeParameters.Ca(digitsVector(36));
    meteo.Oa  = ScopeParameters.Oa(digitsVector(37));

    SpaceTimeInfo.startDOY = ScopeParameters.startDOY(digitsVector(46));
    SpaceTimeInfo.endDOY = ScopeParameters.endDOY(digitsVector(47));
    SpaceTimeInfo.LAT = ScopeParameters.LAT(digitsVector(48));
    SpaceTimeInfo.LON = ScopeParameters.LON(digitsVector(49));
    SpaceTimeInfo.timezn = ScopeParameters.timezn(digitsVector(50));

    angles.tts = ScopeParameters.tts(digitsVector(51));
    angles.tto = ScopeParameters.tto(digitsVector(52));
    angles.psi = ScopeParameters.psi(digitsVector(53));

    %% derived input
    if options.soil_heat_method == 1
        SoilProperties.GAM =  equations.Soil_Inertia1(SoilProperties.SMC);
    else
        SoilProperties.GAM  = equations.Soil_Inertia0(SoilProperties.cs, SoilProperties.rhos, SoilProperties.lambdas);
    end
    if options.calc_rss_rbs
        [SoilProperties.rss, SoilProperties.rbs] = equations.calc_rssrbs(SoilProperties.SMC, canopy.LAI, SoilProperties.rbs);
    end

    if leafbio.Type
        leafbio.Type = 'C4';
    else
        leafbio.Type = 'C3';
    end
    canopy.hot  = canopy.leafwidth / canopy.hc;
    if options.calc_zo
        [canopy.zo, canopy.d]  = equations.zo_and_d(SoilProperties, canopy, kappa);
    end

    if options.calc_PSI == 1
        leafbio.fqe(1) = fqe / 5;
        leafbio.fqe(2) = fqe;
    else
        leafbio.fqe = fqe;
    end
