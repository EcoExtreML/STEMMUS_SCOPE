# Using STEMMUS-SCOPE with GNU Octave

- [Using STEMMUS-SCOPE with GNU Octave](#using-stemmus-scope-with-gnu-octave)
  - [VS Code setup](#vs-code-setup)
  - [Running STEMMUS-SCOPE in Octave](#running-stemmus-scope-in-octave)
  - [Developing STEMMUS-SCOPE in Octave](#developing-stemmus-scope-in-octave)
    - [Octave GUI](#octave-gui)
    - [VS Code](#vs-code)
  - [VS Code + Dev container](#vs-code--dev-container)
    - [Mount extra directory](#mount-extra-directory)
  - [Linux from source](#linux-from-source)

The downloads can be found here
https://octave.org/download

TODO: installation of octave on linux
After installation, launch octave and install the following Octave packages:
`pkg install -forge netcdf`
`pkg install -forge statistics`

For off-line installation, first, download the packages [netcdf](https://octave.sourceforge.io/netcdf/index.html), [io](https://octave.sourceforge.io/io/index.html) and [statistics](https://octave.sourceforge.io/statistics/index.html). Then, launch octave and run:

`pkg install netcdf-1.0.16.tar.gz`
`pkg install io-2.6.4.tar.gz`
`pkg install statistics-1.4.3.tar.gz`

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

## Running STEMMUS-SCOPE in Octave
It is possible to run STEMMUS-SCOPE from the command line with the following setup:
`octave.bat --no-gui --interactive --silent --eval "STEMMUS_SCOPE_exe('path_to_config_file')"`

On a Unix system, use `octave` instead of `octave.bat`.
## Developing STEMMUS-SCOPE in Octave
Open the `run_Octave.m` file, either in VS Code or the Octave GUI.

### Octave GUI
Set the workspace to the `STEMMUS_SCOPE/src` folder, and open the `run_Octave.m` file.
Here you can set the config file that should be used, and then run the file.

### VS Code
While having the `STEMMUS_SCOPE` folder as the workspace, open the debugger and select `Octave: Debug STEMMUS-SCOPE`.
Start the debugger to run (and debug) the model.

In the `run_Octave.m` file you can set the config file that should be used.

## VS Code + Dev container

If you have Docker installed and running you can use a container to do development.

Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VS code extension and reopen the folder in VS Code.

It will then start a Docker container with your code, Octave and the VS Code Octave extensions.

### Mount extra directory

By default a Dev container only has the current VS code folder mounted inside the container.

To add additional directories like directory with model input files to the container you will need to edit the [.devcontainer/decontainer.json](.devcontainer/decontainer.json) and add

```json
"mounts": [
  "source=/local/source/path/goes/here,target=/target/path/in/container/goes/here,type=bind,consistency=cached"
]
```

After editing file you can restart the editor to get the extra directory inside the dev container.

See [dev container docs](https://code.visualstudio.com/remote/advancedcontainers/add-local-file-mount) for more info.

To mount Windows directory inside the dev container you have to start the container in WSL2 and use unix paths like `/mnt/c/...`.

## Linux from source

Octave on many Linux distributions is too old so we need to compile it ourselves.
See [https://wiki.octave.org/Building](https://wiki.octave.org/Building).

<details>
<summary>Here are build instructions for Ubuntu 22.04</summary>

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

Install Octave dependencies with

```shell
octave --eval 'pkg install -forge statistics'
octave --eval 'pkg install -forge netcdf'
```
</details>