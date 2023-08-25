%% plot behavior
f0 = unique([trialAllTemp.f0]);
nChangePeriod = mode([trialAllTemp.nChangePeriod]);

trialsControl = trialAllTemp(isnan([trialAllTemp.pos]));
trialsMid = trialAllTemp([trialAllTemp.pos] == 50);
trialsHead = trialAllTemp([trialAllTemp.pos] < 50);
trialsTail = trialAllTemp([trialAllTemp.pos] > 50);

deltaAmp = unique([trialAllTemp.deltaAmp]);
deltaAmp(isnan(deltaAmp)) = [];
ratioMid = zeros(1, length(deltaAmp));
ratioHead = zeros(1, length(deltaAmp));
ratioTail = zeros(1, length(deltaAmp));
for dIndex = 1:length(deltaAmp)
    temp = trialsMid([trialsMid.deltaAmp] == deltaAmp(dIndex));
    ratioMid(dIndex) = sum([temp.correct]) / length(temp);

    temp = trialsHead([trialsHead.deltaAmp] == deltaAmp(dIndex));
    ratioHead(dIndex) = sum([temp.correct]) / length(temp);

    temp = trialsTail([trialsTail.deltaAmp] == deltaAmp(dIndex));
    ratioTail(dIndex) = sum([temp.correct]) / length(temp);
end
deltaAmp = [0, deltaAmp];
ratioControl = 1 - sum([trialsControl.correct]) / length(trialsControl);
ratioMid =  [ratioControl, ratioMid];
ratioHead = [ratioControl, ratioHead];
ratioTail = [ratioControl, ratioTail];

fitResMid  = fitBehavior(ratioMid , deltaAmp);
fitResHead = fitBehavior(ratioHead, deltaAmp);
fitResTail = fitBehavior(ratioTail, deltaAmp);

figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min', 'alignment', 'center-left');
plot(deltaAmp, ratioMid, 'r.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Middle');
set(gca, 'FontSize', 14);
hold on;
plot(deltaAmp, ratioHead, 'b.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Head');
plot(deltaAmp, ratioTail, 'k.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Tail');
plot(fitResMid(1, :), fitResMid(2, :), 'g.-', 'LineWidth', 2, 'DisplayName', 'Fit(Middle)');
legend("Location", "best");
title(['DMS behavior: ', char(numstrcat(nChangePeriod ./ f0 * 1000, ',')), '-ms change in ', char(numstrcat(f0, ',')), ' Hz tone | Control: ', ...
       num2str(sum([trialsControl.correct])), '/', num2str(length(trialsControl))]);
xlabel('Difference in amplitude');
ylabel('Push for difference ratio');
xlim([deltaAmp(1), deltaAmp(end)]);
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
set(gca, 'FontSize', 14);
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