ccc;

load("..\..\DATA\MAT DATA\pre\20240619-2024061901\165\data.mat");

%% 
colors = [{[0, 0, 0]}; generateGradientColors(11, 'r')];

%% 
pos = unique([trialAll.pos])';
pos = pos(~isnan(pos));
dur = mode([trialAll.dur]) * 1000; % ms

temp = trialsEEG(isnan([trialAll.pos]));
chData(1, 1).chMean = calchMean(temp);
chData(1, 1).color = colors{1};
chData(1, 1).legend = 'control';

for pIndex = 1:length(pos)
    temp = trialsEEG([trialAll.pos] == pos(pIndex));
    chData(pIndex + 1, 1).chMean = calchMean(temp);
    chData(pIndex + 1, 1).color = colors{pIndex + 1};
    chData(pIndex + 1, 1).legend = num2str(pos(pIndex));
end

tar_pos = 50;
% plotRawWaveMultiEEG(chData([1, find(pos == tar_pos) + 1]), window, [], EEGPos_Neuracle64);
% addLines2Axes(struct("X", {0; dur / 100 * pos(pos == tar_pos); dur}));
% scaleAxes("x", [-500, 1000]);

plotRawWaveMulti(chData([1, find(pos == tar_pos) + 1]), window);
addLines2Axes(struct("X", {0; dur / 100 * pos(pos == tar_pos); dur}));
scaleAxes("x", [-500, 1000]);
