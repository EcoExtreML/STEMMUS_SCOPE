function [TT, CHK, RHS, C5] = solveTridiagonalMatrixEquations(C5, C5_a, TT, NN, NL, RHS)
    %{
        Use Thomas algorithm to solve the tridiagonal matrix equations, which
        is in the form of Equation 4.25, STEMMUS Technical Notes, page 41.
    %}

    RHS(1) = RHS(1) / C5(1, 1);

    for ML = 2:NN
        C5(ML, 1) = C5(ML, 1) - C5_a(ML - 1) * C5(ML - 1, 2) / C5(ML - 1, 1);
        RHS(ML) = (RHS(ML) - C5_a(ML - 1) * RHS(ML - 1)) / C5(ML, 1);
    end

    for ML = NL:-1:1
        RHS(ML) = RHS(ML) - C5(ML, 2) * RHS(ML + 1) / C5(ML, 1);
    end

    for MN = 1:NN
        CHK(MN) = abs(RHS(MN) - TT(MN));
        SAVETT(MN) = TT(MN); % abs((RHS(MN)-TT(MN))/TT(MN)); %
        TT(MN) = RHS(MN);
    end
end
