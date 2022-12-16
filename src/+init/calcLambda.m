function calcLambda(VPER, POR, Lamda_soc, XSOC)

    Lamda = (2.91 + 0.159 * VPER / (1 - POR) *100);
    Lamda = 1 / (Lamda * (1 - XSOC) + XSOC * Lamda_soc);    
end