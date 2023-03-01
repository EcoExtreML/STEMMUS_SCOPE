%%%%%%% A function to run STEMMUS_SCOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STEMMUS_SCOPE_exe(config_file)

    % disable all warnings
    warning('off', 'all');

    % set the global variable CFG
    CFG = config_file;

    % run STEMMUS_SCOPE main code
    run STEMMUS_SCOPE;
