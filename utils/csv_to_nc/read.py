from netCDF4 import Dataset
import os

workdir = r'path_to_output_dir'

filename = workdir + '\\AU-Tum_2002-2017_OzFlux_Met.nc'
print(filename, 'contains the following:')
nc_fid = Dataset(filename, mode='r')
print(nc_fid)
x=nc_fid.variables['x']
y=nc_fid.variables['y']
time=nc_fid.variables['time']

filename = workdir + '\\output.nc'
if os.path.exists(filename):
    print()
    print(filename, 'contains the following:')
    nc_fid2 = Dataset(filename, mode='r')
    print(nc_fid2)
    x2=nc_fid2.variables['x']
    y2=nc_fid2.variables['y']
    z2=nc_fid2.variables['z']
    time2=nc_fid2.variables['time']
    temp2=nc_fid2.variables['SoilTemp']
    moist2=nc_fid2.variables['SoilMoist']


