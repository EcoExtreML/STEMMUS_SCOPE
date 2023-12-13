function [Theta_LL,Se,KfL_h,KfL_T,DTheta_LLh,hh,hh_frez,Theta_UU,DTheta_UUh,Theta_II,KL_h]=CondL_h(Theta_r,Theta_s,Alpha,hh,hh_frez,h_frez,n,m,Ks,NL,Theta_L,h,KIT,TT,Thmrlefc,POR,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,Theta_II,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se)
global hd hm Theta_m Gama_hh
SFCC=1;SWCC=1;
MN=0;
for ML=1:NL
    %     J=IS(ML);
    J=ML;%
    hd=-1e7;hm=-9899;
    for ND=1:2
        MN=ML+ND-1;%SAVEKfL_h(ML,ND)=KfL_h(ML,ND);
        if SWCC==1
%             if SFCC==1
%             hh_frez(MN)=0; 
            if abs(hh(MN))>=abs(hd)
                Gama_hh(MN)=0;
            elseif abs(hh(MN))>=abs(hm)
                Gama_hh(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
            else
                Gama_hh(MN)=1;
            end
                Theta_m(ML)=Gama_hh(MN)*Theta_r(J)+(Theta_s(J)-Gama_hh(MN)*Theta_r(J))*(1+abs(Alpha(J)*(-2))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
                if Theta_m(ML)>=POR(J)
                    Theta_m(ML)=POR(J);
                elseif Theta_m(ML)<=Theta_s(J)
                    Theta_m(ML)=Theta_s(J);
                end
%                 Theta_m(ML)=Theta_s(J);
                 
                if hh(MN)>=-2%1e-6
                    Theta_UU(ML,ND)=Theta_s(J);
                    DTheta_LLh(ML,ND)=0;%hh_frez(MN)=h_frez(MN);
                    if (hh_frez(MN))>=-1e-6
                        Theta_LL(ML,ND)=Theta_s(J);
                        DTheta_UUh(ML,ND)=0;%Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                        Se(ML,ND)=1;
                    else
                        if Thmrlefc
                            if (hh(MN)+hh_frez(MN))<=hd
                                Theta_LL(ML,ND)=0;
                                DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                                Se(ML,ND)=0;
                            else
                                Theta_LL(ML,ND)=Gama_hh(MN)*Theta_r(J)+(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))/(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
                                DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                                Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                            end
                            
                        else
                            if abs(hh(MN)-h(MN))<1e-3
                                DTheta_UUh(ML,ND)=(Theta_m(ML)-Theta_r(J))*Alpha(J)*n(J)*abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1);
                            else
                                DTheta_UUh(ML,ND)=(Theta_LL(ML,ND)-Theta_L(ML,ND))/(hh(MN)+hh_frez(MN)-h(MN)-h_frez(MN));
                            end
                        end
                    end
                else
                    if Thmrlefc
                        if Gama_hh(MN)==0
                            Theta_UU(ML,ND)=0;
                            DTheta_LLh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                            if (hh(MN)+hh_frez(MN))<=hd
                                Theta_LL(ML,ND)=0;
                                DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                                Se(ML,ND)=0;
                            else
                                Theta_LL(ML,ND)=Gama_hh(MN)*Theta_r(J)+(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))/(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
                                DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                                Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                            end
                        else
                            Theta_UU(ML,ND)=Gama_hh(MN)*Theta_r(J)+(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))/(1+abs(Alpha(J)*hh(MN))^n(J))^m(J);
                            DTheta_LLh(ML,ND)=(-Theta_r(J))/(abs(hh(MN))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1))*(abs(Alpha(J)*hh(MN))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                            if (hh(MN)+hh_frez(MN))<=hd
                                Theta_LL(ML,ND)=0;
                                DTheta_UUh(ML,ND)=0;%(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                                Se(ML,ND)=0;
                            else
                                Theta_LL(ML,ND)=Gama_hh(MN)*Theta_r(J)+(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))/(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
                                DTheta_UUh(ML,ND)=(-Theta_r(J))/(abs((hh(MN)+hh_frez(MN)))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^n(J))^(-m(J)-1))*(abs(Alpha(J)*(hh(MN)+hh_frez(MN)))^(n(J)-1));  %(Theta_s(J)-Gama_hh(MN)*Theta_a(J))*Alpha(J)*n(J)*abs(Alpha(J)*hh(MN))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1);
                                Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                            end
                        end
                    else
                        if abs(hh(MN)-h(MN))<1e-3
                            DTheta_LLh(ML,ND)=(Theta_m(ML)-Theta_r(J))*Alpha(J)*n(J)*abs(Alpha(J)*(hh(MN)))^(n(J)-1)*(-m(J))*(1+abs(Alpha(J)*(hh(MN)))^n(J))^(-m(J)-1);
                        else
                            DTheta_LLh(ML,ND)=(Theta_UU(ML,ND)-Theta_U(ML,ND))/(hh(MN)-h(MN));
                        end
                    end
                end
        end
                %%% 20190911
                if Theta_LL(ML,ND)<=Gama_hh(MN)*Theta_r(J)
                    Theta_LL(ML,ND)=Gama_hh(MN)*Theta_r(J)+1e-5;
                    Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                elseif Theta_LL(ML,ND)>=Theta_s(J)
                    Theta_LL(ML,ND)=Theta_s(J);
                    Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                end        
                if Theta_UU(ML,ND)<=Gama_hh(MN)*Theta_r(J)
                    Theta_UU(ML,ND)=Gama_hh(MN)*Theta_r(J)+1e-5;
