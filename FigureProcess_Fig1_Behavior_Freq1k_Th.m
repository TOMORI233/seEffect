ccc;

%% 
MATPATHs = dir("..\DATA\EEG\MAT DATA\behavior\**\161.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);
[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 1), MATPATHs, "UniformOutput", false);

%% 
thL = 0.3;
thH = 0.6;
th = 0.5;

colors = {[0, 0.5, 0], [1, 0, 0], [0, 0, 1]};

%% 
data = cellfun(@load, MATPATHs);
data = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules), data, "UniformOutput", false);

f0 = mode(cellfun(@(x) unique([x.f0]'), data));
nChangePeriod = mode(cellfun(@(x) mode([x.nChangePeriod]'), data));
dur = mode(cellfun(@(x) mode([x.dur]'), data));

groups = cellfun(@(x) unique([replaceValMat([x.f1]', f0, nan), replaceValMat([x.pos]', 0, nan)], "rows"), data, "UniformOutput", false);
subjectIdx1 = cellfun(@(x) isequal(x, groups{1}), groups);
groups = groups{1}; % col1-freq, col2-pos
f1 = unique(groups(:, 1));
pos = unique(groups(:, 2));

%% 
ratio0 = nan(numel(data), size(groups, 1)); % subject_group
for sIndex = 1:numel(data)
    trialAll = data{sIndex};
    trialAll = trialAll([trialAll.key] ~= 0);
    temp = [replaceValMat([trialAll.f1]', f0, nan), replaceValMat([trialAll.pos]', 0, nan)];
    
    for gIndex = 1:size(groups, 1)
        idx = all(temp == groups(gIndex, :), 2);
        ratio0(sIndex, gIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    end

end

ratio = cell(numel(pos) - 1, 1);
for pIndex = 2:numel(pos)
    ratio{pIndex - 1} = ratio0(:, groups(:, 2) == pos(pIndex));
end

subjectIdx2 = ratio0(:, 1) <= thL & ratio{2}(:, end) >= thH & ratio{2}(:, end) > ratio{2}(:, 1);
subjectIdx = subjectIdx1 & subjectIdx2;
if any(~subjectIdx)
    list = join(SUBJECTs(~subjectIdx), ', ');
    disp(['Subjects excluded from analysis: ', list{1}]);
end

data = data(subjectIdx);
SUBJECTs = SUBJECTs(subjectIdx);
ratio0 = ratio0(subjectIdx, :);
ratio = cellfun(@(x) x(subjectIdx, :), ratio, "UniformOutput", false);
ratio = cellfun(@(x) [ratio0(:, 1), x], ratio, "UniformOutput", false);

save("subjectIdx_161.mat", "subjectIdx");

%% 
X = (f1 - f0) / f0 * 100; % percentage of change

try
    load("behavior fit_161.mat", "fitRes");
catch ME
    fitRes = cellfun(@(x) rowFcn(@(y) fitBehavior(y, X), x, "UniformOutput", false), ratio, "UniformOutput", false);
    save("behavior fit_161.mat", "fitRes");
end

behaviorTh = cellfun(@(x) cellfun(@(y) findBehaviorThreshold(y, th), x), fitRes, "UniformOutput", false);

%% 
figure;
ax = mSubplot(1, 2, 1, "shape", "square-min");
hold on;
boxplotGroup({ratio{:}}, ...
             'PrimaryLabels', repmat({''}, 1, numel(ratio)), ...
             'SecondaryLabels', arrayfun(@num2str, X(:)', "UniformOutput", false), ...
             'Colors', cat(1, colors{:}), ...
             'GroupType', 'betweenGroups', ...
             'Symbol', '+');
obj = findall(gca, 'Tag', 'Box');
legend(obj(1:numel(X):end), {'start', 'middle', 'end'}, "Location", "northwest");
for pIndex = 1:numel(ratio)
    L = errorbar(pIndex:(numel(ratio) + 1):numel(X) * (numel(ratio) + 1), mean(ratio{pIndex}, 1), SE(ratio{pIndex}, 1), "Color", colors{pIndex}, "LineWidth", 2);
    setLegendOff(L);
end
temp = xlabel("% Frequency change");
temp.Position(2) = temp.Position(2) - abs(temp.Position(2) * 0.25);
ylabel("Ratio of change detection");

mSubplot(2, 2, 2);
hold on;
boxplotGroup({2 * ratio{2} - ratio{1} - ratio{3}}, ...
             'PrimaryLabels', {''}, ...
             'SecondaryLabels', arrayfun(@num2str, X(:)', "UniformOutput", false), ...
             'Colors', 'k', ...
             'GroupType', 'betweenGroups', 'Symbol', '+');
L = errorbar(1:2:numel(X) * 2, mean(2 * ratio{2} - ratio{1} - ratio{3}, 1), SE(2 * ratio{2} - ratio{1} - ratio{3}, 1), "Color", "k", "LineWidth", 2);
setLegendOff(L);
temp = xlabel("% Frequency change");
temp.Position(2) = temp.Position(2) - abs(temp.Position(2) * 0.2);
ylabel("\DeltaRatio of change detection");

mSubplot(2, 2, 4, "margin_top", 0.1);
mHistogram(behaviorTh, "BinWidth", 1, "FaceColor", colors, "DistributionCurve", "show", ...
           "DisplayName", {'start', 'middle', 'end'});
xlabel("Threshold (% frequency change)");
ylabel("Counts");

%% 
temp = arrayfun(@(x) repmat(x, 1, 3), X, "UniformOutput", false);
cat(2, temp{:});

temp = arrayfun(@(x) cellfun(@(y) y(:, x), ratio, "UniformOutput", false), 1:length(X), "UniformOutput", false);
temp = cellfun(@(x) cat(2, x{:}), temp, "UniformOutput", false);
cat(2, temp{:});

[mean(ratio{1}, 1)', mean(ratio{2}, 1)', mean(ratio{3}, 1)'];

cat(2, behaviorTh{:});
cellfun(@median, behaviorTh);
cellfun(@mean, behaviorTh);