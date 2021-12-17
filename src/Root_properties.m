%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction - Root - Properties         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%REFERENCES   
function[Rl]=Root_properties(Rl,Ac,rroot,frac,bbx,KT)
%%% INPUTS
global DeltZ sfactor LAI_msr
% BR = 10:1:650; %% [gC /m^2 PFT]
% rroot =  0.5*1e-3 ; % 3.3*1e-4 ;%% [0.5-6 *10^-3] [m] root radius
%%% OUTPUTS 
if KT<2880
fr=0.3*3*exp(-0.15*LAI_msr(KT))/(exp(-0.15*LAI_msr(KT))+2*sfactor);
  if fr<0.15
    fr=0.15;
  end
else
    fr=0.001;
end
   %if KT<3840
       %fr=-0.091*LAI(KT)+0.40;
  % else
      % fr=0.001;
   %end
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
%for i=1:nn
%   if Rl(i)>50000
%       frac(i)=0;
%    end
%end
if ~isnan(frac)
frac=frac/sum(sum(frac));
else
    frac=Rl./sum(sum(Rl));
end
Delta_Rl=frac.*bbx*Delta_Rltot;
Rl=Rl+Delta_Rl;
Rl=Rl./DeltZ0;
else
end
%for i=1:nn
%    if Rl(i)>50000
%       Rl(i)=50000;
%    end
%end
end 