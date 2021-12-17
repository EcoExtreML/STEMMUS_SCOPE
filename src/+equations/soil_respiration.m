function [R] = soil_respiration(Ts)
R = 0.5+0.14375*Ts;    %umol m-2 s-1