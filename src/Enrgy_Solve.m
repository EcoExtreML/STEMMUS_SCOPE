function Enrgy_Solve
global C5 TT RHS ML NN ML NL CHK C5_a

RHS(1)=RHS(1)/C5(1,1);

for ML=2:NN
    C5(ML,1)=C5(ML,1)-C5_a(ML-1)*C5(ML-1,2)/C5(ML-1,1);
    RHS(ML)=(RHS(ML)-C5_a(ML-1)*RHS(ML-1))/C5(ML,1);
end

for ML=NL:-1:1
    RHS(ML)=RHS(ML)-C5(ML,2)*RHS(ML+1)/C5(ML,1);
end

for MN=1:NN
    CHK(MN)=abs(RHS(MN)-TT(MN)); %abs((RHS(MN)-TT(MN))/TT(MN)); %
    TT(MN)=RHS(MN);
end