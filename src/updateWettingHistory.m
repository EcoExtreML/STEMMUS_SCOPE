function [J, XWRE, XOLD] = updateWettingHistory(NL, J, Theta_L, XOLD, Theta_LL, XWRE, IH, Theta_s, XK)
    %{
    This subroutine is caled after one time step to update the wetting
    history. If the change in average moisture content of the element during the
    last time step was in the opposite direction of that during the previous
    time step, the history is updated. As an approximation, only primary
    scanning curves are used, subject to the constraint that matric head and
    moisture content be continuous in time.
    %}

    for i = 1:NL
        % Soil type index;
        J = i;

        % The average moisture content of an element;
        EX = 0.5 * (Theta_L(i, 1) + Theta_L(i, 2));
        % Has average trend of wetting in the element changed? If the trend is
        % still in drying, keep running like this. Otherwise, change trend from
        % drying to wetting. Then, IH value needs to be changed as 2, and XWRE
        % needs to be re-evaluated. However, if the trend is still in wetting,
        % keep running like that. Otherwise, change trend from wetting to drying.
        if IH(i) == 1 && XOLD(i) <= (EX + 1e-12)  % IH=1 means wetting.
            XOLD(i) = EX;
            return
        elseif IH(i) == 2  % IH=2 means drying.
            if XOLD(i) >= (EX - 1e-12)
                XOLD(i) = EX;
                return
            else
                IH(i) = 1;
                for j = 1:2
                    if (Theta_s(J) - Theta_LL(i, j)) < 1e-3
                        XWRE(i, j) = Theta_s(J);
                    else
                        XWRE(i, j) = Theta_s(J) * (Theta_L(i, j) - Theta_LL(i, j)) / (Theta_s(J) - Theta_LL(i, j));
                    end
                end
                XOLD(i) = EX;
                return
            end
        else
            IH(i) = 2;
            for j = 1:2
                if (Theta_LL(J) - XK(J)) < 1e-3
                    XWRE(i, j) = XK(J);
                else
                    XWRE(i, j) = Theta_LL(i, j) + Theta_s(J) * (Theta_L(i, j) / Theta_LL(i, j) - 1);
                end
            end
            XOLD(i) = EX;
            return
        end
    end
end