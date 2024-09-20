ccc;

%% 
load("D:\Education\Lab\Projects\Start-end effect\DATA\MAT DATA\pre\20240619-2024061901\166\data.mat");

windowNew = [-500, 1000];
trialsEEG = cutData(trialsEEG, window, windowNew);
window = windowNew;

%% 
colors = [{[0.5, 0.5, 0.5]}; ...
          flip(generateGradientColors(5, 'b', 0.2)); ...
          generateGradientColors(6, 'r', 0.2)];

run("config\avgConfig_Neuracle64.m");

%% 
pos = unique([trialAll.pos])';
pos(isnan(pos)) = [];
dur = mode([trialAll.dur]) * 1000; % ms

idx = isnan([trialAll.pos]);
chData(1).chMean = calchMean(trialsEEG(idx));
chData(1).color = colors{1};
chData(1).legend = 'control';
chDataGFP(1).chMean = calGFP(calchMean(trialsEEG(idx)), badChs);
chDataGFP(1).color = colors{1};
chDataGFP(1).legend = 'control';
t = linspace(window(1), window(2), length(chDataGFP(1).chMean));

for pIndex = 1:length(pos)
    idx = [trialAll.pos] == pos(pIndex);
    chData(pIndex + 1).chMean = calchMean(trialsEEG(idx));
    chData(pIndex + 1).color = colors{pIndex + 1};
    chData(pIndex + 1).legend = num2str(pos(pIndex));
    chDataGFP(pIndex + 1).chMean = calGFP(calchMean(trialsEEG(idx)), badChs);
    chDataGFP(pIndex + 1).color = colors{pIndex + 1};
    chDataGFP(pIndex + 1).legend = num2str(pos(pIndex));
end

plotRawWaveMultiEEG(chData, window, [], EEGPos_Neuracle64);
addLines2Axes(struct("X", num2cell(dur * pos / 100)));

plotRawWaveMulti(chDataGFP, window);
addLines2Axes(struct("X", num2cell(dur * pos / 100)));

figure;
plotSize = autoPlotSize(length(pos));
for pIndex = 1:length(pos)
    mSubplot(plotSize(1), plotSize(2), pIndex);
    hold on;
    plot(t, chDataGFP(1).chMean, "k", "LineWidth", 2);
    plot(t, chDataGFP(pIndex + 1).chMean, "r", "LineWidth", 2);
    addLines2Axes(gca, struct("X", {0; dur * pos(pIndex) / 100; dur}));
end
scaleAxes("x", [-100, dur + 100]);
scaleAxes("y");
