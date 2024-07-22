function groundWaterDepth = calculateGroundWaterDepth(topLevel, headBotmLayer, Tot_Depth)
    % water table depth: depth from top soil layer to groundwater level
    groundWaterDepth = topLevel - headBotmLayer; % depth from top layer to groundwater level

    % Check that the position of the water table is within the soil column
    if groundWaterDepth <= 0
        warning('The soil is fully saturated up to the land surface level!');
        groundWaterDepth = 1.0; % to avoid model crashing, assign minimum groundWaterDepth value of 1 cm
    elseif groundWaterDepth > Tot_Depth
        warning('Groundwater table is below the end of the soil column!');
    end

end
