function options = setOptions(parameter_file,path_input)
%{
Read parameter file and set options. The parameter_file is defined in set_parameter_filenames.m

Input:
    parameter_file:  A cell array of the strings where each string is a
        file name.
    path_input: The path of parameter files. the path of setOptions.m .
 
Output:
    options: A structure containing options we set in parameter file.
%}


%     run([path_input parameter_file{1}])
%     
%     options.calc_ebal           = N(1);    % calculate the energy balance (default). If 0, then only SAIL is executed!
%     options.calc_vert_profiles  = N(2);    % calculate vertical profiles of fluxes
%     options.calc_fluor          = N(3);    % calculate chlorophyll fluorescence in observation direction
%     options.calc_planck         = N(4);    % calculate spectrum of thermal radiation
%     options.calc_directional    = N(5);    % calculate BRDF and directional temperature
%     options.calc_xanthophyllabs = N(6);    % include simulation of reflectance dependence on de-epoxydation state
%     options.calc_PSI            = N(7);    % 0: optipar 2017 file with only one fluorescence spectrum vs 1: Franck et al spectra for PSI and PSII
%     options.rt_thermal          = N(8);    % 1: use given values under 10 (default). 2: use values from fluspect and soil at 2400 nm for the TIR range
%     options.calc_zo             = N(9);
%     options.soilspectrum        = N(10);    %0: use soil spectrum from a file, 1: simulate soil spectrum with the BSM model
%     options.soil_heat_method    = N(11);    % 0: calculated from specific heat and conductivity (default), 1: empiricaly calibrated, 2: G as constant fraction of soil net radiation
%     options.Fluorescence_model  = N(12);     %0: empirical, with sustained NPQ (fit to Flexas' data); 1: empirical, with sigmoid for Kn; 2: Magnani 2012 model
%     options.calc_rss_rbs        = N(13);    % 0: calculated from specific heat and conductivity (default), 1: empiricaly calibrated, 2: G as constant fraction of soil net radiation
%     options.apply_T_corr        = N(14);    % correct Vcmax and rate constants for temperature in biochemical.m
%     options.verify              = N(15);
%     options.save_headers        = N(16);    % write headers in output files
%     options.makeplots           = N(17);
%     options.simulation          = N(18);    % 0: individual runs (specify all input in a this file)
     % 1: time series (uses text files with meteo input as time series)
     % 2: Lookup-Table (specify the values to be included)
     % 3: Lookup-Table with random input (specify the ranges of values)
end


  