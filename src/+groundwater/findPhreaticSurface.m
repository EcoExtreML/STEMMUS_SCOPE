function [depToGWT, indxGWLay] = findPhreaticSurface(soilWaterPotential, KT, soilThick, indxBotmLayer_R)
    %{
        added by Mostafa, modified after Lianyu
        This function finds the soil layer that includes the phreatic surface (saturated zone) and is used in the groundwater recharge calculations

                                %%%%%%%%%% Important notes %%%%%%%%%%
        The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
        which is the opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indices need to be flipped

        Although the groundwater depth (variable -> "gw_Dep") is calculated already from the MODFLOW inputs, it is re-calculated again in this function for two reasons:
        1) In this function, the groundwater depth is re-calculated, but this time is from the STEMMUS matric potential, so to ensure that ...
            STEMMUS understood the location of the groundwater depth correctly. The re-calculated groundwater depth is stored in the "depToGWT" variable.
        2) The depToGWT needs to be assigned to a certain soil layer. Because of that assignment, there will be a slight difference between gw_Dep  ...
            and depToGWT (e.g. difference = 1-10 cm  based on the thickness of the soil layer that contains the depToGWT).

                                %%%%%%%%%% Variables definitions %%%%%%%%%%
        depToGWT            water table depth: depth from top soil layer to groundwater level, calculated from STEMMUS variables
        indxBotmLayer_R     index of the bottom layer that contains the current headBotmLayer (top to bottom)
        indxGWLay           index of the soil layer that includes the phreatic surface, so the recharge is ....
                            extracted from that layer (index order is from top layer to bottom)
                            Note: indxGWLay must equal to indxBotmLayer_R
        Shh                 soil matric potential (from top layer to bottom; opposite of hh)
        soilThick           cumulative soil layers thickness (from top to bottom)
    %}

    % Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % number of nodes

    % Call the matric potential
    Shh(1:1:NN) = soilWaterPotential(NN:-1:1);
    depToGWT = 0; % starting value for initialization, updated below
    indxGWLay = NN - 2; % starting value for initialization, updated below

    % Find the phreatic surface (saturated zone)
    for i = NN:-1:2
        hh_lay = Shh(i);
        soilThick_lay = soilThick(i);
        hh_nextlay = Shh(i - 1);
        soilThick_nextlay = soilThick(i - 1);
        % apply a condition to find the groundwater table from the matric potential by differentiating ....
        %  between a) first layer with positive or zero head value and b) last layer with negative head value
        if hh_lay > -1e-5 && hh_nextlay <= -1e-5
            depToGWT = (hh_lay * soilThick_nextlay - hh_nextlay * soilThick_lay) / (hh_lay - hh_nextlay);
            midThick = (soilThick(i) + soilThick(i - 1)) / 2;
            if depToGWT >= midThick
                indxGWLay = i;
            elseif depToGWT < midThick
                indxGWLay = i - 1;
            end
            break
        end
    end

    if KT > 1 % start the checks from the first time step (after initialization)
        % check 1
        if depToGWT <= 0
            warning('The phreatic surface level is equal or higher than the land surface level!');
            % check 2
        elseif depToGWT > ModelSettings.Tot_Depth % total soil depth
            warning('The phreatic surface level is lower than the end of the soil column!');
        end
        % check 3
        diff = abs(indxGWLay - indxBotmLayer_R);
        if diff > 1
            warning('Index of the bottom layer boundary that includes groundwater head ~= index of the layer that has zero matric potential!');
        end
    end
end
