% psi50 = ParaPlant.psi50;
% ck = ParaPlant.ck;
function phwsf = PlantHydraulicsStressFactor(psi, psi50, shapeFactor, phwsfMethod)
% This function is to calculate water stress factor based on plant
% hydraulisc theory.
%     Input:
%         psi: water potential
%         psi50: parameter of plant hydraulic pathway
%         shapeFactor: a struct contains parameter of plant hydraulic pathway
%                      ck for CLM5
%                      a for ED2
%                      m for PHS
%         phwsf_method : phwsf_method, the default approah is weibull method
% 
%     Output:
%         phwsf: plant hydraulic water stress factor, scale from 0 to 1.
%         The value of 0 means that a severe water stress, and the value of
%         1 means there is no water stress.
%
%     References:
%         1. D. Kennedy et al_2019_JAMESM_Implementing Plant Hydraulics in the Community Land Model, Version 5, DOI: https://doi.org/10.1029/2018MS001500
%         2. X. Xu et al_2016_New Phytol_Diversity in plant hydraulic traits explains seasonal and inter-annual variations of vegetation dynamics in seasonally dry tropical forests, DOI: 10.1111/nph.14009

    
    % ========== define phwsf method ===============
    if nargin < 4
        phwsfMethod = 'CLM5';
    else
        phwsfMethod = phwsfMethod;
    end
    
    % ========= calculate phwsf ===================
    switch phwsfMethod
        case 'CLM5'
            ckCLM = shapeFactor;  % shape factor in CLM5 scheme
            phwsf = CLM5(psi, psi50, ckCLM);
            phwsf(phwsf < 5e-5) = 0;
        case 'ED2'
            aED2  = shapeFactor;   % shape factor in ED2 scheme
            phwsf =  ED2(psi, psi50, aED2);
        case 'STEMMUS-SCOPE'
            mPHS  = shapeFactor;   % shape factor in STEMMUS-SCOPE-PHS
            p0 = -0.33; 
            phwsf = PHS(psi, psi50, mPHS)       
%         case ''
        otherwise
            phwsf = NaN;
            fprintf('phwsf method need to be defined\n.')
    end
end

function phwsf = CLM5(psi, psi50, ck)
%{
    This function calculated plant hydraulic water stress factor based on
    the scheme of CLM5
    Input:
        psi      : leaf water potential (m)
        psi50    : P50 value            (m)
        ck       : shape factor         (-)
    Output:
        phwsf    : plant hydraulic water stress factor, range from 0 to 1.
%}
    phwsf = 2.^(-(psi./psi50)).^ck;
    phwsf(phwsf < 5e-5) = 0;
    
end

function phwsf = ED2(psi, psi50, a)
%{
    This function calculated plant water stress factor based on the scheme
    of ED2. (Xu, Xiangtao_2016_new phytologist)
%}

    phwsf = (1+(psi./psi50).^a).^-1;
end


function phwsf = PHS(psi, psi50, m)
%{
    A new plant water stress function format based on soil water stress
    factor. Since the observed plant water potential with the unit of MPa,
    thus, we translate the unit from m to MPa at first. Then use curve
    fitting to retrive the parameters.
%}
    m2MPa = 1*9810/1e6;
    psiMPa = psi .* m2MPa;
    psi50MPa  = psi50 .* m2MPa;
    psi0  = -0.33; % psi0 is p0, we use the soil water potential at the field capacity to represent this value.
    % -m .* psi0 = psi0 + (psi1.5MPa + psi0)/2
    phwsf = (1+exp(-m .* psi0 * (psiMPa - psi50MPa))).^-1;
%     % -m .* psi0 = psi0 + (psi1.5MPa + psi0)/2
end




