function [gsMethod, phwsfMethod] = setScenario(gsOption, phsOption)
%{
    This function is used to set the stomatal conductance scheme and plant
    hydraulic pathway option.

    input:
        gsOption: a string indicate which stomatal conductance will be used
        phsOption: a number indicate whether use plant hydraulic pathway

    output:
        biochemical: a string, indicate which function will be used
        gsMethod: a number indicate the stomatal conductance scheme:
                  1 for BallBerry
                  2 for Medlyn
        phsOption: a number indicate if open the plant hydraulic pathway.
                   1 for CLM5,
                   2 for ED2,
                   3 for PHS
                   
%}

    %% Set scenario
    %biochemical = @biochemical;
    if strcmp(gsOption, 'BallBerry')
        gsMethod = 1;
    elseif strcmp(gsOption, 'Medlyn')
        gsMethod = 2;
    end
    %% PHS setting
    if phsOption      % if phsOption is true, PHS open. Set plant water stress method.
        switch phsOption
            case 1
                phwsfMethod = 'CLM5';
            case 2
                phwsfMethod = 'ED2';
            case 3
                phwsfMethod = 'PHS';
            otherwise
                fprintf('Please set phsOption\n');
        end
    else  % if phsOption is false, PHS close.
        phwsfMethod = 'WSF';
        fprintf('PHS close, use soil water stress factor\n')
    end

end