function [soil,leafbio,canopy,meteo,angles,xyt] = select_input(ScopeParameters,vi,canopy,options,xyt,soil)
global Theta_LL theta_s0
soil.spectrum      = ScopeParameters.spectrum(1);
soil.rss           = ScopeParameters(17).Val(vi(17));
soil.rs_thermal    = ScopeParameters(18).Val(vi(18));
soil.cs            = ScopeParameters(19).Val(vi(19));
soil.rhos          = ScopeParameters(20).Val(vi(20));
soil.CSSOIL        = ScopeParameters(43).Val(vi(43));
soil.lambdas       = ScopeParameters(21).Val(vi(21));
soil.rbs           = ScopeParameters(44).Val(vi(44));
soil.SMC           = Theta_LL(54,1); %%%%%%% soil.SMC = flip£¨Theta_LL£©£¨:,1£©
soil.BSMBrightness = ScopeParameters(61).Val(vi(61));
soil.BSMlat	       = ScopeParameters(62).Val(vi(62));
soil.BSMlon	       = ScopeParameters(63).Val(vi(63));

leafbio.Cab     = ScopeParameters(1).Val(vi(1));
leafbio.Cca     = ScopeParameters(2).Val(vi(2));
if options.Cca_function_of_Cab
    leafbio.Cca = 0.25*ScopeParameters(1).Val(vi(1));
end
leafbio.Cdm     = ScopeParameters(3).Val(vi(3));
leafbio.Cw      = ScopeParameters(4).Val(vi(4));
leafbio.Cs      = ScopeParameters(5).Val(vi(5));
leafbio.Cant    = ScopeParameters(60).Val(vi(60));
leafbio.N       = ScopeParameters(6).Val(vi(6));
leafbio.Vcmo    = ScopeParameters(9).Val(vi(9));
leafbio.m       = ScopeParameters(10).Val(vi(10));
leafbio.BallBerry0 = ScopeParameters(64).Val(vi(64)); % JAK 2016-10. Accidentally left out of v1.70
leafbio.Type    = ScopeParameters(11).Val(vi(11));
leafbio.Tparam  = ScopeParameters(14).Val(:); % this is correct (: instead of 14)
fqe             = ScopeParameters(15).Val(vi(15));
leafbio.Rdparam = ScopeParameters(13).Val(vi(13));

leafbio.rho_thermal = ScopeParameters(7).Val(vi(7));
leafbio.tau_thermal = ScopeParameters(8).Val(vi(8));

leafbio.Tyear         = ScopeParameters(55).Val(vi(55));
leafbio.beta          = ScopeParameters(56).Val(vi(56));
leafbio.kNPQs         = ScopeParameters(57).Val(vi(57));
leafbio.qLs           = ScopeParameters(58).Val(vi(58));
leafbio.stressfactor  = ScopeParameters(59).Val(vi(59));

canopy.LAI  = ScopeParameters(22).Val(vi(22));
canopy.hc  = ScopeParameters(23).Val(vi(23));
canopy.LIDFa = ScopeParameters(26).Val(vi(26));
canopy.LIDFb  = ScopeParameters(27).Val(vi(26)); % this is correct (26 instead of 27)
canopy.leafwidth  = ScopeParameters(28).Val(vi(28));
canopy.rb   = ScopeParameters(38).Val(vi(38));
canopy.Cd  = ScopeParameters(39).Val(vi(39));
canopy.CR = ScopeParameters(40).Val(vi(40));
canopy.CD1  = ScopeParameters(41).Val(vi(41));
canopy.Psicor  = ScopeParameters(42).Val(vi(42));
canopy.rwc  = ScopeParameters(45).Val(vi(45));
canopy.kV = ScopeParameters(12).Val(vi(12));
canopy.zo  = ScopeParameters(24).Val(vi(24));
canopy.d = ScopeParameters(25).Val(vi(25));

meteo.z  = ScopeParameters(29).Val(vi(29));
meteo.Rin   = ScopeParameters(30).Val(vi(30));
meteo.Ta = ScopeParameters(31).Val(vi(31));
meteo.Rli  = ScopeParameters(32).Val(vi(32));
meteo.p  = ScopeParameters(33).Val(vi(33));
meteo.ea  = ScopeParameters(34).Val(vi(34));
meteo.u   = ScopeParameters(35).Val(vi(35));
meteo.Ca = ScopeParameters(36).Val(vi(36));
meteo.Oa  = ScopeParameters(37).Val(vi(37));

xyt.startDOY = ScopeParameters(46).Val(vi(46));
xyt.endDOY = ScopeParameters(47).Val(vi(47));
xyt.LAT = ScopeParameters(48).Val(vi(48));
xyt.LON = ScopeParameters(49).Val(vi(49));
xyt.timezn = ScopeParameters(50).Val(vi(50));

angles.tts = ScopeParameters(51).Val(vi(51));
angles.tto = ScopeParameters(52).Val(vi(52));
angles.psi = ScopeParameters(53).Val(vi(53));

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