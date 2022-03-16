% function Latent
% global TT L MN NN 
function [L]= Latent(TT,NN)

    for MN=1:NN
        L(MN)=(2.501*10^6-2369.2*TT(MN))/1000;   % J g-1
    end
    
    
% Git lesson test
