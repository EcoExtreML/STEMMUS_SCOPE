function ModelSettings = getModelSettings()
    %{
    %}

    ModelSettings.R_depth = 350;

    % Indicator denotes the index of soil type for choosing soil physical parameters
    ModelSettings.J = 1;

    % indicator for choose the soil water characteristic curve, =0, Clapp and
    % Hornberger; =1, Van Gen
    ModelSettings.SWCC = 1;

    % If the value of Hystrs is 1, then the hysteresis is considered, otherwise 0;
    ModelSettings.Hystrs = 0;

    % Consider the isothermal water flow if the value is 0, otherwise 1;
    ModelSettings.Thmrlefc = 1;

    % The dry air transport is considered with the value of 1,otherwise 0;
    ModelSettings.Soilairefc = 0;

    % Value of 1, the special calculation of water capacity is used, otherwise 0;
    ModelSettings.hThmrl = 1;

    % Value of 0 means that the heat of wetting would be calculated by Milly's
    % method/Otherwise,1. The method of Lyle Prunty would be used;
    ModelSettings.W_Chg = 1;

    % The indicator for choosing Milly's effective thermal capacity and conductivity
    % formulation to verify the vapor and heat transport in extremly dry soil.
    ModelSettings.ThmrlCondCap = 1;

    % The indicator for choosing effective thermal conductivity methods, 1= de vries
    % method;2= Jonhansen methods;3= Simplified de vries method(Tian 2016);4=
    % Farouki methods
    ModelSettings.ThermCond = 1;

    % Surface area for loam,for sand 10^2 (cm^-1)
    ModelSettings.SSUR = 10^5;

    % The fraction of clay,for loam,0.036; for sand,0.02
    ModelSettings.fc = 0.022;

    % Reference temperature
    ModelSettings.Tr = 20;
    ModelSettings.T0 = 273.15;

    % Other settings
    ModelSettings.rwuef = 1;
    ModelSettings.rroot = 1.5 * 1e-3;
    ModelSettings.SFCC = 1;

    ModelSettings.Tot_Depth = 500; % Unit is cm. it should be usually bigger than 0.5m. Otherwise,
    ModelSettings.Eqlspace = 0; % Indicator for deciding is the space step equal or not; % the DeltZ would be reset in 50cm by hand;

    ModelSettings.NS = 1; % Number of soil types;

    % The time and domain information setting
    ModelSettings.NIT = 30; % Desirable number of iterations in a time step;
    ModelSettings.KT = 0; % Number of time steps;

    % Determination of NL, the number of elments
    ModelSettings.NL = 100;
    if ~ModelSettings.Eqlspace
        [DeltZ, DeltZ_R, NL, ML] = Dtrmn_Z(ModelSettings.NL, ModelSettings.Tot_Depth);
    else
        for i = 1:ModelSettings.NL
            DeltZ(i) = ModelSettings.Tot_Depth / ModelSettings.NL;
        end
    end
    ModelSettings.NL = NL;
    ModelSettings.ML = ML;
    ModelSettings.DeltZ = DeltZ;
    ModelSettings.DeltZ_R = DeltZ_R;

    ModelSettings.NN = ModelSettings.NL + 1; % Number of nodes;
    ModelSettings.mN = ModelSettings.NN + 1;
    ModelSettings.mL = ModelSettings.NL + 1; % Number of elements. Prevending the exceeds of size of arraies;
    ModelSettings.nD = 2;
end
