ccc;

%% 
MATPATHs = dir("..\DATA\EEG\MAT DATA\behavior\**\102.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);
[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 1), MATPATHs, "UniformOutput", false);

%% 
thL = 0.3;
thH = 0.6;
th = 0.5;

colors = {[0, 0.5, 0], [1, 0, 0], [0, 0, 1]};

%% 
data = cellfun(@load, MATPATHs, "UniformOutput", false);
data = cellfun(@(x) struct("rules", x.rules, "trialsData", x.trialsData), data);
data = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules), data, "UniformOutput", false);

f0 = mode(cellfun(@(x) unique([x.f0]'), data));
nChangePeriod = mode(cellfun(@(x) mode([x.nChangePeriod]'), data));
dur = mode(cellfun(@(x) mode([x.dur]'), data));

pos = cellfun(@(x) unique(replaceValMat([x.pos]', 0, nan)), data, "UniformOutput", false);
pos = pos{1}(2:end);
dAmps = cellfun(@(x) unique(replaceValMat([x.deltaAmp]', 0, nan)), data, "UniformOutput", false);
dAmps = unique(cat(1, dAmps{:}));
dAmps = dAmps(2:end);

%% 
ratio_control = nan(numel(SUBJECTs), 1);
ratio = cell(numel(SUBJECTs), 1);
for sIndex = 1:numel(data)
    trialAll = data{sIndex};
    trialAll = trialAll([trialAll.key] ~= 0);
    temp = trialAll(isnan([trialAll.pos]));
    ratio_control(sIndex) = sum([temp.key] == 37) / numel(temp);

    ratio_temp = nan(numel(pos), numel(dAmps));
    for pIndex = 1:numel(pos)
        trials = trialAll([trialAll.pos] == pos(pIndex));

        for aIndex = 1:numel(dAmps)
            temp = trials([trials.deltaAmp] == dAmps(aIndex));
            ratio_temp(pIndex, aIndex) = sum([temp.key] == 37) / numel(temp);
        end

    end

    ratio{sIndex} = ratio_temp;
end

ratio = changeCellRowNum(ratio);

temp = rowFcn(@(x) x(~isnan(x)), ratio{2}, "UniformOutput", false);
temp = cat(1, temp{:});
subjectIdx = ratio_control <= thL & temp(:, end) >= thH & temp(:, end) > temp(:, 1);
if any(~subjectIdx)
    list = join(SUBJECTs(~subjectIdx), ', ');
    disp(['Subjects excluded from analysis: ', list{1}]);
end

data = data(subjectIdx);
SUBJECTs = SUBJECTs(subjectIdx);
ratio = cellfun(@(x) x(subjectIdx, :), ratio, "UniformOutput", false);
ratio = cellfun(@(x) [ratio_control, x], ratio, "UniformOutput", false);

save("subjectIdx_102.mat", "subjectIdx");

%% 
X = [0; dAmps * 100]; % percentage of change

figure;
mSubplot(1, 2, 1);
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
    L = errorbar(pIndex:(numel(ratio) + 1):numel(X) * (numel(ratio) + 1), mean(ratio{pIndex}, 1, "omitnan"), SE(ratio{pIndex}, 1, "omitnan"), "Color", colors{pIndex}, "LineWidth", 2);
    setLegendOff(L);
end
temp = xlabel("% Amplitude change");
temp.Position(2) = temp.Position(2) - abs(temp.Position(2) * 0.25);
ylabel("Ratio of change detection");

mSubplot(1, 2, 2);
hold on;
boxplotGroup({2 * ratio{2} - ratio{1} - ratio{3}}, ...
             'PrimaryLabels', {''}, ...
             'SecondaryLabels', arrayfun(@num2str, X(:)', "UniformOutput", false), ...
             'Colors', 'k', ...
             'GroupType', 'betweenGroups', 'Symbol', '+');
L = errorbar(1:2:numel(X) * 2, mean(2 * ratio{2} - ratio{1} - ratio{3}, 1, "omitnan"), SE(2 * ratio{2} - ratio{1} - ratio{3}, 1, "omitnan"), "Color", "k", "LineWidth", 2);
setLegendOff(L);
temp = xlabel("% Amplitude change");
temp.Position(2) = temp.Position(2) - abs(temp.Position(2) * 0.2);
ylabel("\DeltaRatio of change detection");

%% 
temp = arrayfun(@(x) repmat(x, 1, 3), X, "UniformOutput", false);
cat(2, temp{:});

temp = arrayfun(@(x) cellfun(@(y) y(:, x), ratio, "UniformOutput", false), 1:length(X), "UniformOutput", false);
temp = cellfun(@(x) cat(2, x{:}), temp, "UniformOutput", false);
cat(2, temp{:});

[mean(ratio{1}, 1, "omitnan")', mean(ratio{2}, 1, "omitnan")', mean(ratio{3}, 1, "omitnan")'];
