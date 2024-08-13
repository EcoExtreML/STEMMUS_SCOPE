function [psiLeaf, psiStem, psiRoot, kSoil2Root, kRoot2Stem, kStem2Leaf, phwsfLeaf, TempVar] = calPlantWaterPotential(Trans,Ks, Ksoil, ParaPlant,...
                                                         RootProperties, soilDepthB2T, lai, sfactor, psiSoil, canopyHeight, bbx, TestPHS, iTimeStep)
% Calculation of plant hydraulic conductance among plant components

% Input:
%     Trans: Transpiration [m/s]
%     Ks : saturated soil hydraulic conductivity [m s-1]
%     Ksoil: unsaturated soil hydraulic conductivity [m s-1]
%     ParaPlant: A structure contains plant parameters
%     RootProperties: A structure contains root properties
%     soilDepthB2T: An array contains soil depth of each soil layer to soil
%           surface. (direction: from bottom to top)
%            
%     lai: An array contains LAI
%     sfactor: soil water stress factor, WSF

% Output:
%     psiLeaf: leaf water potential [m]
%     psiStem: stem water potential [m]
%     psiRoot: root water potential [m]
%     kSoil2Root: hydraulic conductance from soil to root
%     kRoot2Stem: hydraulic conductance from root to stem
%     kStem2Leaf: hydraulic conductance from stem to leaf
%     phwsfLeaf : leaf water stress factor

    %% +++++++++++++++++++++++++ PHS ++++++++++++++++++++++++++++++++
    % ----------------------------------------------------------------
    % qSoil2Root = kSoil2Root * (psiSoil - psiRoot - soilDepth)
    %                                              
    %            kSoil2Root * (psiSoil - soilDepth) -  qSoil2Root
    %  psiRoot = --------------------------------------------------                                 
    %                          kSoil2Root

    % qRoot2Stem = kRoot2Stem * SAI * (psiRoot - psiStem - canopyHeight)
    %                                         qRoot2Stem          
    % psiStem = psiRoot - canopyHeight -  -----------------
    %                                       kRoot2Stem * SAI
    %        

    % qStem2Leaf = kStem2Leaf * LAI * (psiLeaf - psiStem)
    %                           qStem2Leaf        
    % psiLeaf = psiStem  -  ---------------------
    %                           kStem2Leaf *LAI
    %        
    % ---------------------------------------------------------------- 
    
    %% =============== Input variables ================
    Krootmax = ParaPlant.Krootmax;
    Kstemmax = ParaPlant.Kstemmax;
    Kleafmax = ParaPlant.Kleafmax;
    p50Root  = ParaPlant.p50Root;
    p50Stem  = ParaPlant.p50Stem;
    p50Leaf  = ParaPlant.p50Leaf;
    shapeFactorRoot = ParaPlant.shapeFactorRoot;
    shapeFactorStem = ParaPlant.shapeFactorStem;
    shapeFactorLeaf = ParaPlant.shapeFactorLeaf;
    rootLateralLength = ParaPlant.rootLateralLength;
    s2l    = ParaPlant.s2l;
    phwsfMethod = ParaPlant.phwsfMethod;
    
    rootSpac = RootProperties.spac;    
    rootFrac = RootProperties.frac;
    lengthDensity = RootProperties.lengthDensity;
    
    endOfSeason = TestPHS.endOfSeason;
    % inverse soilDepth 
%     soilDepthflip = flipud(soilDepth);
    
    % Q_soil2root = Q_root2stem = Q_stem2leaf = Transpiration
    qSoil2Root = Trans;  % unit [m/s]
    qRoot2Stem = Trans;
    qStem2Leaf = Trans;    
    
    numSoilLayer = length(Ksoil);
