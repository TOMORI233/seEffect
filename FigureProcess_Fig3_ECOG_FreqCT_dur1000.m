ccc;

%% Paths
DATAPATHs = dir("..\DATA\ECOG\MAT DATA\pre\SEeffect_Locs_Multi__FreqDiff_LocS14_nPeriod2_Dur1000\**\data.mat");
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

[~, ~, recordID] = cellfun(@(x) getLastDirPath(x, 1), DATAPATHs, "UniformOutput", false);

%% Params
colors = [{[0, 0, 0]}; ...
          generateGradientColors(6, [0, 160, 0] / 255, 0.3); ...
          {[255, 100, 100] / 255}; ...
          flipud(generateGradientColors(6, [0, 100, 255] / 255, 0.3))];

windowBase = [-300, 0]; % ms
windowOnset = [0, 300]; % ms

windowBand = [0, 160]; % ms
rms = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));
rmfcn = @(x) rms(x, 2);

alphaVal = 0.05;

%% 
data = cellfun(@load, DATAPATHs);

fs = data(1).fs;
window = data(1).window;
dur = 1e3; % ms
pos = [0, 25, 50, 75, 100, 150, 250, 500, 750, 850, 900, 925, 950, 975]; % ms

%% 
[RM, RM_control] = deal(cell(numel(data), numel(pos) - 1));
trialsECOG_group = cell(numel(data), numel(pos));
for dIndex = 1:numel(data)
    trialAll = data(dIndex).trialAll;
    trialsECOG = data(dIndex).trialsECOG;

    for pIndex = 1:numel(pos)
        trialsECOG_group{dIndex, pIndex} = trialsECOG([trialAll.order] == pIndex);
        
        if pIndex > 1
            windowRM = pos(pIndex) + windowBand;
            RM{dIndex, pIndex - 1} = calRM(trialsECOG_group{dIndex, pIndex}, window, windowRM, rmfcn);
            RM_control{dIndex, pIndex - 1} = calRM(trialsECOG([trialAll.order] == 1), window, windowRM, rmfcn);
        end

        chData(dIndex, pIndex).chMean = calchMean(trialsECOG_group{dIndex, pIndex});
        chData(dIndex, pIndex).color = colors{pIndex};
        chData(dIndex, pIndex).legend = num2str(pos(pIndex));
    end
    
end

t = linspace(window(1), window(2), size(chData(1).chMean, 2))';
channels = 1:size(chData(1).chMean, 1);

plotRawWaveMulti(chData(1, :), window);
plotRawWaveMulti(chData(1, :), window, [], [1, 1], 8);

%% Permutation test
try
    load("perm_test ECOG_Freq_dur1000.mat", "stats", "statsOnset");
catch ME
    for dIndex = 1:numel(data)
        stats(dIndex, 1) = CBPT([], trialsECOG_group{dIndex, 1}, trialsECOG_group{dIndex, 8});
        statsOnset(dIndex, 1) = CBPT([], cutData(trialsECOG_group{dIndex, 1}(2:end), window, windowOnset), ...
                                         cutData(trialsECOG_group{dIndex, 1}(2:end), window, windowBase));
    end
    save("perm_test ECOG_Freq_dur1000.mat", "stats", "statsOnset");
end

t_onset = linspace(windowOnset(1), windowOnset(2), size(statsOnset(1).mask, 2));
figure;
for dIndex = 1:numel(data)
    mSubplot(2, numel(data), dIndex);
    imagesc("XData", t_onset, "YData", channels, "CData", abs(statsOnset(dIndex).stat) .* statsOnset(dIndex).mask);
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    title(recordID{dIndex});
    
    mSubplot(2, numel(data), dIndex + numel(data));
    imagesc("XData", t_onset, "YData", channels, "CData", abs(statsOnset(dIndex).stat));
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
end
colormap(slanCM('YlOrRd'));
scaleAxes("c");
addLines2Axes(struct("X", 0));

tval = arrayfun(@(x) max(abs(x.stat(:, t_onset >= 0 & t_onset <= 50)), [], 2), statsOnset, "UniformOutput", false);
[~, chIdx] = cellfun(@(x) sort(x, "descend"), tval, "UniformOutput", false);
chIdx = cellfun(@(x) x(1:fix(numel(x) / 2)), chIdx, "UniformOutput", false);

figure;
for dIndex = 1:numel(data)
    mSubplot(2, numel(data), dIndex);
    imagesc("XData", t, "YData", channels, "CData", abs(stats(dIndex).stat) .* stats(dIndex).mask);
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    title(recordID{dIndex});
    
    mSubplot(2, numel(data), dIndex + numel(data));
    imagesc("XData", t, "YData", channels, "CData", abs(stats(dIndex).stat));
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
end
colormap(slanCM('YlOrRd'));
scaleAxes("x", [400, 800]);
scaleAxes("c");
addLines2Axes(struct("X", 500));

%% 
for dIndex = 1:size(RM, 1)
    RM(dIndex, :) = cellfun(@(x) cellfun(@(y) mean(y(chIdx{dIndex})), x), RM(dIndex, :), "UniformOutput", false);
    RM_control(dIndex, :) = cellfun(@(x) cellfun(@(y) mean(y(chIdx{dIndex})), x), RM_control(dIndex, :), "UniformOutput", false);
end
RM_control = cellfun(@mean, RM_control, "UniformOutput", false);
dRM = cellfun(@(x, y) x - y, RM, RM_control, "UniformOutput", false);

%% Statistics
[pRM, tvalRM] = deal(cell(size(dRM, 1), 1));
for dIndex = 1:size(dRM, 1)
    pRM_temp = nan(size(dRM, 2));
    tvalRM_temp = nan(size(dRM, 2));
    for pIndex1 = 1:size(dRM, 2)
        for pIndex2 = 1:size(dRM, 2)
            [pRM_temp(pIndex1, pIndex2), statTemp] = mstat.ttest2(dRM{dIndex, pIndex1}, dRM{dIndex, pIndex2});
            tvalRM_temp(pIndex1, pIndex2) = statTemp.tstat;
        end
    end
    pRM{dIndex} = pRM_temp;
    tvalRM{dIndex} = abs(tvalRM_temp);
end

X = pos(2:end);
figure;
for dIndex = 1:numel(tvalRM)
    mSubplot(1, numel(tvalRM), dIndex, "shape", "square-min");
    imagesc("XData", 1:size(tvalRM{dIndex}, 2), "YData", 1:size(tvalRM{dIndex}, 1), "CData", tvalRM{dIndex} .* (pRM{dIndex} < alphaVal));
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    xticks(1:size(tvalRM{dIndex}, 2));
    yticks(1:size(tvalRM{dIndex}, 1));
    xticklabels(num2str(X(:)));
    yticklabels(num2str(X(:)));
end
cb = mColorbar("Location", "southoutside", "Width", 0.03);
colormap(slanCM('YlOrRd'));
scaleAxes("c");

%% 
figure;
for dIndex = 1:size(dRM, 1)
    temp = dRM(dIndex, :);
    res = prepareGroupData(temp{:});

    mSubplot(1, size(dRM, 1), dIndex);
    hold on;
    boxplot(res(:, 1), res(:, 2), 'Positions', X, 'Colors', 'k', 'Symbol', '+');
    
    errorbar(X, cellfun(@mean, temp), cellfun(@SE, temp), "Color", "k", "LineWidth", 1);
    xticklabels(num2str(X(:)));
    title(recordID{dIndex});
end

%% 

