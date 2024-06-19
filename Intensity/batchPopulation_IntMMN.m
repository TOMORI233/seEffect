ccc;

MATPATHs = dir("DATA\MAT DATA\single\**\105_res.mat");
SUBJECTs = cellfun(@(x) split(x, '\'), {MATPATHs.folder}', "UniformOutput", false);
SUBJECTs = cellfun(@(x) string(x{end}), SUBJECTs);
FIGURESINGLEPATHs = strrep(string({MATPATHs.folder}'), '\DATA\MAT DATA\single\', '\Figures\Single\');
MATPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false));

colors = {[0.5, 0.5, 0.5], [0, 0, 1], [1, 0, 0], [0, 0, 0]};

%% Load data
data = arrayfun(@(x) load(fullfile(x)), MATPATHs);
fs = data(1).fs;
window = data(1).window;

%% Individual plot
for sIndex = 1:length(data)
    close all force;

    trialsEEG = data(sIndex).trialsEEG;
    trialAll = data(sIndex).trialAll;

    pos = unique([trialAll.pos])';
    pos(isnan(pos)) = [];
    dur = mode([trialAll.dur]);

    ISI = mode([trialAll.ISI]) * 1000; % ms
    nSTD = mode([trialAll.nSTD]);

    chData = [];
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
                               ISI * nSTD + pos(3) / 100 * dur * 1000}));
    scaleAxes("x", [ISI * nSTD - 100, ISI * nSTD + 1000]);
    scaleAxes("y", [-10, 10], "symOpt", "max", "uiOpt", "show");

    mPrint(gcf, fullfile(FIGURESINGLEPATHs(sIndex), "105.jpg"), "-djpeg", "-r300");

    plotRawWaveMultiEEG(chData, window, ISI * nSTD, [], EEGPos);
    scaleAxes("x", [-100, ISI * nSTD + 1000]);
    scaleAxes("y", [-10, 10], "symOpt", "max", "uiOpt", "show");
end

%% Copy figures
FIGUREPOPUPATH = "Figures\Population\105";
mkdir(FIGUREPOPUPATH);
arrayfun(@(x, y) copyfile(fullfile(x, "105.jpg"), fullfile(FIGUREPOPUPATH, strcat(y, " IntMMN.jpg"))), FIGURESINGLEPATHs, SUBJECTs);

%% Population plot
posAll = cell2mat(cellfun(@(x) [x.pos]', {data.trialAll}', "UniformOutput", false));
dur = data(1).trialAll(1).dur;
ISI = data(1).trialAll(1).ISI * 1000; % ms
nSTD = data(1).trialAll(1).nSTD;
trialsEEG = vertcat(data.trialsEEG);

clearvars data

pos = unique(posAll);
pos = pos(~isnan(pos));

chData = [];
chData(1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsEEG(isnan(posAll))), "UniformOutput", false));
chData(1).color = colors{1};
chData(1).legend = "control";

for pIndex = 1:length(pos)
    chData(pIndex + 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsEEG(posAll == pos(pIndex))), "UniformOutput", false));
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