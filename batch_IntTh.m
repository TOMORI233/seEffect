ccc;

MATPATHs = dir("Data\**\102.mat");
MATPATHs(contains({MATPATHs.folder}, "preliminary")) = [];
SUBJECTs = cellfun(@(x) split(x, '\'), {MATPATHs.folder}', "UniformOutput", false);
SUBJECTs = cellfun(@(x) string(x{end}), SUBJECTs);
SAEVPATHs = strrep(string({MATPATHs.folder}'), '\Data\', '\Figures\Single\');
MATPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false));

arrayfun(@mkdir, SAEVPATHs);

trialAll = [];

for mIndex = 1:length(MATPATHs)
    load(MATPATHs(mIndex), "trialsData", "rules");
    controlIdx = find(isnan(rules.deltaAmp));
    trialAllTemp = generalProcessFcn(trialsData, rules, controlIdx);

    % reserve common fields
    if ~isempty(trialAll)
        temp1 = fieldnames(trialAll);
        temp2 = fieldnames(trialAllTemp);
        temp = intersect(temp1, temp2, "stable");
        trialAll = [keepfields(trialAll, temp); keepfields(trialAllTemp, temp)];
    else
        trialAll = trialAllTemp;
    end

    % daily result
    disp(['Miss: ', num2str(sum([trialAllTemp.miss])), '/', num2str(length(trialAllTemp))]);
    trialAllTemp([trialAllTemp.miss]) = [];
    run("start_end_effectPlot_IntTh.m");
    print(gcf, fullfile(SAEVPATHs(mIndex), "102.jpg"), "-djpeg", "-r300");
    close all;
end

%% Collect figures
FIGUREPATHs = dir("Figures\**\102.jpg");
FIGUREPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), FIGUREPATHs, "UniformOutput", false));
POPULATIONPATH = "Figures\Population\102\";
mkdir(POPULATIONPATH);
arrayfun(@(x, y) copyfile(x, fullfile(POPULATIONPATH, strcat(y, " IntTh-1kHz.jpg"))), FIGUREPATHs, SUBJECTs);

trialAllTemp = trialAll;
trialAllTemp([trialAllTemp.miss]) = [];
run("start_end_effectPlot_IntTh.m");
print(gcf, fullfile(POPULATIONPATH, "Population IntTh-1kHz.jpg"), "-djpeg", "-r300");