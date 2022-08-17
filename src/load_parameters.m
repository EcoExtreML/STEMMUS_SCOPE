function [ScopeParameters,Options] = load_parameters(ScopeParameters,Options,use_xlsx,ExcelData,ForcingData,N)
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
end
