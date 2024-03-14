function [GAM] = Soil_Inertia1(SMC, theta_s0)
    % soil inertia method by Murray and Verhoef (2007), and the soil inertial (GAM) is used to calculate the soil heat flux

    % % parameters

    theta_s = theta_s0; % (saturated water content, m3/m3)
    Sr = SMC / theta_s;

    % fss = 0.58; % (sand fraction)
    gamma_s = 0.27; % (soil texture dependent parameter; if fss>0.4, gamma_s=0.96 while fss=<0.4, gamma_s=0.27)
    dels = 1.33; % (shape parameter, constant)

    ke = exp(gamma_s * (1 - power(Sr, gamma_s - dels))); % (Kersten number, Eq.(15))

    phis  = theta_s0; % (porosity, phis=theta_s=theta_s0) 
    lambda_d = -0.56 * phis + 0.51; % (thermal conductivity for air-dry soil, Eq.(16))

    QC = 0.20; % (quartz content, approximate to fss if no measured QC)
    lambda_qc = 7.7;  % (thermal conductivity of quartz, W/m.K, constant)

    lambda_s = (lambda_qc^(QC)) * lambda_d^(1 - QC); % (thermal conductivity of the soil solids, Eq.(18))
    lambda_wtr = 0.57;   % (thermal conductivity of water, W/m.K, constant)

    lambda_w = (lambda_s^(1 - phis)) * lambda_wtr^(phis); % (thermal conductivity for saturated soil, Eq.(17))

    lambdas = ke * (lambda_w - lambda_d) + lambda_d; % Eq.(14)

    Hcs = 2.0 * 10^6; % (heat capacity of solid soil minerals, J/m3.K)
    Hcw = 4.2 * 10^6; % (heat capacity of water, J/m3.K)

    Hc = (Hcw * SMC) + (1 - theta_s) * Hcs; % Eq.(13)

    GAM = sqrt(lambdas .* Hc); % Eq.(10)
end
