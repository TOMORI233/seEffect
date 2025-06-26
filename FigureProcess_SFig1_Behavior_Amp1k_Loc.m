ccc;

%% 
MATPATHs = dir("..\DATA\EEG\MAT DATA\behavior\**\104.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 1), MATPATHs, "UniformOutput", false);

%% 
thL = 0.3;

%% 
data = cellfun(@load, MATPATHs, "UniformOutput", false);
data = cellfun(@(x) struct("rules", x.rules, "trialsData", x.trialsData), data);
data = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules), data, "UniformOutput", false);

f0 = mode(cellfun(@(x) unique([x.f0]'), data));
nChangePeriod = mode(cellfun(@(x) mode([x.nChangePeriod]'), data));
dur = mode(cellfun(@(x) mode([x.dur]'), data));
pos = cellfun(@(x) unique([x.pos]') / 100 * dur * 1000, data, "UniformOutput", false);
pos = pos{1}(~isnan(pos{1}));

%% 
ratio_control = nan(numel(SUBJECTs), 1);
ratio = nan(numel(SUBJECTs), numel(pos)); % subject_pos

for sIndex = 1:numel(SUBJECTs)
    trialAll = data{sIndex};
    temp = [trialAll.pos]' / 100 * dur * 1000;

    idx = isnan(temp);
    ratio_control(sIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    for pIndex = 1:numel(pos)
        idx = temp == pos(pIndex);
        ratio(sIndex, pIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    end
end

subjectIdx = ratio_control <= thL;

ratio_control = ratio_control(subjectIdx);
ratio = ratio(subjectIdx, :);

%% 
figure;
mSubplot(1, 1, 1, "shape", "square-min");
hold on;
errorbar(pos, mean(ratio, 1), SE(ratio, 1), "Color", "r", "LineWidth", 2);
boxplot(ratio, 'Positions', pos, 'Colors', 'r', 'Symbol', '+');
xticklabels(num2str(pos(:)));
xlabel("Change time (ms)");
ylabel("Ratio of change detection");

%% 
[pos, mean(ratio, 1)', SE(ratio, 1)'];
