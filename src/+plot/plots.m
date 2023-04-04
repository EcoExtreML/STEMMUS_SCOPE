function plots(Output_dir)
    % plots.m (script) makes plots the output of SCOPE_v1.51 of the latest run.

    % clc, clear all, close all
    %
    % directories         =   dir('..\output\*');
    % [time_value_s,I]    =   sort([directories(3:end).datenum]);
    % Directory           =   directories(2+I(end)).name;

    %% load verification data
    path1_ = [Output_dir];
    info1   = dir([path1_ '*.csv']);           % the most recent output

    L = length(info1);
    % wl = dlmread([path1_ 'wl.csv'],'',2,0);

    for i = 12
        D1 = readmatrix([path1_ info1(i).name]);
        spn = ceil(sqrt(size(D1, 2)));
        h1 = textread([path1_ info1(i).name], '%s', 'delimiter', ',');
        figure(i);

        for m = 1:size(D1, 2)
            subplot(spn, spn, m);
            plot(D1(:, m), 'r');
            title([info1(i).name h1(m)], 'Interpreter', 'none');
            set(gca, 'FontSize', 4);
        end
        exportgraphics(figure(i), [path1_ 'Fluxes.jpg']);
        close;
    end
    for i = 2
        D1 = readmatrix([path1_ info1(i).name]);
        spn = ceil(sqrt(size(D1, 2)));
        h1 = textread([path1_ info1(i).name], '%s', 'delimiter', ' ');
        figure(i);

        for m = 1:size(D1, 2)
            subplot(spn, spn, m);
            plot(D1(:, m), 'r');
            title([info1(i).name], 'Interpreter', 'none');
            set(gca, 'FontSize', 2);
        end
        exportgraphics(figure(i), [path1_ 'Soil temperature.jpg']);
        close;
    end
    for i = 3
        D1 = readmatrix([path1_ info1(i).name]);
        spn = ceil(sqrt(size(D1, 2)));
        h1 = textread([path1_ info1(i).name], '%s', 'delimiter', ' ');
        figure(i);

        for m = 1:size(D1, 2)
            subplot(spn, spn, m);
            plot(D1(:, m), 'r');
            title([info1(i).name], 'Interpreter', 'none');
            set(gca, 'FontSize', 2);
        end
        exportgraphics(figure(i), [path1_ 'Soil moisture.jpg']);
        close;
    end
end
