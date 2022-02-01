# STEMMUS_SCOPE
Integrated code of SCOPE and STEMMUS 

(1) How to run STEMMUS_SCOPE v1.0.0 on CRIB:

    1. Log in CRIB. Open https://crib.utwente.nl/, then click login (with your username and pasword). 
    2. Find the 'Remote Desktop' in the Launcher and click it.
    3. Find the 'Applications'and click it, you will find the 'MATLAB' software in the 'Research'.
    4. Open the 'MATLAB' using your account.
    5. All the code can be found in the folder 'src' in this repository.
    6. In a terminal, run:
    ```bash
    matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
    ```

(2) The dataflow of the STEMMUS_SCOPE v1.0.0:

    1. The driving data provided by PLUMBER2 were saved at the folder named 'Plumber2_data'. 
       The soil texture data and soil hydraulic parameters data were saved at the folder named 'SoilProperty'.
       The results of the model will be saved at the folder named 'output'.

    2. The main program is 'STEMMUS_SCOPE.m'. Currently, the model can be run at the site scale. 
    For example, if we put the 'FI-Hyy_1996-2014_FLUXNET2015_Met.nc' file in the 'input' folder. The model will be run at the FI-Hyy site.

    3. After the model was started, the workflow are as follows:
       (1) The model will read the 'FI-Hyy_1996-2014_FLUXNET2015_Met.nc' file and transfer it into '.dat' files with 'filesread.m' (you can find the '.dat' files in the 'input' folder). In addition, the site information (including location and vegetation) were also read.
       (2) Then, the model will read the soil parameters with 'soilpropertyread.m'.
       (3) Some constants will be loaded using 'Constant.m'.
       (4) The model will run step by step until the whole simulation period is completed.
       (5) The results will be saved as 'binary files' temporarily and the 'binary files' will be transferred to '.csv' files at the end.

(3) Run STEMMUS_SCOPE v1.0.0 on a different compute node:

Open the file "filesread.m" and set all paths at the top of this file. The rest of the workflow is the same as explained above. 

(4) Converting `.csv` files to NetCDF files:

There is some files in utils directory in this repository. The utils are used to
read `.csv` files and save them in `.nc` format. 

> An example NetCDF file is stored in the project directory to show the desired
  structure of variables in one file.

(5) [Create Standalone Application from MATLAB](https://nl.mathworks.com/help/compiler/mcc.html)

```bash
mcc -m STEMMUS_SCOPE/src/STEMMUS_SCOPE_exe.m -a STEMMUS_SCOPE/src -d STEMMUS_SCOPE/exe -o STEMMUS_SCOPE -R nodisplay
```