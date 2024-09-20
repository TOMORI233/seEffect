clear; clc;

% data1 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240628-2024062801\162.mat")); % 0.5s
% data2 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240628-2024062801\163.mat")); % 1s

% data1 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240703-2024070302\162.mat")); % 0.5s
% data2 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240703-2024070302\163.mat")); % 1s

% data1 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061901\162.mat")); % 0.5s
% data2 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061901\163.mat")); % 1s

% data1 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061902\162.mat"));
% data2 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240619-2024061902\163.mat"));

% data1 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240708-2024070801\162.mat"));
% data2 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240708-2024070801\163.mat"));

data1 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240710-2024071001\162.mat"));
data2 = load(fullfile(getRootDirPath(pwd, 2), "DATA\raw\20240710-2024071001\163.mat"));



%% 
f0 = mode(data1.rules.f0);
f1 = data1.rules.f1;
nChangePeriod = mode(data1.rules.nChangePeriod);
controlIdx = find(isnan(f1));

trialAll1 = generalProcessFcn(data1.trialsData, data1.rules, controlIdx);
trialAll2 = generalProcessFcn(data2.trialsData, data2.rules, controlIdx);

dur1 = mode(data1.rules.dur) * 1000; % ms
dur2 = mode(data2.rules.dur) * 1000; % ms

disp(['Miss (Duration=', num2str(dur1), 'ms): ', num2str(sum([trialAll1.miss])), '/' , num2str(length(trialAll1))]);
trialAll1([trialAll1.miss]) = [];

disp(['Miss (Duration=', num2str(dur2), 'ms): ', num2str(sum([trialAll2.miss])), '/' , num2str(length(trialAll2))]);
trialAll2([trialAll2.miss]) = [];

pos1 = unique([trialAll1.pos]);
pos1(isnan(pos1)) = [];
pos2 = unique([trialAll2.pos]);
pos2(isnan(pos2)) = [];

[ratio1, ratio2] = deal(zeros(1, length(pos1)));
for lIndex = 1:length(pos1)
    temp = trialAll1([trialAll1.pos] == pos1(lIndex));
    ratio1(lIndex) = sum([temp.correct]) / length(temp);

    temp = trialAll2([trialAll2.pos] == pos2(lIndex));
    ratio2(lIndex) = sum([temp.correct]) / length(temp);
end

% transfer to absolute position
pos1 = pos1 / 100 * dur1; % ms
pos2 = pos2 / 100 * dur2; % ms

%% 
figure;
maximizeFig;
mSubplot(1, 2, 1);
plot(pos1, ratio1, "b.-", "LineWidth", 2, "MarkerSize", 20, "DisplayName", ['Duration ', num2str(dur1), ' ms']);
hold on;
plot(pos2, ratio2, "r.-", "LineWidth", 2, "MarkerSize", 20, "DisplayName", ['Duration ', num2str(dur2), ' ms']);
legend;
set(gca, 'FontSize', 12);
xlabel('Change center relative to onset (ms)');
ylabel('Push for difference ratio');
ylim([0, 1]);
% xlim([0, min(dur1, dur2)]);
title(['DMS task | ', num2str(nChangePeriod), ' period change in ', num2str(f0), ' Hz tone']);

mSubplot(1, 2, 2);
plot(pos1 - dur1, ratio1, "b.-", "LineWidth", 2, "MarkerSize", 20, "DisplayName", ['Duration ', num2str(dur1), ' ms']);
hold on;
plot(pos2 - dur2, ratio2, "r.-", "LineWidth", 2, "MarkerSize", 20, "DisplayName", ['Duration ', num2str(dur2), ' ms']);
legend;
set(gca, 'FontSize', 12);
xlabel('Change center relative to offset (ms)');
ylabel('Push for difference ratio');
ylim([0, 1]);
% xlim([-min(dur1, dur2), 0]);
