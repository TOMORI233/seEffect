ccc;

load('20230517-2\1.mat');

rules = readtable('rules_20230517-2.xlsx');
insertDur = 20;
freq = mode(rules.freq);
Diffs = rules.Diff;
locN = rules.locN;
controlIdx = find(Diffs == 0);
locN(isnan(locN)) = 0; % replace NAN with 0
Locs = unique(locN);

for tIndex = 1:length(trialsData)
    trialAll(tIndex, 1).trialNum = tIndex;

    idx = trialsData(tIndex).code - 3;
    trialAll(tIndex).Diff = Diffs(idx);

    switch locN(idx)
        case Locs(1)
            trialAll(tIndex).loc = "NONE";
        case Locs(2)
            trialAll(tIndex).loc = "HEAD";
        case Locs(3)
            trialAll(tIndex).loc = "MID";
        case Locs(4)
            trialAll(tIndex).loc = "TAIL";
    end

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
trialsControl = trialAll([trialAll.loc] == "NONE");
trialsMid = trialAll([trialAll.loc] == "MID");
trialsHead = trialAll([trialAll.loc] == "HEAD");
trialsTail = trialAll([trialAll.loc] == "TAIL");

Diffs = unique([trialAll.Diff]);
Diffs(Diffs == 0) = [];
ratioMid = zeros(1, length(Diffs));
ratioHead = zeros(1, length(Diffs));
ratioTail = zeros(1, length(Diffs));
for index = 1:length(Diffs)
    temp = trialsMid([trialsMid.Diff] == Diffs(index));
    ratioMid(index) = sum([temp.correct]) / length(temp);

    temp = trialsHead([trialsHead.Diff] == Diffs(index));
    ratioHead(index) = sum([temp.correct]) / length(temp);

    temp = trialsTail([trialsTail.Diff] == Diffs(index));
    ratioTail(index) = sum([temp.correct]) / length(temp);
end

figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min', 'alignment', 'center-left');
plot(Diffs, ratioMid, 'r.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Middle');
set(gca, 'FontSize', 12);
hold on;
plot(Diffs, ratioHead, 'b.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Head');
plot(Diffs, ratioTail, 'k.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Tail');
legend("Location", "best");
title(['SDM behavior: ', num2str(insertDur), '-ms change in ', num2str(freq), ' Hz tone | Control: ', ...
       num2str(sum([trialsControl.correct])), '/', num2str(length(trialsControl))]);
xlabel('Difference in amplitude (%)');
ylabel('Push for difference ratio');
xlim([Diffs(1), Diffs(end - 1)]);
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