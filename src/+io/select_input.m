function [soil,leafbio,canopy,meteo,angles,xyt] = select_input(ScopeParameters,vi,canopy,options,xyt,soil)
global Theta_LL theta_s0
soil.spectrum      = ScopeParameters.spectrum(vi(16));
soil.rss           = ScopeParameters.rss(vi(17));
soil.rs_thermal    = ScopeParameters.rs_thermal(vi(18));
soil.cs            = ScopeParameters.cs(vi(19));
soil.rhos          = ScopeParameters.rhos(vi(20));
soil.CSSOIL        = ScopeParameters.CSSOIL(vi(43));
soil.lambdas       = ScopeParameters.lambdas(vi(21));
soil.rbs           = ScopeParameters.rbs(vi(44));
soil.SMC           = Theta_LL(54,1); %%%%%%% soil.SMC = flip£¨Theta_LL£©£¨:,1£©
soil.BSMBrightness = ScopeParameters.BSMBrightness(vi(61));
soil.BSMlat	       = ScopeParameters.BSMlat(vi(62));
soil.BSMlon	       = ScopeParameters.BSMlon(vi(63));

leafbio.Cab     = ScopeParameters.Cab(vi(1));
leafbio.Cca     = ScopeParameters.Cca(vi(2));
if options.Cca_function_of_Cab
    leafbio.Cca = 0.25*ScopeParameters.Cab(vi(1));
end
leafbio.Cdm     = ScopeParameters.Cdm(vi(3));
leafbio.Cw      = ScopeParameters.Cw(vi(4));
leafbio.Cs      = ScopeParameters.Cs(vi(5));
leafbio.Cant    = ScopeParameters.Cant(vi(60));
leafbio.N       = ScopeParameters.N(vi(6));
leafbio.Vcmo    = ScopeParameters.Vcmo(vi(9));
leafbio.m       = ScopeParameters.m(vi(10));
leafbio.BallBerry0 = ScopeParameters.BallBerry0(vi(64)); % JAK 2016-10. Accidentally left out of v1.70
leafbio.Type    = ScopeParameters.Type(vi(11));
leafbio.Tparam  = ScopeParameters.Tparam; % this is correct (: instead of 14)
fqe             = ScopeParameters.fqe(vi(15));
leafbio.Rdparam = ScopeParameters.Rdparam(vi(13));

leafbio.rho_thermal = ScopeParameters.rho_thermal(vi(7));
leafbio.tau_thermal = ScopeParameters.tau_thermal(vi(8));

leafbio.Tyear         = ScopeParameters.Tyear(vi(55));
leafbio.beta          = ScopeParameters.beta(vi(56));
leafbio.kNPQs         = ScopeParameters.kNPQs(vi(57));
leafbio.qLs           = ScopeParameters.qLs(vi(58));
leafbio.stressfactor  = ScopeParameters.stressfactor(vi(59));

canopy.LAI  = ScopeParameters.LAI(vi(22));
canopy.hc  = ScopeParameters.hc(vi(23));
canopy.LIDFa = ScopeParameters.LIDFa(vi(26));
canopy.LIDFb  = ScopeParameters.LIDFb(vi(26)); % this is correct (26 instead of 27)
canopy.leafwidth  = ScopeParameters.leafwidth(vi(28));
canopy.rb   = ScopeParameters.rb(vi(38));
canopy.Cd  = ScopeParameters.Cd(vi(39));
canopy.CR = ScopeParameters.CR(vi(40));
canopy.CD1  = ScopeParameters.CD1(vi(41));
canopy.Psicor  = ScopeParameters.Psicor(vi(42));
canopy.rwc  = ScopeParameters.rwc(vi(45));
canopy.kV = ScopeParameters.kV(vi(12));
canopy.zo  = ScopeParameters.zo(vi(24));
canopy.d = ScopeParameters.d(vi(25));

meteo.z  = ScopeParameters.z(vi(29));
meteo.Rin   = ScopeParameters.Rin(vi(30));
meteo.Ta = ScopeParameters.Ta(vi(31));
meteo.Rli  = ScopeParameters.Rli(vi(32));
meteo.p  = ScopeParameters.p(vi(33));
meteo.ea  = ScopeParameters.ea(vi(34));
meteo.u   = ScopeParameters.u(vi(35));
meteo.Ca = ScopeParameters.Ca(vi(36));
meteo.Oa  = ScopeParameters.Oa(vi(37));

xyt.startDOY = ScopeParameters.startDOY(vi(46));
xyt.endDOY = ScopeParameters.endDOY(vi(47));
xyt.LAT = ScopeParameters.LAT(vi(48));
xyt.LON = ScopeParameters.LON(vi(49));
xyt.timezn = ScopeParameters.timezn(vi(50));

angles.tts = ScopeParameters.tts(vi(51));
angles.tto = ScopeParameters.tto(vi(52));
angles.psi = ScopeParameters.psi(vi(53));

%% derived input
if options.soil_heat_method ==1
    soil.GAM =  equations.Soil_Inertia1(soil.SMC);
else
    soil.GAM  = equations.Soil_Inertia0(soil.cs,soil.rhos,soil.lambdas);
end
if options.calc_rss_rbs
    [soil.rss,soil.rbs] = equations.calc_rssrbs(soil.SMC,canopy.LAI,soil.rbs);
end

if leafbio.Type
    leafbio.Type = 'C4';
else
    leafbio.Type = 'C3';
end
canopy.hot  = canopy.leafwidth/canopy.hc;
if options.calc_zo
    [canopy.zo,canopy.d ]  = equations.zo_and_d(soil,canopy);
end

if options.calc_PSI == 1
    leafbio.fqe(1) = fqe/5;
    leafbio.fqe(2) = fqe;
else
    leafbio.fqe = fqe;
end