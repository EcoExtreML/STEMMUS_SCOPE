function [HPILLAR,IBOT]=TIME_INTERPOLATION(T1,T0,IP,BOT,HPILLAR1N,HPILLAR0,T,DELT,X,NUMNP,Q3DF,ADAPTF)
% find the bottom layer of soil column
IBOT=[];
if(Q3DF)
    HPILLAR=HPILLAR0+(HPILLAR1N-HPILLAR0)*(T-T0)/DELT;
    if HPILLAR>max(HPILLAR1N,HPILLAR0)
        HPILLAR=max(HPILLAR1N,HPILLAR0);
    elseif HPILLAR<min(HPILLAR1N,HPILLAR0)
        HPILLAR=min(HPILLAR1N,HPILLAR0);
    end
    if(ADAPTF)
        XTABLE=BOT(1,IP)-HPILLAR;
        for I=1:NUMNP-1
            XMID=(X(I)+X(I+1))/2;
            
            if(XTABLE>=X(I) && XTABLE<X(I+1))
                if(XTABLE<XMID)
                    IBOT=I;%(IP)
                elseif(XTABLE>=XMID)
                    IBOT=I+1;
                end
                break;
            elseif(XTABLE>=X(I+1))
                continue
            end
            disp('NO TABLE FOUND FOR MOVING LOWER BOUNDARY')
        end
        if isempty(IBOT)
              
            IBOT=NUMNP;
        else
            IBOT=IBOT+3;
        end
        IBOT=min(IBOT,NUMNP);
    else
        IBOT=NUMNP;
    end
else
    IBOT=NUMNP;
    return
end
end