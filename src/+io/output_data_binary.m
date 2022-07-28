function n_col = output_data_binary(f, k, xyt, rad,  canopy, V, vi, vmax, options, fluxes, meteo, iter, thermal,spectral, gap, profiles, Sim_Theta_U, Sim_Temp, Trap, Evap)
%% OUTPUT DATA
% author C. Van der Tol
% date:      30 Nov 2019 

%%
if isdatetime(xyt.t)
    get_doy = @(x) juliandate(x) - juliandate(datetime(year(x), 1, 0));
    V(46).Val = get_doy(timestamp2datetime(xyt.startDOY));
    V(47).Val = get_doy(timestamp2datetime(xyt.endDOY));
    xyt.t = get_doy(xyt.t);
end

%% Fluxes product
flu_out = [k iter.counter xyt.year(k) xyt.t(k) fluxes.Rntot fluxes.lEtot fluxes.Htot fluxes.Rnctot fluxes.lEctot, ...
    fluxes.Hctot fluxes.Actot fluxes.Rnstot fluxes.lEstot fluxes.Hstot fluxes.Gtot fluxes.Resp 1E6*fluxes.aPAR, ...
    1E6*fluxes.aPAR_Cab fluxes.aPAR/rad.PAR fluxes.aPAR_Wm2 1E6*rad.PAR rad.Eoutf rad.Eoutf./fluxes.aPAR_Wm2 Trap(k)*10 Evap(k)*10 Trap(k)*10+Evap(k)*10 fluxes.GPP fluxes.NEE];
n_col.flu = length(flu_out);
fwrite(f.flu_file,flu_out,'double');

%% surftemp
surftemp_out =  [k xyt.year(k) xyt.t(k) thermal.Ta thermal.Ts(1) thermal.Ts(2) thermal.Tcave thermal.Tsave];
n_col.surftemp = length(surftemp_out);
fwrite(f.surftemp_file,surftemp_out,'double');

%% aerodyn
aerodyn_out =  [k xyt.year(k) xyt.t(k) thermal.raa, thermal.rawc, thermal.raws, thermal.ustar, thermal.raa+thermal.rawc, thermal.raa+thermal.raws];
n_col.aerodyn = length(aerodyn_out);
fwrite(f.aerodyn_file,aerodyn_out,'double');

%% radiation
radiation_out =  [k xyt.year(k) xyt.t(k) meteo.Rin meteo.Rli rad.Eouto rad.Eoutt + rad.Eoutte  rad.Eouto+rad.Eoutt + rad.Eoutte meteo.Rin-rad.Eouto meteo.Rli-rad.Eoutt-rad.Eoutte fluxes.Rntot];
n_col.radiation = length(radiation_out);
fwrite(f.radiation_file,radiation_out,'double');

%% Soil temperature
Sim_Theta_out =  [Sim_Theta_U(k,:)];
n_col.Sim_Theta = length(Sim_Theta_out);
fwrite(f.Sim_Theta_file,Sim_Theta_out,'double');
Sim_Temp_out =  [Sim_Temp(k,:)];
n_col.Sim_Temp = length(Sim_Temp_out);
fwrite(f.Sim_Temp_file,Sim_Temp_out,'double');
%% spectrum (added on 19 September 2008)
spectrum_hemis_optical_out =  rad.Eout_;
n_col.spectrum_hemis_optical = length(spectrum_hemis_optical_out);
fwrite(f.spectrum_hemis_optical_file,spectrum_hemis_optical_out,'double');

