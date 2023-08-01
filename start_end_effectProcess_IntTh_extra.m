ccc;

DATAROOTPATH = 'Data\20230801-2';

pID = 103;
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
trialAll([trialAll.miss]) = [];

trialAllTemp = trialAll;
run("start_end_effectPlot_IntTh.m");
disp(['Threshold for ', num2str(mode([trialAll.f0])), ' Hz is ', num2str(findBehaviorThreshold(fitRes, 0.5))]);