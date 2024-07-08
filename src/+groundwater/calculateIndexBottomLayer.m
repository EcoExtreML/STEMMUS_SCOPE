function [headBotmLayer, headBotmLayer_R] = calculateIndexBottomLayer(soilThick, gw_Dep)
    %{
        Calculate the index of the bottom layer level using MODFLOW data

        indxBotmLayer_R     index of the bottom layer that contains the current headBotmLayer (top to bottom)
        indxBotmLayer       index of the bottom layer that contains the current headBotmLayer (bottom to top)

    %}

    indxBotmLayer_R = [];

    % Load model settings
    ModelSettings = io.getModelSettings();

    for i = 1:NL = ModelSettings.NL
        midThick = (soilThick(i) + soilThick(i + 1)) / 2;
        if gw_Dep >= soilThick(i) && gw_Dep < soilThick(i + 1)
            if gw_Dep < midThick
                indxBotmLayer_R = i;
            elseif gw_Dep >= midThick
                indxBotmLayer_R = i + 1;
            end
            break
        elseif gw_Dep >= soilThick(i + 1)
            continue
        end
    end

    % Note: indxBotmLayer_R starts from top to bottom, opposite of STEMMUS (bottom to top)
    indxBotmLayer = ModelSettings.NN - indxBotmLayer_R + 1; % index of bottom layer (from bottom to top)
end