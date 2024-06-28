clear; clc;

% load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061901\2.mat"));

% Ishrat
load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240628-2024062801\162.mat")); % 0.5s
% load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240628-2024062801\163.mat")); % 1s

dur = mode(rules.dur); % sec
f0 = mode(rules.f0);
f1 = rules.f1;
controlIdx = find(isnan(f1));
trialAll = generalProcessFcn(trialsData, rules, controlIdx);

disp(['Miss: ', num2str(sum([trialAll.miss])), '/' , num2str(length(trialAll))]);
trialAll([trialAll.miss]) = [];

%% 
trialsControl = trialAll(isnan([trialAll.f1]));
nChangePeriod = mode([trialAll.nChangePeriod]);
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
title(['DMS task | ', num2str(nChangePeriod), ' period change in ', num2str(1000 * dur), '-ms, ' , num2str(f0), ' Hz tone | Control: ', ...
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