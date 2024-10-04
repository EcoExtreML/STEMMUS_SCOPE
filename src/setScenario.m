function [gsMethod, phwsfMethod] = setScenario(gsOption, phsOption)
%{
    This function is used to set the stomatal conductance scheme and plant
    hydraulic pathway option.

    input:
        gsOption: a number indicate the stomatal conductance approach: 
                  1 for BallBerry, ref[1]
                  2 for Medlyn, ref[2]
        phsOption: a number indicate whether use plant hydraulic pathway

    output:
        gsMethod: a number indicate the stomatal conductance scheme:
                  1 for BallBerry
                  2 for Medlyn
        phsOption: a number indicate if open the plant hydraulic pathway.
                   1 for CLM5,
                   2 for ED2,
                   3 for PHS
                   
    references:
        [1] Ball, J. T., et al. (1987). A Model Predicting Stomatal Conductance 
            and its Contribution to the Control of Photosynthesis under 
            Different Environmental Conditions, Springer, Dordrecht.

        [2] Medlyn, B. E., et al. (2011). "Reconciling the optimal and empirical 
            approaches to modelling stomatal conductance." 
            Global Change Biology 17(6): 2134-2144.

%}

    %% Set scenario
    switch gsOption
        case 1
            gsMethod = 1; % BallBerry stomatal conductance
        case 2
            gsMethod = 2; % Medlyn stomatal conductance
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