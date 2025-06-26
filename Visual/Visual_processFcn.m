ccc;
variableNames = {'trialsData'}; 
% data = dir(fullfile(getRootDirPath(pwd, 1), "MATDATA\EEG\Behavior\**\180.mat"));
data = dir(fullfile('F:\PAPER\(forming)start end effect\reference code\Visual\**\180.mat'));

dur = 1; % s
%% 
data = arrayfun(@(x) load(fullfile(x.folder, x.name), variableNames{:}), data);
trialAll = arrayfun(@(x) x.trialsData, data, "UniformOutput", false);
trialAll = cellfun(@(x) x(~[x.miss]), trialAll, "UniformOutput", false);

temp = cat(1, trialAll{:});
pos = unique([temp.changePos]);
pos(isnan(pos)) = []; % percentage

ratioAll = zeros(length(trialAll), length(pos));
for sIndex = 1:length(trialAll)
    temp = trialAll{sIndex};
    ratioAll(sIndex, :) = arrayfun(@(x) sum([temp([temp.changePos] == x).correct]) / sum([temp.changePos] == x), pos);
    reactTimeAll(sIndex, :) = arrayfun(@(x) mean([temp([temp.changePos] == x).RT] * 1000), pos);
end

% transfer to absolute position
pos = pos * dur * 1000; % ms

% normalize
% ratioAll = ratioAll - max(ratioAll, [], 2);
%% 
figure;
mSubplot(1, 2, 1, "shape", "square-min");
errorbar(pos, mean(ratioAll, 1), SE(ratioAll, 1), "Color", "k", "LineWidth", 2);
xticks(pos);
xticklabels(num2cell(pos, 1));
set(gca, 'FontSize', 12);
xlabel('Change center relative to onset (ms)');
ylabel('Normalized ratio of change detection');
title(['Visual task: ChangeDur ', num2str(50), ' ms | N = ', num2str(length(data))]);

mSubplot(1, 2, 2, "shape", "square-min");
errorbar(pos, mean(reactTimeAll, 1), SE(reactTimeAll, 1), "Color", "k", "LineWidth", 2);
xticks(pos);
xticklabels(num2cell(pos, 1));
set(gca, 'FontSize', 12);
xlabel('Change center relative to onset (ms)');
ylabel('Reaction Time (ms)');
