function [TT_CRIT,hh_frez]=HT_frez(hh,T0,g,L_f,TT,NN,hd)

    for MN=1:NN+1
        HHH(MN)=hh(MN);
        TT_CRIT(MN)=T0;
        if HHH(MN)>=-1e-6
            TT_CRIT(MN)=T0;
        elseif hh(MN)<=-10^(7)
                TT_CRIT(MN)=-inf;  % unit K
        else
            TT_CRIT(MN)=T0+g*T0*HHH(MN)/L_f/1e4/2;
        end
        if TT_CRIT(MN)<=T0-50
            TT_CRIT(MN)=T0-50;  % unit K
        elseif TT_CRIT(MN)>=T0
            TT_CRIT(MN)=T0;
        else
            TT_CRIT(MN)=TT_CRIT(MN);
        end
        if heaviside(TT_CRIT(MN)-(TT(MN)+T0))>0 
            if TT(MN)<-60
                hh_frez(MN,1)=0;
            else
                hh_frez(MN,1)=L_f*1e4*((TT(MN)+T0)-TT_CRIT(MN))/g/T0;
            end
        else
            hh_frez(MN,1)=0;
        end
        if HHH(MN)<=hd
            hh_frez(MN,1)=0;   
        end
        if hh_frez(MN,1)>=-1e-6
            hh_frez(MN,1)=0;
        elseif hh_frez(MN,1)<=-1e6
            hh_frez(MN,1)=-1e6;
        end
    end