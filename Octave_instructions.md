# Using STEMMUS-SCOPE with GNU Octave
The downloads can be found here
https://octave.org/download

TODO: installation of octave on linux
After installation, install the following Octave packages have to be installed:
`pkg install -forge netcdf`
`pkg install -forge statistics`

For off-line installation, first, download the packages [netcdf](https://octave.sourceforge.io/netcdf/index.html), [io](https://octave.sourceforge.io/io/index.html) and [statistics](https://octave.sourceforge.io/statistics/index.html). Then, launch octave and run:

`pkg install netcdf-1.0.16.tar.gz`
`pkg install io-2.6.4.tar.gz`
`pkg install statistics-1.4.3.tar.gz`

### VS Code setup
Add Octave to path, e.g. for (64-bit) Windows:
`C:\Program Files\GNU Octave\Octave-7.1.0\mingw64\bin`

Add the extensions
`Octave Debugger` by Paulo Silva https://marketplace.visualstudio.com/items?itemName=paulosilva.vsc-octave-debugger
This allows to run Octave in the VS Code debugger.
The debugger configurations are included in `/.vscode/launch.json`

`Octave Hacking` by Andrew Janke https://marketplace.visualstudio.com/items?itemName=apjanke.octave-hacking
This adds syntax highlighting and formatting.

### Running STEMMUS-SCOPE in Octave
It is possible to run STEMMUS-SCOPE from the command line with the following setup:
`octave.bat --no-gui --interactive --silent --eval "STEMMUS_SCOPE_exe('path_to_config_file')"`

On a Unix system, use `octave` instead of `octave.bat`.
### Developing STEMMUS-SCOPE in Octave
Open the `run_Octave.m` file, either in VS Code or the Octave GUI.

#### Octave GUI
Set the workspace to the `STEMMUS_SCOPE/src` folder, and open the `run_Octave.m` file.
Here you can set the config file that should be used, and then run the file.

#### VS Code
While having the `STEMMUS_SCOPE` folder as the workspace, open the debugger and select `Octave: Debug STEMMUS-SCOPE`.
Start the debugger to run (and debug) the model.

In the `run_Octave.m` file you can set the config file that should be used.



