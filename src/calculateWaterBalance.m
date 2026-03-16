function [wbal, Theta_UU_corrected] = calculateWaterBalance(ForcingData, SoilVariables, TimeProperties, KT, Theta_UU_previous, VanGenuchten, ...
                                                            Evap, Trap, gwfluxes, HBoundaryFlux, ModelSettings, GroundwaterSettings, correctWaterBalance)
    %{
        Added by Mostafa
        This function performs two tasks: 1) checks the original water balance of the unsaturated zone
                                          2) (optional) if water balance error is large -> correct water balance error
        Outputs
        wbal                     a structure that includes water balance fluxes
        Theta_UU_corrected       a 2D array of the corrected soil moisture profile

        Task 1: Check water balance
        Water balance concept: Total inflow = Total outflow + residual
        Total inflow = precipitation
        Total outflow = evapotranspiration + runoff + bottom boundary flux + delta storage
        Delta storage = (storage at time t+1 - storage at time t) / time step length
                      = (soil moisture(t+1) - soil moisture(t)) * soil thickness / time step length
        Residual = total inflow - total outflow - delta storage
        Error = (residual / total inflow) * 100%

        Task 2: Correct water balance
        To close the water balance, one of the water fluxes (ET, runoff, bottom boundary flux, or delta storage) must be adjusted.
        Since all fluxes depend on soil moisture, delta storage is chosen for correction. Why?
        Because the adjustment is distributed across the entire soil moisture profile, so each soil layer
        undergoes only a minor modification, minimizing potential disturbances.
        This approach prevents large changes in other fluxes that could occur if they were corrected directly.

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ET                       One value       Evapotranspiration [sum of Evaporation (Evap) + Transpiration (Trap)]
        runoff                   One value       Runoff [sum of Hortonian runoff + Dunnian runoff]
        botmFluxIn               One value       Flux at bottom boundary of soil (input to unsaturated zone)
        botmFluxOut              One value       Flux at bottom boundary of soil (output from unsaturated zone)
        botmFlux                 One value       Flux at bottom boundary of soil (difference between botmFluxIn and botmFluxOut)
        Theta_UU_previous        2D array        Soil moisture (liquid + ice) of the previous time step
        Theta_UU_current         2D array        Soil moisture (liquid + ice) of the current time step
        Theta_UU_corrected       2D array        Corrected soil moisture (liquid + ice) at the end of the current time step
        deltaStorageIn           One value       Change in storage entering unsaturated zone (sum over all soil layers)
        deltaStorageOut          One value       Change in storage leaving unsaturated zone (sum over all soil layers)
        deltaStorage             One value       Net change in storage of the unsaturated zone (sum over all soil layers)
        deltaStorageLay          1D array        Change in storage of the unsaturated zone per soil layer
        totalInflowInit          One value       Total inflow to unsaturated zone (before water balance correction)
        totalOutflowInit         One value       Total outflow from unsaturated zone (before water balance correction)
        residualInit             One value       Residual (total inflow - total outflow)
        errorInit                One value       Error of water balance (before water balance correction)
        thetaCorrection          One value       Corrected soil moisture value
        thetaCorrectionLay       1D array        Corrected soil moisture array
        correctedDeltaSIn        One value       Corrected change in storage entering unsaturated zone (sum over all soil layers)
        correctedDeltaSOut       One value       Corrected change in storage leaving unsaturated zone (sum over all soil layers)
        correctedDeltaS          One value       Corrected net change in storage of the unsaturated zone
        totalInflow              One value       Corrected total inflow to unsaturated zone (after water balance correction)
        totalOutflow             One value       Corrected total outflow from unsaturated zone (after water balance correction)
        error                    One value       Error of water balance (after water balance correction)
    %}

    %%%%%%%%%%%%%%%%%% Task 1: Check water balance error %%%%%%%%%%%%%%%%%%
    % 1.1. Get water balance components (ET and runoff)
    ET = Evap + Trap;
    runoff = ForcingData.runoffHort + ForcingData.runoffDunn;

    % 1.2. Calculate delta storage
    if KT == 1 % For the first time step only (for later steps, Theta_UU_previous is provided as input)
        Theta_UU_previous = SoilVariables.Theta_UU;
    end
    Theta_UU_current = SoilVariables.Theta_UU;
    Theta_UU_corrected = SoilVariables.Theta_UU; % will be corrected below
    deltaStorageLay = (Theta_UU_current(1:end - 1, 1) - Theta_UU_previous(1:end - 1, 1))' .* ModelSettings.DeltZ;
    deltaStorage = sum(deltaStorageLay) / TimeProperties.DELT;
    deltaStorageIn  = max(deltaStorage, 0);
    deltaStorageOut = max(-deltaStorage, 0);

    % 1.3. Get flux at bottom boundary
    if ~GroundwaterSettings.GroundwaterCoupling  % no groundwater coupling
        botmFlux = HBoundaryFlux.QMB;
    else
        botmFlux = gwfluxes.recharge;
    end
    botmFluxIn  = max(botmFlux, 0); % input to soil zone (capillary rise flux in case of groundwater coupling)
    botmFluxOut = max(-botmFlux, 0); % output from soil zone (recharge in case of groundwater coupling)

    % 1.4. Calculate initial total inflow, total outflow, residual, and error
    totalInflowInit = ForcingData.Precip + botmFluxIn + deltaStorageIn;
    totalOutflowInit = runoff + ET + botmFluxOut + deltaStorageOut;
    residualInit = totalInflowInit - totalOutflowInit;
    errorDenominator = mean([totalInflowInit + totalOutflowInit]); % avoid division by zero if total inflow = 0
    errorInit = residualInit / max(errorDenominator, eps) * 100; % use small value (eps) to avoid division by zero
    errorInit = max(min(errorInit, 100), -100); % constrain extreme error values

    % Update for values in csv file (use only net values of delta storage and bottom flux)
    totalInflowInit = ForcingData.Precip;
    totalOutflowInit = runoff + ET - botmFlux - deltaStorage;

    % define outputs (used if correction below is skipped or error < error threshold)
    correctedDeltaS   = 0;
    correctedDeltaSIn = 0;
    correctedDeltaSOut = 0;
    residual = residualInit;
    error    = errorInit;
    totalInflow  = totalInflowInit;
    totalOutflow = totalOutflowInit;
    Theta_UU_corrected = SoilVariables.Theta_UU;

    %%%%%%%%%%%%%%%%%% Task 2: Enforce closing water balance by correcting soil moisture profile %%%%%%%%%%%%%%%%%%
    errorThreshold = 1; % unit is percentage
    maxIterations  = 30;
    if correctWaterBalance && abs(errorInit) > errorThreshold
        iteration = 0;
        residual = 0; % starting value at each iteration

        % Loop to correct soil moisture until the water balance error is below the threshold
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

            % Apply max change in soil moisture (to avoid dramatic changes)
            maxThetaChange = 0.02;
            thetaCorrection = sign(thetaCorrection) * min(abs(thetaCorrection), maxThetaChange);

            % Add the correction value to the soil moisture profile
            for i = indxBotm + 1:ModelSettings.NL
                Theta_UU_corrected(i, 1) = Theta_UU_current(i, 1) + thetaCorrection;
                Theta_UU_corrected(i, 2) = Theta_UU_current(i, 2) + thetaCorrection;
            end

            % 2.3. Ensure corrected soil moisture values remain within residual and saturated water content limits
            [Theta_UU_corrected] = io.constrainSoilVariables(Theta_UU_corrected, VanGenuchten);

            % Recalculate the correction value of soil moisture after checking residual and saturation bounds
            thetaCorrectionLay = Theta_UU_corrected(1:end - 1, 1) - Theta_UU_previous(1:end - 1, 1);

            % 2.4. Recalculate corrected delta storage (based on the corrected soil moisture profile)
            correctedDeltaS = sum(thetaCorrectionLay .* ModelSettings.DeltZ') / TimeProperties.DELT;
            correctedDeltaSIn  = max(-correctedDeltaS, 0);
            correctedDeltaSOut = max(correctedDeltaS, 0);

            % 2.5. Calculate corrected total inflow, total outflow, residual and error
            totalInflow = ForcingData.Precip + botmFluxIn + deltaStorageIn + correctedDeltaSIn;
            totalOutflow = runoff + ET + botmFluxOut + deltaStorageOut + correctedDeltaSOut;
            residual = totalInflow - totalOutflow;
            errorDenominator = mean([totalInflow + totalOutflow]); % avoid division by zero if total inflow = 0
            error = residual / max(errorDenominator, eps) * 100; % use small value (eps) to avoid division by zero
            error = max(min(error, 100), -100); % constrain extreme error values
        end

        % Update values in csv file (use only net values of delta storage and bottom flux)
        totalInflow = ForcingData.Precip;
        totalOutflow = runoff + ET - botmFlux - deltaStorage + correctedDeltaS;
    end

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
    wbal.botmFlux = botmFlux;
    wbal.botmFluxIn = botmFluxIn;
    wbal.botmFluxOut = botmFluxOut;
end
