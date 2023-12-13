function [KL_T]=CondL_T(NL)

MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        KL_T(ML,ND)=0; 
    end
end

%%%%%%%% Unit of KL_T is determined by KL_h, which is subsequently %%%%%%%%
%%%%%%%% determined by Ks set at the beginning. %%%%%%%%%%%%%%%%%%%%%%%%%%%