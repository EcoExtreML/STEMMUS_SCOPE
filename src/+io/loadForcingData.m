function [ForcingData] = loadForcingData(InputPath, TimeProperties, fmax, Tot_Depth)
    %{
    %}
    DELT = TimeProperties.DELT;
    Dur_tot = TimeProperties.Dur_tot;

    fID = fopen([InputPath, 'Mdata.txt']);
    Mdata = textscan(fID, "");
    fclose(fID);

    ForcingData.Ta_msr = Mdata{:, 2};
    ForcingData.RH_msr = Mdata{:, 3};
    ForcingData.WS_msr = Mdata{:, 4};
    ForcingData.Pg_msr = Mdata{:, 5};
    ForcingData.Rn_msr = Mdata{:, 7};
    ForcingData.Rns_msr = Mdata{:, 7};
    ForcingData.VPD_msr = Mdata{:, 9};
    ForcingData.LAI_msr = Mdata{:, 10};
    ForcingData.G_msr = Mdata{:, 7} * 0.15;
    ForcingData.Precip_msr = Mdata{:, 6} * 10 * DELT;
    ForcingData.Precip_msr = Precip_msr .* (1 - fmax .* exp(-0.5 * 0.5 * Tot_Depth / 100));
    % replace negative values
    for jj = 1:Dur_tot
        if ForcingData.Ta_msr(jj) < -100
            ForcingData.Ta_msr(jj) = NaN;
        end
    end
    ForcingData.Tmin = min(ForcingData.Ta_msr);
end
