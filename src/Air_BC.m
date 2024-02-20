function Air_BC
global RHS BtmPg C6 TopPg NN KT 
global NBCPB BCPB NBCP BCP C6_a

%%%%%%%%% Apply the bottom boundary condition called for by NBCPB %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NBCPB==1  %---------------------> Bounded bottom with the water table;
    RHS(1)=BtmPg;
    C6(1,1)=1;
    RHS(2)=RHS(2)-C6(1,2)*RHS(1);
    C6(1,2)=0;
    C6_a(1)=0;
elseif NBCPB==2 %------------------> The soil air is allowed to escape from the bottom; 
    RHS(1)=RHS(1)+BCPB; 
end

%%%%%%%%%% Apply the surface boundary condition called by NBCP %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NBCP==1    %----------> Ponded infiltration with Bonded bottom, 
        RHS(NN)=BtmPg; 
        C6(NN,1)=1;
        RHS(NN-1)=RHS(NN-1)-C6(NN-1,2)*RHS(NN);
        C6(NN-1,2)=0;
        C6_a(NN-1)=0;
elseif NBCP==2          %----------> Specified flux on the surface;
    RHS(NN)=RHS(NN)-BCP;
else
    RHS(NN)=TopPg(KT);  
    C6(NN,1)=1;
    RHS(NN-1)=RHS(NN-1)-C6(NN-1,2)*RHS(NN);
    C6(NN-1,2)=0;
    C6_a(NN-1)=0;
end




