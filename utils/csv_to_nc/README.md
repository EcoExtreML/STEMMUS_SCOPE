# Converting `.csv` files to NetCDF files

The model outputs are expected to be in one NetCDF file according to [ALMA
conventions](https://web.lmd.jussieu.fr/~polcher/ALMA/). The file
[required_netcdf_variables.csv](./required_netcdf_variables.csv)
lists required variable names and their attributes based on [`ALMA+CF`
convention table](https://docs.google.com/spreadsheets/d/1CA3aTvI9piXqRqO-3MGrsH1vW-Sd87D8iZXHGrqK42o/edit#gid=2085475627).  

The MATLAB source code writes model outputs in `csv` format in the output
directory. The NetCDF file is generated using the module `save.py` from
[`PyStemmusScope`](https://pystemmusscope.readthedocs.io/en/latest/reference/#PyStemmusScope.save).