%     %% =================== reverse soil variables ==============
%     KsoilR = flipud(Ksoil);
%     KsR = flipud(Ks);
    %% =================== root area index =====================
    % new fine-root carbon to new foliage carbon ratio
    if iTimeStep <= endOfSeason  % during growth season
        froot2leaf=0.3*3*exp(-0.15*lai)/(exp(-0.15*lai)+2*sfactor);
        if froot2leaf<0.15
            froot2leaf=0.15;
        end
        if froot2leaf>0.3
            froot2leaf = 0.3;
        end
    else  % when leaves start desiccation, set carbon allocation for roots growth as a constant 
        froot2leaf = TestPHS.froot2leaf;
    end
    froot2leaf=max(0.001, froot2leaf);
    
    % stem area index
    sai = s2l .*lai;  
    
    % root area index
    % rai = (sai + lai) * f_{root-shoot} * r_i (Kennedy et al. 2019 JAMES)
    rai = (sai + lai).* rootFrac .* froot2leaf;

    %% =================== soil to root conductance =====================
    soilConductance = min(Ks' , Ksoil) ./100 ./ rootSpac ; % 100 is a transfer factor from [cm/s] to [m/s]
    
    phwsfRoot = PlantHydraulicsStressFactor(psiSoil, p50Root, shapeFactorRoot, phwsfMethod);
    phwsfRoot = max(phwsfRoot, 1e-2);
    
    rootConductance = phwsfRoot .* rai .* Krootmax./(rootLateralLength + soilDepthB2T./100); % unit [m/s]

    soilConductance = max(soilConductance, 1e-16);
    rootConductance = max(rootConductance, 1e-16);
    kSoil2Root = 1./(1./soilConductance + 1./rootConductance); % unit [m/s]
    
    %% =================== root water potential ========================
    % Q_soil2root = Q_root2stem = Q_stem2leaf = Transpiration
    if (abs(sum(kSoil2Root,1)) == 0)
        % for saturated condition
        psiRoot = sum((psiSoil - soilDepthB2T./100)) / numSoilLayer;
    else
        % for unsaturated condition
%         psiRoot = (sum(kSoil2Root.*(psiSoil - soilDepthB2T./100).*bbx) - qSoil2Root) / sum(kSoil2Root.*bbx);
        
        % %-consider the root fraction on calculation of root water potential
        % -------------------rootFrac------------------------------
%         rootFracFactor = (rootFrac.*bbx)./sum(rootFrac.*bbx);
%         psiRoot_temp = ((kSoil2Root.*(psiSoil - soilDepthB2T./100)) - qSoil2Root.*rootFracFactor) ./ (kSoil2Root);
%         psiRoot = nansum(psiRoot_temp.*rootFracFactor ,1);
        % ---------------------------------------------------------
        
        % consider the root fraction via root length density
        % ------------------ rootLengthDensityFrac -----------------
        rootLengthDensityFrac = (lengthDensity.*bbx)./sum(lengthDensity.*bbx);
        psiRoot_temp = ((kSoil2Root.*(psiSoil - soilDepthB2T./100)) - qSoil2Root.*rootLengthDensityFrac) ./ (kSoil2Root);
        psiRoot = nansum(psiRoot_temp.*rootLengthDensityFrac ,1);

        if ~isreal(psiRoot)
%         psiRoot = sum(psiSoil.*bbx)/sum(bbx);   % root zone averaged soil water potential
            psiRoot = sum(psiSoil.*rootLengthDensityFrac)
        end
        psiRoot = max(psiRoot, -1000); % -10MPa to m = -1019.368 
        psiRoot = min(0, psiRoot);
    end

    %% =================== stem water potential ========================
    phwsfStem = PlantHydraulicsStressFactor(psiRoot, p50Stem, shapeFactorStem, phwsfMethod);
    phwsfStem = max(phwsfStem, 0.1);
    if ( sai>0 && phwsfStem >0 ) 
        % stem hydraulic conductance
        kRoot2Stem = ParaPlant.Kstemmax ./ canopyHeight .* phwsfStem; 
        psiStem = psiRoot - canopyHeight - qRoot2Stem ./sai ./ kRoot2Stem;
    else
        psiStem = psiRoot - canopyHeight; 
    end
    
    %% ===================== leaf water potential ====================
    phwsfStem2Leaf = PlantHydraulicsStressFactor(psiStem, p50Leaf, shapeFactorLeaf, phwsfMethod);
    if (lai>0 && phwsfStem2Leaf>0)
        % leaf hydraulic conductance
        kStem2Leaf = ParaPlant.Kleafmax .* phwsfStem2Leaf;

        % leaf water potential
        psiLeaf = psiStem - qStem2Leaf ./ lai ./kStem2Leaf;
    else
        psiLeaf = psiStem;
    end
     phwsfLeaf = PlantHydraulicsStressFactor(psiLeaf, -150, shapeFactorLeaf, phwsfMethod);

    %% ==================== set complex value ======================
    if ~isreal(psiRoot)
%         psiRoot = sum(psiSoil.*bbx)/sum(bbx);   % root zone averaged soil water potential
        psiRoot = sum(psiSoil.*rootFracFactor)
    end
    if ~isreal(psiStem)
        psiStem = psiRoot;
    end

    
    %% ================== set default conductance ==================
    if ~exist('kSoil2Root','var')
        kSoil2Root = NaN;
    end
    
    if ~exist('kRoot2Stem','var')
        kRoot2Stem = NaN;
    end
    
    if~exist('kStem2Leaf', 'var')
        kStem2Leaf = NaN;
    end
    
    %% ======================= Temp ==================================
    TempVar.froot2leaf = froot2leaf;
    TempVar.sai = sai;
    TempVar.rai = rai;
    TempVar.phwsfRoot = phwsfRoot;
    TempVar.phwsfStem2Leaf = phwsfStem2Leaf;
    TempVar.soilConductance = soilConductance;
    TempVar.rootConductance = rootConductance;
    
end