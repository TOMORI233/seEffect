ccc;

DATAROOTPATH = 'Data\20230731-1';

pID = 104;
DATAPATH = fullfile(DATAROOTPATH, [num2str(pID), '.mat']);
load(DATAPATH, "trialsData", "protocol", "rules", "pID");
rules = rules(rules.pID == pID, :);
dur = mode(rules.dur);
f0 = mode(rules.f0);
nChangePeriod = mode(rules.nChangePeriod);
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

%% 
trialsControl = trialAll(isnan([trialAll.pos]));

deltaAmp = unique([trialAll.deltaAmp]);
deltaAmp(isnan(deltaAmp)) = [];
pos = unique([trialAll.pos]);
pos(isnan(pos)) = [];

ratio = zeros(1, length(pos));
for lIndex = 1:length(pos)
    temp = trialAll([trialAll.pos] == pos(lIndex));
    ratio(lIndex) = sum([temp.correct]) / length(temp);
end

figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min', 'alignment', 'center-left');
plot(pos, ratio, "k.-", "LineWidth", 2, "MarkerSize", 20);
set(gca, 'FontSize', 12);
title('');
xlabel('Normalized change position in percentage (%)');
ylabel('Push for difference ratio');
ylim([0, 1]);
title(['SDM behavior: ', num2str(nChangePeriod / f0 * 1000), '-ms amplitude increase of ', num2str(mode(deltaAmp) * 100), '% in ', num2str(f0), ' Hz tone | Control: ', ...
       num2str(sum([trialsControl.correct])), '/', num2str(length(trialsControl))]);

mSubplot(2, 1, 1, [0.4, 1], 'alignment', 'center-right');
rtMidC = [trialAll([trialAll.correct] & [trialAll.pos] == 50).RT]';
rtHeadC = [trialAll([trialAll.correct] & [trialAll.pos] <= 30).RT]';
rtTailC = [trialAll([trialAll.correct] & [trialAll.pos] >= 70).RT]';
pC = anova1([rtMidC; rtHeadC; rtTailC], ...
            [ones(length(rtMidC), 1); 2 * ones(length(rtHeadC), 1); 3 * ones(length(rtTailC), 1)], ...
            "off");
mHistogram({rtMidC; ...
            rtHeadC; ...
            rtTailC}, ...
           "Color", {'r', 'b', 'k'}, ...
           "DisplayName", {['Middle (Mean at ', num2str(mean(rtMidC)), ')'], ...
                           ['Head (Mean at ', num2str(mean(rtHeadC)), ')'], ...
                           ['Tail (Mean at ', num2str(mean(rtTailC)), ')']});
set(gca, 'FontSize', 14);
title(['Correct | one-way ANOVA p=', num2str(pC)]);
ylabel('Count');
xlim([0, 2]);

mSubplot(2, 1, 2, [0.4, 1], 'alignment', 'center-right');
rtMidW = [trialAll(~[trialAll.correct] & [trialAll.pos] == 50).RT]';
rtHeadW = [trialAll(~[trialAll.correct] & [trialAll.pos] <= 30).RT]';
rtTailW = [trialAll(~[trialAll.correct] & [trialAll.pos] >= 70).RT]';
pW = anova1([rtMidW; rtHeadW; rtTailW], ...
            [ones(length(rtMidW), 1); 2 * ones(length(rtHeadW), 1); 3 * ones(length(rtTailW), 1)], ...
            "off");
mHistogram({rtMidW; ...
            rtHeadW; ...
            rtTailW}, ...
           "Color", {'r', 'b', 'k'}, ...
           "DisplayName", {['Middle (Mean at ', num2str(mean(rtMidW)), ')'], ...
                           ['Head (Mean at ', num2str(mean(rtHeadW)), ')'], ...
                           ['Tail (Mean at ', num2str(mean(rtTailW)), ')']});
set(gca, 'FontSize', 14);
title(['Wrong | one-way ANOVA p=', num2str(pW)]);
xlabel('Reaction time (sec)');
ylabel('Count');
xlim([0, 2]);