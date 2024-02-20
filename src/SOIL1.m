function SOIL1
% This subroutine is caled after one time step to update the wetting history.If the change in average moisture content
% of the element during the last time step was in the opposite direction of that during the previous time step, the history
% is updated. As an approximation, only primary scanning curves are used, subject to the constraint that matric
% head and moisture content be continuous in time.
global EX ML NL ND Theta_L XOLD IS J Theta_LL XWRE IH Theta_s XK

for ML=1:NL
    % Soil type index;
    J=IS(ML);  
    % The average moisture content of an element;
    EX=0.5*(Theta_L(ML,1)+Theta_L(ML,2));    
% Has average trend of wetting in the element changed? If the trend is 
% still in drying, keep running like this. Otherwise, change trend from
% drying to wetting. Then, IH value needs to be changed as 2, and XWRE 
% needs to be re-evaluated. However, if the trend is still in wetting,
% keep running like that. Otherwise, change trend from wetting to drying.    
    if IH(ML)==1 && XOLD(ML)<=(EX+1e-12)  % IH=1 means wetting.
        XOLD(ML)=EX;
        return
    elseif IH(ML)==2                     % IH=2 means drying.
        if XOLD(ML)>=(EX-1e-12)
            XOLD(ML)=EX;
            return
        else
            IH(ML)=1;
            for ND=1:2
                if (Theta_s(J)-Theta_LL(ML,ND))<1e-3
                    XWRE(ML,ND)=Theta_s(J);
                else
                    XWRE(ML,ND)=Theta_s(J)*(Theta_L(ML,ND)-Theta_LL(ML,ND))/(Theta_s(J)-Theta_LL(ML,ND));
                end    
            end
            XOLD(ML)=EX;
            return
        end
    else
        IH(ML)=2;
        for ND=1:2
            if (Theta_LL(J)-XK(J))<1e-3
                XWRE(ML,ND)=XK(J);
            else
                XWRE(ML,ND)=Theta_LL(ML,ND)+Theta_s(J)*(Theta_L(ML,ND)/Theta_LL(ML,ND)-1);
            end
        end
        XOLD(ML)=EX;
        return
    end
end