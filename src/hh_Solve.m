function [CHK,hh,C4,SAVEhh]=hh_Solve(C4,hh,NN,NL,C4_a,RHS)
hRHS=zeros(mN,1);
TTheta_UU=zeros(NL+1,2);hdry(1:NN)=-5e3;hwet(1:NN)=-1;DTTheta_UU=zeros(NL+1,2);TGama_hh=zeros(NL+1,1);TTheta_m=zeros(NL,1);
RHS(1)=RHS(1)/C4(1,1);SAVDTheta_LLh=zeros(NL+1,2);INDICATOR=0;
f=@(hhRHS)((Theta_s(J)-Theta_r(J))*Alpha(J)*n(J)*abs(Alpha(J)*hhRHS)^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hhRHS)^n(J))^(-m(J)-1));
x0=-1000;
hmin=fminsearch(f,x0);
for ML=2:NN
    C4(ML,1)=C4(ML,1)-C4_a(ML-1)*C4(ML-1,2)/C4(ML-1,1);
    RHS(ML)=(RHS(ML)-C4_a(ML-1)*RHS(ML-1))/C4(ML,1);
end

for ML=NL:-1:1
    RHS(ML)=RHS(ML)-C4(ML,2)*RHS(ML+1)/C4(ML,1);
end


hRHS(1:NN)=hh(1:NN); %hj+1,k; RHS, hj+1,k+1
% RTheta_LL=Theta_LL; %thetaj+1,k;
MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        if hRHS(MN)<=hdry(MN) && RHS(MN)>=hwet(MN)
            RHS(MN)=(hRHS(MN)+hmin)/2;
        elseif RHS(MN)<=hdry(MN)*3 && hRHS(MN)>=hwet(MN)
            RHS(MN)=(hRHS(MN))/2;
        end
    end
end

for MN=1:NN
    CHK(MN)=abs(RHS(MN)-hh(MN));SAVEhh(MN)=RHS(MN);
    if isnan(RHS(MN))
        RHS(MN)=h(MN);
        CHK(MN)=0;
    end

    hh(MN)=RHS(MN);
end

if isnan(SAVEhh)==1
    keyboard
end
if ~isreal(SAVEhh)
    keyboard
end