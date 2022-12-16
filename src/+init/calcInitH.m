function initH = calcInitH(Theta_s, Theta_r, initX, nParameter, mParameter, alphaParameter)
    initH = -(((Theta_s-Theta_r)/(initX-Theta_r))^(1/mParameter)-1)^(1/nParameter)/alphaParameter;
end