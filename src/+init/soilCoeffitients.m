function Coefficient = soilCoeffitients(SWCC, CHST)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% Long description

    for JJ=1:6
        % parameters of van Genuchten model
        Coefficient.Theta.s(JJ)=SaturatedMC(JJ); % TODO check these vars
        Coefficient.Theta.r(JJ)=ResidualMC(JJ);
        Coefficient.Theta.f(JJ)=fieldMC(JJ);
        Coefficient.n(JJ)=Coefficient_n(JJ);
        Coefficient.Alpha(JJ)=Coefficient_Alpha(JJ);
        Coefficient.m(JJ)=1-1/n(JJ);
    %     XK(JJ)=0.09; %0.11 This is for silt loam; For sand XK=0.025
        Coefficient.XK(JJ)=Theta_r(JJ)+0.02; %0.11 This is for silt loam; For sand XK=0.025
        Coefficient.XWILT(JJ)=equations.van_genuchten(Theta, Alpha(JJ), -1.5e4, n(JJ), m(JJ));
        Coefficient.XCAP(JJ)=equations.van_genuchten(Theta, Alpha(JJ), -336, n(JJ), m(JJ));

        Coefficient.POR(JJ)=porosity(JJ);
        Coefficient.VPERS(JJ)=FOS(JJ)*(1-POR(JJ));
        Coefficient.VPERSL(JJ)=FOSL(JJ)*(1-POR(JJ));
        Coefficient.VPERC(JJ)=FOC(JJ)*(1-POR(JJ));

        Coefficient.Ks(JJ)=SaturatedK(JJ);
        if SWCC==0
            if CHST==0
                Coefficient.Phi_s(JJ)=Phi_S(JJ);
                Coefficient.Lamda(JJ)=Coef_Lamda(JJ);
            end
            Coefficient.Theta_s(JJ)=Theta_s_ch(JJ);
        end
    end
end

POR Theta_s Theta_r Theta_f n Ks Alpha m 