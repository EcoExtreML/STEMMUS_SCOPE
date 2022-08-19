function [Constant] = ConstantOfInit(MSOC, FOC, FOS)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% Long description
    Constant.hd = -1e7;
    Constant.hm = -9899;
    % SWCC = 0;    % indicator for choose the soil water characteristic curve, =0, Clapp and Hornberger; =1, Van Gen;
    Constant.CHST = 0;
    Constant.Elmn_Lnth = 0;
    Constant.Dmark = 0;
    Constant.Vol_qtz = FOS;
    Constant.VPERSOC = MSOC.*2700./((MSOC.*2700)+(1-MSOC).*1300);  % fraction of soil organic matter
    Constant.FOSL = 1-FOC-FOS-VPERSOC;
    Constant.Phi_S = [-17.9 -17 -17 -19 -10 -10];
    Constant.Phi_soc = -0.0103;
    Constant.Lamda_soc = 2.7;
    Constant.Theta_soc = 0.6;

end