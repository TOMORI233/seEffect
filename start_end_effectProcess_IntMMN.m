ccc;

DATAROOTPATH = pathConfig;

pID = 105;
DATAPATH = fullfile(DATAROOTPATH, [num2str(pID), '.mat']);
load(DATAPATH, "trialsData", "protocol", "rules", "pID");
rules = rules(rules.pID == pID, :);
dur = mode(rules.dur);
controlIdx = find(isnan(rules.deltaAmp));

for tIndex = 1:length(trialsData)
    trialAll(tIndex, 1).trialNum = tIndex;

    idx = find(rules.code == trialsData(tIndex).code);
    
    for vIndex = 1:length(rules.Properties.VariableNames)
        trialAll(tIndex).(rules.Properties.VariableNames{vIndex}) = rules(idx, :).(rules.Properties.VariableNames{vIndex});
    end

    trialAll(tIndex).key = trialsData(tIndex).key;

    if trialsData(tIndex).key == 0
        trialAll(tIndex).correct = false;
        trialAll(tIndex).miss = true;
        trialAll(tIndex).RT = inf;
    else
        trialAll(tIndex).miss = false;
        if (~ismember(idx, controlIdx) && trialsData(tIndex).key == 37) || (ismember(idx, controlIdx) && trialsData(tIndex).key == 39)
            trialAll(tIndex).correct = true;
        else
            trialAll(tIndex).correct = false;
        end
        trialAll(tIndex).RT = trialsData(tIndex).push - trialsData(tIndex).offset;
    end
end

disp(['Miss: ', num2str(sum([trialAll.miss])), '/', num2str(length(trialAll))]);

trialAllTemp = trialAll(~[trialAll.miss]);
run("start_end_effectPlot_IntTh.m");
disp(['Threshold for ', num2str(mode([trialAllTemp.f0])), ' Hz is ', num2str(findBehaviorThreshold(fitRes, 0.5))]);

%% Load EEG Data
EEG = readbdfdata({'data.bdf', 'evt.bdf'}, char(strcat(fullfile(DATAROOTPATH, num2str(pID)), '\')));

%% Params
window = [-1000, 9000]; % ms
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

plotRawWaveMultiEEG(chData, window, ISI * nSTD);
scaleAxes("x", [ISI * (nSTD - 1), ISI * nSTD + 1000]);
scaleAxes("y", [-10, 10], "symOpt", "max", "uiOpt", "show");