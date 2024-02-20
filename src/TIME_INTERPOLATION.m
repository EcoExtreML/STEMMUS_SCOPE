function [HPILLAR,IBOT]=TIME_INTERPOLATION(T1,T0,IP,BOT,HPILLAR1N,HPILLAR0,T,DELT,X,NUMNP,Q3DF,ADAPTF)
%       % PREDICTING THE LOWER BOUNDARY OF THE SOIL COLUMNS
%       USE Q3DMODULE,ONLY:DELT0,IBOT,BOT,Q3DF,ADAPTF
%       USE HYDRUS,ONLY:T,NUMNP,HPILLAR00,HPILLAR0,HPILLAR1N,HPILLAR,X
%       USE GWFBASMODULE,ONLY:DELT
%
%       A=zeros(NUMNP,1);B=zeros(NUMNP,1);C=zeros(NUMNP,1);
%       REAL T1,T0
%       DOUBLEPRECISION XTABLE,XMID
%
% global Q3DF ADAPTF
IBOT=[];
if(Q3DF)
    %if(T0<=0)
    
    HPILLAR=HPILLAR0+(HPILLAR1N-HPILLAR0)*(T-T0)/DELT;
    if HPILLAR>max(HPILLAR1N,HPILLAR0)
        HPILLAR=max(HPILLAR1N,HPILLAR0);
    elseif HPILLAR<min(HPILLAR1N,HPILLAR0)
        HPILLAR=min(HPILLAR1N,HPILLAR0);
    end
    %        elseif(T0>0) %SECOND ORDER INTERPOLATION
    %         A=((HPILLAR1N-HPILLAR0)/DELT-(HPILLAR0-HPILLAR00)/DELT0)
    %       1  /(DELT+DELT0)
    %         B=(HPILLAR0-HPILLAR00)/DELT0
    %         C=HPILLAR1N-A*T1*T1-B*T1
    %         HPILLAR=A*T*T+B*T+C
    %        end
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
                break;%exit
            elseif(XTABLE>=X(I+1))
                continue%CYCLE
            end
            disp('NO TABLE FOUND FOR MOVING LOWER BOUNDARY')
        end
        if isempty(IBOT)
              
            IBOT=NUMNP;
        else
            IBOT=IBOT+3;
        end
    else
        IBOT=NUMNP;
    end
else
    IBOT=NUMNP;
    return
end
%         if isempty(IBOT(IP))
%             IBOT(IP)=NUMNP;
%         end
    return
end