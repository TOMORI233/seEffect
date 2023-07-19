ccc;

DATAROOTPATH = 'Data\20230718-1';

pID = 101;
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

disp(['Miss: ', num2str(sum(([trialAll.miss])) / length(trialAll))]);
trialAll([trialAll.miss]) = [];

%% 
trialsControl = trialAll(isnan([trialAll.pos]));
trialsMid = trialAll([trialAll.pos] == 50);
trialsHead = trialAll([trialAll.pos] < 50);
trialsTail = trialAll([trialAll.pos] > 50);

deltaAmp = unique([trialAll.deltaAmp]);
deltaAmp(isnan(deltaAmp)) = [];
ratioMid = zeros(1, length(deltaAmp));
ratioHead = zeros(1, length(deltaAmp));
ratioTail = zeros(1, length(deltaAmp));
ratioAll = zeros(1, length(deltaAmp));
for dIndex = 1:length(deltaAmp)
    temp = trialsMid([trialsMid.deltaAmp] == deltaAmp(dIndex));
    ratioMid(dIndex) = sum([temp.correct]) / length(temp);

    temp = trialsHead([trialsHead.deltaAmp] == deltaAmp(dIndex));
    ratioHead(dIndex) = sum([temp.correct]) / length(temp);

    temp = trialsTail([trialsTail.deltaAmp] == deltaAmp(dIndex));
    ratioTail(dIndex) = sum([temp.correct]) / length(temp);

    temp = trialAll([trialAll.deltaAmp] == deltaAmp(dIndex));
    ratioAll(dIndex) = sum([temp.correct]) / length(temp);
end
deltaAmp = [0, deltaAmp];
ratioControl = 1 - sum([trialsControl.correct]) / length(trialsControl);
ratioMid =  [ratioControl, ratioMid];
ratioHead = [ratioControl, ratioHead];
ratioTail = [ratioControl, ratioTail];
ratioAll =  [ratioControl, ratioAll];

fitRes = fitBehavior(ratioAll, deltaAmp);

figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min', 'alignment', 'center-left');
plot(deltaAmp, ratioMid, 'r.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Middle');
set(gca, 'FontSize', 12);
hold on;
plot(deltaAmp, ratioHead, 'b.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Head');
plot(deltaAmp, ratioTail, 'k.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Tail');
plot(fitRes(1, :), fitRes(2, :), 'g.-', 'LineWidth', 2, 'DisplayName', 'Fit');
legend("Location", "best");
title(['SDM behavior: ', num2str(nChangePeriod / f0 * 1000), '-ms change in ', num2str(f0), ' Hz tone | Control: ', ...
       num2str(sum([trialsControl.correct])), '/', num2str(length(trialsControl))]);
xlabel('deltaAmperence in amplitude (%)');
ylabel('Push for difference ratio');
xlim([deltaAmp(1), deltaAmp(end - 1)]);
ylim([0, 1]);

mSubplot(2, 1, 1, [0.4, 1], 'alignment', 'center-right');
rtMidC = [trialsMid([trialsMid.correct]).RT]';
rtHeadC = [trialsHead([trialsHead.correct]).RT]';
rtTailC = [trialsTail([trialsTail.correct]).RT]';
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
set(gca, 'FontSize', 12);
title(['Correct | one-way ANOVA p=', num2str(pC)]);
ylabel('Count');
xlim([0, 2]);

mSubplot(2, 1, 2, [0.4, 1], 'alignment', 'center-right');
rtMidW = [trialsMid(~[trialsMid.correct]).RT]';
rtHeadW = [trialsHead(~[trialsHead.correct]).RT]';
rtTailW = [trialsTail(~[trialsTail.correct]).RT]';
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
set(gca, 'FontSize', 12);
title(['Wrong | one-way ANOVA p=', num2str(pW)]);
xlabel('Reaction time (sec)');
ylabel('Count');
xlim([0, 2]);