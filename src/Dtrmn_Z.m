function [DeltZ, DeltZ_R, NL, ML] = Dtrmn_Z(NL, Tot_Depth)
    %{
        The determination of the element length
    %}
    Elmn_Lnth = 0;
    sitename = 'CH-HTC';
    if strcmp(sitename,'CH-HTC')
        for ML=1:6
            DeltZ_R(ML)=1;%4
        end
    %         DeltZ_R(6)=1;%4
        for ML=7:13
            DeltZ_R(ML)=2;%5
        end
        for ML=14:21
            DeltZ_R(ML)=2.5;%5
        end
        for ML=22:25
            DeltZ_R(ML)=5;
        end
        for ML=26:29
            DeltZ_R(ML)=10;
        end
        NL= ML;
        for ML=1:NL
            MML=NL-ML+1;
            DeltZ(ML)=DeltZ_R(MML);
        end
    else
        for ML = 1:3
            DeltZ_R(ML) = 1; % 4
        end
        DeltZ_R(4) = 2; % 4
        for ML = 5:14
            DeltZ_R(ML) = 2; % 5
        end
        for ML = 15:18
            DeltZ_R(ML) = 2.5; % 5
        end
        for ML = 19:23
            DeltZ_R(ML) = 5;
        end
        for ML = 24:31
            DeltZ_R(ML) = 10;
        end
        for ML = 32:40
            DeltZ_R(ML) = 10;
        end
        for ML = 41:42
            DeltZ_R(ML) = 15; % 5
        end
        % Sum of element lengths and compared to the total lenght, so that judge
        % can be made to determine the length of rest elements.

        for ML = 1:42
            Elmn_Lnth = Elmn_Lnth + DeltZ_R(ML);
        end

        % If the total sum of element lenth is over the predefined depth, stop the
        % for loop, make the ML, at which the element lenth sumtion is over defined
        % depth, to be new NL.
        DeltZ = [];
        for ML = 43:NL
            DeltZ_R(ML) = 20;
            Elmn_Lnth = Elmn_Lnth + DeltZ_R(ML);
            if Elmn_Lnth >= Tot_Depth
                DeltZ_R(ML) = Tot_Depth - Elmn_Lnth + DeltZ_R(ML);
                NL = ML;
                for ML = 1:NL
                    MML = NL - ML + 1;
                    DeltZ(ML) = DeltZ_R(MML);
                end
                return
            end
        end
    end
end
