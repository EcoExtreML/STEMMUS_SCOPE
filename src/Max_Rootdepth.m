%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Depth         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%REFERENCES   
function[bbx]=Max_Rootdepth(bbx,NL,KT,Ta)
%%% INPUTS
global DeltZ LR
% BR = 10:1:650; %% [gC /m^2 PFT]
% rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius
%%% OUTPUTS 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root lenth distribution %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Ta>40
        Ta=40;
    end
    if Ta<10
        Ta=10;
    end
   % Lm=123;
  %  RL0=20;   
    %r=9.48915E-07;  % root growth rate cm/s
   % fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*TIME)));
   % LR(KT)=Lm*fr(KT);
   if KT<=1
    LR=35;
   else 
    LR=LR+(Ta-10)*0.0015;
   if LR>55
       LR=55;
   end
   end
    RL=500;
    Elmn_Lnth=0;   
        for ML=1:NL
            Elmn_Lnth=Elmn_Lnth+DeltZ(ML);
            if Elmn_Lnth<RL-LR
                bbx(ML)=0;
            elseif Elmn_Lnth>=RL-LR && Elmn_Lnth<=RL-0.1*LR
                bbx(ML)=1;
            else
                bbx(ML)=0;
            end
        end
end 