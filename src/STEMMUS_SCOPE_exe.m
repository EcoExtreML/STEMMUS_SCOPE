%%%%%%% A function to run STEMMUS_SCOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STEMMUS_SCOPE_exe(config_file, runMode)
    if ~exist('runMode', 'var')
        runMode = "full";
    end

    % disable all warnings
    warning('off', 'all');

    % set the variable CFG
    CFG = config_file;
    bmiMode = "none";

    % If the runMode is "full" or was not provided, the model will run as normal
    if strcmp(runMode, "full")
        run STEMMUS_SCOPE;

    elseif strcmp(runMode, "bmi")
        % In interactive mode MATLAB stays open and waits for a new command...

        % Define BMI required variable names:
        bmiVarNames = {'ModelSettings', ... % Model settings struct
                       'TimeStep', ... % Time step size (in seconds)
                       'KT', ... % Index of current time step
                       'SiteProperties', ... % Site properties (e.g. lat, lon)
                       'fluxes', ... % Atmospheric fluxes
                       'TT', ... % Soil temperature over depth
                       	'Sim_Theta_U', % Soil moisture over depth
					   'GroundwaterCoupling', % Variable with value = 0 -> deactivate Groundwater coupling, or = 1 -> activate Groundwater coupling 
					   'headBotmLayer', % head at bottom layer
					   'indexBotmLayer', % index of bottom layer that contains current headBotmLayers
                      }; %#ok
                      }; %#ok

        % Variables for tracking the state of the model initialization:
        isInitialized = false;
        isUpdated = false;

        % ...until finalize has been run, at which point it quits.
        while ~strcmp(bmiMode, "finalize")
            bmiMode = input("\nFinished command. Select BMI mode: ", "s");

            if startsWith(bmiMode, "initialize ")
                % Get config file:
                CFG = erase(bmiMode, "initialize ");
                CFG = strtrim(CFG);  % remove leading and trailing whitespace
                CFG = erase(CFG, '"');  % remove quotes

                bmiMode = "initialize";

                run STEMMUS_SCOPE;
                isInitialized = true;

            elseif strcmp(bmiMode, "update")
                if isInitialized
                    % The 'initialize', 'update' and 'finalize' run modes are dispatched to the model.
                    run STEMMUS_SCOPE;
                    isUpdated = true;
                else
                    disp("First initialize the model before calling 'update'");
                end

            elseif strcmp(bmiMode, "finalize")
                if isInitialized & isUpdated
                    run STEMMUS_SCOPE;
                end

            elseif strcmp(bmiMode, "save")
                % Save entire model state to file. This can be retrieved with the
                %  model run mode "load", where this file is opened again.
                save([Output_dir, 'STEMMUS_SCOPE_full_state.mat'], "-v7.3", "-nocompression");

            elseif strcmp(bmiMode, "load")
                % Load the full workspace file
                [~, OutputPath, ~] = io.read_config(CFG);
                stateFile = [OutputPath, 'STEMMUS_SCOPE_full_state.mat'];
                if isfile(stateFile)
                    load(stateFile); %#ok
                else
                    disp(["No file found at ", stateFile, ". Could not load file."]);
                end

            else
                % If the bmiMode is not one of the above, promt user again.
                disp(["Run mode '", bmiMode, "' not recognised. Try again"]);
            end
        end
        disp("Finished clean up. Quitting...");

    else
        disp(["Run mode '", runMode, "' not recognised. Valid modes are 'full' or 'bmi'"]);
    end
end
