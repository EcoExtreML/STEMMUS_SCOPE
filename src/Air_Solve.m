function Air_Solve
global C6 P_gg RHS ML NN NL C6_a

RHS(1)=RHS(1)/C6(1,1);

for ML=2:NN
    C6(ML,1)=C6(ML,1)-C6_a(ML-1)*C6(ML-1,2)/C6(ML-1,1);
    RHS(ML)=(RHS(ML)-C6_a(ML-1)*RHS(ML-1))/C6(ML,1);
end

for ML=NL:-1:1
    RHS(ML)=RHS(ML)-C6(ML,2)*RHS(ML+1)/C6(ML,1);
end

for MN=1:NN
    P_gg(MN)=RHS(MN);
end