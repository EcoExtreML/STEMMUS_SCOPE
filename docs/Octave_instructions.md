# Running STEMMUS-SCOPE in Octave

If you want to run the model for a small time period or tests purpose, you
can use [Octave](https://octave.org/). Allmost all funcationalities of
STEMMUS_SCOPE are compatible with Octave, but the execution time is longer
than MATLAB. After Octave installation, launch octave and install the following Octave packages:

```bash
pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/io-2.6.4.tar.gz"
pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/statistics-1.4.3.tar.gz"
```

Then, pass config file path to the variable `CFG` in the main script
`STEMMUS_SCOPE.m`. Run the model in a terminal:

```bash
cd src/
octave.bat --no-gui --interactive --silent --eval "STEMMUS_SCOPE"
```

On a Unix system, use `octave` instead of `octave.bat`.

<details>
<summary>Octave from source</summary>

Note that Octave on many Linux distributions might be too old so we need to compile it ourselves.
See [https://wiki.octave.org/Building](https://wiki.octave.org/Building). Here are build instructions for Ubuntu 22.04:

```shell
sudo apt update
# install minimal deps, see https://wiki.octave.org/Octave_for_Debian_systems#The_right_way for all dependencies
sudo apt install -yq wget build-essential gfortran liblapack-dev libblas-dev libpcre3-dev libreadline-dev libnetcdf-dev
wget https://mirror.serverion.com/gnu/octave/octave-7.2.0.tar.gz  # or download from local mirror at https://ftpmirror.gnu.org/octave
tar -zxf octave-7.2.0.tar.gz
cd octave-7.2.0
./configure --prefix=/opt/octave
make -j 6
sudo make install
```

Add `/opt/octave/bin` to PATH environment variable.

```shell
export PATH=$PATH:/opt/octave/bin
```

Launch Octave and install Octave dependencies with:

```bash
pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/io-2.6.4.tar.gz"
pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/statistics-1.4.3.tar.gz"
```
</details>

## VS Code setup
Add Octave to path, e.g. for (64-bit) Windows add the following folders:
`C:\Program Files\GNU Octave\Octave-7.1.0\mingw64\bin`
`C:\Program Files\GNU Octave\Octave-7.1.0\usr\bin`

Add the extensions
`Octave Debugger` by Paulo Silva https://marketplace.visualstudio.com/items?itemName=paulosilva.vsc-octave-debugger
This allows to run Octave in the VS Code debugger.
The debugger configurations are included in `/.vscode/launch.json`

`Octave Hacking` by Andrew Janke https://marketplace.visualstudio.com/items?itemName=apjanke.octave-hacking
This adds syntax highlighting and formatting.

## Developing STEMMUS-SCOPE in Octave
Open the `debug_Octave.m` file, either in VS Code or the Octave GUI.

### Octave GUI
Set the workspace to the `STEMMUS_SCOPE/src` folder, and open the `debug_Octave.m` file.
Here you can set the config file that should be used, and then run the file.

### VS Code
While having the `STEMMUS_SCOPE` folder as the workspace, open the debugger and select `Octave: Debug STEMMUS-SCOPE`.
Start the debugger to run (and debug) the model.

In the `debug_Octave.m` file you can set the config file that should be used.

## VS Code + Dev container

If you have Docker installed and running you can use a container to do development.

Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VS code extension and reopen the folder in VS Code.

It will then start a Docker container with your code, Octave and the VS Code Octave extensions.

### Mount extra directory

By default a Dev container only has the current VS code folder mounted inside the container.

To add additional directories like directory with model input files to the
container you will need to edit the
[.devcontainer/devcontainer.json](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/.devcontainer/devcontainer.json)
and add

```json
"mounts": [
  "source=/local/source/path/goes/here,target=/target/path/in/container/goes/here,type=bind,consistency=cached"
]
```

After editing file you can restart the editor to get the extra directory inside the dev container.

See [dev container docs](https://code.visualstudio.com/remote/advancedcontainers/add-local-file-mount) for more info.

To mount Windows directory inside the dev container you have to start the container in WSL2 (aka run Docker service inside WSL2) and use unix paths like `/mnt/c/...`.
