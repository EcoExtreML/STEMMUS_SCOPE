function OcParameters = readOcParameter(pathOcParameters)
% This function is used to create a lookup table for parameters of MLROC 
% model. Nine species are included.
% Reference:
%   Gu, lianhong et al, 2023, PCE (Table S2)
%     pathOcParameters = "..\example_data\MLROC_parameters.xlsx";
    opts = detectImportOptions(pathOcParameters);
    opts.VariableNamesRange = 1;
    opts.Datarange = 'A2';
    OcParameters = readtable(pathOcParameters, opts);
end