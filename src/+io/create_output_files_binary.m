function [Output_dir, fnames] = create_output_files_binary(parameter_file, sitename, path_of_code, input_path, ...
                                                           output_path, spectral, options)

    %% Set Output dir
    Output_dir = output_path;

    %% Log File
    mkdir([Output_dir, 'Parameters' filesep]);
    for i = 1:length(parameter_file)
        copy_name = [strrep(parameter_file{i}, '.csv', '') '_' sitename '.csv'];
        copyfile([input_path parameter_file{i}], [Output_dir, 'Parameters/', copy_name], 'f');
    end
    fidpath          = fopen([Output_dir, 'Parameters/SCOPEversion.txt'], 'w');      % complete path of the SCOPE code
    fprintf(fidpath, '%s', path_of_code);

    %% Filenames, will become .csv if options is on
    fnames.flu_file = fullfile(Output_dir, 'fluxes.bin');
    fnames.surftemp_file = fullfile(Output_dir, 'surftemp.bin');
    fnames.aerodyn_file = fullfile(Output_dir, 'aerodyn.bin');
    fnames.radiation_file = fullfile(Output_dir, 'radiation.bin');
    fnames.fluorescence_file = fullfile(Output_dir, 'fluorescence.bin');
    fnames.wl_file = fullfile(Output_dir, 'wl.bin');  % wavelength
    fnames.reflectance_file = fullfile(Output_dir, 'reflectance.bin');  % reflectance spectrum
    fnames.Sim_Theta_file = fullfile(Output_dir, 'Sim_Theta.bin');  % soil moisture
    fnames.Sim_Temp_file = fullfile(Output_dir, 'Sim_Temp.bin');  % soil temperature
    fnames.waterStressFactor_file = fullfile(Output_dir, 'waterStressFactor.bin');
    fnames.waterPotential_file = fullfile(Output_dir, 'waterPotential.bin'); % leaf water potential
    fnames.Sim_hh_file = fullfile(Output_dir, 'Sim_hh.bin'); % soil matric potential
    fnames.Sim_qlh_file = fullfile(Output_dir, 'qlh.bin'); % liquid flux due to matric potential gradient
    fnames.Sim_qlt_file = fullfile(Output_dir, 'qlt.bin'); % liquid flux due to temprature gradient
    fnames.Sim_qla_file = fullfile(Output_dir, 'qla.bin'); % liquid flux due to dry air pressure gradient
    fnames.Sim_qvh_file = fullfile(Output_dir, 'qvh.bin'); % vapour flux due to matric potential gradient
    fnames.Sim_qvt_file = fullfile(Output_dir, 'qvt.bin'); % vapour flux due to temprature gradient
    fnames.Sim_qva_file = fullfile(Output_dir, 'qva.bin'); % vapour flux due to dry air pressure gradient
    fnames.Sim_qtot_file = fullfile(Output_dir, 'qtot.bin'); % total flux (liquid + vapour)

    % if ~(options.simulation==1)
    fnames.pars_and_input_file           = fullfile(Output_dir, 'pars_and_input.bin');      % wavelength

    % for j = 1:length(V)
    %   fprintf(fidv,'%s\t',V(j).Name);
    % end
    % fprintf(fidv,'\r');
    % end

    % if ~(options.simulation==1)
    fnames.pars_and_input_short_file           = fullfile(Output_dir, 'pars_and_input_short.bin');      % wavelength
    % for j = find(vmax>1)
    %  fprintf(fidvs,'%s\t',V(vmax>1).Name);
    % end
    % fprintf(fidvs,' \r');
    %
    %% Optional Output
    if options.calc_vert_profiles
        fnames.leaftemp_file        = fullfile(Output_dir, 'leaftemp.bin');        % leaftemp
        fnames.layer_H_file         = fullfile(Output_dir, 'layer_H.bin');      % vertical profile
        fnames.layer_LE_file        = fullfile(Output_dir, 'layer_lE.bin');         % latent heat
        fnames.layer_A_file         = fullfile(Output_dir, 'layer_A.bin');        %
        fnames.layer_aPAR_file      = fullfile(Output_dir, 'layer_aPAR.bin');    %
        fnames.layer_aPAR_Cab_file  = fullfile(Output_dir, 'layer_aPAR_Cab.bin');     %
        fnames.layer_Rn_file        = fullfile(Output_dir, 'layer_Rn.bin');        %
        if options.calc_fluor
            fnames.layer_fluorescence_file = fullfile(Output_dir, 'layer_fluorescence.bin');        %
            fnames.layer_fluorescenceEm_file = fullfile(Output_dir, 'layer_fluorescenceEm.bin');        %
            fnames.layer_NPQ_file = fullfile(Output_dir, 'layer_NPQ.bin');        %
        end

    else
        delete([Output_dir, 'leaftemp.bin']);
        delete([Output_dir, 'layer_H.bin']);
        delete([Output_dir, 'layer_lE.bin']);
        delete([Output_dir, 'layer_A.bin']);
        delete([Output_dir, 'layer_aPAR.bin']);
        delete([Output_dir, 'layer_Rn.bin']);
    end

    if options.calc_fluor
        fnames.fluorescence_file              = fullfile(Output_dir, 'fluorescence.bin');      % Fluorescence
        if options.calc_PSI
            fnames.fluorescencePSI_file       = fullfile(Output_dir, 'fluorescencePSI.bin');     % Fluorescence
            fnames.fluorescencePSII_file      = fullfile(Output_dir, 'fluorescencePSII.bin');     % Fluorescence
        end
    else
        delete([Output_dir, 'fluorescence.bin']);
    end

    if options.calc_directional
        delete([Output_dir, 'BRDF/*.bin']);
    end

    % Create empty files for appending
    structfun(@(x) fopen(x, 'w'), fnames, 'UniformOutput', false);
    fclose("all");

    %% write wl
    wlS = spectral.wlS; %#ok<*NASGU>
    wlF = spectral.wlF;

    save([Output_dir 'wlS.txt'], 'wlS', '-ascii');
    save([Output_dir 'wlF.txt'], 'wlF', '-ascii');
end
