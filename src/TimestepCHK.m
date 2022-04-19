function [KT,TIME,Delt_t,tS,NBChh,IRPT1,IRPT2]=TimestepCHK(NBCh,BCh,NBChh,DSTOR,DSTOR0,EXCESS,QMT,Precip,Evap,hh,IRPT1,NN,SAVEhh,TT_CRIT,T0,TT,T,EPCT,h,T_CRIT,xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,KT,TIME,Delt_t,NL,Thmrlefc,NBChB,NBCT,NBCTB,tS,uERR)

    if Delt_t<1.0e-10
        %%keyboard
        fprintf('\n Warning: FIX_ME: replace keyboard \r')
    end
% testing this function %%%
if NBCh==1
%     CnvrgnCHK
    [KT,TIME,Delt_t,IRPT1,IRPT2,tS]=CnvrgnCHK(xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR);
elseif NBCh==3
    if NBChh==2           %------------------------> NBCh is equal to 3. Which type of BC was used on last time step?
        if SAVEhh(NN)<= DSTOR %hh(NN)------------------------> NBChh is equal to 2. Check that calculated surface matric head is not unrealistic. 
%             CnvrgnCHK                              % If it is not, proceed to check the convergence condition.If it is, switch over to NBChh=1.
    [KT,TIME,Delt_t,IRPT1,IRPT2,tS]=CnvrgnCHK(xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR);
        else
            NBChh=1;
            if IRPT1==1   %------------------------> Since IRPT1=1, we know that simply switching the value of NBChh and re-running the time step
                IRPT1=0;IRPT2=1;                  % will not work, since both values of NBChh have been tried. We therefore decrease the length of
                KT=KT-1;TIME=TIME-Delt_t;         % the time step. If the step is sufficiently small, we can always find a value of NBChh that gives
                Delt_t=Delt_t*0.25;                %*0.25 consistent results.
                tS=tS+1;  %-----------------------> tS has passed one, then, whenever it is necessary to repeat a time step, tS should be plused one  
                return                             % to keep consistant with the number of records of meteorological forcing data.
            else          %-----------------------> Control is transfered here whenever it is found necessary to switch the value of NBChh as a                               
                IRPT1=1;IRPT2=0;                  % result of inconsistencies between actual and assumed surface BC on moisture. As long as the
                KT=KT-1;
                TIME=TIME-Delt_t;
                tS=tS+1;
                return                             % current value of IRPT1 is 0, this is the first time the switch has been made this time step
                                                   % with this value of Delt_t. In that case, IRPT1 is set equal to 1 to indicate that a switch is
            end                                    % being made, and control returns to the main program in order to repeat the time step. IRPT2=0 
        end                                        % means that Delt_t has not been decreased.
    elseif EXCESS>=0      %-----------------------> NBChh is equal to 1. As long as a non-negative value for EXCESS was found, the result is OK. 
%         CnvrgnCHK
        [KT,TIME,Delt_t,IRPT1,IRPT2,tS]=CnvrgnCHK(xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR);
    else 
        if DSTOR0 <= 1e-8 || (-QMT-Precip(KT)+Evap(KT))<=0 
           NBChh=2;                               
           if IRPT1==1
               IRPT1=0;IRPT2=1;
               KT=KT-1;TIME=TIME-Delt_t;
               Delt_t=Delt_t*0.25;%
               tS=tS+1;
               return
           else 
               IRPT1=1;IRPT2=0; 
               KT=KT-1;
               TIME=TIME-Delt_t;
               tS=tS+1;
               return
           end
        else           %-----------------------> Two situations are considered when excess comes out negative. If there was depression storage at
            IRPT1=0;IRPT2=1;                  % the start of the step and the infiltration rate was greater than the effective precipitation rate,
            KT=KT-1;TIME=TIME-Delt_t;         % then the time step is decreased so as to make the depression storage just disappear at the end of the step.
            Delt_t=DSTOR0/(-QMT-Precip(KT)+Evap(KT));
            tS=tS+1;
            return
        end
    end 
else
    if NBChh==2        %-----------------------> NBChh is equal to 2. This means that the soil was thought to be capable of supporting the sepcified flux,
        if hh(NN)>=-1e6 && hh(NN)<=DSTOR            % BCh. Check to be sure that the resulting matric head does not have a physically unrealistic value. If it
%             CnvrgnCHK                              % does not, proceed to find the new Delt_t. If it does, then repeat the time step with NBChh equal to 1.
            [KT,TIME,Delt_t,IRPT1,IRPT2,tS]=CnvrgnCHK(xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR);
        else
            NBChh=1;
            if IRPT1==1
                IRPT1=0; IRPT2=1;
                KT=KT-1; TIME=TIME-Delt_t;
                Delt_t=Delt_t*0.25;%
                tS=tS+1;
                return
            else
                IRPT1=1; IRPT2=0;
                KT=KT-1;
                TIME=TIME-Delt_t;
                tS=tS+1;
                return
            end
        end
    else 
        if abs(QMT)<=abs(BCh)  %-------------------> NBChh is equal to 1. This means that the potential flux was thought to be excessive, and a specified head
%             CnvrgnCHK                                  % (saturation or dryness) was applied. Check to be sure that the resulting flux did not exceed the potential value 
                                                       % in magnitude. If it did not, proceed to find new Delt_T. If it did, repeat the step with NBChh equal to 2;
        [KT,TIME,Delt_t,IRPT1,IRPT2,tS]=CnvrgnCHK(xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR);
        else
            NBChh=2;
            if IRPT1==1
                IRPT1=0; IRPT2=1;
                KT=KT-1; TIME=TIME-Delt_t;
                Delt_t=Delt_t*0.25;%
                tS=tS+1;
                return
            else
                IRPT1=1; IRPT2=0;
                KT=KT-1;
                TIME=TIME-Delt_t;
                tS=tS+1;
                return
            end
        end
    end    
end
% end

end