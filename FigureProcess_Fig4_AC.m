ccc;

DATAPATHs = dir("..\DATA\NP\RNP_SEeffect_MultiFreqDiff_LocS14_Dur1000\**\ResavespkRes.mat");
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

[~, ~, recordID] = cellfun(@(x) getLastDirPath(x, 1), DATAPATHs, "UniformOutput", false);

ACPATHs = DATAPATHs(cellfun(@(x) contains(x, '_AC'), recordID));
MGBPATHs = DATAPATHs(cellfun(@(x) contains(x, '_MGB'), recordID));
ICPATHs = DATAPATHs(cellfun(@(x) contains(x, '_IC'), recordID));
recordID_AC = recordID(cellfun(@(x) contains(x, '_AC'), recordID));
recordID_MGB = recordID(cellfun(@(x) contains(x, '_MGB'), recordID));
recordID_IC = recordID(cellfun(@(x) contains(x, '_IC'), recordID));

%% Params
windowBand = [0, 200]; % ms

binSize = 5; % ms
step = 5; % ms

alphaVal = 0.05;

%% Load
load(ACPATHs{1}, "CTLParams");
pos = CTLParams.ICI2(:); % ms
window = CTLParams.Window; % ms
dur = CTLParams.S1Duration(1); % ms

dataAC = cellfun(@(x) load(x).chSpkRes', ACPATHs, "UniformOutput", false);

for index = 1:length(dataAC)
    dataAC{index} = addfield(dataAC{index}, "pos", num2cell(pos));

    temp = {dataAC{index}.chSPK}';
    temp = cellfun(@(x) keepfields(x, {'info', 'Trialspike'}), temp, "UniformOutput", false);
    temp = cellfun(@(x) renamefields(x, {'info', 'Trialspike'}, {'cluster', 'spike'}), temp, "UniformOutput", false);
    temp = cellfun(@(x) addfield(x, "spike", arrayfun(@(y) cellfun(@(z) z(:, 1), y.spike, "UniformOutput", false, "ErrorHandler", @mErrorFcnEmpty), x, "UniformOutput", false)), temp, "UniformOutput", false);
    temp = rowFcn(@(x, y) addfield(x{1}, "pos", repmat(y, numel(x{1}), 1)), temp, pos, "UniformOutput", false);
    temp = cellfun(@(x) addfield(x, "cluster", cellfun(@(y) strcat(recordID_AC{index}, '-', y), {x.cluster}', "UniformOutput", false)), temp, "UniformOutput", false);

    temp = cat(1, temp{:});

    dataAC{index} = temp;
end
dataAC = cat(1, dataAC{:});

%% 
clustersAC = unique({dataAC.cluster}', 'stable');
dfr = cell(numel(pos) - 1, numel(clustersAC));
[latencyOnset, latencyOffset] = deal(nan(numel(clustersAC), 1));
[p, tval] = deal(cell(size(dfr, 2), 1));
X = pos(2:end);

for cIndex = 1:numel(clustersAC)
    close all;

    temp = dataAC(strcmp({dataAC.cluster}, clustersAC{cIndex}));
    [psth, edges] = arrayfun(@(x) calPSTH(x.spike, window, binSize, step), temp, "UniformOutput", false);
    psth = cat(2, psth{:})';
    edges = edges{1};

    dpsth = psth(2:end, :) - psth(1, :);
    dpsth(isnan(dpsth)) = 0;
    dpsthBand = rowFcn(@(x, y) y(edges >= x + windowBand(1) & edges <= x + windowBand(2)), pos(2:end), dpsth, "UniformOutput", false);
    dpsthBand = cat(1, dpsthBand{:});

    fr = arrayfun(@(x, y) calFR(x.spike, y + windowBand), temp(2:end), pos(2:end), "UniformOutput", false);
    frBase = arrayfun(@(x) calFR(temp(1).spike, x + windowBand), pos(2:end), "UniformOutput", false);
    frBase = cellfun(@mean, frBase, "UniformOutput", false);
    dfr(:, cIndex) = cellfun(@(x, y) x - y, fr, frBase, "UniformOutput", false);

    latency = calLatency(cellfun(@(x) x - dur, temp(1).spike, "UniformOutput", false), ...
                         [0, 50], [200, 250]);
    if ~isempty(latency)
        latencyOffset(cIndex) = latency;
    end

    latency = calLatency(temp(1).spike, [0, 50], [-30, 0]);
    if ~isempty(latency)
        latencyOnset(cIndex) = latency;
    end

    tvalTemp = nan(numel(X));
    pTemp = nan(numel(X));
    for pIndex1 = 1:numel(X)
        for pIndex2 = 1:numel(X)
            [pTemp(pIndex1, pIndex2), statTemp] = mstat.ttest2(dfr{pIndex1, cIndex}, dfr{pIndex2, cIndex});
            tvalTemp(pIndex1, pIndex2) = statTemp.tstat;
        end
    end
    p{cIndex} = pTemp;
    tval{cIndex} = tvalTemp;

    % plot
    % Fig = figure;
    % mSubplot(2, 2, 1);
    % rasterData = [];
    % for pIndex = 1:numel(pos)
    %     rasterData(pIndex).X = temp(pIndex).spike;
    %     if pIndex > 1
    %         rasterData(pIndex).lines = struct("X", pos(pIndex), "style", "-", "color", "r", "width", 2);
    %     end
    % end
    % mRaster(rasterData, 5, "border", true);
    % yticklabels('');
    % xlim([-50, dur + windowBand(2)]);
    % addLines2Axes(gca, struct("X", {0; 1000}, "style", "-", "color", "r", "width", 1));
    % 
    % mSubplot(2, 2, 3);
    % imagesc("XData", edges, "YData", 1:size(dpsth, 1), "CData", dpsth);
    % set(gca, "XLimitMethod", "tight");
    % set(gca, "YLimitMethod", "tight");
    % xlim([-50, dur + windowBand(2)]);
    % yticks(1:size(dpsth, 1));
    % yticklabels(num2str(pos(2:end)));
    % xlabel("Time from onset (ms)");
    % ylabel("Change center (ms)");
    % addLines2Axes(gca, struct("X", {0; dur}));
    % 
    % mSubplot(2, 2, 2, "nSize", [1/4, 1], "alignment_horizontal", "left");
    % rasterData = [];
    % for pIndex = 1:numel(pos)
    %     rasterData(pIndex).X = cellfun(@(x) x - pos(pIndex), temp(pIndex).spike, "UniformOutput", false);
    % end
    % mRaster(rasterData, 5, "border", true);
    % yticklabels('');
    % xlim(windowBand);
    % 
    % mSubplot(2, 2, 4, "nSize", [1/4, 1], "alignment", "left-center");
    % imagesc("XData", edges(edges >= windowBand(1) & edges <= windowBand(2)), "YData", 1:size(dpsthBand, 1), "CData", dpsthBand);
    % set(gca, "XLimitMethod", "tight");
    % set(gca, "YLimitMethod", "tight");
    % yticks(1:size(dpsth, 1));
    % yticklabels(num2str(X));
    % xlabel("Time from change center (ms)");
    % mColorbar("Width", 0.1, "Label", "\DeltaFR (Hz)");
    % scaleAxes("c", "symOpt", "max");
    % 
    % mSubplot(2, 2, 2, "nSize", [3/5, 0.9], "alignment", "right-top");
    % errorbar(X, cellfun(@mean, dfr(:, cIndex)), cellfun(@SE, dfr(:, cIndex)), ...
    %          "Color", "k", "LineWidth", 2);
    % yline(0);
    % xlabel("Time from onset (ms)");
    % ylabel("\DeltaFR (Hz)");
    % 
    % mSubplot(2, 2, 4, "shape", "square-min", "alignment_horizontal", "right");
    % hold on;
    % imagesc("XData", 1:numel(X), "YData", 1:numel(X), "CData", abs(tval{cIndex}) .* (p{cIndex} < alphaVal));
    % xticks(1:3:numel(X));
    % xticklabels(num2str(X(1:3:end)));
    % yticks(1:3:numel(X));
    % yticklabels(num2str(X(1:3:end)));
    % set(gca, "XLimitMethod", "tight");
    % set(gca, "YLimitMethod", "tight");
    % [~, idx] = max(cellfun(@mean, dfr(:, cIndex)));
    % scatter(idx, idx, 100, "black", "Marker", "+", "LineWidth", 1.5);
    % colormap(gca, slanCM('YlOrRd'));
    % cb = mColorbar("Width", 0.05, "Label", "t-statistics");
    % 
    % addTitle2Fig(Fig, clustersAC{cIndex});
    % exportgraphics(Fig, ['..\Figures\NP\AC\', clustersAC{cIndex}, '.jpg'], "Resolution", 300);
end

[~, p0] = cellfun(@ttest, dfr);

%% 
dfrZ = zscore(dfrMean', 0, 2);
figure;
mSubplot(2, 2, 1);
errorbar(X, mean(dfrZ, 1), SE(dfrZ, 1), "Color", "r", "LineWidth", 2);
mSubplot(2, 2, 2);
[~, temp] = maxt(dfrZ, X, 2);
mHistogram(temp, "BinWidth", 100);

nClusters = 2;
[clusterIdx, C] = kmeans(dfrZ, nClusters, 'Distance', 'sqeuclidean', 'Replicates', 20);
tabulate(clusterIdx);

mSubplot(2, 2, 3);
hold on;
colors = lines(nClusters);
for k = 1:nClusters
    plot(X, C(k, :), 'LineWidth', 2, 'Color', colors(k, :), 'DisplayName', ['Cluster ', num2str(k), ' (', num2str(roundn(sum(clusterIdx == k) / numel(clusterIdx) * 100, -2)), '%)']);
end
xlabel('Time (ms)');
ylabel('Z-scored \DeltaFR');
title('Average \DeltaFR curve per cluster');
legend("Location", "best");

mSubplot(2, 2, 4);
[~, temp] = arrayfun(@(x) maxt(dfrZ(clusterIdx == x, :), X, 2), 1:nClusters, "UniformOutput", false);
mHistogram(temp, "BinWidth", 100);

%% 
temp = dfrMean';
temp = temp(clusterIdx == 2, :);
[~, I] = sort(temp, 2, "ascend");
[~, I2] = sortrows(I, 1:13, "ascend");

figure;
mSubplot(1, 1, 1, "shape", "square-min");
imagesc("XData", 1:numel(X), "YData", 1:size(temp, 1), "CData", temp(I2, :));

figure;



