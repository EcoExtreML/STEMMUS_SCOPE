function [DeltZ_R,NL,DeltZ,MML]=Dtrmn_Z(IP0STm)
%  The determination of the element length
% global Elmn_Lnth ML DeltZ NL Tot_Depth DeltZ_R MML 

Elmn_Lnth=0;
if IP0STm==10 || IP0STm==16 || IP0STm==33 || IP0STm==35 || IP0STm==36
    DeltZ_R = [0.01	0.01	0.01	0.02	0.02	0.02	0.03	0.03	0.03	0.04	0.04	0.04 ...
        0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.5	0.5	0.5	0.5	0.5	...
        0.5	0.5	0.5	0.5	0.5	0.5	0.5	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2 ...
        2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1].*100;
    NL=length(DeltZ_R);
    for ML=1:NL
        MML=NL-ML+1;
        DeltZ(ML)=DeltZ_R(MML);
    end
else
    DeltZ_R = [ 0.01	0.01	0.01	0.02	0.02	0.02	0.03	0.03	0.03	0.04	0.04	0.04 ...
        0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.3	0.5	0.5	0.5 ...
        0.5	0.5	0.5	0.5	0.5	0.5	0.5	0.5	0.5	1	1	1	1	1	1	1	1	1	1	1	1	2	2 ...
        2	2	2	2	2	2].*100;
    NL=length(DeltZ_R);
    for ML=1:NL
        MML=NL-ML+1;
        DeltZ(ML)=DeltZ_R(MML);
    end
end