function SOIL2
global hThmrl MN NN ML NL ND TT Tr COR hhU hh J IS Hystrs XWRE XSAVE
global Theta_V Theta_LL POR DTheta_LLh Theta_s IH KIT Theta_g

% if hThmrl==1
%     for MN=1:NN
%         COR(MN)=exp(0.0068*(TT(MN)-Tr));
%         if COR(MN)==0
%             COR(MN)=1;
%         end
%     end
% else
%     for MN=1:NN
%         COR(MN)=1;
%     end
% end
    for MN=1:NN
        COR(MN)=1;
    end
for MN=1:NN
   hhU(MN)=COR(MN)*hh(MN);
   hh(MN)=hhU(MN);
end

run CondL_h;

for MN=1:NN
   hhU(MN)=hh(MN);
   hh(MN)=hhU(MN)/COR(MN);
end

if Hystrs==0 
    for ML=1:NL
        J=IS(ML);
        for ND=1:2
            Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND);
            if Theta_V(ML,ND)<=1e-14
                Theta_V(ML,ND)=1e-14;
            end
            Theta_g(ML,ND)=Theta_V(ML,ND);
        end
    end
else
    for ML=1:NL
        J=IS(ML);
        for ND=1:2          
            if IH(ML)==2
                if XWRE(ML,ND)<Theta_LL(ML,ND)
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND);
                else
                    XSAVE=Theta_LL(ML,ND);
                    Theta_LL(ML,ND)=XSAVE*(1+(XWRE(ML,ND)-Theta_LL(ML,ND))/Theta_s(J));
                    if KIT>0
                        DTheta_LLh(ML,ND)=DTheta_LLh(ML,ND)*(Theta_LL(ML,ND)/XSAVE-XSAVE/Theta_s(J));
                    end
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND);
                end
            end            
            if IH(ML)==1            
                if XWRE(ML,ND)>Theta_LL(ML,ND)
                    XSAVE=Theta_LL(ML,ND);
                    Theta_LL(ML,ND)=(2-XSAVE/Theta_s(J))*XSAVE;
                    if KIT>0
                        DTheta_LLh(ML,ND)=2*DTheta_LLh(ML,ND)*(1-XSAVE/Theta_s(J));
                    end
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND);
                else
                    Theta_LL(ML,ND)=Theta_LL(ML,ND)+XWRE(ML,ND)*(1-Theta_LL(ML,ND)/Theta_s(J));
                    if KIT>0
                        DTheta_LLh(ML,ND)=DTheta_LLh(ML,ND)*(1-XWRE(ML,ND)/Theta_s(J));
                    end
                    Theta_V(ML,ND)=POR(J)-Theta_LL(ML,ND);
                end
            end            
            Theta_g(ML,ND)=Theta_V(ML,ND);
        end
    end
end

                
                
    

