# Using STEMMUS-SCOPE with GNU Octave
The downloads can be found here
https://octave.org/download

After installation, install the following Octave packages have to be installed:
`pkg install netcdf`
`pkg install statistics`

### VS Code setup
Add Octave to path, e.g. for (64-bit) Windows:
`C:\Program Files\GNU Octave\Octave-7.1.0\mingw64\bin`

Add the extensions
`Octave Debugger` by Paulo Silva https://marketplace.visualstudio.com/items?itemName=paulosilva.vsc-octave-debugger
This allows to run Octave in the VS Code debugger.
The debugger configurations are included in `/.vscode/launch.json`

`Octave Hacking` by Andrew Janke https://marketplace.visualstudio.com/items?itemName=apjanke.octave-hacking
This adds syntax highlighting and formatting.

### Running STEMMUS-SCOPE
Open the `run_Octave.m` file, either in VS Code or the Octave GUI.

#### Octave GUI
Set the workspace to the `STEMMUS_SCOPE/src` folder, and open the `run_Octave.m` file.
Here you can set the config file that should be used, and then run the file.

#### VS Code
While having the `STEMMUS_SCOPE` folder as the workspace, open the debugger and select `Octave: Debug STEMMUS-SCOPE`.
Start the debugger to run (and debug) the model.

In the `run_Octave.m` file you can set the config file that should be used.
