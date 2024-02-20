function Forcing_PARM
global Ta_f Ta_a0 Ta_a Ta_b Ua_f Ua_a0 Ua_a Ua_b HRa_f HRa_a0 HRa_a HRa_b
global Ts_f Ts_a0 Ts_a Ts_b 
global Pg_f Pg_a0 Pg_a Pg_b Rn TIMEOLD
global Ta Ts U HR_a SH Rns Rnl TIME KT P_Va RHOV_A Rv TopPg h_SUR  Hsur_f Hsur_a0 Hsur_a Hsur_b NBCT

    if TIMEOLD==KT 
        Ta(KT)=0;HR_a(KT)=0;Ts(KT)=0;U(KT)=0;SH(KT)=0;Rns(KT)=0;Rnl(KT)=0;Rn(KT)=0;TopPg(KT)=0;h_SUR(KT)=0;
    end
    if NBCT==1 && KT==1
        Ts(1)=0;
    end
        
    for i=1:9
        Ta(KT)=Ta(KT)+Ta_a(i)*cos(2*pi()*Ta_f(i)*TIME/1800)+Ta_b(i)*sin(2*pi()*Ta_f(i)*TIME/1800);
    end
    Ta(KT)=Ta(KT)+Ta_a0;

    for i=1:7
        HR_a(KT)=HR_a(KT)+HRa_a(i)*cos(2*pi()*HRa_f(i)*TIME/1800)+HRa_b(i)*sin(2*pi()*HRa_f(i)*TIME/1800);
    end
    HR_a(KT)=(HR_a(KT)+HRa_a0)*0.01; 

    for i=1:10
        Ts(KT)=Ts(KT)+Ts_a(i)*cos(2*pi()*Ts_f(i)*TIME/1800)+Ts_b(i)*sin(2*pi()*Ts_f(i)*TIME/1800);
    end
    Ts(KT)=Ts(KT)+Ts_a0;

    for i=1:17
        U(KT)=U(KT)+Ua_a(i)*cos(2*pi()*Ua_f(i)*TIME/1800)+Ua_b(i)*sin(2*pi()*Ua_f(i)*TIME/1800);
    end
    U(KT)=(U(KT)+Ua_a0)*100;

    for i=1:13
        TopPg(KT)=TopPg(KT)+Pg_a(i)*cos(2*pi()*Pg_f(i)*TIME/1800)+Pg_b(i)*sin(2*pi()*Pg_f(i)*TIME/1800);
    end
    TopPg(KT)=(TopPg(KT)+Pg_a0)*10;   
    
    for i=1:7
        h_SUR(KT)=h_SUR(KT)+Hsur_a(i)*cos(2*pi()*Hsur_f(i)*TIME/1800)+Hsur_b(i)*sin(2*pi()*Hsur_f(i)*TIME/1800);
    end
    h_SUR(KT)=h_SUR(KT)+Hsur_a0;      
    
    P_Va(KT)=0.611*exp(17.27*Ta(KT)/(Ta(KT)+237.3))*HR_a(KT);  %The atmospheric vapor pressure (KPa)  (1000Pa=1000.1000.g.100^-1.cm^-1.s^-2)

    RHOV_A(KT)=P_Va(KT)*1e4/(Rv*(Ta(KT)+273.15)); 
