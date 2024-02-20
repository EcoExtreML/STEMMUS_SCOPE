function EfeCapCond
global HCAP TCON SF TCA GA1 GA2 GB1 GB2 HCD TARG GRAT
global ZETA0 CON0 PS1 PS2 ETCON EHCAP ZETA XWILT XK XXX TT
global MN ML NL ND IS J POR Theta_LL DRHOVT L D_A RHOV Theta_V

MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        J=IS(ML);
        XXX=Theta_LL(ML,ND);
        if Theta_LL(ML,ND) < XK(J)
            XXX=XK(J);
        end

        if XXX < XWILT(J)
            SF(2)=GA2+GB2(J)*XXX;
        else
            SF(2)=GA1+GB1(J)*XXX;
        end
        D_A(MN)=0.229*(1+TT(MN)/273)^1.75;
        TCON(2)=TCA+D_A(MN)*L(MN)*DRHOVT(MN); %TCA+D_A(MN)*L(MN)*DRHOVT(MN); % Revised from ""(D_V(ML,ND)*Eta(ML,ND)+D_Vg(ML))*L(MN)*DRHOVT(MN)
        
        TARG=TCON(2)/TCON(1)-1;
        GRAT=0.667/(1+TARG*SF(2))+0.333/(1+TARG*(1-2*SF(2)));
        ETCON(ML,ND)=(PS1(J)+XXX*TCON(1)+(POR(J)-XXX)*GRAT*TCON(2))/(PS2(J)+XXX+(POR(J)-XXX)*GRAT);
        ZETA(ML,ND)=GRAT/(GRAT*(POR(J)-XXX)+XXX+PS2(J));
        
        if Theta_LL(ML,ND)==XXX
            EHCAP(ML,ND)=HCD(J)+HCAP(1)*Theta_LL(ML,ND);
            EHCAP(ML,ND)=EHCAP(ML,ND)+(0.448*RHOV(MN)*4.182+HCAP(2))*Theta_V(ML,ND); % The Calorie should be converted as J
        else
            ZETA(ML,ND)=ZETA0(J)+(ZETA(ML,ND)-ZETA0(J))*Theta_LL(ML,ND)/XXX;
            ETCON(ML,ND)=CON0(J)+(ETCON(ML,ND)-CON0(J))*Theta_LL(ML,ND)/XXX;
            EHCAP(ML,ND)=HCD(J)+HCAP(1)*Theta_LL(ML,ND);
            EHCAP(ML,ND)=EHCAP(ML,ND)+(0.448*RHOV(MN)*4.182+HCAP(2))*Theta_V(ML,ND); % The Calorie should be converted as J
        end        
    end
end
        
        
        
        
        
        
        