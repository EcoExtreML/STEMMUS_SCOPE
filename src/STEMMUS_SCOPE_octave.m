%%%%%%% A function to run STEMMUS_SCOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STEMMUS_SCOPE_octave(config_file)

% Load in required Octave packages if STEMMUS-SCOPE is being run in Octave:
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    pkg load netcdf
    pkg load statistics
else
    warning("Install Octave to run the model in Octave.");
end

% disable all warnings 
warning('off','all')

% set the global variable CFG
CFG = config_file;

% run STEMMUS_SCOPE main code
run STEMMUS_SCOPE