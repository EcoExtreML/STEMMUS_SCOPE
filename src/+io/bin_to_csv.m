function bin_to_csv(fnames, V, vmax, n_col, ns, options, SoilLayer)
%% flu
flu_names = {'simulation_number','nu_iterations','year','DoY',...
    'Rntot','lEtot','Htot', ...
    'Rnctot','lEctot','Hctot','Actot', ...
    'Rnstot','lEstot','Hstot','Gtot','Resp', ...
   'aPAR','aPAR_Cab','aPAR/rad.PAR','aPAR_Wm2','PAR','rad.Eoutf','rad.Eoutf./fluxes.aPAR_Wm2','Trap','Evap','ET','GPP','NEE'};
flu_units = {'','','','',  ...
    'W m-2','W m-2','W m-2',...
    'W m-2','W m-2','W m-2','umol m-2 s-1',...
    'W m-2',' W m-2','W m-2','W m-2','umol m-2 s-1',...
    'umol m-2 s-1',' umol m-2 s-1','umol m-2 s-1','W m-2','umol m-2 s-1','W m-2','W m-2','cm s-1','cm s-1','cm s-1','Kg m-2 s-1','Kg m-2 s-1'};
write_output(flu_names, flu_units, fnames.flu_file, n_col.flu, ns)

%% surftemp
surftemp_names = {'simulation_number','year','DoY',...
    'Ta','Ts(1)','Ts(2)','Tcave','Tsave'};
surftemp_units = {'','','',  ...
    'C','C','C','C','C'};
write_output(surftemp_names, surftemp_units, fnames.surftemp_file, n_col.surftemp, ns)

%% aerodyn
aerodyn_names = {'simulation_number','year','DoY',...
    'raa','rawc','raws','ustar','rac','ras'};
aerodyn_units = {'','','',  ...
    's m-1','s m-1','s m-1', 'm s-1','s m-1','s m-1'};
write_output(aerodyn_names, aerodyn_units, fnames.aerodyn_file, n_col.aerodyn, ns)

%% radiation
radiation_names = {'simulation_number','year','DoY',...
    'Rin','Rli','HemisOutShort','HemisOutLong','HemisOutTot','Netshort','Netlong','Rntot'};
radiation_units = {'','','',  ...
    'W m-2','W m-2','W m-2', 'W m-2','W m-2','W m-2','W m-2','W m-2'};
write_output(radiation_names, radiation_units, fnames.radiation_file, n_col.radiation, ns)

%% Get soil layer information
depth = string(SoilLayer.depth);
thickness = string(SoilLayer.thickness);
 
%% Prepare soil moisture data
Sim_Theta_names = [depth; thickness];
Sim_Theta_units = repelem({'m-3 m-3'}, length(depth));
write_output(Sim_Theta_names, Sim_Theta_units, ...
fnames.Sim_Theta_file, n_col.Sim_Theta, ns, true)

%% Prepare soil temperature data
Sim_Temp_names = [depth; thickness];
Sim_Temp_units = repelem({'oC'}, length(depth));
write_output(Sim_Temp_names, Sim_Temp_units, ...
fnames.Sim_Temp_file, n_col.Sim_Temp, ns, true)

%% spectrum (added on 19 September 2008)

spectrum_hemis_optical_names = {'hemispherically integrated radiation spectrum'};
spectrum_hemis_optical_units = {'W m-2 um-1'};
write_output(spectrum_hemis_optical_names, spectrum_hemis_optical_units, fnames.spectrum_hemis_optical_file, n_col.spectrum_hemis_optical, ns, true)

spectrum_obsdir_optical_names = {'radiance spectrum in observation direction'};
spectrum_obsdir_optical_units = {'W m-2 sr-1 um-1'};
write_output(spectrum_obsdir_optical_names, spectrum_obsdir_optical_units, fnames.spectrum_obsdir_optical_file, n_col.spectrum_obsdir_optical, ns, true)

if options.calc_ebal
    write_output({'thermal BlackBody emission spectrum in observation direction'}, {'W m-2 sr-1 um-1'}, ...
        fnames.spectrum_obsdir_BlackBody_file, n_col.spectrum_obsdir_BlackBody, ns, true)
     if options.calc_planck
         write_output({'thermal emission spectrum in hemispherical direction'}, {'W m-2 sr-1 um-1'}, ...
         fnames.spectrum_hemis_thermal_file, n_col.spectrum_hemis_thermal, ns, true)
         write_output({'thermal emission spectrum in observation direction'}, {'W m-2 sr-1 um-1'}, ...
         fnames.spectrum_obsdir_thermal_file, n_col.spectrum_obsdir_thermal, ns, true)
     end
end
         write_output({'irradiance'}, {'W m-2 um-1'}, ...
         fnames.irradiance_spectra_file, n_col.irradiance_spectra, ns, true)
         write_output({'reflectance'}, {'fraction of radiation in observation direction *pi / irradiance'}, ...
         fnames.reflectance_file, n_col.reflectance, ns, true)
