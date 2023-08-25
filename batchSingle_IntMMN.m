ccc;

MATPATHs = dir("Data\raw\**\105.mat");
MATPATHs(contains({MATPATHs.folder}, "preliminary")) = [];

EEGPATHs = dir("Data\raw\**\data.bdf");
EEGPATHs = string({EEGPATHs.folder}');

SUBJECTs = cellfun(@(x) split(x, '\'), {MATPATHs.folder}', "UniformOutput", false);
SUBJECTs = cellfun(@(x) string(x{end}), SUBJECTs);

SAVEPATHs = strrep(string({MATPATHs.folder}'), '\Data\raw\', '\Data\temp\');
FIGUREPATHs = strrep(string({MATPATHs.folder}'), '\Data\raw\', '\Figures\Single\');
MATPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false));

arrayfun(@mkdir, SAVEPATHs);
arrayfun(@mkdir, FIGUREPATHs);

%% Params
window = [-1000, 9000]; % ms
windowBase = [-200, 0]; % ms

fhp = 0.5; % Hz
flp = 40; % Hz

tTh = 0.1;
chTh = 0.2;

colors = {[0.5, 0.5, 0.5], [0, 0, 1], [1, 0, 0], [0, 0, 0]};

%% Daily processing
for mIndex = 2:length(MATPATHs)
    load(MATPATHs(mIndex), "trialsData", "rules");

    controlIdx = find(isnan(rules.deltaAmp));
    trialAll = generalProcessFcn(trialsData, rules, controlIdx);

    EEG = readbdfdata({'data.bdf', 'evt.bdf'}, char(strcat(EEGPATHs(mIndex), '\')));

    fs = EEG.srate; % Hz
    evts = EEG.event;
    codes = str2double({evts.type}');
    latency = [evts.latency]';
    soundOnsetIndex = latency(codes > 3);

    %% Preprocess
    EEG.data = ECOGFilter({EEG.data}, fhp, flp, fs);
    EEG.data = EEG.data{1};
    trialsEEG = rowFcn(@(x) EEG.data(:, x + fix(window(1) / 1000 * fs):x + fix(window(2) / 1000 * fs)), soundOnsetIndex, "UniformOutput", false);
    trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase);
    [exIdx, chIdx] = excludeTrials(trialsEEG, tTh, chTh, "userDefineOpt", "off");
    trialAll(exIdx) = [];
    trialsEEG(exIdx) = [];

    save(fullfile(SAVEPATHs(mIndex), "105_res.mat"), "trialAll", "trialsEEG", "fs", "window");

    %% Plot
    pos = unique([trialAll.pos])';
    pos(isnan(pos)) = [];
    dur = mode([trialAll.dur]);

    ISI = mode([trialAll.ISI]) * 1000; % ms
    nSTD = mode([trialAll.nSTD]);

    chData(1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsEEG(isnan([trialAll.pos]))), "UniformOutput", false));
    chData(1).color = colors{1};
    chData(1).legend = "control";

    for pIndex = 1:length(pos)
        chData(pIndex + 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsEEG([trialAll.pos] == pos(pIndex))), "UniformOutput", false));
        chData(pIndex + 1).color = colors{pIndex + 1};
        chData(pIndex + 1).legend = num2str(pos(pIndex));
    end

    EEGPos = EEGPosConfigNeuracle;
    plotRawWaveMultiEEG(chData, window, ISI * nSTD, [], EEGPos);
    addLines2Axes(struct("X", {ISI * nSTD + pos(1) / 100 * dur * 1000; ...
                               ISI * nSTD + pos(2) / 100 * dur * 1000; ...
                               ISI * nSTD + pos(3) / 100 * dur * 1000}))
    scaleAxes("x", [ISI * nSTD - 100, ISI * nSTD + 1000]);
    scaleAxes("y", [-10, 10], "symOpt", "max", "uiOpt", "show");

    close all force;
end
