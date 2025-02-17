function bin_to_csv(fnames, n_col, ns, options, SoilLayer, GroundwaterSettings, FullCSVfiles)
    %% flu
    flu_names = {'simulation_number', 'nu_iterations', 'year', 'DoY', ...
                 'Rntot', 'lEtot', 'Htot', ...
                 'Rnctot', 'lEctot', 'Hctot', 'Actot', ...
                 'Rnstot', 'lEstot', 'Hstot', 'Gtot', 'Resp', ...
                 'aPAR', 'aPAR_Cab', 'aPAR/rad.PAR', 'aPAR_Wm2', 'PAR', 'rad.Eoutf', 'rad.Eoutf./fluxes.aPAR_Wm2', 'Trap', 'Evap', 'ET', 'GPP', 'NEE'};
    flu_units = {'', '', '', '',  ...
                 'W m-2', 'W m-2', 'W m-2', ...
                 'W m-2', 'W m-2', 'W m-2', 'umol m-2 s-1', ...
                 'W m-2', ' W m-2', 'W m-2', 'W m-2', 'umol m-2 s-1', ...
                 'umol m-2 s-1', ' umol m-2 s-1', 'umol m-2 s-1', 'W m-2', 'umol m-2 s-1', 'W m-2', 'W m-2', 'mm s-1', 'mm s-1', 'mm s-1', 'Kg m-2 s-1', 'Kg m-2 s-1'};
    write_output(flu_names, flu_units, fnames.flu_file, n_col.flu, ns);

    %% surftemp
    surftemp_names = {'simulation_number', 'year', 'DoY', ...
                      'Ta', 'Ts(1)', 'Ts(2)', 'Tcave', 'Tsave'};
    surftemp_units = {'', '', '',  ...
                      'C', 'C', 'C', 'C', 'C'};
    write_output(surftemp_names, surftemp_units, fnames.surftemp_file, n_col.surftemp, ns);

    %% aerodyn
    aerodyn_names = {'simulation_number', 'year', 'DoY', ...
                     'raa', 'rawc', 'raws', 'ustar', 'rac', 'ras'};
    aerodyn_units = {'', '', '',  ...
                     's m-1', 's m-1', 's m-1', 'm s-1', 's m-1', 's m-1'};
    write_output(aerodyn_names, aerodyn_units, fnames.aerodyn_file, n_col.aerodyn, ns);

    %% radiation
    radiation_names = {'simulation_number', 'year', 'DoY', ...
                       'Rin', 'Rli', 'HemisOutShort', 'HemisOutLong', 'HemisOutTot', 'Netshort', 'Netlong', 'Rntot'};
    radiation_units = {'', '', '',  ...
                       'W m-2', 'W m-2', 'W m-2', 'W m-2', 'W m-2', 'W m-2', 'W m-2', 'W m-2'};
    write_output(radiation_names, radiation_units, fnames.radiation_file, n_col.radiation, ns);

    %% Get soil layer information
    depth = arrayfun(@(x) num2str(x), SoilLayer.depth, "UniformOutput", false);
    thickness = arrayfun(@(x) num2str(x), SoilLayer.thickness, "UniformOutput", false);

    %% Soil moisture data
    Sim_Theta_names = [depth; thickness];
    Sim_Theta_units = repelem({'m-3 m-3'}, length(depth));
    write_output(Sim_Theta_names, Sim_Theta_units, fnames.Sim_Theta_file, n_col.Sim_Theta, ns, true);

    %% Soil temperature data
    Sim_Temp_names = [depth; thickness];
    Sim_Temp_units = repelem({'oC'}, length(depth));
    write_output(Sim_Temp_names, Sim_Temp_units, fnames.Sim_Temp_file, n_col.Sim_Temp, ns, true);

    %% Water stress factor
    waterStressFactor_names = {'simulation_number', 'year', 'DoY', 'soilWaterStressFactor'};
    waterStressFactor_units = {'', '', '', '-'};
    write_output(waterStressFactor_names, waterStressFactor_units, fnames.waterStressFactor_file, n_col.waterStressFactor, ns);

    %% Leaf water potential
    waterPotential_names = {'simulation_number', 'year', 'DoY', 'leafWaterPotential'};
    waterPotential_units = {'', '', '', 'm'};
    write_output(waterPotential_names, waterPotential_units, fnames.waterPotential_file, n_col.waterPotential, ns);

    %% Soil matric potential
    Sim_hh_names = [depth; thickness];
    Sim_hh_units = repelem({'cm'}, length(depth));
    write_output(Sim_hh_names, Sim_hh_units, fnames.Sim_hh_file, n_col.Sim_hh, ns, true);

    %% Soil fluxes (liquid and vapour)
    Sim_qlh_names = [depth; thickness];
    Sim_qlh_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qlh_names, Sim_qlh_units, fnames.Sim_qlh_file, n_col.Sim_qlh, ns, true);

    Sim_qlt_names = [depth; thickness];
    Sim_qlt_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qlt_names, Sim_qlt_units, fnames.Sim_qlt_file, n_col.Sim_qlt, ns, true);

    Sim_qla_names = [depth; thickness];
    Sim_qla_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qla_names, Sim_qla_units, fnames.Sim_qla_file, n_col.Sim_qla, ns, true);

    Sim_qvh_names = [depth; thickness];
    Sim_qvh_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qvh_names, Sim_qvh_units, fnames.Sim_qvh_file, n_col.Sim_qvh, ns, true);

    Sim_qvt_names = [depth; thickness];
    Sim_qvt_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qvt_names, Sim_qvt_units, fnames.Sim_qvt_file, n_col.Sim_qvt, ns, true);

    Sim_qva_names = [depth; thickness];
    Sim_qva_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qva_names, Sim_qva_units, fnames.Sim_qva_file, n_col.Sim_qva, ns, true);

    Sim_qtot_names = [depth; thickness];
    Sim_qtot_units = repelem({'cm s-1'}, length(depth));
    write_output(Sim_qtot_names, Sim_qtot_units, fnames.Sim_qtot_file, n_col.Sim_qtot, ns, true);

    if options.calc_fluor
        write_output({'fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
                     fnames.fluorescence_file, n_col.fluorescence, ns, true);
        if options.calc_PSI
            write_output({'fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution, for PSI only'}, {'W m-2 um-1 sr-1'}, ...
                         fnames.fluorescencePSI_file, n_col.fluorescencePSI, ns, true);
            write_output({'fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution, for PSII only'}, {'W m-2 um-1 sr-1'}, ...
                         fnames.fluorescencePSII_file, n_col.fluorescencePSII, ns, true);
        end
    end

    % Optional for large output files
    if FullCSVfiles
        %% Spectrum (added on 19 September 2008)
        spectrum_hemis_optical_names = {'hemispherically integrated radiation spectrum'};
        spectrum_hemis_optical_units = {'W m-2 um-1'};
        write_output(spectrum_hemis_optical_names, spectrum_hemis_optical_units, fnames.spectrum_hemis_optical_file, n_col.spectrum_hemis_optical, ns, true);

        spectrum_obsdir_optical_names = {'radiance spectrum in observation direction'};
        spectrum_obsdir_optical_units = {'W m-2 sr-1 um-1'};
        write_output(spectrum_obsdir_optical_names, spectrum_obsdir_optical_units, fnames.spectrum_obsdir_optical_file, n_col.spectrum_obsdir_optical, ns, true);

        if options.calc_ebal
            write_output({'thermal BlackBody emission spectrum in observation direction'}, {'W m-2 sr-1 um-1'}, ...
                         fnames.spectrum_obsdir_BlackBody_file, n_col.spectrum_obsdir_BlackBody, ns, true);
            if options.calc_planck
                write_output({'thermal emission spectrum in hemispherical direction'}, {'W m-2 sr-1 um-1'}, ...
                             fnames.spectrum_hemis_thermal_file, n_col.spectrum_hemis_thermal, ns, true);
                write_output({'thermal emission spectrum in observation direction'}, {'W m-2 sr-1 um-1'}, ...
                             fnames.spectrum_obsdir_thermal_file, n_col.spectrum_obsdir_thermal, ns, true);
            end
        end
        write_output({'irradiance'}, {'W m-2 um-1'}, ...
                     fnames.irradiance_spectra_file, n_col.irradiance_spectra, ns, true);
        write_output({'reflectance'}, {'fraction of radiation in observation direction *pi / irradiance'}, ...
                     fnames.reflectance_file, n_col.reflectance, ns, true);

        %% input and parameter values (added June 2012)
        % write_output(fnames.pars_and_input_file, true)
        % write_output(fnames.pars_and_input_short_file, true)

        %% Optional Output
        if options.calc_vert_profiles
            write_output({'Fraction leaves in the sun, fraction of observed, fraction of observed&visible per layer'}, {'rows: simulations or time steps, columns: layer numbers'}, ...
                         fnames.gap_file, n_col.gap, ns, true);
            write_output({'aPAR per leaf layer'}, {'umol m-2 s-1'}, ...
                         fnames.layer_aPAR_file, n_col.layer_aPAR, ns, true);
            write_output({'aPAR by Cab per leaf layer'}, {'umol m-2 s-1'}, ...
                         fnames.layer_aPAR_Cab_file, n_col.layer_aPAR_Cab, ns, true);
            if options.calc_ebal
                write_output({'leaf temperature of sunlit leaves, shaded leaves, and weighted average leaf temperature per layer'}, {'^oC ^oC ^oC'}, ...
                             fnames.leaftemp_file, n_col.leaftemp, ns, true);
                write_output({'sensible heat flux per layer'}, {'W m-2'}, ...
                             fnames.layer_H_file, n_col.layer_H, ns, true);
                write_output({'latent heat flux per layer'}, {'W m-2'}, ...
                             fnames.layer_LE_file, n_col.layer_LE, ns, true);
                write_output({'photosynthesis per layer'}, {'umol m-2 s-1'}, ...
                             fnames.layer_A_file, n_col.layer_A, ns, true);
                write_output({'average NPQ = 1-(fm-fo)/(fm0-fo0), per layer'}, {''}, ...
                             fnames.layer_NPQ_file, n_col.layer_NPQ, ns, true);
                write_output({'net radiation per leaf layer'}, {'W m-2'}, ...
                             fnames.layer_Rn_file, n_col.layer_Rn, ns, true);
            end
            if options.calc_fluor
                fluorescence_names = {'supward fluorescence per layer'};
                fluorescence_units = {'W m-2'};
                write_output(fluorescence_names, fluorescence_units, fnames.layer_fluorescence_file, n_col.layer_fluorescence, ns, true);
            end
        end
        if options.calc_fluor
            write_output({'hemispherically integrated fluorescence per simulation for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1'}, ...
                         fnames.fluorescence_hemis_file, n_col.fluorescence_hemis, ns, true);
            write_output({'total emitted fluorescence by all leaves for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1'}, ...
                         fnames.fluorescence_emitted_by_all_leaves_file, n_col.fluorescence_emitted_by_all_leaves, ns, true);
            write_output({'total emitted fluorescence by all photosystems for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1'}, ...
                         fnames.fluorescence_emitted_by_all_photosystems_file, n_col.fluorescence_emitted_by_all_photosystems, ns, true);
            write_output({'TOC fluorescence contribution from sunlit leaves for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
                         fnames.fluorescence_sunlit_file, n_col.fluorescence_sunlit, ns, true);
            write_output({'TOC fluorescence contribution from shaded leaves for wavelengths of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
                         fnames.fluorescence_shaded_file, n_col.fluorescence_shaded, ns, true);
            write_output({'TOC fluorescence contribution from from leaves and soil after scattering for wavelenghts of 640 to 850 nm, with 1 nm resolution'}, {'W m-2 um-1 sr-1'}, ...
                         fnames.fluorescence_scattered_file, n_col.fluorescence_scattered, ns, true);
        end
        write_output({'Bottom of canopy irradiance in the shaded fraction, and average BOC irradiance'}, {'First 2162 columns: shaded fraction. Last 2162 columns: average BOC irradiance. Unit: Wm-2 um-1'}, ...
                     fnames.BOC_irradiance_file, n_col.BOC_irradiance, ns, true);
    end

    fclose('all');

    %% Delete all (temporary) .bin files
    fn = fieldnames(fnames);
    for k = 1:numel(fn)
        delete(fnames.(fn{k}));
    end
end

function write_output(header, units, bin_path, f_n_col, ns, not_header)
    if nargin == 5
        not_header = false;
    end
    n_csv = strrep(bin_path, '.bin', '.csv');

    f_csv = fopen(n_csv, 'w');

    header = cellstr(header); % cellstr is for MATLAB - Octave compatibility
    headerSize = size(header);
    nHeaderLines = headerSize(1); % If there is a multi-line header
    headerString = repmat({}, nHeaderLines, 1);
    for k = 1:nHeaderLines
        % cellstr is for MATLAB - Octave compatibility
        headerString(k) = cellstr(strjoin(header(k, :), ","));
    end
    headerString = strcat(strjoin(headerString, "\n"), "\n");

    if not_header
        headerString = [headerString];
    else
        % it is a header => each column must have one
        assert(length(header) == f_n_col, 'Less headers than lines `%s` or n_col is wrong', bin_path);
    end

    fprintf(f_csv, headerString);
    fprintf(f_csv, [strjoin(units, ','), '\n']);

    f_bin = fopen(bin_path, 'r');
    out = fread(f_bin, 'double');

    out_2d = reshape(out, f_n_col, ns)';
    for k = 1:ns
        fprintf(f_csv, '%d,', out_2d(k, 1:end - 1));
        fprintf(f_csv, '%d\n', out_2d(k, end));  % saves from extra comma
    end
end
