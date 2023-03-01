function initH = calcInitH(Theta_s, Theta_r, initX, nParameter, mParameter, alphaParameter)
    %{
        Calculate soil water potential (initH) using van Genuchten model.
        van Genuchten, M.T. (1980), A Closed-form Equation for Predicting the
        Hydraulic Conductivity of Unsaturated Soils. Soil Science Society of
        America Journal, 44: 892-898.
        https://doi.org/10.2136/sssaj1980.03615995004400050002x
    %}
    initH = -(((Theta_s - Theta_r) / (initX - Theta_r))^(1 / mParameter) - 1)^(1 / nParameter) / alphaParameter;
end
