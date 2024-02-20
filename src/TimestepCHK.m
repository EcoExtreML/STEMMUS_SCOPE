function TimestepCHK
global NBCh BCh NBChh
global DSTOR DSTOR0 EXCESS QMT Precip Evap
global hh KT TIME Delt_t tS IRPT1 IRPT2 NN

if NBCh==1
    CnvrgnCHK
elseif NBCh==3
    if NBChh==2           %------------------------> NBCh is equal to 3. Which type of BC was used on last time step?
        if hh(NN)<= DSTOR %------------------------> NBChh is equal to 2. Check that calculated surface matric head is not unrealistic. 
            CnvrgnCHK                              % If it is not, proceed to check the convergence condition.If it is, switch over to NBChh=1.
        else
            NBChh=1;
            if IRPT1==1   %------------------------> Since IRPT1=1, we know that simply switching the value of NBChh and re-running the time step
                IRPT1=0;IRPT2=1;                  % will not work, since both values of NBChh have been tried. We therefore decrease the length of
                KT=KT-1;TIME=TIME-Delt_t;         % the time step. If the step is sufficiently small, we can always find a value of NBChh that gives
                Delt_t=Delt_t*0.25;                % consistent results.
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
        CnvrgnCHK

    else 
        if DSTOR0 <= 1e-8 || (-QMT-Precip(KT)+Evap(KT))<=0 
           NBChh=2;                               
           if IRPT1==1
               IRPT1=0;IRPT2=1;
               KT=KT-1;TIME=TIME-Delt_t;
               Delt_t=Delt_t*0.25;
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
            CnvrgnCHK                              % does not, proceed to find the new Delt_t. If it does, then repeat the time step with NBChh equal to 1.
        else
            NBChh=1;
            if IRPT1==1
                IRPT1=0; IRPT2=1;
                KT=KT-1; TIME=TIME-Delt_t;
                Delt_t=Delt_T*0.25;
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
            CnvrgnCHK                                  % (saturation or dryness) was applied. Check to be sure that the resulting flux did not exceed the potential value 
                                                       % in magnitude. If it did not, proceed to find new Delt_T. If it did, repeat the step with NBChh equal to 2;
        else
            NBChh=2;
            if IRPT1==1
                IRPT1=0; IRPT2=1;
                KT=KT-1; TIME=TIME-Delt_t;
                Delt_t=Delt_t*0.25;
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



