"""Script to generate netcdf file from model output csv files.

python generate_netcdf_files.py --config_file config_file_crib.txt --variable_file Variables_will_be_in_NetCDF_file.csv

"""
import argparse
import csv_to_nc

from pathlib import Path


def cli():
    """Generate netcdf file from model output csv files."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config_file', '-c',
                        default=Path(Path(__file__).parents[2],'config_file_crib.txt'),
                        help='Config file')
    parser.add_argument('--variable_file', '-v',
                        default=Path(Path(__file__).parents[0],'Variables_will_be_in_NetCDF_file.csv'),
                        help='CSV file with variables that will be in NetCDF')
    args = parser.parse_args()

    with open(args.config_file) as file:
         config = dict(line.strip().split('=') for line in file)
    
    # get paths
    output_path = config['OutputPath']
    forcing_path = config['ForcingPath']
    forcing_filename = config['ForcingFileName']

    # get settings
    duration_size = config['DurationSize']

    # Find model output sub-directory linked to the forcing_filename
    station_name = forcing_filename.split("_")[0]
    model_output_dir = sorted(Path(output_path).glob(f"{station_name}*"))[-1]

    # Generate EC data from forcing data
    ECdata_filename, lat, lon, nctime = csv_to_nc.generate_ec_data(forcing_path, forcing_filename, model_output_dir, duration_size)
    print(f"{ECdata_filename}")

    # # Generate netcdf file from model output csv files
    netcdf_filename = csv_to_nc.generateNetCdf(lat, lon, nctime, model_output_dir, model_output_dir, args.variable_file, duration_size)
    print(f"Done writing {netcdf_filename}")


if __name__ == "__main__":
    cli()

