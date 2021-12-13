function [Theta_LL,Se,KL_h,DTheta_LLh,J,hh]=CondL_h(Theta_r,Theta_s,Alpha,hh,n,m,Ks,NL,Theta_L,h,IS,KIT,TT,Thmrlefc,CKTN,POR,J)

% PRN The lowest suction head (The maximum value of matric head,considering
% the negative sign before them. The absolute value of which is smallest) at which soil remains saturated.

% PRN=-1e-6;

    MN=0;
    for ML=1:NL
        J=IS(ML);
        for ND=1:2
            MN=ML+ND-1;
            
            if hh(MN)>=-1e-6 
                Theta_LL(ML,ND)=Theta_s(J);                
                hh(MN)=-1e-6;
                DTheta_LLh(ML,ND)=0;
                Se(ML,ND)=1;
            elseif hh(MN)<=-1e5
                Theta_LL(ML,ND)=Theta_r(J); 
                hh(MN)=-1e5;
                DTheta_LLh(ML,ND)=0;
                Se(ML,ND)=0;
            else
                Theta_LL(ML,ND)=Theta_r(J)+(Theta_s(J)-Theta_r(J))/(1+abs(Alpha(J)*hh(MN))^n(J))^m(J);
                
                if Thmrlefc
                    DTheta_LLh(ML,ND)=(Theta_s(J)-Theta_r(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                else
                    if abs(hh(MN)-h(MN))<1e-3
                        DThehta_LL(ML,ND)=(Theta_s(J)-Theta_r(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                    else
                        DTheta_LLh(ML,ND)=(Theta_LL(ML,ND)-Theta_L(ML,ND))/(hh(MN)-h(MN));
                    end
                end
                
                Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
            end              

%             if KIT               
                CKT(MN)=CKTN/(50+2.575*TT(MN));
                KL_h(ML,ND)=CKT(MN)*Ks(J)*(Se(ML,ND)^(0.5))*(1-(1-Se(ML,ND)^(1/m(J)))^m(J))^2;
%             else
%                 KL_h(ML,ND)=0;
%             end

        end
    end

%%%%%%%%% Unit of KL_h is determined by Ks, which would be given at the%%%%
%%%%%%%%% beginning.Import thing is to keep the unit of matric head hh(MN)
%%%%%%%%% as 'cm'.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%