function [crop_output,state_vars] = cropgrowth(crop_output,state_vars,meteo,WofostPar,Anet,WaterStressFactor,xyt,KT,Dur_tot)
    %{
        function cropgrowth.m simulate the growth of vegetation
        
        authors: Danyang Yu (yudanyang123@gmail.com)
        date: 2025/01/01
        reference: SWAP version 3.2. Theory description and user manual (Page 147-163)
        
        Table of contents of the function
            1. Initilize crop growth paramters
            2. Calculate the phenological development
            3. Calculate the growth rate of different plant organs
            4. Output the crop growth variables
        
        Input:
            Tsum        Temperature sum from emergence to the simulated day
            tdwi        Initial total crop dry weight
            laiem       Leaf area index at emergence
            f(r,l,s,o)  The fraction of dry matter to root, leaf, stem, storage
            tadw        Initial total crop dry weight
            lvage       leaf age
            lv          save leaf dry matter at different steps
            spa         Specific pod area
            ssa         Specific stem area
            sla         specific leaf area
            Anet_sum    the sum of net assimilation
            dmi         converted dry matter at step KT
            admi        above-ground dry matter
            grrt        growth rate of root, similar for the other organs
            drrt        death rate of root, similar for the other organs
            WofostPar   Wofost parameters, the definitions are in CropD.crp
        
        Output:
            dvs         Developement of stage
            lai         leaf area index
            ph          Plant height        
            wrt         dry matter weight of root
            wlv         dry matter weight of leaves
            wst         dry matter weight of stem
            wso         dry matter weight of storage organ
            dwrt        dry matter weight of dead root
            dwlv        dry matter weight of dead leaves
            dwst        dry matter weight of dead stem
    %}
    
    %% 1. initilization
    if KT == WofostPar.CSTART
        % initial value of crop parameters
        Tsum  =   0;
        dvs   =   0;
        tdwi  =   WofostPar.TDWI;
        laiem =   WofostPar.LAIEM;
        ph    =   0;
        
        frtb  =   WofostPar.FRTB;
        fltb  =   WofostPar.FLTB;
        fstb  =   WofostPar.FSTB;
        fotb  =   WofostPar.FOTB;
        
        fr    =   wofost.afgen(frtb, dvs);
        fl    =   wofost.afgen(fltb, dvs);
        fs    =   wofost.afgen(fstb, dvs);
        fo    =   wofost.afgen(fotb, dvs);
        
        ssa   =   WofostPar.SSA;
        spa   =   WofostPar.SPA;
        
        % initial state variables of the crop
        tadw  =   (1 - fr) * tdwi;
        wrt   =   fr * tdwi;
        wlv   =   fl * tadw;
        wst   =   fs * tadw;
        wso   =   fo * tadw;
        
        dwrt    = 0.0;
        dwlv    = 0.0;
        dwst    = 0.0;
            
        sla        = zeros(Dur_tot+1, 1);
        lvage      = zeros(Dur_tot+1, 1);
        lv         = zeros(Dur_tot+1, 1);
        sla(1)   = wofost.afgen(WofostPar.SLATB, dvs);
        lv(1)    = wlv;
        lvage(1) = 0.0;
        ilvold     = 1;
        
        lasum    = laiem;         
        laiexp   = laiem;     
        glaiex   = 0;
        laimax   = laiem;
        lai      = lasum + ssa * wst + spa * wso;
        Anet_sum  = 0;
        lai_delta = 0;
    
    else
        % Unpack state variables
        dvs = state_vars.dvs;
        wrt = state_vars.wrt;
        wlv = state_vars.wlv;
        wst = state_vars.wst;
        wso = state_vars.wso;
    
        dwrt = state_vars.dwrt;
        dwlv = state_vars.dwlv;
        dwst = state_vars.dwst;
    
        sla = state_vars.sla;
        lvage = state_vars.lvage;
        lv = state_vars.lv;
        lasum = state_vars.lasum;
        laiexp = state_vars.laiexp;
        lai = state_vars.lai;
    
        ph = state_vars.ph;
        Anet_sum = state_vars.Anet_sum;
        lai_delta = state_vars.lai_delta;
    end
    
    %% 1. phenological development
    delt   =  WofostPar.TSTEP / 24;
    tav    =  max(0, meteo.Ta);
    dtsum  =  wofost.afgen(WofostPar.DTSMTB, tav);
    
    if dvs <= 1   % vegetative stage
        dvs    =  dvs + dtsum * delt / WofostPar.TSUMEA;
    else
        dvs    =  dvs + dtsum * delt / WofostPar.TSUMAM;
    end
    
    %% 2. dry matter increase
    frtb  =   WofostPar.FRTB;
    fltb  =   WofostPar.FLTB;
    fstb  =   WofostPar.FSTB;
    fotb  =   WofostPar.FOTB;
    
    fr    =   wofost.afgen(frtb, dvs);
    fl    =   wofost.afgen(fltb, dvs);
    fs    =   wofost.afgen(fstb, dvs);
    fo    =   wofost.afgen(fotb, dvs);
    
    fcheck = fr + (fl + fs + fo) * (1.0 - fr) - 1.0; %check on partitions
    if abs(fcheck) > 0.0001
        print('The sum of partitioning factors for leaves, stems and storage organs is not equal to one at development stage');
        return;
    end
    
    cvf   =  1.0 / ((fl / WofostPar.CVL + fs / WofostPar.CVS + fo / WofostPar.CVO) * (1.0 -fr ) + fr / WofostPar.CVR);
    asrc  =  Anet * 30 / 1000000000 * 10000 * 3600 * WofostPar.TSTEP;  % [umol m-2 s-1] to [kg CH2O ha-1];
    dmi   =  cvf * asrc;
    
    %% 3. Growth rate by root
    % root extension
    % rr    =  min(WofostPar.RDM - WofostPar.RD,WofostPar.RRI);
    admi  =  (1.0 - fr) * dmi;
    grrt  =  fr * dmi;
    drrt  =  wrt * wofost.afgen(WofostPar.RDRRTB, dvs) * delt;
    gwrt  =  grrt - drrt;
    
    %% 4. Growth rate by stem
    % growth rate stems
    grst  =  fs * admi;
    % death rate stems
    drst  =  wofost.afgen(WofostPar.RDRSTB, dvs) * wst * delt;
    % net growth rate stems
    gwst  =  grst - drst;
    
    % growth of plant height
    str   =  wofost.afgen(WofostPar.STRTB, dvs);
    phnew = wst / (WofostPar.STN * WofostPar.STD * pi * str * str) * WofostPar.PHCoeff + WofostPar.PHEM;
    if phnew >= ph
        ph    = phnew;
    end
    
    %% 5. Growth rate by organs
    gwso  = fo * admi;
    
    %% 6. Growth rate by leave
    % weight of new leaves
    grlv = fl * admi;
    
    % death of leaves due to water stress or high lai
    if abs(lai) < 0.1
        dslv1 = 0;
    else
        sfactor = WaterStressFactor.soil;
        dslv1 = wlv * (1.0 - sfactor) * WofostPar.PERDL * delt;
    end
    
    laicr  = WofostPar.LAICR;
    dslv2  = wlv * max(0, 0.03*(lai - laicr) / laicr);
    dslv   = max(dslv1, dslv2);
    
    % death of leaves due to exceeding life span
    % first: leaf death due to water stress or high lai is imposed on array
    %        until no more leaves have to die or all leaves are gone
    rest  = dslv;
    i1    = KT;
    iday  = ceil(KT*delt);
    
    while (rest > lv(i1) && i1 >= 1)
        rest = rest - lv(i1);
        i1   = i1 - 1;
    end
    
    % then: check if some of the remaining leaves are older than span,
    %       sum their weights
    dalv  = 0.0;
    if (lvage(i1) > WofostPar.SPAN && rest > 0 && i1 >= 1)
        dalv  = lv(i1) - rest;
        rest  = 0;
        i1    = i1 - 1;
    end
    
    while (i1 >= 1 && lvage(i1) > WofostPar.SPAN)
        dalv  = dalv + lv(i1);
        i1    = i1 - 1;
    end
    
    % final death rate
    drlv = dslv + dalv;
    
    % calculation of specific leaf area in case of exponential growth:
    slat   =   wofost.afgen(WofostPar.SLATB, dvs);
    if laiexp < 6
        dteff  = max(0, tav - WofostPar.TBASE);               % effective temperature
        glaiex = laiexp * WofostPar.RGRLAI * dteff * delt;    % exponential growth
        laiexp = laiexp + glaiex;
        
        glasol = grlv * slat;                        % source-limited growth
        gla    = min(glaiex, glasol);
    %     gla    = max(0,gla);
        
        slat   = gla / grlv;
        if isnan(slat)
            slat = 0;
        end
    %     if grlv>=0
    %         slat = gla/grlv;                       % the actual sla value
    %     else
    %         slat = 0;
    %     end
    end
    
    % update the information of leave
    dslvt  = dslv;
    i1     = KT;
    while (dslvt>0 && i1>=1)     % water stress and high lai
        if dslvt  >=  lv(i1)
            dslvt  =  dslvt-lv(i1);
            lv(i1) =  0.0;
            i1     =  i1-1;
        else
            lv(i1) = lv(i1)-dslvt;
            dslvt = 0.0;
        end
    end
    
    while (lvage(i1) >= WofostPar.SPAN && i1 >= 1)  % leaves older than span die
        lv(i1) = 0;
        i1 = i1 - 1;
    end
    
    ilvold = KT;   % oldest class with leaves
    fysdel = max(0.0d0, (tav - WofostPar.TBASE) / (35.0 - WofostPar.TBASE));  % physiologic ageing of leaves per time step
    
    for i1 = ilvold: -1: 1         % shifting of contents, updating of physiological age
        lv(i1+1)  = lv(i1);
        sla(i1+1) = sla(i1);
        lvage(i1+1) = lvage(i1) + fysdel * delt;
    end
    ilvold = ilvold + 1;
    
    lv(1) = grlv;
    sla(1) = slat;
    lvage(1) = 0.0;
    
    % calculation of new leaf area and weight
    lasum  = 0.0;
    wlv    = 0.0;
    for i1 = 1:ilvold
        lasum = lasum + lv(i1) * sla(i1);
        wlv   = wlv + lv(i1);
    end
    lasum = max(0, lasum);
    wlv = max(0, wlv);
    
    %% 7. integrals of the crop
    % dry weight of living plant organs
    wrt  =  wrt + gwrt;
    wst  =  wst + gwst;
    wso  =  wso + gwso;
    
    % total above ground biomass
    tadw =  wlv + wst + wso;
    
    % dry weight of dead plant organs (roots,leaves & stems)
    dwrt = dwrt + drrt;
    dwlv = dwlv + drlv;
    dwst = dwst + drst;
    
    % dry weight of dead and living plant organs
    twrt = wrt + dwrt;
    twlv = wlv + dwlv;
    twst = wst + dwst;
    cwdm = twlv + twst + wso;
    
    % leaf area index
    lai  = WofostPar.LAIEM + lasum + WofostPar.SSA * wst + WofostPar.SPA * wso;
    
    Anet_sum = Anet_sum + Anet;                % assume LAI not changed with the respiration
    if Anet_sum < 0 && KT > 1                    % the consumed biomass are the assimilated one at daytime
        lai_delta = lai_delta + grlv * slat;
        lai = lai - lai_delta;
    elseif Anet_sum >= 0 && Anet >= 0
        Anet_sum  = 0;
        lai_delta = 0;
    end
    
    %% 8. integrals of the crop
    crop_output(KT, 1) = xyt.t(KT, 1);            % Day of the year
    crop_output(KT, 2) = dvs;                     % Development of stage
    crop_output(KT, 3) = lai;                     % LAI
    crop_output(KT, 4) = ph;                      % Plant height
    crop_output(KT, 5) = sfactor;                 % Water stress
    crop_output(KT, 6) = wrt;                     % Dry matter of root
    crop_output(KT, 7) = wlv;                     % Dry matter of leaves
    crop_output(KT, 8) = wst;                     % Dry matter of stem
    crop_output(KT, 9) = wso;                     % Dry matter of organ
    crop_output(KT, 10) = dwrt;                   % Dry matter of deadleaves
    crop_output(KT, 11) = dwlv;                   % Dry matter of dead stem
    crop_output(KT, 12) = dwst;                   % Dry matter of dead organ
    
    %% 9. Pack updated state variables
    state_vars.dvs = dvs;
    state_vars.wrt = wrt;
    state_vars.wlv = wlv;
    state_vars.wst = wst;
    state_vars.wso = wso;
    state_vars.dwrt = dwrt;
    state_vars.dwlv = dwlv;
    state_vars.dwst = dwst;
    state_vars.sla = sla;
    state_vars.lvage = lvage;
    state_vars.lv = lv;
    state_vars.lasum = lasum;
    state_vars.laiexp = laiexp;
    state_vars.lai = lai;
    state_vars.ph = ph;
    state_vars.Anet_sum = Anet_sum;
    state_vars.lai_delta = lai_delta;
end


