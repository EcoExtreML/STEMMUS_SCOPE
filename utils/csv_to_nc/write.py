from netCDF4 import Dataset

def split(s):
    t=s.split('"')
    u=[t[i] for i in range(0, len(t), 2)]
    v=[t[i] for i in range(1, len(t), 2)]
    #u=[u[i][(i%2):(len(u[i])-(i+1)%2)] for i in range(0, len(u))]
    u=[u[i][(i%2):(len(u[i])-(i+1)%2)] for i in range(0, len(u)-1)] + [u[i][(i%2):] for i in range(len(u)-1, len(u))]
    w = []
    for i in range(len(u)):
        w.extend(u[i].split(','))
        if i < len(v):
            w.append(v[i])
    return w

def readcsv(filename, nrHeaderLines):
    f = open(filename)
    header = f.readline()
    header = header.strip().split(',')
    if nrHeaderLines > 1: # it is either 1 or 2
        f.readline()
    content = f.readlines()
    data = {}
    for line in content:
        line = split(line.strip())
        for i in range(0, len(header)):
            if header[i] != '':
                if header[i] not in data:
                    data[header[i]] = []
                data[header[i]].append(line[i])
    return data

def read_depths(filename):
    f = open(filename)
    depths = f.readline()
    depths = depths.strip().strip('#').strip(',').split() # the first line has ,,,,,, at the end
    depths = [float(depth) for depth in depths]
    return depths

def read2d_transposed_unit(filename, nrHeaderLines, unit, depths):
    f = open(filename)
    f.readline() # skip the headerline(s)
    if nrHeaderLines > 1: # it is either 1 or 2
        f.readline()
    content = f.readlines()
    data = []
    for line in content:
        line = line.strip().split(',')
        line = [float(l) for l in line] # convert this to float as we may want to scale it
        if unit == 'K':
            # Celsius to Kelvin : K = 273.15 + C
            line = [273.15 + c for c in line]
        elif unit == 'kg/m2':
            # Yijian Zeng: m3/m3 to kg/m2: SM = VolumetricWaterContent * Density * Thickness
            # VolumetricWaterContent: provided (m3/m3)
            # Density: constant (water_density = 1000 kg per m3)
            # Thickness (m): compute from depth (cm)
            line = [(1000.0 * vwc * depth / 100.0) for vwc,depth in zip(line, depths)]
        data.append(line)
    return data

