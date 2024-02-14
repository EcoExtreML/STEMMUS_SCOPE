function [ModflowCoupling, soilLayerThickness] = readModflowConfigs(config_file)
    %{
    %}
    file_id = fopen(config_file);
    config = textscan(file_id, '%s %s', 'HeaderLines', 0, 'Delimiter', '=');
    fclose(file_id);

    %% separate vars and paths
    config_vars = config{1};
    config_values = config{2};
	
    %% find the required path by model
    indx = find(strcmp(config_vars, 'ModflowCoupling'));
    ModflowCoupling = config_values{indx};	

    % Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % added by layers
	
    % next 9 lines -> retreived from Lianyu's STEMMUS_MODFLOW
    soilLayerThickness = zeros(NN, 1); % layer thickness of STEMMUS soil layers
    soilLayerThickness(1) = 0;
    TDeltZ = flip(ModelSettings.DeltZ);
    for ML = 2: NL
	soilLayerThickness(ML) = soilLayerThickness(ML - 1) + TDeltZ(ML - 1);
    end
    soilLayerThickness(NN) = ModelSettings.Tot_Depth;
	
    %  To be decided later if needed
    %ModflowConfigs.NLAY = 3; % number of MODFLOW layers
    %ModflowConfigs.ADAPTF = 1; % indicator for adaptive lower boundary setting, 1 means moving lower boundary; 0 means fixed lower boundary
    %ModflowConfigs.nSoilColumns = 1; % number of STEMMUS soil columns for MODFLOW
    %ModflowConfigs.HPUNIT = 100; % unit conversion from m to cm (MODFLOW values in m)
    %ModflowConfigs.botmLayerLevel = 100.0 * ModflowConfigs.HPUNIT; % elevation of the bottom layer of MODFLOW
    %ModflowConfigs.TopLayerLevel = [200.0  180.0  190.0  185.0  170] .* ModflowConfigs.HPUNIT; % elevation at the top surface
end
