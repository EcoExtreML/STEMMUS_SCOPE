function h_frez = updateHfreez(i)

    
    if T(i)<=0
        h_frez(i)=L_f*1e4*(T(i))/g/T0;
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
        if h_frez(i)<=h(i)-Phi_s(J)
            h_frez(i)=h(i)-Phi_s(J);
        else
            h_frez(i)=h_frez(i);
        end
    end

end