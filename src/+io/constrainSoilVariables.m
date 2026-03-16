function [Theta] = constrainSoilVariables(Theta, VanGenuchten)
    % Added by Prajwal and Mostafa
    % Constrain soil moisture values within Van Genuchten bounds
    %
    % Args:
    %   Theta             2D array (e.g. SoilVariables.Theta_LL or SoilVariables.Theta_UU)
    %   VanGenuchten      Structure with Theta_r (residual) and Theta_s (saturated) bounds
    %
    % Returns:
    %   SoilVariables: Updated structure with constrained mositure (Theta)

    % Input validation
    if ~ismatrix(Theta) && ~ndims(Theta) == 2
        error('Theta must be a 2D matrix');
    end

    if ~isstruct(VanGenuchten) || ~isfield(VanGenuchten, 'Theta_r') || ~isfield(VanGenuchten, 'Theta_s')
        error('VanGenuchten must be a structure with Theta_r and Theta_s fields');
    end

    % Apply constraints using vectorized operations
    smConstrained = Theta;
    smLowerBound = zeros(size(Theta));
    smLowerBound(1:end - 1, 1) = VanGenuchten.Theta_r' + 0.00000001;
    smLowerBound(1:end - 1, 2) = VanGenuchten.Theta_r' + 0.00000001;
    smUpperBound = zeros(size(Theta));
    smUpperBound(1:end - 1, 1) = VanGenuchten.Theta_s' - 0.00000001;
    smUpperBound(1:end - 1, 2) = VanGenuchten.Theta_s' - 0.00000001;
    smConstrained = max(min(smConstrained, smUpperBound), smLowerBound);
    % Update soil mositure array with constrained boundaries
    Theta = smConstrained;
end
