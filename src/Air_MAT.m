function Air_MAT
global C1 C2 C3 C4 C5 C6 C7 DeltZ ML NL NN ND
global Cah CaT Caa Kah KaT Kaa Vah VaT Vaa Cag 
global C4ARG1 C5ARG1 C6ARG1 C7ARG C4ARG2_1 C4ARG2_2  C4_a C5ARG2_1 C5ARG2_2  C5_a C6ARG2_1 C6ARG2_2  C6_a

for MN=1:NN              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files, 
    for ND=1:2            % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        C1(MN,ND)=0; 
        C7(MN)=0;
        C4(MN,ND)=0; 
        C4_a(MN)=0;
        C5_a(MN)=0;
        C6_a(MN)=0;
        C2(MN,ND)=0;
        C3(MN,ND)=0;
        C5(MN,ND)=0;
        C6(MN,ND)=0;
    end
end
        
for ML=1:NL
    C1(ML,1)=C1(ML,1)+Cah(ML,1)*DeltZ(ML)/2;
    C1(ML+1,1)=C1(ML+1,1)+Cah(ML,2)*DeltZ(ML)/2;
    
    C2(ML,1)=C2(ML,1)+CaT(ML,1)*DeltZ(ML)/2;
    C2(ML+1,1)=C2(ML+1,1)+CaT(ML,2)*DeltZ(ML)/2;
    
    C3(ML,1)=C3(ML,1)+Caa(ML,1)*DeltZ(ML)/2;
    C3(ML+1,1)=C3(ML+1,1)+Caa(ML,2)*DeltZ(ML)/2;

    C4ARG1=(Kah(ML,1)+Kah(ML,2))/(2*DeltZ(ML));
    C4ARG2_1=Vah(ML,1)/3+Vah(ML,2)/6;
    C4ARG2_2=Vah(ML,1)/6+Vah(ML,2)/3;
    C4(ML,1)=C4(ML,1)+C4ARG1-C4ARG2_1;
    C4(ML,2)=C4(ML,2)-C4ARG1-C4ARG2_2;
    C4(ML+1,1)=C4(ML+1,1)+C4ARG1+C4ARG2_2;  
    C4_a(ML)=-C4ARG1+C4ARG2_1;
           
    C5ARG1=(KaT(ML,1)+KaT(ML,2))/(2*DeltZ(ML)); 
    C5ARG2_1=VaT(ML,1)/3+VaT(ML,2)/6;
    C5ARG2_2=VaT(ML,1)/6+VaT(ML,2)/3;
    C5(ML,1)=C5(ML,1)+C5ARG1-C5ARG2_1;
    C5(ML,2)=C5(ML,2)-C5ARG1-C5ARG2_2;
    C5(ML+1,1)=C5(ML+1,1)+C5ARG1+C5ARG2_2; 
    C5_a(ML)=-C5ARG1+C5ARG2_1;
    
    C6ARG1=(Kaa(ML,1)+Kaa(ML,2))/(2*DeltZ(ML));  
    C6ARG2_1=Vaa(ML,1)/3+Vaa(ML,2)/6;
    C6ARG2_2=Vaa(ML,1)/6+Vaa(ML,2)/3;
    C6(ML,1)=C6(ML,1)+C6ARG1-C6ARG2_1;
    C6(ML,2)=C6(ML,2)-C6ARG1-C6ARG2_2;
    C6(ML+1,1)=C6(ML+1,1)+C6ARG1+C6ARG2_2;
    C6_a(ML)=-C6ARG1+C6ARG2_1;
    
    C7ARG=(Cag(ML,1)+Cag(ML,2))/2; 
    C7(ML)=C7(ML)-C7ARG;
    C7(ML+1)=C7(ML+1)+C7ARG;   
end