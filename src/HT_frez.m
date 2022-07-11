function [TT_CRIT,hh_frez]=HT_frez(hh,T0,g,L_f,TT,NN,hd,Tmin)

                for MN=1:NN
                    HHH(MN)=hh(MN);
                    TT_CRIT(MN)=T0;
                    if HHH(MN)>=-1e-6
                        TT_CRIT(MN)=T0;
                    else
                        TT_CRIT(MN)=T0+g*T0*HHH(MN)/L_f/1e4/2;
                    end
                    if Tmin>0
                        TTmin=0;
                    else
                        TTmin=Tmin;
                    end
                    if TT_CRIT(MN)<=T0+TTmin
                        TT_CRIT(MN)=T0+TTmin;  % unit K
                    elseif TT_CRIT(MN)>=T0
                        TT_CRIT(MN)=T0;
                    else
                        TT_CRIT(MN)=TT_CRIT(MN);
                    end
                    if helpers.heaviside1(TT_CRIT(MN)-(TT(MN)+T0))>0 
                        hh_frez(MN)=L_f*1e4*((TT(MN)+T0)-TT_CRIT(MN))/g/T0;
                    else
                        hh_frez(MN)=0;
                    end
                    if HHH(MN)<=hd
                        hh_frez(MN)=0;   
                    end
                    if hh_frez(MN)>=-1e-6
                        hh_frez(MN)=0;
                    elseif hh_frez(MN)<=-1e6
                        hh_frez(MN)=-1e6;
                    end
                end
