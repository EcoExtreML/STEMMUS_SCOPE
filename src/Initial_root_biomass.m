function [Rl] = Initial_root_biomass(RTB,DeltZ_R,rroot,ML)
global Ztot IGBP_veg_long
%rri=zeros(1,45);
root_den = 250*1000; %% [gDM / m^3] Root density  Jackson et al., 1997 
R_C = 0.488; %% [gC/gDM] Ratio Carbon-Dry Matter in root   Jackson et al.,  1997 
%% beta is a plant-dependent root distribution parameter adopted from 
%% Jackson et al. (1996), it is refered to CLM5.0 document. 
if strcmp(IGBP_veg_long(1:18), 'Permanent Wetlands')
    beta = 0.993; 
elseif strcmp(IGBP_veg_long(1:19)', 'Evergreen Broadleaf') 
    beta = 0.993; 
elseif strcmp(IGBP_veg_long(1:19)', 'Deciduous Broadleaf') 
    beta = 0.993; 
elseif strcmp(IGBP_veg_long(1:13)', 'Mixed Forests') 
    beta = 0.993; 
elseif strcmp(IGBP_veg_long(1:20)', 'Evergreen Needleleaf') 
    beta = 0.993; 
elseif strcmp(IGBP_veg_long(1:9)', 'Croplands') 
    beta = 0.943; 
elseif strcmp(IGBP_veg_long(1:15)', 'Open Shrublands')
    beta = 0.966; 
elseif strcmp(IGBP_veg_long(1:17)', 'Closed Shrublands') 
    beta = 0.966; 
elseif strcmp(IGBP_veg_long(1:8)', 'Savannas') 
    beta = 0.943; 
elseif strcmp(IGBP_veg_long(1:14)', 'Woody Savannas') 
    beta = 0.943; 
elseif strcmp(IGBP_veg_long(1:9)', 'Grassland') 
    beta = 0.943; 
else 
    beta = 0.943; 
    warning('IGBP vegetation name unknown, "%s" is not recognized. Falling back to default value for beta', IGBP_veg_long)
end

Rltot = RTB/R_C/root_den/(pi*(rroot^2)); %% %% root length index [m root / m^2 PFT]
    %Ztot=DeltZ';
   % Ztot=flip(Ztot);
    Ztot=cumsum(DeltZ_R',1); 
    %Ztot=flip(Ztot);
for i=1:ML
    if i==1
        ri(i)=(1-beta.^(Ztot(i)/2));
    else
        ri(i)=beta.^(Ztot(i-1)-(DeltZ_R(i-1)/2))-beta.^(Ztot(i-1)+(DeltZ_R(i)/2));
    end
end
%for i=1:ML
%    if i==1
 %       rri(i)=ri(i)./2;
 %   else
  %      rri(i)=(ri(i)+ri(i-1))./2;
 %   end
%end
Rl=(ri.*Rltot./(DeltZ_R./100))';
Rl=flipud(Rl);
end