function volumetricWaterContent = van_genuchten(Theta, alpha, hParameter, nParameter, mParameter)
%myFun - Description
%
% Syntax: output = myFun(input)
%
%  van Genuchten model Van Genuchten MTh, Leij FJ, Yates SR (1991) The RETC code
%  for quantifying the hydraulic functions of unsaturated soils.
%  EPA/600/2-91/065. In: Kerr RS (ed) Environmental Research Laboratory. US
%  Environmental Protection Agency, Ada, OK, p 83

    volumetricWaterContent = Theta.r+(Thet.s-Theta.r)/(1+abs(alpha)*(hParameter)^nParameter)^mParameter;
end