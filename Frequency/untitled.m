ccc;

% load("..\..\DATA\MAT DATA\pre\20240619-2024061901\165\data.mat");
% load("D:\Education\Lab\Projects\Hierarchical organization of spatial and temporal auditory information\DATA\MAT DATA\pre\2024092002\167\data.mat");
% load("..\..\DATA\MAT DATA\pre\2024102501\167\data.mat");
load("..\..\DATA\MAT DATA\pre\2024110901\167\data.mat");

%% 
% colors = [{[0, 0, 0]}; generateGradientColors(4, 'r')];
colors = [{[0, 0, 0]}; generateGradientColors(2, 'g'); {'b'}; {'r'}];

run("config_Neuracle64.m");

%% 
pos = [trialAll.pos]';
pos(isnan(pos)) = 0;
trialAll = addfield(trialAll, "pos", pos);
pos = unique([trialAll.pos])';
dur = mode([trialAll.dur]) * 1000; % ms

for pIndex = 1:length(pos)
    temp = trialsEEG([trialAll.pos] == pos(pIndex));
    chDataAll(pIndex, 1).chMean = calchMean(temp);
    chDataAll(pIndex, 1).color = colors{pIndex};
    chDataAll(pIndex, 1).legend = num2str(pos(pIndex));
end
chDataAll(1).legend = 'control';

tar_pos = 20;
plotRawWaveMulti(chDataAll([1, find(pos == tar_pos)]), window);
addLines2Axes(struct("X", {0; dur / 100 * pos(pos == tar_pos); dur}));
scaleAxes("x", [-500, 1500]);

plotRawWaveMulti(chDataAll([1, 3, 4, 5]), window);
addLines2Axes(struct("X", num2cell([dur / 100 * pos; 0; dur])));

%% 
chData = chDataAll;
chData = addfield(chData, "chMean", arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chData, "UniformOutput", false));
plotRawWaveMulti(chData([1, 3, 4, 5]), window);
addLines2Axes(struct("X", num2cell([dur / 100 * pos; 0; dur])));

%% 
p = wavePermTest(trialsEEG([trialAll.pos] == 0), trialsEEG([trialAll.pos] == 80), 1e3, "Tail","both", "Type", "ERP");
t = linspace(window(1), window(2), size(p, 2));

%%
figure;
mSubplot(1, 1, 1, "shape", "square-min");
imagesc("XData", t, "YData", 1:size(p, 1), "CData", - log(p));
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
addLines2Axes(struct("X", num2cell([dur / 100 * pos; 0; dur]), 'color', 'w'));