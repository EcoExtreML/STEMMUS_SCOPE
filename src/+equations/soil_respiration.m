function [R] = soil_respiration(Ts)
R = 2.5 + 0.054375*Ts;    %umol m-2 s-1