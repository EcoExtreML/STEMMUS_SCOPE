1- The versions of STEMMUS and MODFLOW codes that were coupled are in the folders “stemmus_src” “modflow_src”:

2- To highlight the name(s) of the files that you had changed

	Folder “modflow_src”:
MAIN.F
gwf2Q3D1H.F
gwf2Q3D1.f

	Folder “stemmus_src”:
Modified:
Diff_Moisture_Heat.m
Dtrmn_Z.m
Evap_Cal.m
Forcing_PARM.m
h_BC.m

Newly added:
CondL_hUncp.m to replace CondL_h.m
EfeCapCondUncp.m to replace EfeCapCon.m
FINDTABLE.m
HYDRUS1RECHARGE.m
KPILR_Cal.m
MainLoop_par.m
MainLoop11.m to replace MainLoop.m
MainLoopAll.m
SOIL1_SPAT.m to replace SOIL1.m
STEMMUS_config.m to replace Constants.m and StartInit.m
TIME_INTERPOLATION.m

3- To highlight the variable names (and also the variables meanings) that you change or you add into STEMMUS and MODFLOW
Please see the explanations in the changed files.
