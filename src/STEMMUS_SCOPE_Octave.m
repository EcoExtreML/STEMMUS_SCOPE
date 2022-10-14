% A function to run STEMMUS_SCOPE in Octave
function STEMMUS_SCOPE_Octave(config_file)
    % Load Octave packages
    pkg load netcdf
    pkg load statistics

    % disable all warnings
    warning('off','all')

    % set the global variable CFG
    CFG = config_file;

    % run STEMMUS_SCOPE main code
    run STEMMUS_SCOPE
end