ccc;

%% Load
BLOCKPATHs = dir('..\DATA\ECOG\TDT DATA\**\Block-*');
BLOCKPATHs = arrayfun(@(x) fullfile(x.folder, x.name), BLOCKPATHs, "UniformOutput", false);

[~, ~, recordID] = cellfun(@(x) getLastDirPath(x, 2), BLOCKPATHs, "UniformOutput", false);
[~, ~, protocol] = cellfun(@(x) getLastDirPath(x, 3), BLOCKPATHs, "UniformOutput", false);

ROOTPATH = '..\DATA\ECOG\MAT DATA\pre\';
SAVEPATHs = cellfun(@(x, y) fullfile(ROOTPATH, x, y, 'data.mat'), protocol, recordID, "UniformOutput", false);

cellfun(@(x) mkdir(fileparts(x)), SAVEPATHs);

%% 
fhp = 4;
flp = 300;
fnotch = [50, 100, 150];

windowBand = 500; % ms

%% 
for bIndex = 1:numel(BLOCKPATHs)
    data = TDTbin2mat(BLOCKPATHs{bIndex});

    fs = data.streams.Llfp.fs; % Hz
    y = data.streams.Llfp.data * 1e6;
    y = ECOGFilter(y, fhp, flp, fs, "fNotch", fnotch);
    [trialAll, ITI] = seProcessFcn(data.epocs);
    window = [-windowBand, ITI - windowBand];
    trialsECOG = selectWave(y, fs, [trialAll.onset], window);

    plotRawWave(calchMean(trialsECOG([trialAll.order] == 1)), [], window);

    save(SAVEPATHs{bIndex}, "trialsECOG", "trialAll", "window", "fs");
end
