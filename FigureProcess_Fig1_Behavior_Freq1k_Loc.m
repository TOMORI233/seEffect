ccc;

%% 
MATPATHs1 = dir("..\DATA\EEG\MAT DATA\behavior\**\162.mat");
MATPATHs2 = dir("..\DATA\EEG\MAT DATA\behavior\**\163.mat");
MATPATHs1 = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs1, "UniformOutput", false);
MATPATHs2 = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs2, "UniformOutput", false);

% load("subjectIdx_161.mat", "subjectIdx");
% MATPATHs1 = MATPATHs1(subjectIdx);
% MATPATHs2 = MATPATHs2(subjectIdx);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 1), MATPATHs1, "UniformOutput", false);

%% 
thL = 0.3;

%% 
data1 = cellfun(@load, MATPATHs1);
data1 = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules), data1, "UniformOutput", false);

data2 = cellfun(@load, MATPATHs2);
data2 = arrayfun(@(x) generalProcessFcn(x.trialsData, x.rules), data2, "UniformOutput", false);

f0 = mode(cellfun(@(x) unique([x.f0]'), data1));
nChangePeriod = mode(cellfun(@(x) mode([x.nChangePeriod]'), data1));
dur1 = mode(cellfun(@(x) mode([x.dur]'), data1));
dur2 = mode(cellfun(@(x) mode([x.dur]'), data2));

pos1 = cellfun(@(x) unique([x.pos]') / 100 * dur1 * 1000, data1, "UniformOutput", false);
pos1 = pos1{1}(~isnan(pos1{1}));
pos_start1 = pos1;
pos_end1 = pos1 - dur1 * 1000;
pos2 = cellfun(@(x) unique([x.pos]') / 100 * dur2 * 1000, data2, "UniformOutput", false);
pos2 = pos2{1}(~isnan(pos2{1}));
pos_start2 = pos2;
pos_end2 = pos2 - dur2 * 1000;

pos_start = union(pos_start1, pos_start2);
pos_end = union(pos_end1, pos_end2);

%% 
[ratio_control1, ratio_control2] = deal(nan(numel(SUBJECTs), 1));
[ratio_start1, ratio_start2, ...
 ratio_end1, ratio_end2] = deal(nan(numel(SUBJECTs), numel(pos_start))); % subject_pos

for sIndex = 1:numel(SUBJECTs)
    trialAll = data1{sIndex};
    temp1 = [trialAll.pos]' / 100 * dur1 * 1000;
    temp2 = temp1 - dur1 * 1000;
    idx = isnan(temp1);
    ratio_control1(sIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    for pIndex = 1:numel(pos_start)
        idx = temp1 == pos_start(pIndex);
        ratio_start1(sIndex, pIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
        idx = temp2 == pos_end(pIndex);
        ratio_end1(sIndex, pIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    end

    trialAll = data2{sIndex};
    temp1 = [trialAll.pos]' / 100 * dur2 * 1000;
    temp2 = temp1 - dur2 * 1000;
    idx = isnan(temp1);
    ratio_control2(sIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    for pIndex = 1:numel(pos_start)
        idx = temp1 == pos_start(pIndex);
        ratio_start2(sIndex, pIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
        idx = temp2 == pos_end(pIndex);
        ratio_end2(sIndex, pIndex) = sum([trialAll(idx).key] == 37) / sum(idx);
    end
end

subjectIdx1 = load("subjectIdx_161.mat").subjectIdx;
subjectIdx2 = ratio_control1 <= thL & ratio_control2 < thL;
subjectIdx = subjectIdx1 & subjectIdx2;
% subjectIdx = subjectIdx1;
% subjectIdx = subjectIdx2;

ratio_start1 = ratio_start1(subjectIdx, :);
ratio_start2 = ratio_start2(subjectIdx, :);
ratio_end1 = ratio_end1(subjectIdx, :);
ratio_end2 = ratio_end2(subjectIdx, :);
ratio_control1 = ratio_control1(subjectIdx);
ratio_control2 = ratio_control2(subjectIdx);

%% 
[p_start, stat_start, efsz_start] = rowFcn(@mstat.signrank, ratio_start1', ratio_start2', "ErrorHandler", @mErrorFcn, "UniformOutput", false);
p_start = cat(1, p_start{:});
zval_onset = cellfun(@(x) x.zval, stat_start, "ErrorHandler", @mErrorFcn);
efsz_start = cat(1, efsz_start{:});

[p_end, stat_end, efsz_end] = rowFcn(@mstat.signrank, ratio_end1', ratio_end2', "ErrorHandler", @mErrorFcn, "UniformOutput", false);
p_end = cat(1, p_end{:});
zval_end = cellfun(@(x) x.zval, stat_end, "ErrorHandler", @mErrorFcn);
efsz_end = cat(1, efsz_end{:});

%% 
figure;
mSubplot(1, 2, 1);
hold on;
errorbar(pos_start(all(~isnan(ratio_start1), 1)) - 5, mean(ratio_start1(:, all(~isnan(ratio_start1)), 1), 1), SE(ratio_start1(:, all(~isnan(ratio_start1)), 1), 1), "Color", "r", "LineWidth", 2);
errorbar(pos_start(all(~isnan(ratio_start2), 1)) + 5, mean(ratio_start2(:, all(~isnan(ratio_start2)), 1), 1), SE(ratio_start2(:, all(~isnan(ratio_start2)), 1), 1), "Color", "b", "LineWidth", 2);
boxplot(ratio_start1, 'Positions', pos_start - 5, 'Colors', 'r', 'Symbol', '+');
boxplot(ratio_start2, 'Positions', pos_start + 5, 'Colors', 'b', 'Symbol', '+');
xticklabels(num2str(pos_start(:)));
xlabel("Change time post-onset (ms)");
ylabel("Ratio of change detection");

mSubplot(1, 2, 2);
hold on;
errorbar(pos_end(all(~isnan(ratio_end1), 1)) - 5, mean(ratio_end1(:, all(~isnan(ratio_end1)), 1), 1), SE(ratio_end1(:, all(~isnan(ratio_end1)), 1), 1), "Color", "r", "LineWidth", 2);
errorbar(pos_end(all(~isnan(ratio_end2), 1)) + 5, mean(ratio_end2(:, all(~isnan(ratio_end2)), 1), 1), SE(ratio_end2(:, all(~isnan(ratio_end2)), 1), 1), "Color", "b", "LineWidth", 2);
boxplot(ratio_end1, 'Positions', pos_end - 5, 'Colors', 'r', 'Symbol', '+');
boxplot(ratio_end2, 'Positions', pos_end + 5, 'Colors', 'b', 'Symbol', '+');
xticklabels(num2str(pos_end(:)));
xlabel("Change time pre-offset (ms)");
ylabel("Ratio of change detection");

%% 
temp = ratio_start1(:, all(~isnan(ratio_start1), 1));
[pos_start1, mean(temp, 1)', SE(temp, 1)'];

temp = ratio_start2(:, all(~isnan(ratio_start2), 1));
[pos_start2, mean(temp, 1)', SE(temp, 1)'];

temp = ratio_end1(:, all(~isnan(ratio_end1), 1));
[pos_end1, mean(temp, 1)', SE(temp, 1)'];

temp = ratio_end2(:, all(~isnan(ratio_end2), 1));
[pos_end2, mean(temp, 1)', SE(temp, 1)'];