
from . import csv_to_nc

# Forcing data
forcing_path = './Plumber2_data/'
forcing_name = 'AR-SLu_2010-2010_FLUXNET2015_Met.nc'

# One of the model output directory
csvfiles_path = './AR-SLu_2022-02-09-1551'

# Generate EC data from forcing data
ECdata_filename, lat, lon = csv_to_nc.generate_ec_data(forcing_path, forcing_name, csvfiles_path)

# Generate netcdf file from model output csv files
variables_filename = './Variables_will_be_in_NetCDF_file.csv'
model_name = 'stemmus'
output_dir = './AR-SLu_2022-02-09-1551'

csv_to_nc.generateNetCdf(lat, lon, output_dir, csvfiles_path, variables_filename, model_name)





