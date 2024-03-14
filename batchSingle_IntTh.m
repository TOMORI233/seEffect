ccc;

MATPATHs = dir("DATA\raw\**\102.mat");
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

    run("start_end_effectPlot_IntTh.m");
    mPrint(gcf, fullfile(FIGUREPATHs(mIndex), "102.jpg"), "-djpeg", "-r300");

    save(fullfile(SAVEPATHs(mIndex), "102_res.mat"), "trialAll", "deltaAmp", "ratioControl", "ratioHead", "ratioMid", "ratioTail", "fitResMid", "fitResHead", "fitResTail");
    
    close all;
end
