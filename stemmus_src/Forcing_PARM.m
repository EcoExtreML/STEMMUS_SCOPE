
if TIMEOLD==KT
    Ta(KT)=0;HR_a(KT)=0;Ts(KT)=0;U(KT)=0;SH(KT)=0;Rns(KT)=0;Rnl(KT)=0;Rn(KT)=0;TopPg(KT)=0;h_SUR(KT)=0;
end
if NBCT==1 && KT==1
    Ts(1)=0;
end

DELT=86400;
NoTime(KT)=fix(SUMTIME(KT)/DELT);%WS_msr(WS_msr<0.05)=0.05;
if NoTime(KT)<=1
    EVAP_PT(KT)=EVAP_msr(1);
elseif NoTime(KT)>=length(EVAP_msr)
    EVAP_PT(KT)=EVAP_msr(end);
else
    EVAP_PT(KT)=EVAP_msr(NoTime(KT))+(EVAP_msr(NoTime(KT)+1)-EVAP_msr(NoTime(KT)))/DELT*(SUMTIME(KT)-NoTime(KT)*DELT);
end
TRAP_PT(KT)=TRAP_msr;

DELT1=86400;
NoTime1(KT)=fix(SUMTIME(KT)/DELT1);%WS_msr(WS_msr<0.05)=0.05;
    Ts(KT)=Ts_msr(1);
