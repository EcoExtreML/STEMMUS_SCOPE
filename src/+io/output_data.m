function output_data(Output_dir, options, k, iter, xyt, fluxes, rad, thermal, gap, meteo, spectral, V, vi, vmax, profiles, directional, angles)
%% OUTPUT DATA
% author C. Van der Tol
% modified:      31 Jun 2008: (CvdT) included Pntot in output fluxes.dat
% last modified: 04 Aug 2008: (JT)   included variable output directories
%                31 Jul 2008: (CvdT) added layer_pn.dat
%                19 Sep 2008: (CvdT) spectrum of outgoing radiation
%                19 Sep 2008: (CvdT) Pntot added to fluxes.dat
%                15 Apr 2009: (CvdT) Rn added to vertical profiles
%                03 Oct 2012: (CvdT) included boolean variabel calcebal
%                04 Oct 2012: (CvdT) included reflectance and fPAR
%                10 Mar 2013: (CvdT) major revision: introduced structures
%                22 Nov 2013: (CvdT) added additional outputs
%% Standard output

% fluxes
fidf                = fopen([Output_dir,'fluxes.dat'],'a');
fprintf(fidf,'%9.0f %9.0f %9.0f %9.4f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f',...
    [k iter.counter xyt.year(k) xyt.t(k) fluxes.Rntot fluxes.lEtot fluxes.Htot fluxes.Rnctot fluxes.lEctot, ...
    fluxes.Hctot fluxes.Actot fluxes.Rnstot fluxes.lEstot fluxes.Hstot fluxes.Gtot fluxes.Resp 1E6*fluxes.aPAR,...
    1E6*fluxes.aPAR_Cab fluxes.aPAR/rad.PAR fluxes.aPAR_Wm2 1E6*rad.PAR]);
if options.calc_fluor
    fprintf(fidf,'%9.4f %9.6f', rad.Eoutf,  rad.Eoutf./fluxes.aPAR_Wm2);
end
fprintf(fidf,'\r');


%%
fclose all;
end