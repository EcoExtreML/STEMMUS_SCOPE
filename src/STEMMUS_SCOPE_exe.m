%%%%%%% A function to run STEMMUS_SCOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STEMMUS_SCOPE_exe(config_file, run_mode)

    % disable all warnings
    warning('off', 'all');

    % set the variable CFG
    CFG = config_file;

    % set the variable runMode
    runMode = run_mode;

    % run STEMMUS_SCOPE main code
    run STEMMUS_SCOPE;
