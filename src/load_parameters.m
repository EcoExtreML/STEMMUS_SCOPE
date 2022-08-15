function [ScopeParameters,Options] = load_parameters(ScopeParameters,Options,use_xlsx,ExcelData,ForcingData,N,Lat,Lon,hc,z,Ta,Sitename,Vege_type)
    Options.Cca_function_of_Cab = 0;
    for i = 1:length(ScopeParameters)
    j = find(strcmp(strtok(ExcelData(:,1)),ScopeParameters(i).Name));
    if ~use_xlsx, cond = isnan(N(j+1)); else cond = sum(~isnan(N(j,:)))<1; end
    if isempty(j) || cond
    if i==2
        warning('warning: input "', ScopeParameters(i).Name, '" not provided in input spreadsheet...', ...
                'I will use 0.25*Cab instead');
        Options.Cca_function_of_Cab = 1;
    elseif ~(Options.simulation==1) && (i==30 || i==32)
                warning('warning: input "', ScopeParameters(i).Name, '" not provided in input spreadsheet...', ...
                    'I will use the MODTRAN spectrum as it is');
    elseif (Options.simulation == 1 || (Options.simulation~=1 && (i<46 || i>50)))
                    warning('warning: input "', ScopeParameters(i).Name, '" not provided in input spreadsheet');
                    if (Options.simulation ==1 && (i==1 ||i==9||i==22||i==23||i==54 || (i>29 && i<37)))
                        fprintf(1,'%s %s %s\n', 'I will look for the values in Dataset Directory "',char(ForcingData(5).FileName),'"');
                    elseif (i== 24 || i==25)
                            fprintf(1,'%s %s %s\n', 'will estimate it from LAI, CR, CD1, Psicor, and CSSOIL');
                            Options.calc_zo = 1;
                    elseif (i>38 && i<44)
                                fprintf(1,'%s %s %s\n', 'will use the provided zo and d');
                                oOptions.calc_zo = 0;
                    elseif ~(Options.simulation ==1 && (i==30 ||i==32))
                                    fprintf(1,'%s \n', 'this input is required: SCOPE ends');
                                    return
                    else
                                    fprintf(1,'%s %s %s\n', '... no problem, I will find it in Dataset Directory "',char(ForcingData(5).FileName), '"');
                    end
    end                
    end
if ~use_xlsx
        j2 = []; j1 = j+1;
        while 1
            if isnan(N(j1)), break, end
            j2 = [j2; j1]; %#ok<AGROW>
            j1 = j1+1;
        end
        if isempty(j2)
            ScopeParameters(i).Val            = -999;
        else
            ScopeParameters(i).Val            = N(j2);
        end
        
        
    else
        if sum(~isnan(N(j,:)))<1
            ScopeParameters(i).Val            = -999;
        else
            ScopeParameters(i).Val            = N(j,~isnan(N(j,:)));
        end
end
    end
% Define the location information
ScopeParameters(48).Val=Lat; %latitude
ScopeParameters(49).Val=Lon; %longitude
ScopeParameters(62).Val=Lat; %latitude of BSM model
ScopeParameters(63).Val=Lon; %longitude of BSM model
ScopeParameters(29).Val=z;   %reference height
ScopeParameters(23).Val=hc;  %canopy height
ScopeParameters(55).Val=mean(Ta); %calculate mean air temperature
%Input T parameters for different vegetation type
    sitename1=cellstr(Sitename);
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
    if isequal(sitename1,{'ES-ES2'})||isequal(sitename1,{'FR-Gri'})||isequal(sitename1,{'US-ARM'})||isequal(sitename1,{'US-Ne1'})
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
    if isequal(sitename1,{'AR-SLu'})||isequal(sitename1,{'AU-Ync'})||isequal(sitename1,{'CH-Oe1'})||isequal(sitename1,{'DK-Lva'})||isequal(sitename1,{'US-AR1'})||isequal(sitename1,{'US-AR2'})||isequal(sitename1,{'US-Aud'})||isequal(sitename1,{'US-SRG'})
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
% calculate the time zone based on longitude
TZ=fix(Lon/15);
TZZ=mod(Lon,15);
if Lon>0
    if abs(TZZ)>7.5
        ScopeParameters(50).Val= TZ+1;
    else
        ScopeParameters(50).Val= TZ;
    end
else
    if abs(TZZ)>7.5
        ScopeParameters(50).Val= TZ-1;
    else
        ScopeParameters(50).Val= TZ;
    end
end
end
