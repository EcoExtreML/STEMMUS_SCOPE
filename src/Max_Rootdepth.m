%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Depth       计算扎根深度  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%REFERENCES   
function[bbx]=Max_Rootdepth(bbx,NL,KT,TT)
%%% INPUTS
global DeltZ Tot_Depth R_depth
% BR = 10:1:650; %% [gC /m^2 PFT]
% rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius
%%% OUTPUTS 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root lenth distribution %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  R_depth=350;%根长
    Elmn_Lnth=0;   
        for ML=1:NL
            Elmn_Lnth=Elmn_Lnth+DeltZ(ML);
            if Elmn_Lnth<Tot_Depth-R_depth
                bbx(ML)=0;
            elseif Elmn_Lnth>=Tot_Depth-R_depth && Elmn_Lnth<=Tot_Depth-5 %&& TT(ML)>0
                bbx(ML)=1;
            else
                bbx(ML)=0;
            end
        end
end 