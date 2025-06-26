% ccc;
clear; clc;

data1 = dir(fullfile(getRootDirPath(pwd, 2), "DATA\raw\**\162.mat"));
data2 = dir(fullfile(getRootDirPath(pwd, 2), "DATA\raw\**\163.mat"));

%% 
data1 = arrayfun(@(x) load(fullfile(x.folder, x.name)), data1);
data2 = arrayfun(@(x) load(fullfile(x.folder, x.name)), data2);

trialAll1 = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules, 1), data1, "UniformOutput", false);
trialAll2 = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules, 1), data2, "UniformOutput", false);

trialAll1 = cellfun(@(x) x(~[x.miss]), trialAll1, "UniformOutput", false);
trialAll2 = cellfun(@(x) x(~[x.miss]), trialAll2, "UniformOutput", false);

temp = cat(1, trialAll1{:});
f0 = mode([temp.f0]);
nChangePeriod = mode([temp.nChangePeriod]);
dur1 = mode([temp.dur]) * 1000; % ms
pos1 = unique([temp.pos]);
pos1(isnan(pos1)) = []; % percentage

temp = cat(1, trialAll2{:});
dur2 = mode([temp.dur]) * 1000; % ms
pos2 = unique([temp.pos]);
pos2(isnan(pos2)) = []; % percentage

ratio1 = zeros(length(trialAll1), length(pos1));
for sIndex = 1:length(trialAll1)
    temp = trialAll1{sIndex};
    ratio1(sIndex, :) = arrayfun(@(x) sum([temp([temp.pos] == x).correct]) / sum([temp.pos] == x), pos1);
end

ratio2 = zeros(length(trialAll2), length(pos2));
for sIndex = 1:length(trialAll2)
    temp = trialAll2{sIndex};
    ratio2(sIndex, :) = arrayfun(@(x) sum([temp([temp.pos] == x).correct]) / sum([temp.pos] == x), pos2);
end

% transfer to absolute position
pos1 = pos1 / 100 * dur1; % ms
pos2 = pos2 / 100 * dur2; % ms

% normalize
ratio1 = ratio1 - max(ratio1, [], 2);
ratio2 = ratio2 - max(ratio2, [], 2);

%% 
figure;
mSubplot(1, 2, 1, "shape", "square-min");
errorbar(pos1 - 2, mean(ratio1, 1), SE(ratio1, 1), "Color", "b", "LineWidth", 2, "DisplayName", ['Duration ', num2str(dur1), ' ms']);
hold on;
errorbar(pos2 + 2, mean(ratio2, 1), SE(ratio2, 1), "Color", "r", "LineWidth", 2, "DisplayName", ['Duration ', num2str(dur2), ' ms']);
% h = plot(pos1, ratio1, "Color", "b", "LineWidth", 1, "LineStyle", "--", "Marker", "o");
% setLegendOff(h);
% h = plot(pos2, ratio2, "Color", "r", "LineWidth", 1, "LineStyle", "--", "Marker", "o");
% setLegendOff(h);
legend;
set(gca, 'FontSize', 12);
xlabel('Change center relative to onset (ms)');
ylabel('Normalized ratio of change detection');
title(['DMS task | ', num2str(nChangePeriod), ' period change in ', num2str(f0), ' Hz tone | N = ', num2str(length(data1))]);

mSubplot(1, 2, 2, "shape", "square-min");
errorbar(pos1 - dur1 - 2, mean(ratio1, 1), SE(ratio1, 1), "Color", "b", "LineWidth", 2, "DisplayName", ['Duration ', num2str(dur1), ' ms']);
hold on;
errorbar(pos2 - dur2 + 2, mean(ratio2, 1), SE(ratio2, 1), "Color", "r", "LineWidth", 2, "DisplayName", ['Duration ', num2str(dur2), ' ms']);
% h = plot(pos1 - dur1, ratio1, "Color", "b", "LineWidth", 1, "LineStyle", "--", "Marker", "o");
% setLegendOff(h);
% h = plot(pos2 - dur2, ratio2, "Color", "r", "LineWidth", 1, "LineStyle", "--", "Marker", "o");
% setLegendOff(h);
set(gca, 'FontSize', 12);
xlabel('Change center relative to offset (ms)');
ylabel('Normalized ratio of change detection');

%% 
% relative to onset
pos_onset = pos1(ismember(pos1, pos2))';
[~, p_onset] = rowFcn(@(x, y) ttest(x, y), ratio1(:, ismember(pos1, pos2))', ratio2(:, ismember(pos2, pos1))');

% relative to offset
pos_offset = (pos1 - dur1)';
pos_offset = pos_offset(ismember(pos1 - dur1, pos2 - dur2));
[~, p_offset] = rowFcn(@(x, y) ttest(x, y), ratio1(:, ismember(pos1 - dur1, pos2 - dur2))', ratio2(:, ismember(pos2 - dur2, pos1 - dur1))');
