"""
Read forcing data and create EC data in csv format.
"""
import pandas as pd

from netCDF4 import Dataset, num2date

forcing_path = './Plumber2_data/'
forcing_name = 'FI-Hyy_1996-2014_FLUXNET2015_Met.nc'

# read data
nc_fid = Dataset(forcing_path + forcing_name, mode='r')

# Extract variables as numpy arrays
t = nc_fid.variables['time'][:].flatten()/3600/24

Ta = nc_fid.variables['Tair'][:].flatten()-273.15

Rin = nc_fid.variables['SWdown'][:].flatten()

u = nc_fid.variables['Wind'][:].flatten()

Rli = nc_fid.variables['LWdown'][:].flatten()

p = nc_fid.variables['Psurf'][:].flatten()/100

RH = nc_fid.variables['RH'][:].flatten()

LAI = nc_fid.variables['LAI'][:].flatten()

nctime = nc_fid.variables['time']
ncdate = num2date(nctime[:],units= nctime.units, calendar=nctime.calendar)
year = [date.year for date in ncdate]

Pre = nc_fid.variables['Precip'][:].flatten()/10

CO2air = nc_fid.variables['CO2air'][:].flatten()*44/22.4

Qair = nc_fid.variables['Qair'][:].flatten()

data = [t, Ta, Rin, u, Rli, p, RH, LAI, year, Pre, CO2air, Qair]
names = ['t', 'Ta', 'Rin', 'u', 'Rli', 'p', 'RH', 'LAI', 'year', 'Pre', 'CO2air', 'Qair']

# Write to csv
df = pd.DataFrame.from_dict(dict(zip(names, data)))
output_path = "."
output_name = forcing_name.replace(".nc", "_ECdata.csv")
df.to_csv(output_path + output_name, index=False)