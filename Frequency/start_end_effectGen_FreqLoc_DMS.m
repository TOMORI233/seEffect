%% start-end effect pure tone
ccc;

ord = arrayfun(@(x) strrep(x, ' ', '0'), num2str((1:100)'));
soundPath = 'D:\Education\Lab\Projects\EEG\EEG App\sounds\162';
try
    rmdir(soundPath, "s");
end
mkdir(soundPath);

%% Params
% freq diff
freqDiff = validateInput("Input threshold (%)", @(x) isscalar(x) && isnumeric(x), "UI", "on") / 100;

% change position
pos = [5, 10, 15, 20, 30, 50, 70, 80, 85, 90, 95] / 100;

% freq params, in Hz
fs = 384e3;
f0 = [1e3];

% --------------------------------------
% time params, in sec
totalDur = 0.5;
nChangePeriod = 20;
interval = 500e-3;
rfTime = 5e-3;

% wave amp, in volt
Amp = 0.5;

%% Generate tones
t = 1 / fs:1 / fs:totalDur;
pos = pos(:);
n = 0;

for f0Index = 1:length(f0)
    y0 = Amp * sin(2 * pi * f0(f0Index) * t);
    y0 = genRiseFallEdge(y0, fs, rfTime, "both");

    nPeriods = totalDur * f0(f0Index);
    Ns = fix(nPeriods * pos) - nChangePeriod / 2;

    if any(mod(Ns, 1) ~= 0) || any(Ns < rfTime * f0(f0Index)) || any(Ns > nPeriods - rfTime * f0(f0Index) - nChangePeriod)
        error("Invalid change posistion");
    end

    f1 = f0(f0Index) * (1 + freqDiff);
    n = n + 1;
    % control
    audiowrite(fullfile(soundPath, [ord(n, :), ...
                        '_f0-', num2str(f0(f0Index)), ...
                        '_f1-NaN', ...
                        '_nChangePeriod-NaN', ...
                        '_pos-NaN', ...
                        '_dur-', num2str(totalDur), '.wav']), ...
               [y0, zeros(1, interval * fs), y0], fs);

    for f1Index = 1:length(f1)
        y1 = rowFcn(@(x) [y0(1:x * fs / f0(f0Index)), ...
                          Amp * sin(2 * pi * f1(f1Index) * (1 / fs:1 / fs:nChangePeriod / f1(f1Index))), ...
                          y0((x + nChangePeriod) * fs / f0(f0Index):end)], ...
                    Ns, "UniformOutput", false);

        % Plot
        plotSize = autoPlotSize(length(pos) + 1);
        figure;
        maximizeFig;
        mSubplot(plotSize(1), plotSize(2), 1);
        plot(t, y0);
        for pIndex = 1:length(pos)
            mSubplot(plotSize(1), plotSize(2), pIndex + 1);
            plot(y1{pIndex});
            hold on;
            plot(Ns(pIndex) * fs / f0(f0Index) + 1:Ns(pIndex) * fs / f0(f0Index) + nChangePeriod * fs / f1(f1Index), ...
                Amp * sin(2 * pi * f1(f1Index) * (1 / fs:1 / fs:nChangePeriod / f1(f1Index))), 'r.');
            title(['f0=', num2str(f0(f0Index)), ' | f1=', num2str(f1(f1Index)), ' | pos=', strrep(rats(pos(pIndex)), ' ', '')]);
        end
        scaleAxes("y", [-0.6, 0.6]);

        % Export
        wave = cellfun(@(x) [y0, zeros(1, interval * fs), x], y1, "UniformOutput", false);
        filenames = rowFcn(@(x, y) [ord(n + y, :), ...
                                    '_f0-', num2str(f0(f0Index)), ...
                                    '_f1-', num2str(f1(f1Index)), ...
                                    '_nChangePeriod-', num2str(nChangePeriod), ...
                                    '_pos-', num2str(x * 100), ...
                                    '_dur-', num2str(totalDur), '.wav'], ...
                           pos, (1:length(pos))', "UniformOutput", false);

        cellfun(@(x, y) audiowrite(fullfile(soundPath, x), y, fs), filenames, wave, "UniformOutput", false);
        n = n + length(y1);
    end
end

rulesGenerator(soundPath, "D:\Education\Lab\Projects\EEG\EEG App\rules\start-end effect\rules_SE.xlsx", ...
               162, "Start-end效应", "3-位置阶段(1k)", "active", "SE loc-1k", ...
               3.5, 25, "forceOpt", "on");