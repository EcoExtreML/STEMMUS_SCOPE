function fraction = calc_msoc_fraction(MSOC)
    %{
        Retun volumetric fraction of soil organic carbon using mass fraction of
        soil organic carbon (MSOC). Density of organic matter is 1300 kg m-3,
        and the particle density of mineral material is 2700 kg m-3.
    %}

    fraction = MSOC.*2700./((MSOC.*2700)+(1-MSOC).*1300);
end