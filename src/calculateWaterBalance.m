function [wbal, Theta_UU_corrected] = calculateWaterBalance(ForcingData, SoilVariables, TimeProperties, KT, Theta_UU_previous, Evap, Trap, gwfluxes, VanGenuchten, ModelSettings, GroundwaterSettings)
    %{
        Added by Mostafa
        This function does two tasks: 1) checks the original water balance of the unsaturated zone
                                    2) if water balance error is large -> correct water balance
        Outputs
        wbal                     a structure that includes water balance fluxes
        Theta_UU_corrected       a 2D array of the corrected soil moisture profile

        Task 1: Check water balance
        Water balance concept: Total inflow = Total outflow + residual
        Total inflow = Precipitation + Capillary rise flux
        Total outflow = Evapotranspiration + Runoff + Recharge + delta storage
        delta storage = (storage at time t+1 - storage at time t) / time step length
                      = (soil moisture at time t+1 - soil moisture at time t) * soil thickness / time step length
        Residual = total inflow - total outflow - delta storage
        error = (Residual/total inflow)*100%

        Task 2: Correct water balance
        To close water balance, one of the water fluxes (ET, recharge, runoff, or delta storage) needs to be adjusted.
        Since all fluxes depend on soil moisture, delta storage is chosen for correction. Why?
        Because the adjustment is distributed across the entire soil moisture profile, meaning that the soil
        moisture of each soil layer undergoes only a minor modification, minimizing potential disturbances.
        This approach prevents dramatic changes in other fluxes that could occur if they were corrected directly.

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ET                       One value       Evapotranspiration [sum of Evaporation (Evap) + Transpiration (Trap)]
        runoff                   One value       Runoff [sum of Hortonian runoff + Dunnian runoff]
        recharge                 One value       Groundwater recharge
        capillary                One value       Capillary rise flux
        Theta_UU_previous        2D array        Soil moisture (liquid + ice) of the previous time step
        Theta_UU_current         2D array        Soil moisture (liquid + ice) of the current time step
        Theta_UU_corrected       2D array        Corrected soil moisture (liquid + ice) at the end of the current time step
        deltaStorageIn           One value       Change of storage that enters unsaturated zone (sum value over all soil layers)
        deltaStorageOut          One value       Change in storage that exits unsaturated zone (sum value over all soil layers)
        deltaStorage             One value       Change in storage of the unsaturated zone (sum value over all soil layers)
        deltaStorageLay          1D array        Change in storage of the unsaturated zone per soil layer
        totalInflowInit          One value       Total inflow to unsaturated zone (before water balance correction)
        totalOutflowInit         One value       Total outflow from unsaturated zone (before water balance correction)
        residualInit             One value       Residual (total inflow - total outflow)
        errorInit                One value       Error of water balance (before water balance correction)
        thetaCorrection          One value       Corrected soil moisture value
        thetaCorrectionLay       1D array        Corrected soil moisture array
        correctedDeltaSIn        One value       Corrected change of storage that enters unsaturated zone (sum value over all soil layers)
        correctedDeltaSOut       One value       Corrected change of storage that exits unsaturated zone (sum value over all soil layers)
        correctedDeltaS          One value       Corrected change of storage of the unsaturated zone
        totalInflow              One value       Corrected total inflow to unsaturated zone (after water balance correction)
        totalOutflow             One value       Corrected total outflow from unsaturated zone (after water balance correction)
        error                    One value       Error of water balance (after water balance correction)
    %}

    %%%%%%%%%%%%%%%%%% Task 1: Check water balance error %%%%%%%%%%%%%%%%%%
    % 1.1. Get water balance components (ET, runoff, recharge, capillary rise flux, and delta storage)
    ET = Evap + Trap;
    runoff = ForcingData.runoffHort + ForcingData.runoffDunn;
    if gwfluxes.recharge > 0 % capillary rise (input to soil zone)
        recharge = 0;
        capillary = gwfluxes.recharge;
    else % recharge (output from soil zone)
        recharge = -gwfluxes.recharge;
        capillary = 0;
    end

    % 1.2. Calculate delta storage
    if KT == 1 % For first time step only (for the rest, Theta_UU_previous is an input to the function)
        Theta_UU_previous = SoilVariables.Theta_UU;
    end
    Theta_UU_current = SoilVariables.Theta_UU;
    Theta_UU_corrected = SoilVariables.Theta_UU; % will be corrected below
    deltaStorageLay = (Theta_UU_current(1:end - 1, 1) - Theta_UU_previous(1:end - 1, 1))' .* ModelSettings.DeltZ;
    deltaStorage = sum(deltaStorageLay) / TimeProperties.DELT;
    if deltaStorage > 0
        deltaStorageIn = deltaStorage;
        deltaStorageOut = 0;
    else
        deltaStorageIn = 0;
        deltaStorageOut = -deltaStorage;
    end

    % 1.3. Calculate initial total inflow, total outflow, residual, and error
    totalInflowInit = ForcingData.Precip + capillary + deltaStorageIn;
    totalOutflowInit = runoff + ET + recharge + deltaStorageOut;
    residualInit = totalInflowInit - totalOutflowInit;
    errorDenominator = abs(totalInflowInit) + abs(totalOutflowInit); % avoid division by zero if total inflow = 0
    errorInit = residualInit / max(errorDenominator, eps) * 100; % use small value (eps) to avoid division by zero
    errorInit = max(min(errorInit, 100), -100); % constrain extreme error values

    %%%%%%%%%%%%%%%%%% Task 2: Close water balance by correcting soil moisture profile %%%%%%%%%%%%%%%%%%
    errorThreshold = 1; % unit is %
    maxIterations  = 30;
    iteration = 0;
    error = errorInit;
    residual = 0; % starting value at each iteration
    if abs(errorInit) > errorThreshold % correction is needed
        % loop to correct soil moisture to close water balance until water balance error is less than certain threshold
        while abs(error) > errorThreshold && iteration < maxIterations
            iteration = iteration + 1;

            % 2.1. Determine the total soil thickness
            if GroundwaterSettings.GroundwaterCoupling
                indxBotm = GroundwaterSettings.indxBotmLayer;
                soil_depth = sum(ModelSettings.DeltZ(indxBotm + 1:ModelSettings.NL));
            else
                indxBotm = 1;
                soil_depth = sum(ModelSettings.DeltZ);
            end

            % 2.2. Calculate correction value of soil moisture
            thetaCorrection = residual / soil_depth * TimeProperties.DELT;
            % Add the correction value to the soil moisture profile
            for i = indxBotm + 1:ModelSettings.NL
                Theta_UU_corrected(i:end - 1, 1) = Theta_UU_current(i:end - 1, 1) + thetaCorrection;
                Theta_UU_corrected(i:end - 1, 2) = Theta_UU_current(i:end - 1, 2) + thetaCorrection;
            end

            % 2.3. Ensure corrected soil moisture values within ranges of residual and saturated water content
            [Theta_UU_corrected] = io.constrainSoilVariables(Theta_UU_corrected, VanGenuchten);

            % Recalculate correction value of soil moisture after residual and saturated boundaries check
            thetaCorrectionLay = Theta_UU_corrected(1:end - 1, 1) - Theta_UU_previous(1:end - 1, 1);

            % 2.4. Recalculate corrected delta storage (based on recalculated corrected soil moisture)
            correctedDeltaS = sum(thetaCorrectionLay .* ModelSettings.DeltZ') / TimeProperties.DELT;
            if correctedDeltaS > 0
                correctedDeltaSIn = 0;
                correctedDeltaSOut = correctedDeltaS;
            else
                correctedDeltaSIn = -correctedDeltaS;
                correctedDeltaSOut = 0;
            end

            % 2.5. Calculate corrected total inflow, total outflow, residual and error
            totalInflow = ForcingData.Precip + capillary + deltaStorageIn + correctedDeltaSIn;
            totalOutflow = runoff + ET + recharge + deltaStorageOut + correctedDeltaSOut;
            residual = totalInflow - totalOutflow;
            errorDenominator = abs(totalInflow) + abs(totalOutflow); % avoid division by zero if total inflow = 0
            error = residual / max(errorDenominator, eps) * 100; % use small value (eps) to avoid division by zero
            error = max(min(error, 100), -100); % constrain extreme error values
        end

    else % abs(errorInit) < errorThreshold -> No correction needed
        Theta_UU_corrected = SoilVariables.Theta_UU;
        correctedDeltaS = 0;
        correctedDeltaSIn = 0;
        correctedDeltaSOut = 0;
        residual = residualInit;
        error = errorInit;
        totalInflow = totalInflowInit;
        totalOutflow = totalOutflowInit;
    end

        % Update for flux values in csv file
        totalInflow = ForcingData.Precip;
        totalOutflow = runoff + ET - gwfluxes.recharge - deltaStorage + correctedDeltaS;

    % Outputs to be exported in csv or exposed to BMI
    wbal.totalInflowInit = totalInflowInit;
    wbal.totalOutflowInit = totalOutflowInit;
    wbal.totalInflow = totalInflow;
    wbal.totalOutflow = totalOutflow;
    wbal.residual = residual;
    wbal.errorInit = errorInit;
    wbal.error = error;
    wbal.deltaStorage = deltaStorage;
    wbal.deltaStorageIn = deltaStorageIn;
    wbal.deltaStorageOut = deltaStorageOut;
    wbal.correctedDeltaS = correctedDeltaS;
    wbal.correctedDeltaSIn = correctedDeltaSIn;
    wbal.correctedDeltaSOut = correctedDeltaSOut;
    wbal.capillary = capillary;
    wbal.recharge = recharge;
