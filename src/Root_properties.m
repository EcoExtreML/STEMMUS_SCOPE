%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Properties         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%REFERENCES   
function[Rl]=Root_properties(Rl,Ac,rroot,frac,bbx,KT)
%%% INPUTS
global DeltZ LAI
% BR = 10:1:650; %% [gC /m^2 PFT]
% rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius
%%% OUTPUTS 
  % if KT<3800
       fr=-0.0296*LAI(KT)+0.30;
 %  else
  %     fr=0.001;
  % end
%elseif KT<3200
   % fr=0.05;
%else
   % fr=0.02;
%end
DeltZ0=DeltZ'/100;
BR = Ac*fr*1800*12/1000000;
root_den = 250*1000; %% [gDM / m^3] Root density  Jackson et al., 1997 
R_C = 0.488; %% [gC/gDM] Ratio Carbon-Dry Matter in root   Jackson et al.,  1997 
nn=numel(Rl);
if (~isnan(Ac))||(Ac>0)
Rl=Rl.*DeltZ0;
Delta_Rltot = BR/R_C/root_den/(pi*(rroot^2)); %% %% root length index [m root / m^2 PFT]
for i=1:nn
    if Rl(i)>2000
       frac(i)=0;
    end
end
frac=frac/sum(sum(frac));
Delta_Rl=Delta_Rltot*frac.*bbx;
Rl=Rl+Delta_Rl;
Rl=Rl./DeltZ0;
else
Rl=Rl;
end
for i=1:nn
    if Rl(i)>2000
       Rl(i)=2000;
    end
end
end 