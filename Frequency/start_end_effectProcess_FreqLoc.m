clear; clc;

load("D:\Education\Lab\Projects\EEG\EEG App\20240619-2024061901\22.mat");

propNames = rules.Properties.VariableNames(6:end);
controlCode = rules.code(isnan(rules.pos));

for tIndex = 1:length(trialsData)
    trialAll(tIndex, 1).trialNum = tIndex;
    
    for pIndex = 1:length(propNames)
        trialAll(tIndex).(propNames{pIndex}) = rules([rules.code] == trialsData(tIndex).code, :).(propNames{pIndex});
    end

    if trialsData(tIndex).key == 0
        trialAll(tIndex).correct = false;
        trialAll(tIndex).miss = true;
        trialAll(tIndex).RT = inf;
    else
        trialAll(tIndex).miss = false;
        if (~ismember(trialAll(tIndex).code, controlCode) && trialsData(tIndex).key == 37) || (ismember(trialAll(tIndex).code, controlCode) && trialsData(tIndex).key == 39)
            trialAll(tIndex).correct = true;
        else
            trialAll(tIndex).correct = false;
        end
        trialAll(tIndex).RT = trialsData(tIndex).push - trialsData(tIndex).offset;
    end
end

disp(['Miss: ', num2str(sum([trialAll.miss])), '/' , num2str(length(trialAll))]);
trialAll([trialAll.miss]) = [];

%% 
trialsControl = trialAll(ismember([trialAll.code], controlCode));
nChangePeriod = mode([trialAll.nChangePeriod]);
f0 = unique([trialAll.f0]);
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
plot(pos / 100, ratio, "k.-", "LineWidth", 2, "MarkerSize", 20);
set(gca, 'FontSize', 12);
xlabel('Normalized change position');
ylabel('Push for difference ratio');
ylim([0, 1]);
xlim([0, 1]);
title(['Difference detection task | ', num2str(nChangePeriod), ' period change in ', num2str(f0), ' Hz tone | Control: ', ...
       num2str(sum([trialsControl.correct])), '/', num2str(length(trialsControl))]);

mSubplot(2, 1, 1, [0.4, 1], 'alignment', 'center-right');
rtMidC = [trialAll([trialAll.correct] & [trialAll.pos] == 50).RT]';
rtHeadC = [trialAll([trialAll.correct] & [trialAll.pos] < 50).RT]';
rtTailC = [trialAll([trialAll.correct] & [trialAll.pos] > 50).RT]';
pC = anova1([rtMidC; rtHeadC; rtTailC], ...
            [ones(length(rtMidC), 1); 2 * ones(length(rtHeadC), 1); 3 * ones(length(rtTailC), 1)], ...
            "off");
mHistogram({rtMidC; ...
            rtHeadC; ...
            rtTailC}, ...
           "FaceColor", {'r', 'b', 'k'}, ...
           "DisplayName", {['Middle (Mean at ', num2str(mean(rtMidC)), ')'], ...
                           ['Head (Mean at ', num2str(mean(rtHeadC)), ')'], ...
                           ['Tail (Mean at ', num2str(mean(rtTailC)), ')']});
set(gca, 'FontSize', 12);
title(['Correct | one-way ANOVA p=', num2str(pC)]);
ylabel('Count');
xlim([0, 2]);

mSubplot(2, 1, 2, [0.4, 1], 'alignment', 'center-right');
rtMidW = [trialAll(~[trialAll.correct] & [trialAll.pos] == 50).RT]';
rtHeadW = [trialAll(~[trialAll.correct] & [trialAll.pos] < 50).RT]';
rtTailW = [trialAll(~[trialAll.correct] & [trialAll.pos] > 50).RT]';
pW = anova1([rtMidW; rtHeadW; rtTailW], ...
            [ones(length(rtMidW), 1); 2 * ones(length(rtHeadW), 1); 3 * ones(length(rtTailW), 1)], ...
            "off");
mHistogram({rtMidW; ...
            rtHeadW; ...
            rtTailW}, ...
           "FaceColor", {'r', 'b', 'k'}, ...
           "DisplayName", {['Middle (Mean at ', num2str(mean(rtMidW)), ')'], ...
                           ['Head (Mean at ', num2str(mean(rtHeadW)), ')'], ...
                           ['Tail (Mean at ', num2str(mean(rtTailW)), ')']});
set(gca, 'FontSize', 12);
title(['Wrong | one-way ANOVA p=', num2str(pW)]);
xlabel('Reaction time (sec)');
ylabel('Count');
xlim([0, 2]);