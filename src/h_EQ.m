function [RHS,C4,SAVE]=h_EQ(C1,C2,C4,C5,C6,C7,C5_a,C9,NL,NN,Delt_t,T,TT,h,P_gg,Thmrlefc,Soilairefc)

if Thmrlefc && ~Soilairefc
    RHS(1)=-C9(1)-C7(1)+(C1(1,1)*h(1)+C1(1,2)*h(2))/Delt_t ...
        -(C2(1,1)/Delt_t+C5(1,1))*TT(1)-(C2(1,2)/Delt_t+C5(1,2))*TT(2) ...
        +(C2(1,1)/Delt_t)*T(1)+(C2(1,2)/Delt_t)*T(2);
    for ML=2:NL
        ARG1=C2(ML-1,2)/Delt_t;
        ARG2=C2(ML,1)/Delt_t;
        ARG3=C2(ML,2)/Delt_t;

        RHS(ML)=-C9(ML)-C7(ML)+(C1(ML-1,2)*h(ML-1)+C1(ML,1)*h(ML)+C1(ML,2)*h(ML+1))/Delt_t ...
            -(ARG1+C5(ML-1,2))*TT(ML-1)-(ARG2+C5(ML,1))*TT(ML)-(ARG3+C5(ML,2))*TT(ML+1) ...
            +ARG1*T(ML-1)+ARG2*T(ML)+ARG3*T(ML+1);
    end
    RHS(NN)=-C9(NN)-C7(NN)+(C1(NN-1,2)*h(NN-1)+C1(NN,1)*h(NN))/Delt_t ...
    -(C2(NN-1,2)/Delt_t+C5(NN-1,2))*TT(NN-1)-(C2(NN,1)/Delt_t+C5(NN,1))*TT(NN) ...
    +(C2(NN-1,2)/Delt_t)*T(NN-1)+(C2(NN,1)/Delt_t)*T(NN);
elseif ~Thmrlefc && Soilairefc
    RHS(1)=-C9(1)-C7(1)+(C1(1,1)*h(1)+C1(1,2)*h(2))/Delt_t ...
        -C6(1,1)*P_gg(1)-C6(1,2)*P_gg(2);
    for ML=2:NL
        RHS(ML)=-C9(ML)-C7(ML)+(C1(ML-1,2)*h(ML-1)+C1(ML,1)*h(ML)+C1(ML,2)*h(ML+1))/Delt_t ...
            -C6(ML-1,2)*P_gg(ML-1)-C6(ML,1)*P_gg(ML)-C6(ML,2)*P_gg(ML+1);
    end
    RHS(NN)=-C9(NN)-C7(NN)+(C1(NN-1,2)*h(NN-1)+C1(NN,1)*h(NN))/Delt_t ...
        -C6(NN-1,2)*P_gg(NN-1)-C6(NN,1)*P_gg(NN);
elseif Thmrlefc && Soilairefc    
    RHS(1)=-C9(1)-C7(1)+(C1(1,1)*h(1)+C1(1,2)*h(2))/Delt_t ...
        -(C2(1,1)/Delt_t+C5(1,1))*TT(1)-(C2(1,2)/Delt_t+C5(1,2))*TT(2) ...
        -C6(1,1)*P_gg(1)-C6(1,2)*P_gg(2) ...
        +(C2(1,1)/Delt_t)*T(1)+(C2(1,2)/Delt_t)*T(2);
    for ML=2:NL
        ARG1=C2(ML-1,2)/Delt_t;
        ARG2=C2(ML,1)/Delt_t;
        ARG3=C2(ML,2)/Delt_t;

        RHS(ML)=-C9(ML)-C7(ML)+(C1(ML-1,2)*h(ML-1)+C1(ML,1)*h(ML)+C1(ML,2)*h(ML+1))/Delt_t ...
            -(ARG1+C5_a(ML-1))*TT(ML-1)-(ARG2+C5(ML,1))*TT(ML)-(ARG3+C5(ML,2))*TT(ML+1) ...
            -C6(ML-1,2)*P_gg(ML-1)-C6(ML,1)*P_gg(ML)-C6(ML,2)*P_gg(ML+1) ...
            +ARG1*T(ML-1)+ARG2*T(ML)+ARG3*T(ML+1);
    end

    RHS(NN)=-C9(NN)-C7(NN)+(C1(NN-1,2)*h(NN-1)+C1(NN,1)*h(NN))/Delt_t ...
        -(C2(NN-1,2)/Delt_t+C5_a(NN-1))*TT(NN-1)-(C2(NN,1)/Delt_t+C5(NN,1))*TT(NN) ...
        -C6(NN-1,2)*P_gg(NN-1)-C6(NN,1)*P_gg(NN) ...
        +(C2(NN-1,2)/Delt_t)*T(NN-1)+(C2(NN,1)/Delt_t)*T(NN);
else
    RHS(1)=-C9(1)-C7(1)+(C1(1,1)*h(1)+C1(1,2)*h(2))/Delt_t;
    for ML=2:NL 
        RHS(ML)=-C9(ML)-C7(ML)+(C1(ML-1,2)*h(ML-1)+C1(ML,1)*h(ML)+C1(ML,2)*h(ML+1))/Delt_t;
    end
    RHS(NN)=-C9(NN)-C7(NN)+(C1(NN-1,2)*h(NN-1)+C1(NN,1)*h(NN))/Delt_t;
end

for MN=1:NN
    for ND=1:2
        C4(MN,ND)=C1(MN,ND)/Delt_t+C4(MN,ND);
    end        
end

SAVE(1,1,1)=RHS(1);
SAVE(1,2,1)=C4(1,1);
SAVE(1,3,1)=C4(1,2);
SAVE(2,1,1)=RHS(NN);
SAVE(2,2,1)=C4(NN-1,2);
SAVE(2,3,1)=C4(NN,1);
