function Air_EQ
global ARG1 ARG2 ARG3 ARG4 ARG5 ARG6
global MN ML ND NL NN Delt_t RHS T TT h hh P_g SAVE 
global C1 C2 C3 C4 C5 C6 C7 Thmrlefc C4_a C5_a

if Thmrlefc
    RHS(1)=-C7(1)+(C3(1,1)*P_g(1)+C3(1,2)*P_g(2))/Delt_t ...
        -(C2(1,1)/Delt_t+C5(1,1))*TT(1)-(C2(1,2)/Delt_t+C5(1,2))*TT(2) ...
        -(C1(1,1)/Delt_t+C4(1,1))*hh(1)-(C1(1,2)/Delt_t+C4(1,2))*hh(2) ...
        +(C2(1,1)/Delt_t)*T(1)+(C2(1,2)/Delt_t)*T(2) ...
        +(C1(1,1)/Delt_t)*h(1)+(C1(1,2)/Delt_t)*h(2);

    for ML=2:NL
        ARG1=C2(ML-1,2)/Delt_t;
        ARG2=C2(ML,1)/Delt_t;
        ARG3=C2(ML,2)/Delt_t;

        ARG4=C1(ML-1,2)/Delt_t;
        ARG5=C1(ML,1)/Delt_t;
        ARG6=C1(ML,2)/Delt_t;

        RHS(ML)=-C7(ML)+(C3(ML-1,2)*P_g(ML-1)+C3(ML,1)*P_g(ML)+C3(ML,2)*P_g(ML+1))/Delt_t ...
            -(ARG1+C5_a(ML-1))*TT(ML-1)-(ARG2+C5(ML,1))*TT(ML)-(ARG3+C5(ML,2))*TT(ML+1) ...
            -(ARG4+C4_a(ML-1))*hh(ML-1)-(ARG5+C4(ML,1))*hh(ML)-(ARG6+C4(ML,2))*hh(ML+1) ...
            +ARG1*T(ML-1)+ARG2*T(ML)+ARG3*T(ML+1) ...
            +ARG4*h(ML-1)+ARG5*h(ML)+ARG6*h(ML+1);
    end

    RHS(NN)=-C7(NN)+(C3(NN-1,2)*P_g(NN-1)+C3(NN,1)*P_g(NN))/Delt_t ...
        -(C2(NN-1,2)/Delt_t+C5_a(NN-1))*TT(NN-1)-(C2(NN,1)/Delt_t+C5(NN,1))*TT(NN) ...
        -(C1(NN-1,2)/Delt_t+C4_a(NN-1))*hh(NN-1)-(C1(NN,1)/Delt_t+C4(NN,1))*hh(NN) ...
        +(C2(NN-1,2)/Delt_t)*T(NN-1)+(C2(NN,1)/Delt_t)*T(NN) ...
        +(C1(NN-1,2)/Delt_t)*h(NN-1)+(C1(NN,1)/Delt_t)*h(NN);
else
    ARG4=C1(ML-1,2)/Delt_t;
    ARG5=C1(ML,1)/Delt_t;
    ARG6=C1(ML,2)/Delt_t;

    RHS(1)=-C7(1)+(C3(1,1)*P_g(1)+C3(1,2)*P_g(2))/Delt_t ...
        -(C1(1,1)/Delt_t+C4(1,1))*hh(1)-(C1(1,2)/Delt_t+C4(1,2))*hh(2) ...
        +(C1(1,1)/Delt_t)*h(1)+(C1(1,2)/Delt_t)*h(2);
    for ML=2:NL
        RHS(ML)=-C7(ML)+(C3(ML-1,2)*P_g(ML-1)+C3(ML,1)*P_g(ML)+C3(ML,2)*P_g(ML+1))/Delt_t...
            -(ARG4+C4(ML-1,2))*hh(ML-1)-(ARG5+C4(ML,1))*hh(ML)-(ARG6+C4(ML,2))*hh(ML+1) ...
            +ARG4*h(ML-1)+ARG5*h(ML)+ARG6*h(ML+1);
    end
    RHS(NN)=-C7(NN)+(C3(NN-1,2)*P_g(NN-1)+C3(NN,1)*P_g(NN))/Delt_t...
        -(C1(NN-1,2)/Delt_t+C4(NN-1,2))*hh(NN-1)-(C1(NN,1)/Delt_t+C4(NN,1))*hh(NN) ...
        +(C1(NN-1,2)/Delt_t)*h(NN-1)+(C1(NN,1)/Delt_t)*h(NN);
end
    
for MN=1:NN
    for ND=1:2
        C6(MN,ND)=C3(MN,ND)/Delt_t+C6(MN,ND);
    end
end

SAVE(1,1,3)=RHS(1);
SAVE(1,2,3)=C6(1,1);
SAVE(1,3,3)=C6(1,2);
SAVE(2,1,3)=RHS(NN);
SAVE(2,2,3)=C6(NN-1,2);
SAVE(2,3,3)=C6(NN,1);