def generateNetCdf(lat, lon, outputfile, workdir):
    # location and filenames:

    filename_out = workdir + '\\' + outputfile
    variables_filename = workdir + '\\Variables will be in NetCDF file.csv' # This is Sheet 2 from the Excel file, stored as csv, with the following changes, to make it work:
    sim_theta = workdir + '\\Sim_Theta.csv'
    sim_temp = workdir + '\\Sim_Temp.csv'

    # Renamed radiation.dat to radiation.csv
    # Renamed LEtot to lEtot
    # Split AResist into AResist_rac and AResist_ras
    # Renamed the 2nd occurence of SWdown and LWdown to SWdown_ec and LWdown_ex
    # Note that the values in this Excel sheet file determine the metadata that the variables will receive

    # specify additional metadata here:

    additional_metadata = {
        'tower_height': '80 m',
        'license_type': 'CC BY 4.0',
        'license_url': 'https://creativecommons.org/licenses/by/4.0/',
        'latitude': lat,
        'longitude': lon
        }

    # Our CSV reader can't guess the number of header-lines, so this is hardcoded here:

    headerlines = {'aerodyn.csv': 2, 'ECdata.csv': 1, 'fluxes.csv': 2, 'radiation.csv': 2, 'Sim_Temp.csv': 2, 'Sim_Theta.csv': 2, 'surftemp.csv': 2}

    print('Reading variable metadata from', "'" + variables_filename + "'")
    variables = readcsv(variables_filename, 1)
    depths = read_depths(sim_temp)

    # Create a new empty netCDF file, in NETCDF3_CLASSIC format, just like the example file AU-Tum_2002-2017_OzFlux_Met.nc

    print('Creating', "'" + filename_out + "'")
    nc = Dataset(filename_out, mode='w', format='NETCDF3_CLASSIC')

    # Create the dimensions, as required by netCDF

    nc.createDimension('x', size=1)
    nc.createDimension('y', size=1)
    nc.createDimension('z', size=len(depths))
    nc.createDimension('time', None)
    nc.createDimension('nchar', size=200) # this is not used, however the example file has it

    # Create the variables, as required by netCDF

    var_x = nc.createVariable('x', 'float64', ('x'))
    var_y = nc.createVariable('y', 'float64', ('y'))
    var_z = nc.createVariable('z', 'float64', ('z'))
    var_t = nc.createVariable('time', 'float64', ('time'))

    # Add the generic metadata (taken from additional_metadata above)

    for metadata in additional_metadata:
        nc.setncattr(metadata, additional_metadata[metadata])

    # Fill the x, y, time variables with values

    var_x[:] = lon # in the example AU-Tum_2002-2017_OzFlux_Met.nc this is 1
    var_y[:] = lat # in the example AU-Tum_2002-2017_OzFlux_Met.nc this is 1
    var_z.setncattr('units', 'depth in cm')
    var_z[:] = depths
    var_t.setncattr('units', 'seconds since 2002-01-01 00:00:00') # Note: I do not read this from the files; if it changes, edit this
    var_t.setncattr('calendar', 'standard')
    # The data of var_t is inserted at the end; when we "know" the length
    var_t_length = None

    # Add all parameters as a netCDF variable; also add the known metadata (units, long_name, Stemmus_name, definition)

    data = {}

    for i in range(len(variables['short_name_alma'])):
        variable = variables['short_name_alma'][i]
        file = variables['File name'][i]
        stemmusname = variables['Variable name in STEMMUS-SCOPE'][i]
        unit = variables['unit'][i]
        long_name = variables['long_name'][i]
        definition = variables['definition'][i]
        dimensions = variables['dimension'][i]
        var = None
        if dimensions == 'XYT':
            var = nc.createVariable(variable, 'float32', ('time','y','x'))
        elif dimensions == 'XYZT':
            var = nc.createVariable(variable, 'float32', ('time','z','y','x'))
        var.setncattr('units', unit)
        var.setncattr('long_name', long_name)
        if stemmusname != '':
            var.setncattr('Stemmus_name', stemmusname)
        if definition != '':
            var.setncattr('definition', definition)
        if stemmusname != '':
            if file not in data:
                print('Reading data from file', "'" + file + "'")
                data[file] = readcsv(workdir + '\\' + file, headerlines[file])
            var[:] = data[file][stemmusname]
            if var_t_length == None:
                var_t_length = len(data[file][stemmusname])
        else: # Sim_Temp or Sim_Theta
            print('Reading data from file', "'" + file + "'")
            matrix = read2d_transposed_unit(workdir + '\\' + file, headerlines[file], unit, depths)
            var[:] = matrix

    # Finally fill var_t with the nr of seconds per timestep
    # Note: we don't take the numbers from the file, because Year + DoY is not as accurate (it becomes 3599.99, 7199.99 etc)
    var_t[:] = [i*3600 for i in range(var_t_length)]

    nc.close()

    print('Done writing', "'" + filename_out + "'")

# main()
lat = -35.6566009521484
lon = 148.151702880859
workdir = r'path_to_output_dir' # This is the working folder; place all related files here (aerodyn.csv, ECdata.csv, fluxes.csv, radiation.csv, Sim_Temp.csv, Sim_Theta.csv, surftemp.csv, Variables will be in NetCDF file.csv)
site_name = 'MySite' # change as required
model_name = 'Stemmus' # update/correct if needed
outputfile = site_name + '_2002-2017_' + model_name + '.nc' # This is the output filename
generateNetCdf(lat, lon, outputfile, workdir)
