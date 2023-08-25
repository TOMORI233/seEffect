ccc;

MATPATHs = dir("Data\**\104.mat");
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
    run("start_end_effectPlot_IntLoc.m");
    print(gcf, fullfile(SAEVPATHs(mIndex), "104.jpg"), "-djpeg", "-r300");
    close all;
end

%% Collect figures
FIGUREPATHs = dir("Figures\**\104.jpg");
FIGUREPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), FIGUREPATHs, "UniformOutput", false));
POPULATIONPATH = "Figures\Population\104\";
mkdir(POPULATIONPATH);
arrayfun(@(x, y) copyfile(x, fullfile(POPULATIONPATH, strcat(y, " IntLoc.jpg"))), FIGUREPATHs, SUBJECTs);

trialAllTemp = trialAll;
trialAllTemp([trialAllTemp.miss]) = [];
run("start_end_effectPlot_IntLoc.m");
print(gcf, fullfile(POPULATIONPATH, "Population IntLoc.jpg"), "-djpeg", "-r300");