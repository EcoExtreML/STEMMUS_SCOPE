function Enrgy_MAT
global CTh CTT CTa KTh KTT KTa VTT VTh VTa CTg
global Kcvh KcvT Kcva Ccvh CcvT Kcah KcaT Kcaa Ccah CcaT Ccaa
global C4ARG1 C4ARG2 C5ARG1 C5ARG2 C6ARG1 C6ARG2 C7ARG
global C1 C2 C3 C4 C5 C6 C7 Soilairefc DeltZ NN NL ND ML C4ARG2_1 C4ARG2_2  C4_a C5ARG2_1 C5ARG2_2  C5_a C6ARG2_1 C6ARG2_2  C6_a

for MN=1:NN              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files, 
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        C1(MN,ND)=0; 
        C2(MN,ND)=0;
        C3(MN,ND)=0;
        C4_a(MN)=0;
        C5_a(MN)=0;
        C6_a(MN)=0;
        C4(MN,ND)=0;         
        C5(MN,ND)=0;
        C6(MN,ND)=0;
        C7(MN)=0;
    end
end

for ML=1:NL
    C1(ML,1)=C1(ML,1)+CTh(ML,1)*DeltZ(ML)/2;
    C1(ML+1,1)=C1(ML+1,1)+CTh(ML,2)*DeltZ(ML)/2;

    C2(ML,1)=C2(ML,1)+CTT(ML,1)*DeltZ(ML)/2;
    C2(ML+1,1)=C2(ML+1,1)+CTT(ML,2)*DeltZ(ML)/2;%
    
    C4ARG1=(KTh(ML,1)+KTh(ML,2))/(2*DeltZ(ML)); %sqrt(KTh(ML,1)*KTh(ML,2))/(DeltZ(ML));%
    C4ARG2_1=VTh(ML,1)/3+VTh(ML,2)/6;
    C4ARG2_2=VTh(ML,1)/6+VTh(ML,2)/3;
    C4(ML,1)=C4(ML,1)+C4ARG1-C4ARG2_1;
    C4(ML,2)=C4(ML,2)-C4ARG1-C4ARG2_2;
    C4(ML+1,1)=C4(ML+1,1)+C4ARG1+C4ARG2_2;
    C4_a(ML)=-C4ARG1+C4ARG2_1;

    C5ARG1=(KTT(ML,1)+KTT(ML,2))/(2*DeltZ(ML)); %sqrt(KTT(ML,1)*KTT(ML,2))/(DeltZ(ML));%
    C5ARG2_1=VTT(ML,1)/3+VTT(ML,2)/6;
    C5ARG2_2=VTT(ML,1)/6+VTT(ML,2)/3;
    C5(ML,1)=C5(ML,1)+C5ARG1-C5ARG2_1;
    C5(ML,2)=C5(ML,2)-C5ARG1-C5ARG2_2;
    C5(ML+1,1)=C5(ML+1,1)+C5ARG1+C5ARG2_2;
    C5_a(ML)=-C5ARG1+C5ARG2_1;

    if Soilairefc==1
        C3(ML,1)=C3(ML,1)+CTa(ML,1)*DeltZ(ML)/2;
        C3(ML+1,1)=C3(ML+1,1)+CTa(ML,2)*DeltZ(ML)/2;

        C6ARG1=(KTa(ML,1)+KTa(ML,2))/(2*DeltZ(ML));%sqrt(KTa(ML,1)*KTa(ML,2))/(DeltZ(ML)); %
        C6ARG2_1=VTa(ML,1)/3+VTa(ML,2)/6;
        C6ARG2_2=VTa(ML,1)/6+VTa(ML,2)/3;     
        C6(ML,1)=C6(ML,1)+C6ARG1-C6ARG2_1;
        C6(ML,2)=C6(ML,2)-C6ARG1-C6ARG2_2;
        C6(ML+1,1)=C6(ML+1,1)+C6ARG1+C6ARG2_2;
        C6_a(ML)=-C6ARG1+C6ARG2_1;
    end
    
    C7ARG=(CTg(ML,1)+CTg(ML,2))/2; %sqrt(CTg(ML,1)*CTg(ML,2));%
    C7(ML)=C7(ML)-C7ARG;
    C7(ML+1)=C7(ML+1)+C7ARG;
end