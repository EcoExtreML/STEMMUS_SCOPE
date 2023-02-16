function BoundaryCondition = setBoundaryCondition(SoilVariables, SoilConstants, IGBP_veg_long)

    NBCP = [];
    BCTB = [];
    BCPB = [];
    BCT = [];
    BCP = [];

    IRPT1 = 0;
    IRPT2 = 0;

    Ta_msr = SoilConstants.Ta_msr;

    % NBCh: Moisture Surface B.C.:
    % 1 --> Specified matric head(BCh);
    % 2 --> Specified flux(BCh);
    % 3 --> Atmospheric forcing;
    NBCh = 3;

    BCh = -20/3600;
    if strcmp(IGBP_veg_long(1:9)', 'Croplands')  % ['Croplands']
        % NBChB: Moisture Bottom B.C.:
        % 1 --> Specified matric head (BChB);
        % 2 --> Specified flux(BChB);
        % 3 --> Zero matric head gradient (Gravitiy drainage);
        NBChB = 1;
    else
        NBChB = 3;
    end
    BChB = -9e-10;
    if SoilConstants.Thmrlefc==1
        % NBCT: Energy Surface B.C.:
        % 1 --> Specified temperature (BCT);
        % 2 --> Specified heat flux (BCT);
        % 3 --> Atmospheric forcing;
        NBCT = 1;

        BCT = Ta_msr(1);  % surface temperature

        % NBCTB: Energy Bottom B.C.:
        % 1 --> Specified temperature (BCTB);
        % 2 --> Specified heat flux (BCTB);
        % 3 --> Zero temperature gradient;
        NBCTB = 1;

        if nanmean(Ta_msr)<0
            BCTB = 0;  %9 8.1
        else
            BCTB = nanmean(Ta_msr);
        end
    end
    if SoilConstants.Soilairefc==1
        % NBCP: Soil air pressure B.C.:
        % 1 --> Ponded infiltration caused a specified pressure value;
        % 2 --> The soil air pressure is allowed to escape after beyond the threshold value;
        % 3 --> The atmospheric forcing;
        NBCP = 2;

        BCP = 0;

        % NBCPB: Soil air Bottom B.C.:
        % 1 --> Bounded bottom with specified air pressure;
        % 2 --> Soil air is allowed to escape from bottom;
        NBCPB = 2;

        BCPB = 0;
    end

    if NBCh~=1
        NBChh = 2; % Assume the NBChh=2 firstly;
    end

    FACc = 0; % Used in MeteoDataCHG for check is FAC changed?
    BtmPg = 95197.850; % Atmospheric pressure at the bottom (Pa), set fixed with the value of mean atmospheric pressure;
    DSTOR = 0; % Depth of depression storage at end of current time step;
    DSTOR0 = DSTOR; % Dept of depression storage at start of current time step;
    RS = 0; % Rate of surface runoff;
    DSTMAX = 0; % Depression storage capacity;

    % used in main script
    BoundaryCondition.NBCh = NBCh;
    BoundaryCondition.NBCT = NBCT;
    BoundaryCondition.NBChB = NBChB;
    BoundaryCondition.NBCTB = NBCTB;
    BoundaryCondition.BCh = BCh;
    BoundaryCondition.DSTOR = DSTOR;
    BoundaryCondition.DSTOR0 = DSTOR0;
    BoundaryCondition.RS = RS;
    BoundaryCondition.NBChh = NBChh;
    BoundaryCondition.DSTMAX = DSTMAX;
    BoundaryCondition.IRPT1 = IRPT1;
    BoundaryCondition.IRPT2 = IRPT2;

    % used by other scripts
    BoundaryCondition.NBCP = NBCP;
    BoundaryCondition.BChB = BChB;
    BoundaryCondition.BCTB = BCTB;
    BoundaryCondition.BCPB = BCPB;
    BoundaryCondition.BCT = BCT;
    BoundaryCondition.BCP = BCP;
    BoundaryCondition.BtmPg = BtmPg;

end