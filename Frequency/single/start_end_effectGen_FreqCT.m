%% start-end effect complex tone
ccc;

ord = arrayfun(@(x) strrep(x, ' ', '0'), num2str((1:100)'));
soundPath = 'D:\Education\Lab\Projects\EEG\EEG App\sounds\11';
try
    rmdir(soundPath, "s");
end
mkdir(soundPath);

%% Params
% freq diff
% freqDiff = [1, 2, 3, 4, 6] / 100;
freqDiff = [2, 4] / 100;

% change position (center)
pos = [5, 10, 15, 20, 30, 50, 70, 80, 85, 90, 95] / 100;
% pos = [10, 50, 90] / 100;

% freq params, in Hz
fs = 97656;
f0 = 500;
fs0 = lcm(fs, f0);

% freq rank
nRank = 6;

% --------------------------------------
% time params, in sec
totalDur = 0.5;
nChangePeriod = 10;
rfTime = 5e-3;

% wave amp, in volt
Amp = 0.1;

%% Generate tones
t = 1 / fs0:1 / fs0:totalDur;
pos = pos(:);

y0 = Amp * sin(2 * pi * f0 * 2 .^ (0:nRank)' .* t);
y0 = sum(y0, 1);
y0 = genRiseFallEdge(y0, fs0, rfTime, "both");

% start index
nPeriods = totalDur * f0;
Ns = fix(nPeriods * pos) - nChangePeriod / 2;

if any(mod(Ns, 1) ~= 0) || any(Ns < rfTime * f0) || any(Ns > nPeriods - rfTime * f0 - nChangePeriod)
    error("Invalid change posistion");
end

n = 1;
% control
audiowrite(fullfile(soundPath, [ord(n, :), ...
           '_f0-', num2str(f0), ...
           '_freqDiff-NaN', ...
           '_nChangePeriod-NaN', ...
           '_pos-NaN', ...
           '_dur-', num2str(totalDur), '.wav']), ...
           resampleData(y0, fs0, fs), fs);

for fIndex = 1:length(freqDiff)
    y1 = cell(length(Ns), 1);
    for pIndex = 1:length(Ns)
        temp = sum(Amp * sin(2 * pi * f0 * (1 + freqDiff(fIndex)) * 2 .^ (0:nRank)' .* (1 / fs0:1 / fs0:nChangePeriod / (f0 * (1 + freqDiff(fIndex))))), 1);
        y1{pIndex} = [y0(1:Ns(pIndex) * fs0 / f0), temp, y0((Ns(pIndex) + nChangePeriod) * fs0 / f0:end)];
    end

    % Plot
    plotSize = autoPlotSize(length(Ns) + 1);
    figure("WindowState", "maximized");
    mSubplot(plotSize(1), plotSize(2), 1, "margin_bottom", 0.2);
    plot(y0);
    set(gca, "XLimitMethod", "tight");
    for pIndex = 1:length(Ns)
        mSubplot(plotSize(1), plotSize(2), pIndex + 1, "margin_bottom", 0.2);
        plot(y1{pIndex});
        hold on;
        plot(Ns(pIndex) * fs0 / f0 + 1:Ns(pIndex) * fs0 / f0 + nChangePeriod * fs0 / (f0 * (1 + freqDiff(fIndex))), ...
             sum(Amp * sin(2 * pi * f0 * (1 + freqDiff(fIndex)) * 2 .^ (0:nRank)' .* (1 / fs0:1 / fs0:nChangePeriod / (f0 * (1 + freqDiff(fIndex))))), 1), ...
             'r.');
        set(gca, "XLimitMethod", "tight");
        title(['df=', num2str(freqDiff(fIndex) * 100), '% | pos=', strrep(rats(pos(pIndex)), ' ', '')]);
    end
    scaleAxes("y", [-0.6, 0.6]);

    % Resample
    y1 = cellfun(@(x) resampleData(x, fs0, fs), y1, "UniformOutput", false);

    % Export
    filenames = rowFcn(@(x, y) [ord(n + y, :), ...
                       '_f0-', num2str(f0), ...
                       '_freqDiff-', num2str(freqDiff(fIndex) * 100), ...
                       '_nChangePeriod-', num2str(nChangePeriod), ...
                       '_pos-', num2str(x * 100), ...
                       '_dur-', num2str(totalDur), '.wav'], ...
                       pos, (1:length(pos))', "UniformOutput", false);

    cellfun(@(x, y) audiowrite(fullfile(soundPath, x), y, fs), filenames, y1, "UniformOutput", false);
    n = n + length(y1);
end
