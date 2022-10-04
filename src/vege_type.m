%Input T parameters for different vegetation type
function [ScopeParameters] = vege_type(ScopeParameters,Sitename,Vege_type)
    Sitename=cellstr(Sitename);
if strcmp(Vege_type(1:18)', 'Permanent Wetlands') 
    ScopeParameters(14).Val = [0.2 0.3 288 313 328]; % These are five parameters specifying the temperature response.
    ScopeParameters(9).Val = [120]; % Vcmax, maximum carboxylation capacity (at optimum temperature)
    ScopeParameters(10).Val = [9]; % Ball-Berry stomatal conductance parameter
    ScopeParameters(11).Val = [0]; % Photochemical pathway: 0=C3, 1=C4
    ScopeParameters(28).Val = [0.05]; % leaf width
elseif strcmp(Vege_type(1:19)', 'Evergreen Broadleaf')  
    ScopeParameters(14).Val = [0.2 0.3 283 311 328];
    ScopeParameters(9).Val = [80];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];
    ScopeParameters(28).Val = [0.05];
elseif strcmp(Vege_type(1:19)', 'Deciduous Broadleaf') 
    ScopeParameters(14).Val = [0.2 0.3 283 311 328];
    ScopeParameters(9).Val = [80];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];  
    ScopeParameters(28).Val = [0.05];
elseif strcmp(Vege_type(1:13)', 'Mixed Forests') 
    ScopeParameters(14).Val = [0.2 0.3 281 307 328];
    ScopeParameters(9).Val = [80];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0]; 
    ScopeParameters(28).Val = [0.04];
elseif strcmp(Vege_type(1:20)', 'Evergreen Needleleaf') 
    ScopeParameters(14).Val = [0.2 0.3 278 303 328];
    ScopeParameters(9).Val = [80];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];   
    ScopeParameters(28).Val = [0.01];
elseif strcmp(Vege_type(1:9)', 'Croplands')    
    if isequal(Sitename,{'ES-ES2'})||isequal(Sitename,{'FR-Gri'})||isequal(Sitename,{'US-ARM'})||isequal(Sitename,{'US-Ne1'})
        ScopeParameters(14).Val = [0.2 0.3 278 303 328];
        ScopeParameters(9).Val = [50];
        ScopeParameters(10).Val = [4];
        ScopeParameters(11).Val = [1]; 
        ScopeParameters(13).Val = [0.025]; % Respiration = Rdparam*Vcmcax
        ScopeParameters(28).Val = [0.03];
    else 
        ScopeParameters(14).Val = [0.2 0.3 278 303 328];
        ScopeParameters(9).Val = [120];
        ScopeParameters(10).Val = [9];
        ScopeParameters(11).Val = [0]; 
        ScopeParameters(28).Val = [0.03];    
    end
elseif strcmp(Vege_type(1:15)', 'Open Shrublands')
    ScopeParameters(14).Val = [0.2 0.3 288 313 328];
    ScopeParameters(9).Val = [120];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];  
    ScopeParameters(28).Val = [0.05];
elseif strcmp(Vege_type(1:17)', 'Closed Shrublands') 
    ScopeParameters(14).Val = [0.2 0.3 288 313 328];
    ScopeParameters(9).Val = [80];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];
    ScopeParameters(28).Val = [0.05];
elseif strcmp(Vege_type(1:8)', 'Savannas')  
    ScopeParameters(14).Val = [0.2 0.3 278 313 328];
    ScopeParameters(9).Val = [120];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];
    ScopeParameters(28).Val = [0.05];
elseif strcmp(Vege_type(1:14)', 'Woody Savannas')
    ScopeParameters(14).Val = [0.2 0.3 278 313 328];
    ScopeParameters(9).Val = [120];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];
    ScopeParameters(28).Val = [0.03];
elseif strcmp(Vege_type(1:9)', 'Grassland')  
    ScopeParameters(14).Val = [0.2 0.3 288 303 328];
    if isequal(Sitename,{'AR-SLu'})||isequal(Sitename,{'AU-Ync'})||isequal(Sitename,{'CH-Oe1'})||isequal(Sitename,{'DK-Lva'})||isequal(Sitename,{'US-AR1'})||isequal(Sitename,{'US-AR2'})||isequal(Sitename,{'US-Aud'})||isequal(Sitename,{'US-SRG'})
        ScopeParameters(9).Val = [120];
        ScopeParameters(10).Val = [4];
        ScopeParameters(11).Val = [1];
        ScopeParameters(13).Val = [0.025]; 
    else
        ScopeParameters(9).Val = [120];
        ScopeParameters(10).Val = [9];
        ScopeParameters(11).Val = [0];
    end
    ScopeParameters(28).Val = [0.02];
else
    ScopeParameters(14).Val = [0.2 0.3 288 313 328];
    ScopeParameters(9).Val = [80];
    ScopeParameters(10).Val = [9];
    ScopeParameters(11).Val = [0];
    ScopeParameters(28).Val = [0.05];
    warning('IGBP vegetation name unknown, "%s" is not recognized. ', Vege_type)
end
end