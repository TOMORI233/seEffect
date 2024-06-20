clear; clc;

% load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061901\1.mat"));
% load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061902\1.mat"));
load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240620-2024062001\1.mat"));

nChangePeriod = mode(rules.nChangePeriod);
f0 = mode(rules.f0);
f1 = rules.f1;
pos = rules.pos;
dur = rules.dur(1);
controlIdx = find(isnan(f1));
pos(isnan(pos)) = 0; % replace NAN with 0
Locs = unique(pos);

for tIndex = 1:length(trialsData)
    trialAll(tIndex, 1).trialNum = tIndex;

    idx = trialsData(tIndex).code - 3;
    trialAll(tIndex).f1 = f1(idx);

    switch pos(idx)
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

disp(['Miss: ', num2str(sum([trialAll.miss])), '/' , num2str(length(trialAll))]);
trialAll([trialAll.miss]) = [];

%% 
trialsControl = trialAll([trialAll.loc] == "NONE");
trialsMid = trialAll([trialAll.loc] == "MID");
trialsHead = trialAll([trialAll.loc] == "HEAD");
trialsTail = trialAll([trialAll.loc] == "TAIL");

temp = [trialAll.f1];
temp(isnan(temp)) = 0;
f1 = unique(temp);
f1(f1 == 0) = [];
ratioMid = zeros(1, length(f1));
ratioHead = zeros(1, length(f1));
ratioTail = zeros(1, length(f1));
for index = 1:length(f1)
    temp = trialsMid([trialsMid.f1] == f1(index));
    ratioMid(index) = sum([temp.correct]) / length(temp);

    temp = trialsHead([trialsHead.f1] == f1(index));
    ratioHead(index) = sum([temp.correct]) / length(temp);

    temp = trialsTail([trialsTail.f1] == f1(index));
    ratioTail(index) = sum([temp.correct]) / length(temp);
end
ratioMid =  [1 - sum([trialsControl.correct]) / length(trialsControl), ratioMid];
ratioHead = [1 - sum([trialsControl.correct]) / length(trialsControl), ratioHead];
ratioTail = [1 - sum([trialsControl.correct]) / length(trialsControl), ratioTail];

X = [0, (f1 - f0) / f0 * 100];
fitResMid = fitBehavior(ratioMid, X);

figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min', 'alignment', 'center-left');
set(gca, 'FontSize', 12);
hold on;
plot(X, ratioMid, 'r.-', 'LineWidth', 2, "MarkerSize", 20, 'DisplayName', 'Middle');
plot(X, ratioHead, 'b.-', 'LineWidth', 2, "MarkerSize", 20, 'DisplayName', 'Head');
plot(X, ratioTail, 'k.-', 'LineWidth', 2, "MarkerSize", 20, 'DisplayName', 'Tail');
plot(fitResMid(1, :), fitResMid(2, :), "g", "LineWidth", 2, "DisplayName", "Fit (Middle)");
legend("Location", "northwest");
title(['DMS task | ', num2str(nChangePeriod), '-period change in ', num2str(dur * 1000), '-ms ', num2str(f0), ' Hz tone']);
xlabel('Difference in frequency (%)');
ylabel('Push for difference ratio');
ylim([0, 1]);

mSubplot(2, 1, 1, [0.4, 1], 'alignment', 'center-right');
rtMidC  = [trialsMid([trialsMid.correct]).RT]';
rtHeadC = [trialsHead([trialsHead.correct]).RT]';
rtTailC = [trialsTail([trialsTail.correct]).RT]';
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
rtMidW  = [trialsMid(~[trialsMid.correct]).RT]';
rtHeadW = [trialsHead(~[trialsHead.correct]).RT]';
rtTailW = [trialsTail(~[trialsTail.correct]).RT]';
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