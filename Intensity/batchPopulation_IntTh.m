ccc;

MATPATHs = dir("DATA\MAT DATA\single\**\102_res.mat");
SUBJECTs = cellfun(@(x) split(x, '\'), {MATPATHs.folder}', "UniformOutput", false);
SUBJECTs = cellfun(@(x) string(x{end}), SUBJECTs);
FIGURESINGLEPATHs = strrep(string({MATPATHs.folder}'), '\DATA\MAT DATA\single\', '\Figures\Single\');
MATPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false));

%% Copy figures
FIGUREPOPUPATH = "Figures\Population\102";
mkdir(FIGUREPOPUPATH);
arrayfun(@(x, y) copyfile(fullfile(x, "102.jpg"), fullfile(FIGUREPOPUPATH, strcat(y, " IntTh-1kHz.jpg"))), FIGURESINGLEPATHs, SUBJECTs);

%% Load data
data = arrayfun(@(x) load(fullfile(x)), MATPATHs);
deltaAmp = unique(vertcat(data.deltaAmp));
ratioHead = cell(length(data), length(deltaAmp));
ratioMid  = cell(length(data), length(deltaAmp));
ratioTail = cell(length(data), length(deltaAmp));

for sIndex = 1:length(data)
    idx = find(ismember(deltaAmp, data(sIndex).deltaAmp));

    for dIndex = 1:length(idx)
        ratioHead{sIndex, idx(dIndex)} = data(sIndex).ratioHead(dIndex);
        ratioMid {sIndex, idx(dIndex)} = data(sIndex).ratioMid (dIndex);
        ratioTail{sIndex, idx(dIndex)} = data(sIndex).ratioTail(dIndex);
    end

end

deltaMidHead  = rowFcn(@(x) cell2mat(x), (ratioMid  - ratioHead)', "UniformOutput", false);
deltaMidTail  = rowFcn(@(x) cell2mat(x), (ratioMid  - ratioTail)', "UniformOutput", false);
deltaTailHead = rowFcn(@(x) cell2mat(x), (ratioTail - ratioHead)', "UniformOutput", false);

ratioHead = rowFcn(@(x) cell2mat(x), ratioHead', "UniformOutput", false);
ratioMid  = rowFcn(@(x) cell2mat(x), ratioMid' , "UniformOutput", false);
ratioTail = rowFcn(@(x) cell2mat(x), ratioTail', "UniformOutput", false);

%% Plot
figure;
maximizeFig;
mSubplot(1, 1, 1, [0.45, 1], "alignment", "center-left");
errorbar(deltaAmp, cellfun(@mean, ratioMid), cellfun(@SE, ratioMid), 'r.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Middle');
hold on;
errorbar(deltaAmp - 0.001, cellfun(@mean, ratioHead), cellfun(@SE, ratioHead), 'b.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Head');
errorbar(deltaAmp + 0.001, cellfun(@mean, ratioTail), cellfun(@SE, ratioTail), 'k.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Tail');
set(gca, 'FontSize', 14);
legend("Location", "best");
title(['DMS behavior | N = ', num2str(length(data))]);
xlabel('Difference in amplitude');
ylabel('Push for difference ratio');
set(gca, "XLimitMethod", "tight");
ylim([0, 1]);

mSubplot(1, 1, 1, [0.45, 1], "alignment", "center-right");
errorbar(deltaAmp, cellfun(@mean, deltaMidHead), cellfun(@SE, deltaMidHead), 'b.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Middle - Head');
hold on;
errorbar(deltaAmp - 0.001, cellfun(@mean, deltaMidTail), cellfun(@SE, deltaMidTail), 'k.-', 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Middle - Tail');
errorbar(deltaAmp + 0.001, cellfun(@mean, deltaTailHead), cellfun(@SE, deltaTailHead), 'Color', [0.5, 0.5, 0.5], "Marker", ".", 'LineWidth', 2, "MarkerSize", 15, 'DisplayName', 'Tail - Head');
set(gca, 'FontSize', 14);
legend("Location", "best");
title(['DMS behavior | N = ', num2str(length(data))]);
xlabel('Difference in amplitude');
ylabel('\DeltaPush for difference ratio');
set(gca, "XLimitMethod", "tight");

%% Threshold
thMid  = cellfun(@(x) findBehaviorThreshold(x, 0.5), {data.fitResMid })';
thHead = cellfun(@(x) findBehaviorThreshold(x, 0.5), {data.fitResHead})';
thTail = cellfun(@(x) findBehaviorThreshold(x, 0.5), {data.fitResTail})';

[~, pMidHead]  = ttest(thMid , thHead);
[~, pMidTail]  = ttest(thMid , thTail);
[~, pHeadTail] = ttest(thHead, thTail);

figure;
maximizeFig;
mSubplot(1, 3, 1, "shape", "square-min", "margin_left", 0.1);
scatter(thHead, thMid, 100, "black", "filled");
xlabel("Threshold for Head");
ylabel("Threshold for Middle");
title(['Pairwise t-test p = ', num2str(pMidHead), ' | N = ', num2str(length(data))]);
set(gca, "FontSize", 12);
xyLim = [0, max([get(gca, "XLim"), get(gca, "YLim")])];
xlim(xyLim);
ylim(xyLim);
addLines2Axes(gca);

mSubplot(1, 3, 2, "shape", "square-min", "margin_left", 0.1);
scatter(thTail, thMid, 100, "black", "filled");
xlabel("Threshold for Tail");
ylabel("Threshold for Middle");
title(['Pairwise t-test p = ', num2str(pMidTail), ' | N = ', num2str(length(data))]);
set(gca, "FontSize", 12);
xyLim = [0, max([get(gca, "XLim"), get(gca, "YLim")])];
xlim(xyLim);
ylim(xyLim);
addLines2Axes(gca);

mSubplot(1, 3, 3, "shape", "square-min", "margin_left", 0.1);
scatter(thHead, thTail, 100, "black", "filled");
xlabel("Threshold for Head");
ylabel("Threshold for Tail");
title(['Pairwise t-test p = ', num2str(pHeadTail), ' | N = ', num2str(length(data))]);
set(gca, "FontSize", 12);
xyLim = [0, max([get(gca, "XLim"), get(gca, "YLim")])];
xlim(xyLim);
ylim(xyLim);
addLines2Axes(gca);

