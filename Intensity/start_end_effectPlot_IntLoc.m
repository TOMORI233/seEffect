%% Intensity location
f0 = mode(rules.f0);
nChangePeriod = mode([trialAllTemp.nChangePeriod]);

trialsControl = trialAllTemp(isnan([trialAllTemp.pos]));
deltaAmp = unique([trialAllTemp.deltaAmp]);
deltaAmp(isnan(deltaAmp)) = [];
pos = unique([trialAllTemp.pos]);
pos(isnan(pos)) = [];

ratio = zeros(1, length(pos));
for lIndex = 1:length(pos)
    temp = trialAllTemp([trialAllTemp.pos] == pos(lIndex));
    ratio(lIndex) = sum([temp.correct]) / length(temp);
end

figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min', 'alignment', 'center-left');
plot(pos, ratio, "k.-", "LineWidth", 2, "MarkerSize", 20);
set(gca, 'FontSize', 12);
xlabel('Normalized change position in percentage (%)');
ylabel('Push for difference ratio');
ylim([0, 1]);
title(['DMS behavior: ', num2str(nChangePeriod / f0 * 1000), '-ms amplitude increase of ', num2str(mean(deltaAmp) * 100), '% in ', num2str(f0), ' Hz tone | Control: ', ...
       num2str(sum([trialsControl.correct])), '/', num2str(length(trialsControl))]);

mSubplot(2, 1, 1, [0.4, 1], 'alignment', 'center-right');
rtMidC = [trialAllTemp([trialAllTemp.correct] & [trialAllTemp.pos] == 50).RT]';
rtHeadC = [trialAllTemp([trialAllTemp.correct] & [trialAllTemp.pos] <= 30).RT]';
rtTailC = [trialAllTemp([trialAllTemp.correct] & [trialAllTemp.pos] >= 70).RT]';
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
rtMidW = [trialAllTemp(~[trialAllTemp.correct] & [trialAllTemp.pos] == 50).RT]';
rtHeadW = [trialAllTemp(~[trialAllTemp.correct] & [trialAllTemp.pos] <= 30).RT]';
rtTailW = [trialAllTemp(~[trialAllTemp.correct] & [trialAllTemp.pos] >= 70).RT]';
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