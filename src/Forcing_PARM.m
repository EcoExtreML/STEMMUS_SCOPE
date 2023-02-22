function Forcing_PARM
    global Umax Umin tmax1 DayNum Hrmax Hrmin Tmax Tmin Um Ur DURTN Tsmax Tsmin
    global Pg_w Pg_a0 Pg_a Pg_b Rn TIMEOLD DELT
    global Ta Ts U HR_a SH Rns Rnl TIME KT P_Va RHOV_A Rv TopPg h_SUR  Hsur_w Hsur_a0 Hsur_a Hsur_b NBCT
    global Ts_a0 Ts_a Ts_w Ts_b Ts_msr Tbtm Tb_msr Ta_msr RH_msr Rn_msr WS_msr G_msr Pg_msr G_SOIL HourInput Rns_msr SH_msr LET LE_msr SUMTIME NoTime Precip Precip_msr LAI_msr Gvc Tss Tsss

    if TIMEOLD == KT
        Ta(KT) = 0;
        HR_a(KT) = 0;
        Ts(KT) = 0;
        U(KT) = 0;
        SH(KT) = 0;
        Rns(KT) = 0;
        Rnl(KT) = 0;
        Rn(KT) = 0;
        TopPg(KT) = 0;
        h_SUR(KT) = 0;
    end
    if NBCT == 1 && KT == 1
        Ts(1) = 0;
    end
    HourInput = 1; % DELT=3600;
    WS_msr(WS_msr < 0.05) = 0.05;
    Ta(KT) = Ta_msr(KT);
    HR_a(KT) = 0.01 .* (RH_msr(KT));
    U(KT) = 100 .* (WS_msr(KT));
    Rns(KT) = (Rns_msr(KT)) * 8.64 / 24 / 100 * 1;
    TopPg(KT) = 100 .* (Pg_msr(KT));
    Ts(KT) = Tss;
    Rn(KT) = (Rn_msr(KT)) * 8.64 / 24 / 100 * 1;
    Precip(KT) = Precip_msr(KT) * 0.1 / DELT;
    Gvc(KT) = LAI_msr(KT);

    P_Va(KT) = 0.611 * exp(17.27 * Ta(KT) / (Ta(KT) + 237.3)) * HR_a(KT);  % The atmospheric vapor pressure (KPa)  (1000Pa=1000.1000.g.100^-1.cm^-1.s^-2)

    RHOV_A(KT) = P_Va(KT) * 1e4 / (Rv * (Ta(KT) + 273.15));
