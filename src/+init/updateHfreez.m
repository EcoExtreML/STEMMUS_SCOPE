function h_frez = updateHfreez(i, SoilVariables, SoilConstants)
    global Phi_s % this is due to a bug
    L_f=3.34*1e5; %latent heat of freezing fusion J Kg-1
    T0=273.15; % unit K

    T = SoilVariables.T;
    h_frez = SoilVariables.h_frez;
    h = SoilVariables.h;

    SWCC = SoilConstants.SWCC;

    if T(i)<=0
        h_frez(i)=L_f*1e4*(T(i))/SoilConstants.g/T0;
    else
        h_frez(i)=0;
    end
    if SWCC==1
        if h_frez(i)<=h(i)+1e-6
            h_frez(i)=h(i)+1e-6;
        else
            h_frez(i)=h_frez(i);
        end
    else
        if h_frez(i)<=h(i)-Phi_s(SoilConstants.J)
            h_frez(i)=h(i)-Phi_s(SoilConstants.J);
        else
            h_frez(i)=h_frez(i);
        end
    end

end