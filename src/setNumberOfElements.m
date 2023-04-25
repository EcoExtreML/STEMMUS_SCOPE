function [NL, ML, DeltZ] = setNumberOfElements(Tot_Depth, Eqlspace)
%{
    Determination of NL, the number of elments
%}
    NL = 100;
    if ~Eqlspace
        run Dtrmn_Z;
    else
        for ML = 1:NL
            DeltZ(ML) = Tot_Depth / NL;
        end
    end

end