%%%%%%% A function to run STEMMUS_SCOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STEMMUS_SCOPE_exe(config_file, run_mode)
    if ~exist('run_mode', 'var')
        runMode = "full";
    else
        runMode = run_mode;
    end

    % disable all warnings
    warning('off', 'all');

    % set the variable CFG
    CFG = config_file;

    % If the runMode is "full" or was not provided, the model will run as normal
    if strcmp(runMode, "full")
        run STEMMUS_SCOPE;

    elseif strcmp(runMode, "interactive")
        % In interactive mode MATLAB stays open and waits for a new command...

        % Define BMI required variable names:
        bmiVarNames = {'ModelSettings', ... % Model settings struct
                       'TimeStep', ... % Time step size (in seconds)
                       'KT', ... % Index of current time step
                       'SiteProperties', ... % Site properties (e.g. lat, lon)
                       'fluxes', ... % Atmospheric fluxes
                       'TT' ... % Soil temperature over depth
                      }; %#ok

        % ...until finalize has been run, at which point it quits.
        while ~strcmp(runMode, "finalize")
            runMode = input("\nFinished command. Select run mode: ", "s");

            if strcmp(runMode, "initialize") || strcmp(runMode, "update") || strcmp(runMode, "finalize")
                % The 'initialize', 'update' and 'finalize' run modes are dispatched to the model.
                run STEMMUS_SCOPE;

            elseif strcmp(runMode, "save")
                % Save entire model state to file. This can be retrieved with the
                %  model run mode "load", where this file is opened again.
                save([Output_dir, 'STEMMUS_SCOPE_full_state.mat'], "-v7.3", "-nocompression");

            elseif strcmp(runMode, "load")
                % Load the full workspace file
                [~, OutputPath, ~] = io.read_config(CFG);
                stateFile = [OutputPath, 'STEMMUS_SCOPE_full_state.mat'];
                if isfile(stateFile)
                    load(stateFile); %#ok
                else
                    disp(["No file found at ", stateFile, ". Could not load file."]);
                end

            else
                % If the runMode is not one of the above, promt user again.
                disp(["Run mode '", runMode, "' not recognised. Try again"]);
            end
        end
        disp("Finished clean up. Quitting...");

    else
        disp(["Run mode '", runMode, "' not recognised. The only valid modes are 'full' or 'interactive'"]);
    end
