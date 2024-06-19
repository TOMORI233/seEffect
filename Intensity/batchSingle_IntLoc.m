ccc;

MATPATHs = dir("DATA\raw\**\104.mat");
MATPATHs(contains({MATPATHs.folder}, "preliminary")) = [];

SUBJECTs = cellfun(@(x) split(x, '\'), {MATPATHs.folder}', "UniformOutput", false);
SUBJECTs = cellfun(@(x) string(x{end}), SUBJECTs);

SAVEPATHs = strrep(string({MATPATHs.folder}'), '\DATA\raw\', '\DATA\MAT DATA\single\');
FIGUREPATHs = strrep(string({MATPATHs.folder}'), '\DATA\raw\', '\Figures\Single\');
MATPATHs = string(arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false));

arrayfun(@mkdir, SAVEPATHs);
arrayfun(@mkdir, FIGUREPATHs);

%% Daily processing
for mIndex = 1:length(MATPATHs)
    load(MATPATHs(mIndex), "trialsData", "rules");
    
    controlIdx = find(isnan(rules.deltaAmp));
    trialAll = generalProcessFcn(trialsData, rules, controlIdx);

    disp(['Miss: ', num2str(sum([trialAll.miss])), '/', num2str(length(trialAll))]);
    trialAllTemp = trialAll(~[trialAll.miss]);

    run("start_end_effectPlot_IntLoc.m");
    mPrint(gcf, fullfile(FIGUREPATHs(mIndex), "104.jpg"), "-djpeg", "-r300");

    ratioControl = 1 - sum([trialsControl.correct]) / length(trialsControl);
    save(fullfile(SAVEPATHs(mIndex), "104_res.mat"), "trialAll", "deltaAmp", "ratioControl", "ratio", "pos");
    
    close all;
end
