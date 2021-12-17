function [C1,C2,C4,C3,C4_a,C5,C6,C7,C5_a,C9]=h_MAT(Chh,ChT,Khh,KhT,Kha,Vvh,VvT,Chg,DeltZ,NL,NN,Srt)

for MN=1:NN             % Clean the space in C1-7 every iteration,otherwise, in *.PARM files, 
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        C1(MN,ND)=0; 
        C7(MN)=0;
        C9(MN)=0; % C9 is the matrix coefficient of root water uptake;
        C4(MN,ND)=0; 
        C4_a(MN)=0;
        C5_a(MN)=0;
        C2(MN,ND)=0;
        C3(MN,ND)=0;
        C5(MN,ND)=0;
        C6(MN,ND)=0;
    end
end
for ML=1:NL
    C1(ML,1)=C1(ML,1)+Chh(ML,1)*DeltZ(ML)/2;
    C1(ML+1,1)=C1(ML+1,1)+Chh(ML,2)*DeltZ(ML)/2;%
    
    C2(ML,1)=C2(ML,1)+ChT(ML,1)*DeltZ(ML)/2;
    C2(ML+1,1)=C2(ML+1,1)+ChT(ML,2)*DeltZ(ML)/2; %
    
    C4ARG1=(Khh(ML,1)+Khh(ML,2))/(2*DeltZ(ML));%sqrt(Khh(ML,1)*Khh(ML,2))/(DeltZ(ML));%
    C4ARG2_1=Vvh(ML,1)/3+Vvh(ML,2)/6;
    C4ARG2_2=Vvh(ML,1)/6+Vvh(ML,2)/3;
    C4(ML,1)=C4(ML,1)+C4ARG1-C4ARG2_1;
    C4(ML,2)=C4(ML,2)-C4ARG1-C4ARG2_2;
    C4(ML+1,1)=C4(ML+1,1)+C4ARG1+C4ARG2_2;
    C4_a(ML)=-C4ARG1+C4ARG2_1;
    
    C5ARG1=(KhT(ML,1)+KhT(ML,2))/(2*DeltZ(ML));%sqrt(KhT(ML,1)*KhT(ML,2))/(DeltZ(ML));%
    C5ARG2_1=VvT(ML,1)/3+VvT(ML,2)/6;
    C5ARG2_2=VvT(ML,1)/6+VvT(ML,2)/3;
    C5(ML,1)=C5(ML,1)+C5ARG1-C5ARG2_1;
    C5(ML,2)=C5(ML,2)-C5ARG1-C5ARG2_2;
    C5(ML+1,1)=C5(ML+1,1)+C5ARG1+C5ARG2_2;
    C5_a(ML)=-C5ARG1+C5ARG2_1;
    
    C6ARG=(Kha(ML,1)+Kha(ML,2))/(2*DeltZ(ML));%sqrt(Kha(ML,1)*Kha(ML,2))/(DeltZ(ML));%
    C6(ML,1)=C6(ML,1)+C6ARG;
    C6(ML,2)=C6(ML,2)-C6ARG;
    C6(ML+1,1)=C6(ML+1,1)+C6ARG;

    C7ARG=(Chg(ML,1)+Chg(ML,2))/2;%sqrt(Chg(ML,1)*Chg(ML,2));%
    C7(ML)=C7(ML)-C7ARG;
    C7(ML+1)=C7(ML+1)+C7ARG;
   
    % Srt, root water uptake; 
    C9ARG1=(2*Srt(ML,1)+Srt(ML,2))*DeltZ(ML)/6;%sqrt(Chg(ML,1)*Chg(ML,2));%  
    C9ARG2=(Srt(ML,1)+2*Srt(ML,2))*DeltZ(ML)/6;
    C9(ML)=C9(ML)+C9ARG1;
    C9(ML+1)=C9(ML+1)+C9ARG2;
end