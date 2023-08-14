%% start-end effect pure tone
ccc;

pID = 105; % 1 kHz

ord = arrayfun(@(x) strrep(x, ' ', '0'), num2str((1:1000)'));

soundPath = strcat('D:\Education\Lab\Projects\EEG\EEG App\sounds\', num2str(pID));
try
    rmdir(soundPath, "s");
end
mkdir(soundPath);

%% Params
% int diff
intDiff = validateInput("Input threshold", @(x) isscalar(x) && isnumeric(x), "UI", "on"); % th

% change position
pos = [5, 50, 95] / 100;

% freq params, in Hz
fs = 48e3;
f0 = 1e3;

% MMN params
nSTD = 6;
ISI = 0.8; % sec

% --------------------------------------
% time params, in sec
totalDur = 0.5;
nChangePeriod = 15;
interval = ISI - totalDur;
rfTime = 5e-3;

% wave amp, in volt
Amp = 0.5;

%% Generate tones
disp(strcat("Using ", num2str(f0), " Hz as base frequency"));
t = 1 / fs:1 / fs:totalDur;
pos = reshape(pos, [length(pos), 1]);
n = 0;

for f0Index = 1:length(f0)
    y0 = Amp * sin(2 * pi * f0(f0Index) * t);
    y0 = genRiseFallEdge(y0, fs, rfTime, "both");

    nPeriods = totalDur * f0(f0Index);
    Ns = nPeriods * pos;

    if any(mod(Ns, 1) ~= 0) || any(Ns <= rfTime * f0(f0Index)) || any(Ns >= nPeriods - rfTime * f0(f0Index))
        error("Invalid change posistion");
    end

    Amp1 = Amp * (1 + intDiff);
    n = n + 1;
    
    ySTD = [];
    for sIndex = 1:nSTD
        ySTD = [ySTD, y0, zeros(1, fix(interval * fs))];
    end

    % control
    audiowrite(fullfile(soundPath, [ord(n, :), ...
                        '_f0-', num2str(f0(f0Index)), ...
                        '_deltaAmp-NaN', ...
                        '_nChangePeriod-NaN', ...
                        '_pos-NaN', ...
                        '_dur-', num2str(totalDur), ...
                        '_nSTD-', num2str(nSTD), ...
                        '_ISI-', num2str(ISI), '.wav']), ...
               [ySTD, y0], fs);

    for ampIndex = 1:length(Amp1)
        y1 = rowFcn(@(x) [y0(1:x * fs / f0(f0Index)), ...
                          Amp1(ampIndex) * sin(2 * pi * f0(f0Index) * (1 / fs:1 / fs:nChangePeriod / f0(f0Index))), ...
                          y0((x + nChangePeriod) * fs / f0(f0Index) + 1:end)], ...
                    Ns, "UniformOutput", false);

        % Plot
        plotSize = autoPlotSize(length(pos) + 1);
        figure;
        maximizeFig;
        mSubplot(plotSize(1), plotSize(2), 1);
        plot(y0);
        for pIndex = 1:length(pos)
            mSubplot(plotSize(1), plotSize(2), pIndex + 1);
            plot(y1{pIndex});
            hold on;
            plot(Ns(pIndex) * fs / f0(f0Index) + 1:Ns(pIndex) * fs / f0(f0Index) + nChangePeriod * fs / f0(f0Index), ...
                 Amp1(ampIndex) * sin(2 * pi * f0(f0Index) * (1 / fs:1 / fs:nChangePeriod / f0(f0Index))), 'r.');
            title(['Relative \DeltaAmp=', num2str(Amp1(ampIndex) / Amp - 1), ' | pos=', strrep(rats(pos(pIndex)), ' ', '')]);
        end
        scaleAxes("y", "symOpt", "max", "cutoffRange", [-1, 1]);

        % Export
        wave = cellfun(@(x) [ySTD, x], y1, "UniformOutput", false);
        filenames = rowFcn(@(x, y) [ord(n + y, :), ...
                                    '_f0-', num2str(f0(f0Index)), ...
                                    '_deltaAmp-', num2str(Amp1(ampIndex) / Amp - 1), ...
                                    '_nChangePeriod-', num2str(nChangePeriod), ...
                                    '_pos-', num2str(x * 100), ...
                                    '_dur-', num2str(totalDur), ...
                                    '_nSTD-', num2str(nSTD), ...
                                    '_ISI-', num2str(ISI), '.wav'], ...
                           pos, (1:length(pos))', "UniformOutput", false);

        cellfun(@(x, y) audiowrite(fullfile(soundPath, x), y, fs), filenames, wave, "UniformOutput", false);
        n = n + length(y1);
    end
end

run("rulesGen.m");