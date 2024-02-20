function Enrgy_sub
global TT MN NN BCTB

for MN=1:NN
    if TT(MN)<=0
        TT(MN)=BCTB;        
    end
end

EnrgyPARM;
Enrgy_MAT;
Enrgy_EQ;
Enrgy_BC;
Enrgy_Solve;

for MN=1:NN
    if TT(MN)<=0
        TT(MN)=BCTB;        
    end
end

Enrgy_Bndry_Flux;