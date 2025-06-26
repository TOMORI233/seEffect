ccc;

%% 
MATPATHs = dir("..\DATA\EEG\MAT DATA\behavior\**\181.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 1), MATPATHs, "UniformOutput", false);

%% 
thL = 0.3;

%% 
data = cellfun(@load, MATPATHs);

pos = arrayfun(@(x) unique([x.trialsData.changePos]'), data, "UniformOutput", false);
pos = pos{1}(2:end);

dur = 1e3; % ms

%% 
ratio_control = nan(numel(SUBJECTs), 1);
ratio = nan(numel(SUBJECTs), numel(pos)); % subject_pos

for sIndex = 1:numel(SUBJECTs)
    trialAll = data(sIndex).trialsData;
    trialAll = trialAll([trialAll.keyPressed] ~= 0);

    idx = [trialAll.changePos] == 0;
    ratio_control(sIndex) = sum([trialAll(idx).keyPressed] == 37) / sum(idx);
    for pIndex = 1:numel(pos)
        idx = [trialAll.changePos] == pos(pIndex);
        ratio(sIndex, pIndex) = sum([trialAll(idx).keyPressed] == 37) / sum(idx);
    end
end

subjectIdx = ratio_control <= thL;

ratio_control = ratio_control(subjectIdx);
ratio = ratio(subjectIdx, :);

%% 
figure;
mSubplot(1, 1, 1, "shape", "square-min");
hold on;
errorbar(pos, mean(ratio, 1, "omitnan"), SE(ratio, 1, "omitnan"), "Color", "r", "LineWidth", 2);
boxplot(ratio, 'Positions', pos, 'Colors', 'r', 'Symbol', '+');
xticklabels(num2str(pos(:)));
xlabel("% Change center");
ylabel("Ratio of change detection");

%% 
[dur * pos, mean(ratio, 1, "omitnan")', SE(ratio, 1, "omitnan")'];
