function [SoilPropertyPath, InputPath, OutputPath, ForcingPath, ForcingFileName] = read_config(config_file)

file_id = fopen(config_file);
config = textscan(file_id,'%s %s', 'HeaderLines',0, 'Delimiter', '=');
fclose(file_id);

%% separate vars and paths
config_vars = config{1};
config_paths = config{2};

%% find the required path by model
indx = find(strcmp(config_vars, 'SoilPropertyPath'));
SoilPropertyPath = config_paths{indx};

indx = find(strcmp(config_vars, 'InputPath'));
InputPath = config_paths{indx};

indx = find(strcmp(config_vars, 'OutputPath'));
OutputPath = config_paths{indx};

indx = find(strcmp(config_vars, 'ForcingPath'));
ForcingPath = config_paths{indx};

indx = find(strcmp(config_vars, 'ForcingFileName'));
ForcingFileName = config_paths{indx};
