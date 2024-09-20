% ccc;
clear; clc;

MATPATHs = dir("..\..\DATA\MAT DATA\single\**\104_res.mat");
SUBJECTs = cellfun(@(x) split(x, '\'), {MATPATHs.folder}', "UniformOutput", false);
SUBJECTs = cellfun(@(x) string(x{end}), SUBJECTs);
FIGURESINGLEPATHs = strrep(string({MATPATHs.folder}'), '\DATA\MAT DATA\single\', '\Figures\Single\');
MATPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false));

%% Copy figures
FIGUREPOPUPATH = "Figures\Population\104";
mkdir(FIGUREPOPUPATH);
arrayfun(@(x, y) copyfile(fullfile(x, "104.jpg"), fullfile(FIGUREPOPUPATH, strcat(y, " IntLoc.jpg"))), FIGURESINGLEPATHs, SUBJECTs);

%% Load data
data = arrayfun(@(x) load(fullfile(x)), MATPATHs);
pos = data(1).pos;
ratio = cell2mat(arrayfun(@(x) x.ratio - x.ratio(pos == 50), data, "UniformOutput", false));

%% Plot
figure;
maximizeFig;
mSubplot(1, 1, 1, 'shape', 'square-min');
errorbar(pos, mean(ratio, 1), SE(ratio, 1), "k.-", "LineWidth", 2, "MarkerSize", 20);
set(gca, 'FontSize', 12);
xlabel('Normalized change position in percentage (%)');
ylabel('\DeltaPush for difference ratio');
title('DMS behavior | Amplitude change | Location profile');
