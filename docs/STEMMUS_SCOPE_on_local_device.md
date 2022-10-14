## STEMMUS_SCOPE on local device

You can run STEMMUS_SCOPE locally. Follow the steps below and use `config_file_crib.txt` to configure the paths correctly.

### How to run STEMMUS_SCOPE on local device:

1. Download the source code from this repository or get it using `git clone` in
  a terminal:
  
  ` git clone https://github.com/EcoExtreML/STEMMUS_SCOPE.git `
  
  All the codes can be found in the folder `src` whereas the executable file in
  the folder `exe`.

2. Check `config_file_crib.txt` and change the paths if needed, specifically
   "InputPath" and "OutputPath".
3. Follow the instructions below:

#### Run using MATLAB Compiler that does not require a license

If you want to run the model as a standalone application, you need MATLAB
Runtime version `2021a`. To download and install the MATLAB Runtime, follow
this
[instruction](https://nl.mathworks.com/products/compiler/matlab-runtime.html).
The "STEMMUS_SCOPE" executable file is in `STEMMUS_SCOPE/exe` directory
in this repository. You can run the model by passing the path of the config
file in a terminal:

```bash
exe/STEMMUS_SCOPE config_file_crib.txt
```