%% input and parameter values (added June 2012)
%write_output(fnames.pars_and_input_file, true)
%write_output(fnames.pars_and_input_short_file, true)
%% Optional Output
if options.calc_vert_profiles
    write_output({'Fraction leaves in the sun, fraction of observed, fraction of observed&visible per layer'}, {'rows: simulations or time steps, columns: layer numbers'}, ...
    fnames.gap_file, n_col.gap, ns, true)
    write_output({'aPAR per leaf layer'}, {'umol m-2 s-1'}, ...
    fnames.layer_aPAR_file, n_col.layer_aPAR, ns, true)
    write_output({'aPAR by Cab per leaf layer'}, {'umol m-2 s-1'}, ...
    fnames.layer_aPAR_Cab_file, n_col.layer_aPAR_Cab, ns, true)
    if options.calc_ebal
    write_output({'leaf temperature of sunlit leaves, shaded leaves, and weighted average leaf temperature per layer'}, {'^oC ^oC ^oC'}, ...
    fnames.leaftemp_file, n_col.leaftemp, ns, true)
    write_output({'sensible heat flux per layer'}, {'W m-2'}, ...
    fnames.layer_H_file, n_col.layer_H, ns, true)
    write_output({'latent heat flux per layer'}, {'W m-2'}, ...
    fnames.layer_LE_file, n_col.layer_LE, ns, true)
    write_output({'photosynthesis per layer'}, {'umol m-2 s-1'}, ...
    fnames.layer_A_file, n_col.layer_A, ns, true)
    write_output({'average NPQ = 1-(fm-fo)/(fm0-fo0), per layer'}, {''}, ...
    fnames.layer_NPQ_file, n_col.layer_NPQ, ns, true)
    write_output({'net radiation per leaf layer'}, {'W m-2'}, ...
    fnames.layer_Rn_file, n_col.layer_Rn, ns, true)
    end
if options.calc_fluor
fluorescence_names = {'supward fluorescence per layer'};
fluorescence_units = {'W m-2'};
write_output(fluorescence_names, fluorescence_units, fnames.layer_fluorescence_file, n_col.layer_fluorescence, ns, true)
end
end
if options.calc_fluor
    write_output({'fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
    fnames.fluorescence_file, n_col.fluorescence, ns, true)
    if options.calc_PSI
        write_output({'fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution, for PSI only'}, {'W m-2 um-1 sr-1'}, ...
        fnames.fluorescencePSI_file, n_col.fluorescencePSI, ns, true)
        write_output({'fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution, for PSII only'}, {'W m-2 um-1 sr-1'}, ...
        fnames.fluorescencePSII_file, n_col.fluorescencePSII, ns, true)
    end
    write_output({'hemispherically integrated fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1'}, ...
    fnames.fluorescence_hemis_file, n_col.fluorescence_hemis, ns, true)
    write_output({'total emitted fluorescence by all leaves for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1'}, ...
    fnames.fluorescence_emitted_by_all_leaves_file, n_col.fluorescence_emitted_by_all_leaves, ns, true)
    write_output({'total emitted fluorescence by all photosystems for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1'}, ...
    fnames.fluorescence_emitted_by_all_photosystems_file, n_col.fluorescence_emitted_by_all_photosystems, ns, true)
    write_output({'TOC fluorescence contribution from sunlit leaves for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
    fnames.fluorescence_sunlit_file, n_col.fluorescence_sunlit, ns, true)
    write_output({'TOC fluorescence contribution from shaded leaves for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
    fnames.fluorescence_shaded_file, n_col.fluorescence_shaded, ns, true)
    write_output({'TOC fluorescence contribution from from leaves and soil after scattering for wavelenghts of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
    fnames.fluorescence_scattered_file, n_col.fluorescence_scattered, ns, true)
end
write_output({'Bottom of canopy irradiance in the shaded fraction, and average BOC irradiance'}, {'First 2162 columns: shaded fraction. Last 2162 columns: average BOC irradiance. Unit: Wm-2 um-1'}, ...
fnames.BOC_irradiance_file, n_col.BOC_irradiance, ns, true)

fclose('all');

%% deleting .bin
structfun(@delete, fnames)
end

function write_output(header, units, bin_path, f_n_col, ns, not_header)
    if nargin == 5
        not_header = false;
    end
    n_csv = strrep(bin_path, '.bin', '.csv');
    
    f_csv = fopen(n_csv, 'w');

    %% in case header has more than one row
    header_str = string(join(append(join(header, ','), '\n'), ''));
   
    if not_header
        header_str = [header_str];
    else
        % it is a header => each column must have one
        assert(length(header) == f_n_col, 'Less headers than lines `%s` or n_col is wrong', bin_path)
    end
    fprintf(f_csv, header_str);
    fprintf(f_csv, [strjoin(units, ','), '\n']);
    
    f_bin = fopen(bin_path, 'r');
    out = fread(f_bin, 'double');
%     fclose(f_bin);  % + some useconds to execution
    
    out_2d = reshape(out, f_n_col, ns)';
%     dlmwrite(n_csv, out_2d, '-append', 'precision', '%d'); % SLOW!
    for k=1:ns
        fprintf(f_csv, '%d,', out_2d(k, 1:end-1));
        fprintf(f_csv, '%d\n', out_2d(k, end));  % saves from extra comma
    end
%     fclose(f_csv);
end
