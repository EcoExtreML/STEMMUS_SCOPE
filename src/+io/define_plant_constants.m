function ParaPlant = define_plant_constants(SiteProperties, phwsfMethod)
% define parameters used in plant hydraulic pathway
% Input: 
%     SiteProperties
%     phwsfMethod: define phwsf method

% Output:
%     ParaPlant: A structure contains all of parameters used in plant hydraulic pathway.

% Reference:
%     Parameters cite from Li,Hongmei_forests_2021
%     Functions cite from Kennedy_JAMES_2019

       
    %% ----------------------- root growth ----------------------------
    ParaPlant.C2B            = 2;         %(g biomass / gC)
    ParaPlant.B2C            = 0.488;     % ratio of biomass to carbon [gC / g biomass]
    ParaPlant.rootRadius     = 1.5*1e-3;  % root radius [m] (2.9e-4 in CLM5),  (0.5-6e-3 m)in STEMMUS_SCOPE_GMD
    ParaPlant.rootDensity    = 250*1000;  % Root density Jackson et al., 1997 [gDM / m^3] 
    pa2m                     = 1/9810;    % Pressure = rho g h = 1000kg m-3 * 9.81 m s-2 *1 m = 9810 Pa. 1m = 9810Pa
    ParaPlant.s2l            = 0.1;       % The ratio of stem area index to leaf area index: SAI = s2l * LAI;
    
    %% ----------------------- define IGBP vegetation type ----------------------
    igbpVegLong = SiteProperties.landcoverClass;
    ParaPlant.phwsfMethod = phwsfMethod;
    switch phwsfMethod
        case 'CLM5'
            %% ----------------------- Plant hydraulics -----------------------
            if strcmp(igbpVegLong(1:18)', 'Permanent Wetlands') 
                    ParaPlant.p50Leaf        = -260;       % parameter of plant hydraulic pathway [m] 
                    ParaPlant.p50Stem        = -260;       % parameter of plant hydraulic pathway [m] 
                    ParaPlant.p50Root        = -260;       % parameter of plant hydraulic pathway [m] 

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule in CLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:19)', 'Evergreen Broadleaf') 
                    ParaPlant.p50Leaf        = -260;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -175;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -175;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 1.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 1.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 1.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =6e-9;%1.28e-7;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =4e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =4e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:19)', 'Deciduous Broadleaf')
                    ParaPlant.p50Leaf        = -270;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -270;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -270;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:13)', 'Mixed Forests') 
                    ParaPlant.p50Leaf        = -260;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -260;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -260;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:20)', 'Evergreen Needleleaf') 
                    ParaPlant.p50Leaf        = -465;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -465;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -465;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:9)', 'Croplands')
                    ParaPlant.p50Leaf        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -340;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:15)', 'Open Shrublands')
                    ParaPlant.p50Leaf        = -260;       % parameter of plant hydraulic pathway [m].
                    ParaPlant.p50Stem        = -260;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -260;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:17)', 'Closed Shrublands') 
                    ParaPlant.p50Leaf        = -260;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -260;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -260;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:8)', 'Savannas')  
                    ParaPlant.p50Leaf        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -340;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:14)', 'Woody Savannas')
                    ParaPlant.p50Leaf        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -340;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

            elseif strcmp(igbpVegLong(1:9)', 'Grassland')    
                    ParaPlant.p50Leaf        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -340;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -340;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]
            else
                warning("Don't find IGBP vegetation type! \n")
            end
        case 'ED2'
                if strcmp(igbpVegLong(1:19)', 'Evergreen Broadleaf')
                    ParaPlant.p50Leaf        = -67.67;  %-175;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -342; %-60; %-175;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -30;    %-175;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 1.98; %2.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 1.98; %0.8; %2.95;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 0.8; %2.95;      % parameter of plant hydraulic pathway [unitless]

                    ParaPlant.Krootmax          =2e-9;%1.28e-7;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =4e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =4e-8;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]
                else
                    
                    ParaPlant.p50Leaf        = -67.67;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -342.51;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -300;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 1.98;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 1.98;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 1.98;      % parameter of plant hydraulic pathway [unitless]
                    
                    ParaPlant.Krootmax          =1.28e-7;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =3.88e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =1.77e-10;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]
                end
        case 'PHS'
                if strcmp(igbpVegLong(1:19)', 'Evergreen Broadleaf') 
                    ParaPlant.p50Leaf        = -67.67;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Stem        = -342.51;       % parameter of plant hydraulic pathway [m]
                    ParaPlant.p50Root        = -300;       % parameter of plant hydraulic pathway [m]

                    ParaPlant.shapeFactorLeaf         = 1.98;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
                    ParaPlant.shapeFactorStem         = 1.98;      % parameter of plant hydraulic pathway [unitless]
                    ParaPlant.shapeFactorRoot         = 1.98;      % parameter of plant hydraulic pathway [unitless]
                    
                    ParaPlant.Krootmax          =1.28e-7;%2e-9;       % root conductivity [m s-1]
                    ParaPlant.Kstemmax          =3.88e-8;%2e-8;       % stem conductivity [m s-1]
                    ParaPlant.Kleafmax          =1.77e-10;%2e-7;       % maximum leaf conductance [s-1]
                    ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]
                end
        otherwise
                fprintf('phwsf method need to be defined.')
    end
    
    
    
% %     ParaPlant.psi50_sunleaf  = ;        % parameter of plant hydraulic pathway [MPa]
% %     ParaPlant.psi50_shdleaf  = ;        % parameter of plant hydraulic pathway [MPa]
% %     ParaPlant.ck_sunleaf     = ;        % parameter of plant hydraulic pathway [MPa]
% %     ParaPlant.ck_shdleaf     = ;        % parameter of plant hydraulic pathway [MPa]
% 
%     ParaPlant.p50Leaf        = -260;%50.97;%-1.75; %0.5;   % unit MPa   5.0968e-11;  % 0.5./1e6*pa2m;       % parameter of plant hydraulic pathway [m] 0.5MPa refer to Kennedy 2019.
%     ParaPlant.p50Stem        = -260;%-1.75; % unit MPa  -1.7839e-10; % -1.75./1e6*pa2m;     % parameter of plant hydraulic pathway [m] -1.75MPa refer to Kennedy 2019.
%     ParaPlant.p50Root        = -260;%-1.75; % unit MPa  -1.7839e-10; % -1.75./1e6*pa2m;     % parameter of plant hydraulic pathway [m] -1.75MPa refer to Kennedy 2019.
%     
%     ParaPlant.ckLeaf         = 3.95;      % parameter  of plant hydraulic pathway, 2.95 is the default vaule inCLM
%     ParaPlant.ckStem         = 3.95;      % parameter of plant hydraulic pathway [unitless]
%     ParaPlant.ckRoot         = 3.95;      % parameter of plant hydraulic pathway [unitless]
% 
%     ParaPlant.Krootmax          =2e-8;%2e-9;       % root conductivity [m s-1]
%     ParaPlant.Kstemmax          =2e-8;%2e-8;       % stem conductivity [m s-1]
%     ParaPlant.Kleafmax          =2e-8;%2e-7;       % maximum leaf conductance [s-1]
%     ParaPlant.rootLateralLength = 0.25;      % average coarse root length [m]

    
end

