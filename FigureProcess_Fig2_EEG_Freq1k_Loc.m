ccc;

%% Paths
MATPATHs = dir("..\DATA\EEG\MAT DATA\temp\**\167\chMean.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 1), MATPATHs, "UniformOutput", false);

%% Params
EEGPos = EEGPos_Neuracle64;

alphaVal = 0.05;

colors = [{[0, 0, 0]}; ...
          generateGradientColors(5, [0, 160, 0] / 255, 0.3); ...
          {[255, 100, 100] / 255}; ...
          flipud(generateGradientColors(5, [0, 100, 255] / 255, 0.3))];
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];

chIdx = ~ismember(EEGPos.channels, EEGPos.ignore);
exampleCh = 'POz';
chIdxExample = find(ismember(EEGPos.channelNames, exampleCh));

pIdxExample = [1, 2, 7, 12]; % 0, 5, 50, 95

windowBand = [60, 220]; % ms
rms = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));
rmfcn = @(x) rms(x, 2);

%% Load
data = cellfun(@load, MATPATHs);

for sIndex = 1:numel(SUBJECTs)
    temp = str2double({data(sIndex).chData.legend}');
    temp(isnan(temp)) = 0;
    data(sIndex).chData = addfield(data(sIndex).chData, "pos", temp);
end

fs = data(1).fs;
window = data(1).window;
data = {data.chData}';
dur = 1e3; % ms
durChange = 20; % ms
pos = cellfun(@(x) [x.pos]', data, "UniformOutput", false);
pos = unique(cat(1, pos{:})); % percentage

%% Raw wave
trialsEEG_group = cell(numel(pos), 1);
for pIndex = 1:numel(pos)
    trialsEEG_group{pIndex} = cellfun(@(x) x([x.pos] == pos(pIndex)).chMean, data, "UniformOutput", false, "ErrorHandler", @mErrorFcn);
    trialsEEG_group{pIndex} = trialsEEG_group{pIndex}(cellfun(@(x) ~all(isnan(x), 'all'), trialsEEG_group{pIndex}));
    trialsEEG_group{pIndex} = cellfun(@(x) x ./ std(x, [], 2), trialsEEG_group{pIndex}, "UniformOutput", false);
    trialsEEG_group{pIndex} = cellfun(@(x) replaceValMat(x, 0, nan), trialsEEG_group{pIndex}, "UniformOutput", false);

    chData(pIndex, 1).chMean = calchMean(trialsEEG_group{pIndex});
    chData(pIndex).chErr = calchErr(trialsEEG_group{pIndex});
    chData(pIndex).color = colors{pIndex};
    chData(pIndex).legend = num2str(pos(pIndex));
end

t = linspace(window(1), window(2), size(chData(1).chMean, 2))';

plotRawWaveMulti(chData(pIdxExample), window, [], [1, 1], chIdxExample);
addLines2Axes(struct("X", num2cell(dur * pos(pIdxExample) / 100), "color", colors(pIdxExample)));

%% 
try
    load("perm_test EEG.mat", "stats");
catch ME
    cfg = [];
    cfg.minnbchan = 1;
    cfg.neighbours = EEGPos.neighbours;
    stats = CBPT(cfg, trialsEEG_group{1}, trialsEEG_group{7});
    
    save("perm_test EEG.mat", "stats");
end

figure;
mSubplot(1, 1, 1);
imagesc("XData", t, "YData", EEGPos.channels, "CData", abs(stats.stat));
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
colormap(slanCM('YlOrRd'));
clim([0, inf]);
mColorbar("Width", 0.01);

%% GFP
gfp = cellfun(@(x) cellfun(@(y) calGFP(y, EEGPos.ignore), x, "UniformOutput", false), trialsEEG_group, "UniformOutput", false);

for pIndex = 1:numel(pos)
    gfpData(pIndex, 1).chMean = calchMean(gfp{pIndex});
    gfpData(pIndex).chErr = calchErr(gfp{pIndex});
    gfpData(pIndex).color = colors{pIndex};
    gfpData(pIndex).legend = num2str(pos(pIndex));
end

%% RM
[RM_channels, RM_control_channels] = deal(cell(numel(SUBJECTs), numel(pos) - 1));
[RM, RM_control] = deal(nan(numel(SUBJECTs), numel(pos) - 1));

for sIndex = 1:numel(SUBJECTs)
    chDataTemp = data{sIndex};

    for pIndex = 2:numel(pos)
        idx = [chDataTemp.pos] == pos(pIndex);
        windowRM = windowBand + dur * pos(pIndex) / 100;
        if any(idx)
            RM_channels{sIndex, pIndex - 1} = calRM(chDataTemp(idx).chMean, window, windowRM, rmfcn);
            RM(sIndex, pIndex - 1) = mean(RM_channels{sIndex, pIndex - 1}(chIdx));

            RM_control_channels{sIndex, pIndex - 1} = calRM(chDataTemp([chDataTemp.pos] == 0).chMean, window, windowRM, rmfcn);
            RM_control(sIndex, pIndex - 1) = mean(RM_control_channels{sIndex, pIndex - 1}(chIdx));
        end
    end
    
end

RM_channels = rowFcn(@(x) cat(2, x{:}), RM_channels', "UniformOutput", false);
RM_control_channels = rowFcn(@(x) cat(2, x{:}), RM_control_channels', "UniformOutput", false);

%% 
p_channels = cellfun(@(x, y) rowFcn(@mstat.signrank, x, y), RM_channels, RM_control_channels, "UniformOutput", false);
[~, ~, ~, p_channels] = cellfun(@(x) fdr_bh(x, alphaVal, 'pdep'), p_channels, "UniformOutput", false);

p = rowFcn(@mstat.signrank, RM', RM_control');

%% 
dRM = RM - RM_control;
dRM_channels = cellfun(@(x, y) x - y, RM_channels, RM_control_channels, "UniformOutput", false);
X = dur * pos(2:end) / 100;

figure;
mSubplot(1, 1, 1, "nSize", [1/2, 2/3], "alignment", "bottom-center");
hold on;
boxplot(dRM, 'Positions', X, 'Colors', 'k', 'Symbol', '+');
errorbar(X, mean(dRM, 1, "omitnan"), SE(dRM, 1, "omitnan"), ...
         "Color", "k", "LineWidth", 2);
yline(0);
xticklabels(num2str(X));
for pIndex = 1:numel(dRM_channels)
    ax(pIndex) = mSubplot(1, numel(dRM_channels), pIndex, "nSize", [1, 1/3], "alignment", "top-center");
    params = topoplotConfig(EEGPos, find(p_channels{pIndex} < alphaVal), 0, 10);
    topoplot(mean(dRM_channels{pIndex}, 2), EEGPos.locs, params{:});
    % title(num2str(pos(pIndex + 1) * dur / 100));
end
set(findobj(gcf, "Type", "Patch"), "FaceColor", "w");
set(gcf, "Color", "w");
% mColorbar("Width", 0.1);
cRange = scaleAxes(ax, "c", "ignoreInvisible", false);

for pIndex = 1:numel(ax)
    exportgraphics(ax(pIndex), ['..\Docs\Figures\jpg\resources\EEG topo-', num2str(pIndex), '.jpg'], "Resolution", 600);
end

exportcolorbar(cRange, '..\Docs\Figures\jpg\resources\EEG topo colorbar.jpg', flipud(slanCM('RdYlBu')));

%% 
temp = arrayfun(@(x) x.chMean(chIdxExample, :)', chData, "UniformOutput", false);
[t(:), cat(2, temp{:})];

X';
[mean(dRM, 1, "omitnan")', SE(dRM, 1, "omitnan")'];