%                     Se(ML,ND)=Theta_LL(ML,ND)/POR(J);
                elseif Theta_UU(ML,ND)>=Theta_s(J)
                    Theta_UU(ML,ND)=Theta_s(J);
                end        
        
        if Se(ML,ND)>=1
            Se(ML,ND)=1;
        elseif Se(ML,ND)<=0
            Se(ML,ND)=0;
        end

        if (Theta_UU(ML,ND)-Theta_LL(ML,ND))>0 && hh_frez(MN)<-1E-6 && (DTheta_UUh(ML,ND)-DTheta_LLh(ML,ND))~=0
            Theta_II(ML,ND)=(Theta_UU(ML,ND)-Theta_LL(ML,ND))*RHOL/RHOI;  % ice water content
            if Theta_UU(ML,ND)~=0
                Ratio_ice(ML,ND)=RHOI*Theta_II(ML,ND)/(RHOL*Theta_UU(ML,ND)); % ice ratio
            else
                Ratio_ice(ML,ND)=0;
            end
        else
            Theta_II(ML,ND)=0;
            Ratio_ice(ML,ND)=0;
        end

        if KIT
            MU_W0=2.4152*10^(-4);   %(g.cm^-1.s^-1)
            MU1=4742.8;                   %(J.mol^-1)
            MU_WN=MU_W0*exp(MU1/(8.31441*(20+133.3)));
            if TT(MN)<-20
                MU_W(ML,ND)=3.71e-2; %CKT(MN)=0.2688;
            elseif TT(MN)>100
                MU_W(ML,ND)=0.0028;%1.81e-3;
            else
                MU_W(ML,ND)=MU_W0*exp(MU1/(8.31441*(TT(MN)+133.3)));
                
            end
                % CKT(MN)=CKTN/(50+2.575*TT(MN));
                CKT(MN)=1;%MU_WN/MU_W(ML,ND);
            if isnan(CKT(MN))==1
                CKT(MN)=1;
            end                
            if Se(ML,ND)==0
                KL_h(ML,ND)=0;
            else
                KL_h(ML,ND)=CKT(MN)*Ks(J)*(Se(ML,ND)^(0.5))*(1-(1-Se(ML,ND)^(1/m(J)))^m(J))^2;
            end

            CORF=1;
            FILM=1;   % indicator for film flow parameterization; =1, Zhang (2010); =2, Lebeau and Konrad (2010)
            if FILM==1
                % %%%%%%%%% see Zhang (2010)
                AGR(J)=0.00035;
                    % %%%%%%%%% see Zeng (2011) and Zhang (2010)
                RHOW0=1e3;GVA=9.81;
                uw0=2.4152e-5; % Pa s
                u1=4.7428; % kJ mol-1
                R=8.314472; % J mol-1 K-1
                e=78.54;
                e0=8.85e-12;
                B_sig=235.8E-3; 
                Tc=647.15;
                e_sig=1.256;
                c_sig=-0.625;
                kb=1.381e-23; %Boltzmann constant
                Bi=1;Ba=1.602e-19*Bi;
                uw=uw0*exp(u1/R/(TT(MN)+133.3));
                sigma=B_sig*((Tc-(TT(MN)+273.15))/Tc)^e_sig*(1+c_sig*(Tc-(TT(MN)+273.15))/Tc);
                B(J)=2^0.5*pi()^2*RHOW0*GVA/uw*(e*e0/2/sigma)^1.5*(kb*(TT(MN)+273.15)/(Bi*Ba))^3;
                
                
                Coef_f=0.0373*(2*AGR(J))^3.109;
                Ks_flm(ML,ND)=B(J)*(1-POR(J))*(2*AGR(J))^0.5; %m2
                if hh(MN)<-1
                    Kr(ML,ND)=Coef_f*(1+2*AGR(J)*RHOW0*GVA*abs(hh(MN)/100)/2/sigma)^(-1.5);
                else
                    Kr(ML,ND)=1;
                end
                KL_h_flm(ML,ND)=Ks_flm(ML,ND)*Kr(ML,ND)*1e4; %m2 --> cm2
            else
                %%%%%%%%% see sutraset --> perfilm.f based on Lebeau and Konrad (2010)
                %  EFFECTIVE DIAMETER
                ASVL=-6e-20;
                GVA=9.8;
                PERMVAC=8.854e-12; %(VAC)CUM (PERM)EABILITY [PERMFS] [C2J-1M-1 OR F/M OR S4A2/KG/M3]
                ELECTRC=1.602e-19;
                BOTZC=1.381e-23;
                RHOW0=1000;
                PSICM=1000;
                SWM=0.1; %THE SATURATION WHEN SURFACE ROUGHNESS OF THE SOLID GRAIN BECOMES NEGNIGIBLE (-) IT IS EQUIVALENT TO
                %  		SATURATION BEEN 1000M FROM TULLER AND OR (2005)
                RELPW=78.54;
                %                 SWG=1;
                ED=6.0*(1-POR(J))*(-ASVL/(6.0*pi()*RHOW0*GVA*PSICM))^(1.0/3.0)/POR(J)/SWM;
                %  FILM THICKNESS (WARNING) THIS IS NOT THE FULL PART
                DEL=(RELPW*PERMVAC/(2*RHOW0*GVA))^0.50*(pi()*BOTZC*298.15/ELECTRC);
                Ks_flm(ML,ND)=CORF*4.0*(1-POR(J))*DEL^3.0/pi()/ED;

                if hh(MN)<=-1
                    Kr(ML,ND)=(1-Se(ML,ND))*abs(hh(MN)/100)^(-1.50);
                else
                    Kr(ML,ND)=1;
                end
                KL_h_flm(ML,ND)=Ks_flm(ML,ND)*Kr(ML,ND)*1e4; %m2 --> cm2
            end
            if KL_h_flm(ML,ND)<=0
                KL_h_flm(ML,ND)=0;
            elseif KL_h_flm(ML,ND)>=1e-6
                KL_h_flm(ML,ND)=1e-6;
            end
            if KL_h(ML,ND)<=1E-20
                KL_h(ML,ND)=1E-20;
            end
            if Ratio_ice(ML,ND)~=0 %Gama_hh(MN)~=1
                KfL_h(ML,ND)=KL_h(ML,ND)*10^(-1*Imped(MN)*Ratio_ice(ML,ND));%+KL_h_flm(ML,ND);  % hydraulic conductivity for freezing soil
%                                     KL_h(ML,ND)=KL_h(ML,ND)+KL_h_flm(ML,ND);
            else
                KfL_h(ML,ND)=KL_h(ML,ND);%*10^(-1*Imped(MN)*Ratio_ice(ML,ND));  % hydraulic conductivity for freezing soil
            end
                
            if isnan(KL_h(ML,ND))==1
                KL_h(ML,ND)=0;
                keyboard
            end
            if ~isreal(KL_h(ML,ND))
                keyboard
            end
            KfL_T(ML,ND)=0;%heaviside(TT_CRIT(MN)-(TT(MN)+T0))*L_f*1e4/(g*(T0));   % thermal consider for freezing soil
        else
            KL_h(ML,ND)=0;
            KfL_h(ML,ND)=0;
            KfL_T(ML,ND)=0;
        end
    end
end

%%%%%%%%% Unit of KL_h is determined by Ks, which would be given at the%%%%
%%%%%%%%% beginning.Import thing is to keep the unit of matric head hh(MN)
%%%%%%%%% as 'cm'.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%