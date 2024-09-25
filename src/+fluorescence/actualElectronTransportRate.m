function [jA] = actualElectronTransportRate()
%{
This function is used to calculated actual electron transport rate based on
MLROC model.

Input:

Output:
    jA: [] actual electron transport rate
Reference:
    [1] Gu,Lianhong et al., 2022, PCE
%}
    
    numerator = 2 .* u .* fT .* fS .* fQ .* (qR -q) .* q;
    denominator = (R1 + 2 .* R2 .* fS .* fQ -1) .* q + qR;
    jA = numerator ./ denominator; % eq.25 in ref[1].
end




