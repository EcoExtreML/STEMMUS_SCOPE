function h_sub
global hh MN NN

hPARM;
h_MAT;
h_EQ;
h_BC;
hh_Solve; 

for MN=1:NN
    if hh(MN)<=-10^(5)
        hh(MN)=-10^(5);
%     elseif hh(MN)>=-1e-6
%         hh(MN)=-1e-6;
    end
end            
h_Bndry_Flux;