spectrum_obsdir_optical_out =  [rad.Lo_'];
n_col.spectrum_obsdir_optical = length(spectrum_obsdir_optical_out);
fwrite(f.spectrum_obsdir_optical_file,spectrum_obsdir_optical_out,'double');

if options.calc_ebal

    spectrum_obsdir_BlackBody_out =  [rad.LotBB_'];
    n_col.spectrum_obsdir_BlackBody = length(spectrum_obsdir_BlackBody_out);
    fwrite(f.spectrum_obsdir_BlackBody_file,spectrum_obsdir_BlackBody_out,'double');
    
    if options.calc_planck
        
      spectrum_hemis_thermal_out =  [rad.Eoutte_']; 
      n_col.spectrum_hemis_thermal = length(spectrum_hemis_thermal_out);
      fwrite(f.spectrum_hemis_thermal_file,spectrum_hemis_thermal_out,'double');
    
      spectrum_obsdir_thermal_out =  [rad.Lot_'];
      n_col.spectrum_obsdir_thermal = length(spectrum_obsdir_thermal_out);
      fwrite(f.spectrum_obsdir_thermal_file,spectrum_obsdir_thermal_out,'double');
      
    end
end

      irradiance_spectra_out =  [meteo.Rin*(rad.fEsuno+rad.fEskyo)'];
      n_col.irradiance_spectra = length(irradiance_spectra_out);
      fwrite(f.irradiance_spectra_file,irradiance_spectra_out,'double');
      
      reflectance = pi*rad.Lo_./(rad.Esun_+rad.Esky_);
      reflectance(spectral.wlS>3000) = NaN;
      reflectance_out =  [reflectance'];
      n_col.reflectance = length(reflectance_out);
      fwrite(f.reflectance_file,reflectance_out,'double');
%% input and parameter values (added June 2012)

for i = 1:length(V)
pars_and_input_out =  [V(i).Val(vi(i))];
fwrite(f.pars_and_input_file,pars_and_input_out,'double');
end

k2 = find(vmax>1);
for i = 1:length(k2)
pars_and_input_short_out =  [V(k2(i)).Val(vi(k2(i)))];
fwrite(f.pars_and_input_short_file,pars_and_input_short_out,'double');
end

%% Optional Output

if options.calc_vert_profiles
    
    % gap
    gap_out   =  [gap.Ps gap.Po gap.Pso];
    n_col.gap = numel(gap_out(:));
    fwrite(f.gap_file,gap_out,'double');
    
    layer_aPAR_out   =  [1E6*profiles.Pn1d' 0];
    n_col.layer_aPAR = length(layer_aPAR_out);
    fwrite(f.layer_aPAR_file,layer_aPAR_out,'double');
    
    layer_aPAR_Cab_out   =  [1E6*profiles.Pn1d_Cab' 0];
    n_col.layer_aPAR_Cab = length(layer_aPAR_Cab_out);
    fwrite(f.layer_aPAR_Cab_file,layer_aPAR_Cab_out,'double');   
    
    if options.calc_ebal
        
        % leaftemp       
        leaftemp_out   =  [profiles.Tcu1d' profiles.Tch' profiles.Tc1d'];
        n_col.leaftemp = length(leaftemp_out);
        fwrite(f.leaftemp_file,leaftemp_out,'double');   
        
        layer_H_out    =  [profiles.Hc1d' fluxes.Hstot];
        n_col.layer_H = length(layer_H_out);
        fwrite(f.layer_H_file,layer_H_out,'double');           
        
        layer_LE_out   =  [profiles.lEc1d' fluxes.lEstot];
        n_col.layer_LE = length(layer_LE_out);
        fwrite(f.layer_LE_file,layer_LE_out,'double');  
        
        layer_A_out    =  [profiles.A1d' fluxes.Resp];
        n_col.layer_A = length(layer_A_out);
        fwrite(f.layer_A_file,layer_A_out,'double');    
        
        layer_NPQ_out  =  [profiles.qE' 0];
        n_col.layer_NPQ = length(layer_NPQ_out);
        fwrite(f.layer_NPQ_file,layer_NPQ_out,'double');    
        
        layer_Rn_out  =  [profiles.Rn1d' fluxes.Rnstot];
        n_col.layer_Rn = length(layer_Rn_out);
        fwrite(f.layer_Rn_file,layer_Rn_out,'double');   
        
    end
    if options.calc_fluor
        layer_fluorescence_out  =  [profiles.fluorescence'];
        n_col.layer_fluorescence = length(layer_fluorescence_out);
        fwrite(f.layer_fluorescence_file,layer_fluorescence_out,'double');   
    end
end

if options.calc_fluor% && options.calc_ebal
    for j=1:size(spectral.wlF,1)
        fluorescence_out  =  [rad.LoF_];
        n_col.fluorescence = length(fluorescence_out);
        fwrite(f.fluorescence_file,fluorescence_out,'double');   
        
        if options.calc_PSI
              fluorescencePSI_out  =  [rad.LoF1_];
              n_col.fluorescencePSI = length(fluorescencePSI_out);
              fwrite(f.fluorescencePSI_file,fluorescencePSI_out,'double');     
              
              fluorescencePSII_out  =  [rad.LoF2_];
              n_col.fluorescencePSII = length(fluorescencePSII_out);
              fwrite(f.fluorescencePSII_file,fluorescencePSII_out,'double');    
        end
        
        fluorescence_hemis_out  =  [rad.Fhem_];
        n_col.fluorescence_hemis = length(fluorescence_hemis_out);
        fwrite(f.fluorescence_hemis_file,fluorescence_hemis_out,'double');    
        
        fluorescence_emitted_by_all_leaves_out  =  [rad.Fem_];
        n_col.fluorescence_emitted_by_all_leaves = length(fluorescence_emitted_by_all_leaves_out);
        fwrite(f.fluorescence_emitted_by_all_leaves_file,fluorescence_emitted_by_all_leaves_out,'double');      
        
        fluorescence_emitted_by_all_photosystems_out  =  [rad.Femtot];
        n_col.fluorescence_emitted_by_all_photosystems = length(fluorescence_emitted_by_all_photosystems_out);
        fwrite(f.fluorescence_emitted_by_all_photosystems_file,fluorescence_emitted_by_all_photosystems_out,'double');     
        
        fluorescence_sunlit_out  =  [sum(rad.LoF_sunlit,2)];
        n_col.fluorescence_sunlit = length(fluorescence_sunlit_out);
        fwrite(f.fluorescence_sunlit_file,fluorescence_sunlit_out,'double');       
        
        fluorescence_shaded_out  =  [sum(rad.LoF_shaded,2)];
        n_col.fluorescence_shaded = length(fluorescence_shaded_out);
        fwrite(f.fluorescence_shaded_file,fluorescence_shaded_out,'double');      
        
        fluorescence_scattered_out  =  [sum(rad.LoF_scattered,2)+sum(rad.LoF_soil,2)];
        n_col.fluorescence_scattered = length(fluorescence_scattered_out);
        fwrite(f.fluorescence_scattered_file,fluorescence_scattered_out,'double');        
        
    end    
end
        BOC_irradiance_out  =  [rad.Emin_(canopy.nlayers+1,:),rad.Emin_(canopy.nlayers+1,:)+(rad.Esun_*gap.Ps(canopy.nlayers+1)')'];
        n_col.BOC_irradiance = length(BOC_irradiance_out);
        fwrite(f.BOC_irradiance_file,BOC_irradiance_out,'double');       

%%
if options.calc_directional && options.calc_ebal
    Output_angle    =   [directional.tto';  directional.psi'; angles.tts*ones(size(directional.psi'))];
    Output_brdf     =   [spectral.wlS'     directional.brdf_];
    if options.calc_planck
        Output_temp =   [spectral.wlT'    directional.Lot_];
    else
        Output_temp =   [directional.BrightnessT];
    end
    if options.calc_fluor
        Output_fluor = [spectral.wlF'     directional.LoF_];
    end
    
    save([Output_dir,'Directional/',sprintf('BRDF (SunAngle %2.2f degrees).dat',angles.tts)],'Output_brdf' ,'-ASCII','-TABS')
    save([Output_dir,'Directional/',sprintf('Angles (SunAngle %2.2f degrees).dat',angles.tts)],'Output_angle','-ASCII','-TABS')
    save([Output_dir,'Directional/',sprintf('Temperatures (SunAngle %2.2f degrees).dat',angles.tts)],'Output_temp','-ASCII','-TABS')
    
    if options.calc_fluor
        save([Output_dir,'Directional/',sprintf('Fluorescence (SunAngle %2.2f degrees).dat',angles.tts)],'Output_fluor','-ASCII','-TABS')
    end
    
    fiddirtir       =   fopen([Output_dir,'Directional/','read me.txt'],'w');
    fprintf(fiddirtir,'The Directional data is written in three files: \r\n');
    fprintf(fiddirtir,'\r\n- Angles: contains the directions. \r\n');
    fprintf(fiddirtir,'   * The 1st row gives the observation zenith  angles\r\n');
    fprintf(fiddirtir,'   * The 2nd row gives the observation azimuth angles\r\n');
    fprintf(fiddirtir,'   * The 3rd row gives the solar       zenith  angles\r\n');
    fprintf(fiddirtir,'\r\n- Temperatures: contains the directional brightness temperature. \r\n');
    fprintf(fiddirtir,'   * The 1st column gives the wl values corresponding to the brightness temperature values (except for broadband)\r\n');
    fprintf(fiddirtir,'   * The 2nd column gives the Tb values corresponding to the directions given by first column in the Angles file\r\n');
    fprintf(fiddirtir,'\r\n- BRDF: contains the bidirectional distribution functions values. \r\n');
    fprintf(fiddirtir,'   * The 1st column gives the wl values corresponding to the BRDF values\r\n');
    fprintf(fiddirtir,'   * The 2nd column gives the BRDF values corresponding to the directions given by first column in the Angles file\r\n');
    fclose(fiddirtir);
end
end
