function hh_Solve
global C4 hh RHS ML NN NL CHK C4_a

RHS(1)=RHS(1)/C4(1,1);

for ML=2:NN
    C4(ML,1)=C4(ML,1)-C4_a(ML-1)*C4(ML-1,2)/C4(ML-1,1);
    RHS(ML)=(RHS(ML)-C4_a(ML-1)*RHS(ML-1))/C4(ML,1);
end

for ML=NL:-1:1
    RHS(ML)=RHS(ML)-C4(ML,2)*RHS(ML+1)/C4(ML,1);
end

for MN=1:NN
    CHK(MN)=abs(RHS(MN)-hh(MN)); 
    hh(MN)=RHS(MN);
end
