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
         paths = dict(line.strip().split('=') for line in file)
    
    output_path = paths['OutputPath']
    forcing_path = paths['ForcingPath']
    forcing_filename = paths['ForcingFileName']

    # Find model output sub-directory linked to the forcing_filename
    station_name = forcing_filename.split("_")[0]
    model_output_dir = sorted(Path(output_path).glob(f"{station_name}*"))[-1]

    # Generate EC data from forcing data
    ECdata_filename, lat, lon, nctime = csv_to_nc.generate_ec_data(forcing_path, forcing_filename, model_output_dir)
    print(f"{ECdata_filename}")

    # # Generate netcdf file from model output csv files
    netcdf_filename = csv_to_nc.generateNetCdf(lat, lon, nctime, model_output_dir, model_output_dir, args.variable_file)
    print(f"Done writing {netcdf_filename}")


if __name__ == "__main__":
    cli()

