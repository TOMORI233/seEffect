ccc;

DATAROOTPATH = "D:\Education\Lab\Projects\Human behavior\Start-end effect\DATA\raw\20230830-2023083001\";

pID = 106;
DATAPATH = fullfile(DATAROOTPATH, [num2str(pID), '.mat']);
load(DATAPATH, "trialsData", "rules");
rules = rules(rules.pID == pID, :);
dur = mode(rules.dur);
controlIdx = find(isnan(rules.deltaAmp));
trialAll = generalProcessFcn(trialsData, rules, controlIdx);

%% Load EEG DATA
EEG = readbdfdata({'data.bdf', 'evt.bdf'}, char(strcat(fullfile(DATAROOTPATH, num2str(pID)), '\')));

%% Params
window = [-1000, 5000]; % ms
windowBase = [-200, 0]; % ms

fs = EEG.srate; % Hz
evts = EEG.event;
codes = str2double({evts.type}');
latency = [evts.latency]';
soundOnsetIndex = latency(codes > 3);

fhp = 0.5; % Hz
flp = 40; % Hz

tTh = 0.1;
chTh = 0.2;

colors = {[0, 0, 1], [1, 0, 0], [0, 0, 0]};

%% Preprocess
EEG.data = ECOGFilter({EEG.data}, fhp, flp, fs);
EEG.data = EEG.data{1};
trialsEEG = rowFcn(@(x) EEG.data(:, x + fix(window(1) / 1000 * fs) + 1:x + fix(window(2) / 1000 * fs)), soundOnsetIndex, "UniformOutput", false);
trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase);
[exIdx, chIdx] = excludeTrials(trialsEEG, tTh, chTh, "userDefineOpt", "on");
trialAll(exIdx) = [];
trialsEEG(exIdx) = [];

%% 
pos = unique([trialAll.pos])';
pos(isnan(pos)) = [];

ISI = mode([trialAll.ISI]) * 1000; % ms
nSTD = mode([trialAll.nSTD]);

for pIndex = 1:length(pos)
    chData(pIndex).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsEEG([trialAll.pos] == pos(pIndex))), "UniformOutput", false));
    chData(pIndex).color = colors{pIndex};
    chData(pIndex).legend = num2str(pos(pIndex));
end

EEGPos = EEGPosConfigNeuracle;
plotRawWaveMultiEEG(chData, window, 0, [], EEGPos);
addLines2Axes(struct("X", num2cell((1:nSTD)' * ISI)));
scaleAxes("y", [-10, 10], "symOpt", "max", "uiOpt", "show");