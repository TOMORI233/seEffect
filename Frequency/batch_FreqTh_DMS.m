ccc;

data = dir(fullfile(getRootDirPath(pwd, 2), "DATA\raw\**\161.mat"));
data = arrayfun(@(x) load(fullfile(x.folder, x.name)), data);
trialAll = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules, 1), data, "UniformOutput", false);
trialAll = cellfun(@(x) x(~[x.miss]), trialAll, "UniformOutput", false);

%% 
temp = cat(1, trialAll{:});
f0 = mode([temp.f0]);
nChangePeriod = mode([temp.nChangePeriod]);
dur = mode([temp.dur]) * 1000; % ms
pos = unique([temp.pos]);
pos(isnan(pos)) = [];
f1 = unique([temp.f1]);
f1(isnan(f1)) = [];

[ratioHead, ratioMiddle, ratioTail] = deal(zeros(length(trialAll), length(f1) + 1));
for sIndex = 1:length(trialAll)
    temp = trialAll{sIndex};
    ratioHead(sIndex, 1) = 1 - sum(isnan([temp.f1]) & [temp.correct]) / sum(isnan([temp.f1]));
    ratioMiddle(sIndex, 1) = 1 - sum(isnan([temp.f1]) & [temp.correct]) / sum(isnan([temp.f1]));
    ratioTail(sIndex, 1) = 1 - sum(isnan([temp.f1]) & [temp.correct]) / sum(isnan([temp.f1]));
    
    % Head
    temp = trialAll{sIndex};
    temp = temp([temp.pos] == pos(1));
    for fIndex = 1:length(f1)
        ratioHead(sIndex, fIndex + 1) = sum([temp.f1] == f1(fIndex) & [temp.correct]) / sum([temp.f1] == f1(fIndex));
    end

    % Middle
    temp = trialAll{sIndex};
    temp = temp([temp.pos] == pos(2));
    for fIndex = 1:length(f1)
        ratioMiddle(sIndex, fIndex + 1) = sum([temp.f1] == f1(fIndex) & [temp.correct]) / sum([temp.f1] == f1(fIndex));
    end

    % Tail
    temp = trialAll{sIndex};
    temp = temp([temp.pos] == pos(3));
    for fIndex = 1:length(f1)
        ratioTail(sIndex, fIndex + 1) = sum([temp.f1] == f1(fIndex) & [temp.correct]) / sum([temp.f1] == f1(fIndex));
    end
end

X = ([f0, f1] - f0) / f0 * 100; % percentage
figure;
mSubplot(1, 1, 1, "shape", "square-min");
hold on;
errorbar(X, mean(ratioHead, 1, "omitnan"), SE(ratioHead, 1, "omitnan"), "Color", "b", "LineWidth", 2, "DisplayName", "Head");
errorbar(X, mean(ratioMiddle, 1, "omitnan"), SE(ratioMiddle, 1, "omitnan"), "Color", "r", "LineWidth", 2, "DisplayName", "Middle");
errorbar(X, mean(ratioTail, 1, "omitnan"), SE(ratioTail, 1, "omitnan"), "Color", "k", "LineWidth", 2, "DisplayName", "Tail");
legend;
xlabel('Difference in frequency (%)');
ylabel('Ratio of change detection');
title(['DMS task | ', num2str(nChangePeriod), ' period change in ', num2str(f0), ' Hz tone | N = ', num2str(length(data))]);
set(gca, "XLimitMethod", "tight");
set(gca, 'FontSize', 12);
