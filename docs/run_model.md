#

> NOTE: The instructions below is meant for users who want to run the model. If
you want to develop the model, see the documentation on `Contributing guide`.

## Workflow of STEMMUS_SCOPE

1. The model reads the forcing file associated with the specified location,
  e.g., `FI-Hyy_1996-2014_FLUXNET2015_Met.nc` from "ForcingPath" and extracts
  forcing variables in `.dat` format. The `.dat` files are stored in the
  `InputPath` directory. In addition, the model reads the site information i.e.
  the location and vegetation parameters.
2. The model runs step by step until the whole simulation period is completed
    i.e till the last time step of the forcing data.
3. The results are saved as binary files temporarily. Then, the binary files are
    converted to `.csv` files and stored in a `sitename_timestamped` output
    directory under `OutputPath`.

## Run the model with MATLAB

=== "Local device"
    If you have [MATLAB](https://nl.mathworks.com/products/matlab.html) installed on
    your device, you can run the model by passing config file path to the
    variable `CFG` in the main script `STEMMUS_SCOPE.m`.

    As an alternative, you can run the main script using MATLAB command line in a
    terminal:

    ```bash
    cd src/
    matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
    ```
=== "CRIB"
    To open MATLAB desktop on CRIB, click on the `Remote Desktop` in the
    Launcher. Click on the `Applications`. You will find the 'MATLAB' software
    under the `Research`. After clicking on 'MATLAB', it asks for your account
    information that is connected to a MATLAB license. Then, you can run the
    model by passing config file path to the variable `CFG` in the main script
    `STEMMUS_SCOPE.m`

=== "Snellius"
    In order to use MATLAB, you need to send a request to add you to the user pool
    on Snellius. Then, pass config file path to the variable `CFG` in the main script
    `STEMMUS_SCOPE.m`. To run the main script `STEMMUS_SCOPE.m` using MATLAB command line in a terminal on
    a **compute node**:

    ```bash
    module load 2023
    module load MATLAB/2023a-upd4
    cd src/
    matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
    ```

    To submit a job to a compute node, see instructions [here](https://servicedesk.surf.nl/wiki/display/WIKI/Example+job+scripts).

## Run the model with MATLAB Runtime

=== "Local device"
    If you want to run the model as a standalone application, you need [MATLAB
    Runtime](https://nl.mathworks.com/products/compiler/matlab-runtime.html)
    version `2023a`. You don't need a license for MATLAB Runtime. Note that the
    version of the MATLAB Runtime is tied to the version of MATLAB. The
    executable file works on the operating system on which the file is created.
    The file `STEMMUS_SCOPE` under `exe` directory is an executable file of
    STEMMUS_SCOPE that is created using MATLAB version `2023a` in a **Linux
    system**.

    Make sure `LD_LIBRARY_PATH` is set correctly, in a terminal:

    ```bash
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/MATLAB_Runtime/v2023a/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v2023a/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v2023a/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v2023a/sys/opengl/lib/glnxa64
    ```

    Change `/usr/local/MATLAB/MATLAB_Runtime/v2023a` to the path where MATLAB Runtime is installed.

    Then, you can run the model in a terminal:

    ```bash
    ./STEMMUS_SCOPE/exe/STEMMUS_SCOPE config_file_template.txt
    ```

=== "CRIB"
    On CRIB, [MATLAB
    Runtime](https://nl.mathworks.com/products/compiler/matlab-runtime.html) is
    not available. Contact the system administrator for more information.

=== "Snellius"
    [MATLAB
    Runtime](https://nl.mathworks.com/products/compiler/matlab-runtime.html) is available on Snellius. You can run the
    model by passing the path of the config file in a terminal on a **compute
    node**:

    ```bash
    module load 2023
    module load MATLAB/2023a-upd4
    ./STEMMUS_SCOPE/exe/STEMMUS_SCOPE config_file_snellius.txt
    ```

    Note that you don't need to set `LD_LIBRARY_PATH` on Snellius. To submit a job to a compute node, see instructions [here](https://servicedesk.surf.nl/wiki/display/WIKI/Example+job+scripts).

=== BMI interface
    You can run the model using the [BMI](https://bmi.readthedocs.io/en/stable/)
    interface. The BMI interface is available in the script
    `STEMMUS_SCOPE_exe.m`. For that, you need [MATLAB
    Runtime](https://nl.mathworks.com/products/compiler/matlab-runtime.html)
    version `2023a`. You don't need a license for MATLAB Runtime. Note that the
    version of the MATLAB Runtime is tied to the version of MATLAB. The
    executable file works on the operating system on which the file is created.
    The file `STEMMUS_SCOPE` under `exe` directory is an executable file of
    STEMMUS_SCOPE that is created using MATLAB version `2023a` in a **Linux
    system**.

    Make sure `LD_LIBRARY_PATH` is set correctly, in a terminal:

    ```bash
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/MATLAB_Runtime/v2023a/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v2023a/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v2023a/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v2023a/sys/opengl/lib/glnxa64
    ```

    Change `/usr/local/MATLAB/MATLAB_Runtime/v2023a` to the path where MATLAB Runtime is installed.

    To enter the BMI mode:

    ```bash
    ./STEMMUS_SCOPE/exe/STEMMUS_SCOPE "" bmi
    ```

    Now, BMI asks you to select one of the steps "initialize", "update" or "finalize".
    To initialize the model using a config file, type:

    ```bash
    initialize "path/to/config_file_template.txt"
    ```

    Change `path/to/config_file_template.txt` to the actual path of the config file.

## Run the model with Octave

=== "Local device"
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

=== "CRIB"
    On CRIB, you can use [Octave](https://octave.org/). Allmost all
    funcationalities of STEMMUS_SCOPE are compatible with Octave, but the
    execution time is longer than MATLAB. After Octave installation, launch
    octave and install the following Octave packages:

    ```bash
    pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/io-2.6.4.tar.gz"
    pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/statistics-1.4.3.tar.gz"
    ```

    Then, pass config file path to the variable `CFG` in the main script
    `STEMMUS_SCOPE.m`. Run the model in a terminal:

    ```bash
    octave.bat --no-gui --interactive --silent --eval "STEMMUS_SCOPE"
    ```

=== "Snellius"
    Since Octave is very slow, it is not recommended to run the model on
    Snellius using Octave. Use MATLAB Runtime instead.

## Run the model with Docker

=== "Local device"
    If you have [Docker](https://www.docker.com/) installed on your device, you
    can run the model using the docker image `ecoextreml/stemmus_scope` and
    [BMI](https://bmi.readthedocs.io/en/stable/) interface. The docker image is available
    on
    [EcoExtreML](https://github.com/EcoExtreML/STEMMUS_SCOPE/pkgs/container/stemmus_scope).
    You can pull the `latest` image using the following command:

    ```bash
    docker pull ghcr.io/ecoextreml/stemmus_scope:latest
    ```

    Then, mount the directories and run the model in a terminal:

    ```bash
    docker run -u $(id -u):$(id -g) -v /path_to_input_folder:/path_to_input_folder -v /path_to_output_folder:/path_to_output_folder -it ghcr.io/ecoextreml/stemmus_scope:latest
    ```

    With `-it` option, you can enter the docker interactive mode.
    Now, BMI asks you to select one of the steps "initialize", "update" or "finalize".
    To initialize the model using a config file, type:

    ```bash
    initialize "path/to/config_file_template.txt"
    ```

    Make sure that the input and output directories are mounted correctly
    and `config_file_template.txt` is available in the input directory.
    Also, remove the container after running the model:

    ```bash
    docker rm container_id
    ```

=== "CRIB"
    If [Docker](https://www.docker.com/) is installed on CRIB, follow the same
    instructions as for the `Local device`.

=== "Snellius"
    [Docker](https://www.docker.com/) option is not available on Snellius. You
    need to use
    [Apptainer](https://apptainer.org/docs/user/main/introduction.html), see
    instructions
    [here](https://servicedesk.surf.nl/wiki/pages/viewpage.action?pageId=30660251).
