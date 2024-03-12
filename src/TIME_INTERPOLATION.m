function [headBotmLayer, indexBotmLayer] = TIME_INTERPOLATION(TimeMODFLOW, nSoilColumns, botmLayerLevel, gwheadTN, gwheadT0, TIME, Delt_MODFLOW, soilLayerThickness, NN, Q3DF, ADAPTF)
%%%%%%%% Variables defination %%%%%%%%
	% TimeMODFLOW -> start of the current time step of MODFLOW
	% nSoilColumns -> number of STEMMUS soil columns for MODFLOW
	% botmLayerLevel -> bottom layer level 
	% gwheadTN -> groundwater head at end of time step
	% gwheadT0 -> groundwater head at start of time step
	% TIME -> end of the current time step of STEMMUS
	% Delt_MODFLOW -> time interval of the current time step
	% soilLayerThickness -> Layer thickness of STEMMUS soil layer
	% NN -> Total number of soil layers in STEMMUS
	% Q3DF -> indicator for the quasi-3d simulation; 1 means yes, 0 means no
	% ADAPTF -> indicator for adaptive lower boundary setting; 1 means moving lower boundary, 0 means fixed lower boundary
	% headBotmLayer -> head at bottom layer
	% indexBotmLayer -> index of bottom layer that contains groundwater table

% find the bottom layer of soil column where groundwater table exist (start of groundwater zone)
indexBotmLayer = [];
if(Q3DF)
    headBotmLayer = gwheadT0 + (gwheadTN - gwheadT0) * (TIME - TimeMODFLOW) / Delt_MODFLOW;
    if headBotmLayer > max(gwheadTN, gwheadT0)
        headBotmLayer = max(gwheadTN, gwheadT0);
    elseif headBotmLayer < min(gwheadTN, gwheadT0)
        headBotmLayer = min(gwheadTN, gwheadT0);
    end
    if(ADAPTF)
        gwTable = botmLayerLevel(1, nSoilColumns) - headBotmLayer;
        for I = 1: NN - 1
            XMID = (soilLayerThickness(I) + soilLayerThickness(I+1)) / 2;
            if(gwTable >= soilLayerThickness(I) && gwTable < soilLayerThickness(I+1))
                if(gwTable < XMID)
                    indexBotmLayer = I; %(nSoilColumns)
                elseif(gwTable >= XMID)
                    indexBotmLayer = I+1;
                end
                break;
            elseif(gwTable >= soilLayerThickness(I+1))
                continue
            end
            disp('NO GROUNDWATER TABLE FOUND FOR MOVING LOWER BOUNDARY')
        end
        if isempty(indexBotmLayer)              
            indexBotmLayer = NN;
        else
            indexBotmLayer = indexBotmLayer + 3;
        end
        indexBotmLayer = min(indexBotmLayer, NN);
    else
        indexBotmLayer = NN;
    end
else
    indexBotmLayer = NN;
    return
end
end
