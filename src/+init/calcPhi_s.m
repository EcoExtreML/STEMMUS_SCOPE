function Phi_s = calcPhi_s(VPER, POR, Phi_soc, XSOC)

    Phi_s = -0.01 * 10 ^ (1.88 - 0.0131 * VPER / (1 - POR) * 100);
    Phi_s = (Phi_s * (1 - XSOC) + XSOC * Phi_soc) * 100;

end