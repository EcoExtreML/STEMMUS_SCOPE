%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunction  Root_Fraction        %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[RfH_Zs,RfL_Zs]=Root_Fraction_General(Zs,CASE_ROOT,ZR95_H,ZR50_H,ZR95_L,ZR50_L,ZRmax_H,ZRmax_L)
%%% OUTPUT
%%% ---> Root Distribution ZR_H -ZR_L ---  Root Fraction in a given soil layer
%RfH_Zs, [%] Root Fraction for High Vegetation [1...m]
%RfL_Zs  [%] Root Fraction for Low  Vegetation [1...m]

%%%% INPUT
%ZR95_H, Root Depth (95 percentile) High Vegetation [mm]
%ZR95_L, Root Depth (95 percentile) Low Vegetation [mm]
%ZR50_H, Root Depth (95 percentile) High Vegetation [mm]
%ZR50_L, Root Depth (95 percentile) Low Vegetation [mm]
%Zs, [mm] Depth Layers [1....m]
%CASE_ROOT [#]  Type of desired root profile
%%%%%%%%%%%%%%%%%%%%%%
n=length(Zs)-1;
cc=length(ZR95_H);
RfH_Zs= zeros(cc,n); RfL_Zs= zeros(cc,n);
%%%%%%%%%%%%%%%%%%%%%%
for j=1:cc
    if ZR95_H(j) > Zs(n+1) || ZR95_L(j) > Zs(n+1) || ZRmax_H(j) > Zs(n+1) || ZRmax_L(j) > Zs(n+1)
        disp('ERROR: LAST LAYER TOO SHALLOW FOR ACCOMODATING ROOTS')
        return
    end
end
switch CASE_ROOT
    case 1 %%%% Exponential Profile
        %%%%%%%%%%%%%%%%%%%%%% Arora and Boer 2005
        eta_H=3./ZR95_H; %%[1/mm]  Shape of Root Distribution
        eta_L=3./ZR95_L; %%[1/mm]
        %%%%%%%%%%%%%%%%%%%%%
        for j=1:cc
            i=1;
            if not(ZR95_H(j)==0)
                while i <= n
                    if ZR95_H(j) > Zs(i+1)
                        RfH_Zs(j,i) = exp(-eta_H(j)*Zs(i)) - exp(-eta_H(j)*Zs(i+1));
                    else
                        RfH_Zs(j,i) = exp(-eta_H(j)*Zs(i)) - exp(-eta_H(j)*ZR95_H(j));
                        i=n;
                    end
                    i=i+1;
                end
            end
            %%%%%%%%%%
            i=1;
            if not(ZR95_L(j)==0)
                while i <= n
                    if ZR95_L(j) > Zs(i+1)
                        RfL_Zs(j,i) = exp(-eta_L(j)*Zs(i)) - exp(-eta_L(j)*Zs(i+1));
                    else
                        RfL_Zs(j,i) = exp(-eta_L(j)*Zs(i)) - exp(-eta_L(j)*ZR95_L(j));
                        i=n;
                    end
                    i=i+1;
                end
            end
            %%%%%%% Water Content for the Root
            Rto1 = 0.9502;
            %%%%%%%%% Root Proportion in the Layer
            RfH_Zs(j,:)=RfH_Zs(j,:)/Rto1; RfL_Zs(j,:)= RfL_Zs(j,:)/Rto1;
            %%%%%%%%%%%%%%%
        end
    case 2 %%%%% Linear Dose Response
        %%% Schenk and Jackson 2002, Collins and Bras 2007
        c_H = 2.94./log(ZR50_H./ZR95_H);
        c_L = 2.94./log(ZR50_L./ZR95_L);
        %%%%%%%%%%%%%%%%%%%%%
        for j=1:cc
            i=1;
            if not(ZR95_H(j)==0)
                while i <= n
                    if ZR95_H(j) > Zs(i+1)
                        RfH_Zs(j,i) =  1./(1 + (Zs(i+1)/ZR50_H(j)).^c_H(j) ) -  1./(1 + (Zs(i)/ZR50_H(j)).^c_H(j) ) ;
                    else
                        RfH_Zs(j,i) =  1./(1 + (ZR95_H(j)/ZR50_H(j)).^c_H(j) ) -  1./(1 + (Zs(i)/ZR50_H(j)).^c_H(j) ) ;
                        i=n;
                    end
                    i=i+1;
                end
            end
            i=1;
            if not(ZR95_L(j)==0)
                while i <= n
                    if ZR95_L(j) > Zs(i+1)
                        RfL_Zs(j,i) =  1./(1 + (Zs(i+1)/ZR50_L(j)).^c_L(j) ) -  1./(1 + (Zs(i)/ZR50_L(j)).^c_L(j) ) ;
                    else
                        RfL_Zs(j,i) =  1./(1 + (ZR95_L(j)/ZR50_L(j)).^c_L(j) ) -  1./(1 + (Zs(i)/ZR50_L(j)).^c_L(j) ) ;
                        i=n;
                    end
                    i=i+1;
                end
            end
        end
        Rto1 = 0.9498;
        %%%%%%%%% Root Proportion in the Layer
        RfH_Zs(j,:)=RfH_Zs(j,:)/Rto1; RfL_Zs(j,:)= RfL_Zs(j,:)/Rto1;
    case 3 %%% Constant Profile
        for j=1:cc
            i=1;
            if not(ZR95_H(j)==0)
                while i <= n
                    if ZR95_H(j) > Zs(i+1)
                        RfH_Zs(j,i) = (Zs(i+1)-Zs(i))/ZR95_H(j) ;
                    else
                        RfH_Zs(j,i) = (ZR95_H(j)-Zs(i))/ZR95_H(j);
                        i=n;
                    end
                    i=i+1;
                end
            end
            i=1;
            if not(ZR95_L(j)==0)
                while i <= n
                    if ZR95_L(j) > Zs(i+1)
                        RfL_Zs(j,i) = (Zs(i+1)-Zs(i))/ZR95_L(j) ;
                    else
                        RfL_Zs(j,i) = (ZR95_L(j)-Zs(i))/ZR95_L(j);
                        i=n;
                    end
                    i=i+1;
                end
            end
        end
    case 4  %%% Deep (Tap) Root Profile
        c_H = 2.94./log(ZR50_H./ZR95_H);
        c_L = 2.94./log(ZR50_L./ZR95_L);
        for j=1:cc
            i=1;
            if not(ZR95_H(j)==0)
                while i <= n
                    if ZR95_H(j) > Zs(i+1)
                        RfH_Zs(j,i) =  1./(1 + (Zs(i+1)/ZR50_H(j)).^c_H(j) ) -  1./(1 + (Zs(i)/ZR50_H(j)).^c_H(j) ) ;
                    elseif ZR95_H(j) <= Zs(i+1) && ZR95_H(j) > Zs(i)
                        RfH_Zs(j,i) =  1./(1 + (ZR95_H(j)/ZR50_H(j)).^c_H(j) ) -  1./(1 + (Zs(i)/ZR50_H(j)).^c_H(j) ) ;
                        if ZRmax_H(j) <= Zs(i+1)
                            RfH_Zs(j,i) =  RfH_Zs(j,i) +  0.0502*(ZRmax_H(j)-ZR95_H(j))/(ZRmax_H(j)-ZR95_H(j));
                            i=n;
                        else
                            RfH_Zs(j,i) =  RfH_Zs(j,i) +  0.0502*(Zs(i+1)-ZR95_H(j))/(ZRmax_H(j)-ZR95_H(j));
                        end
                    elseif ZRmax_H(j) > Zs(i+1)
                        RfH_Zs(j,i) = 0.0502*(Zs(i+1)-Zs(i))/(ZRmax_H(j)-ZR95_H(j));
                    else
                        RfH_Zs(j,i) = 0.0502*(ZRmax_H(j)-Zs(i))/(ZRmax_H(j)-ZR95_H(j));
                        i=n;
                    end
                    i=i+1;
                end
            end
            i=1;
            if not(ZR95_L(j)==0)
                while i <= n
                    if ZR95_L(j) > Zs(i+1)
                        RfL_Zs(j,i) =  1./(1 + (Zs(i+1)/ZR50_L(j)).^c_L(j) ) -  1./(1 + (Zs(i)/ZR50_L(j)).^c_L(j) ) ;
                    elseif ZR95_L(j) <= Zs(i+1) && ZR95_L(j) > Zs(i)
                        RfL_Zs(j,i) =  1./(1 + (ZR95_L(j)/ZR50_L(j)).^c_L(j) ) -  1./(1 + (Zs(i)/ZR50_L(j)).^c_L(j) ) ;
                        if ZRmax_L(j) <= Zs(i+1)
                            RfL_Zs(j,i) =  RfL_Zs(j,i) +  0.0502*(ZRmax_L(j)-ZR95_L(j))/(ZRmax_L(j)-ZR95_L(j));
                            i=n;
                        else
                            RfL_Zs(j,i) =  RfL_Zs(j,i) +  0.0502*(Zs(i+1)-ZR95_L(j))/(ZRmax_L(j)-ZR95_L(j));
                        end
                    elseif ZRmax_L(j) > Zs(i+1)
                        RfL_Zs(j,i) = 0.0502*(Zs(i+1)-Zs(i))/(ZRmax_L(j)-ZR95_L(j));
                    else
                        RfL_Zs(j,i) = 0.0502*(ZRmax_L(j)-Zs(i))/(ZRmax_L(j)-ZR95_L(j));
                        i=n;
                    end
                    i=i+1;
                end
            end  
        end 
end
%%%%%%%%%%% Cleaning 
%for j=1:cc
%    if not(ZR95_H(j)==0)
%        Rto1 =sum(RfH_Zs(j,:));
%        RfH_Zs(j,:)=RfH_Zs(j,:)/Rto1;
%    end
%    if not(ZR95_L(j)==0)
%        Rto1 =sum(RfL_Zs(j,:));
%        RfL_Zs(j,:)= RfL_Zs(j,:)/Rto1;
%    end
%end
return


