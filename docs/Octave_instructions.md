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

To add additional directories like directory with model input files to the container you will need to edit the [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) and add

```json
"mounts": [
  "source=/local/source/path/goes/here,target=/target/path/in/container/goes/here,type=bind,consistency=cached"
]
```

After editing file you can restart the editor to get the extra directory inside the dev container.

See [dev container docs](https://code.visualstudio.com/remote/advancedcontainers/add-local-file-mount) for more info.

To mount Windows directory inside the dev container you have to start the container in WSL2 (aka run Docker service inside WSL2) and use unix paths like `/mnt/c/...`.
