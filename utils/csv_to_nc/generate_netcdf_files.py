
import csv_to_nc

# TODO convert it to cli
# Edit path to forcing data
forcing_path = './Plumber2_data'
forcing_name = 'AR-SLu_2010-2010_FLUXNET2015_Met.nc'

# One of the model output directory
csvfiles_path = './AR-SLu_2022-02-09-1551'

# Generate EC data from forcing data
ECdata_filename, lat, lon, nctime = csv_to_nc.generate_ec_data(forcing_path, forcing_name, csvfiles_path)

# Edit paths
variables_filename = './Variables_will_be_in_NetCDF_file.csv'
output_dir = './AR-SLu_2022-02-09-1551'

# Generate netcdf file from model output csv files
csv_to_nc.generateNetCdf(lat, lon, nctime, output_dir, csvfiles_path, variables_filename)





