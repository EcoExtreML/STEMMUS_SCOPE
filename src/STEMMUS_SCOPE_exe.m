%%%%%%% A function to run STEMMUS_SCOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STEMMUS_SCOPE_exe(config_file, run_mode, debug)
    if ~exist('run_mode','var')
        runMode = "full";
    else
        runMode = run_mode;
    end

    if exist('debug','var')
        debugMode = true;
    else
        debugMode = false;
    end

    % disable all warnings
    warning('off', 'all');

    % set the variable CFG
    CFG = config_file;
    % set the variable runMode

    % In interactive mode MATLAB stays open and waits for a new command...
    if strcmp(runMode, "interactive")
        % ...until finalize has been run, at which point it quits.
        while ~strcmp(runMode, "finalize")
            runMode = input("\nFinished command. Select run mode: ", "s");
            if strcmp(runMode, "initialize") | strcmp(runMode, "update") | strcmp(runMode, "finalize")
                if debugMode
                    disp(["Running in mode: ", runMode]);
                end
                run STEMMUS_SCOPE;
            else
                if debugMode
                    disp(["Run mode '", runMode, "' not recognised. Try again"]);
                end
            end
        end
        disp("Finished clean up. Quitting...");

    else
        % run STEMMUS_SCOPE main code, in the selected run mode, and then quit.
        run STEMMUS_SCOPE;
    end

