# STEMMUS_SCOPE
Integrated code of SCOPE and STEMMUS 

How to run STEMMUS_SCOPE v1.0.0 on CRIB:
    1. Log in CRIB. Open https://crib.utwente.nl/, then click login (with your username and pasword). 
    2. Find the 'Remote Desktop' in the Launcher and click it.
    3. Find the 'Applications'and click it, you will find the 'MATLAB' software in the 'Research'.
    4. Open the 'MATLAB' using your account.
    5. The STEMMUS_SCOPE v1.0.0 was saved at the folder '/data/shared/EcoExtreML/STEMMUS_SCOPE v1.0.0/src/STEMMUS_SCOPE.m'
    6. Open the 'STEMMUS_SCOPE.m' file and run it.

The dataflow of the STEMMUS_SCOPE v1.0.0
    1. The driving data provided by PLUMBER2 were saved at the folder named '../Plumber2 data'. 
       The soil texture data and soil hydraulic parameters data were saved at the folder named '../SoilProperty'.
       The results of the model will be saved at the folder named '../output'.
       All the code can be find at the folder named '../src'.

    2. The main program is 'STEMMUS_SCOPE.m'. Currently, the model can be run at the site scale. 
    For example, if we put the 'AU-Tum_2002-2017_OzFlux_Met.nc' file in the 'input' folder. The model will be run at the AU-TUM site.

    3. After the model was started, the workflow are as follows:
       (1) The model will read the 'AU-Tum_2002-2017_OzFlux_Met.nc' file and transfer it into '.dat' files with 'filesread.m' (you can find the '.dat' files in the 'input' folder). In addition, the site information (including location and vegetation) were also read.
       (2) Then, the model will read the soil parameters with 'soilpropertyread.m'.
       (3) Some constants will be load using 'constant.m'.
       (4) The model will run step by step until the whole simulation period completed.
       (5) The results were be saved as 'binary files' temporarily and the 'binary files' will be transfer to '.csv' files at the end.



