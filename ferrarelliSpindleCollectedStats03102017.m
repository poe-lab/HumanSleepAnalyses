function ferrarelliSpindleCollectedStats03102017(batchProcess)
%% Load MATLAB data generated from 'ferrarelliSpindleStats03102017.m':
working_dir=pwd;
if batchProcess
    % Select folder and get list of MAT files:
    fileType = '*.mat';
    [dataFolder, fileList, numberOfDataFiles] = batchLoadFiles(fileType);
else
    dataFolder = [];
    fileName = [];
    fileSelectedCheck = 0;
    % Select a single file:
    while isequal(fileSelectedCheck,0)
        [fileName, dataFolder] = uigetfile('*.mat', 'Select the spindle data file');
        if isempty(fileName) || isempty(dataFolder)
            uiwait(errordlg('You need to select a file. Please try again',...
                'ERROR','modal'));
        else
            fileSelectedCheck = 1;
        end 
    end
    cd(working_dir);
    numberOfDataFiles = 1;
end

%% Create output variables (format for columns is [mean SD n]):
% [ferrarelliSpindle.duration ferrarelliSpindle.maxP2pAmp' ferrarelliSpindle.symmetry' ferrarelliSpindle.power' ferrarelliSpindle.peakFreq']
tableAllNight.duration = zeros(numberOfDataFiles, 3);
tableAllNight.maxPk2PkAmp = zeros(numberOfDataFiles, 3);
tableAllNight.symmetry = zeros(numberOfDataFiles, 3);
tableAllNight.power = zeros(numberOfDataFiles, 3);
tableAllNight.peakFreq = zeros(numberOfDataFiles, 3);

nrem1.density = zeros(numberOfDataFiles, 1);
nrem1.duration = zeros(numberOfDataFiles, 3);
nrem1.maxPk2PkAmp = zeros(numberOfDataFiles, 3);
nrem1.symmetry = zeros(numberOfDataFiles, 3);
nrem1.power = zeros(numberOfDataFiles, 3);
nrem1.peakFreq = zeros(numberOfDataFiles, 3);

nrem2.density = zeros(numberOfDataFiles, 1);
nrem2.duration = zeros(numberOfDataFiles, 3);
nrem2.maxPk2PkAmp = zeros(numberOfDataFiles, 3);
nrem2.symmetry = zeros(numberOfDataFiles, 3);
nrem2.power = zeros(numberOfDataFiles, 3);
nrem2.peakFreq = zeros(numberOfDataFiles, 3);

nrem3.density = zeros(numberOfDataFiles, 1);
nrem3.duration = zeros(numberOfDataFiles, 3);
nrem3.maxPk2PkAmp = zeros(numberOfDataFiles, 3);
nrem3.symmetry = zeros(numberOfDataFiles, 3);
nrem3.power = zeros(numberOfDataFiles, 3);
nrem3.peakFreq = zeros(numberOfDataFiles, 3);

nrem4.density = zeros(numberOfDataFiles, 1);
nrem4.duration = zeros(numberOfDataFiles, 3);
nrem4.maxPk2PkAmp = zeros(numberOfDataFiles, 3);
nrem4.symmetry = zeros(numberOfDataFiles, 3);
nrem4.power = zeros(numberOfDataFiles, 3);
nrem4.peakFreq = zeros(numberOfDataFiles, 3);

%% Load and calculate statistics for each variable in each .MAT file:
for i = 1:numberOfDataFiles
    if batchProcess
        fileName = strtrim(fileList(i,:)); %Removes any whites space at end of file name string.
    end
    matFile = fullfile(dataFolder,fileName);
    load(matFile);
    % Assemble averages for whole night for all spindles:
    if isempty(ferrarelliSpindle.stats.fullNightAllSpindles.mean)
    else
        tableAllNight.duration(i,1:3) = [ferrarelliSpindle.stats.fullNightAllSpindles.mean(1) ferrarelliSpindle.stats.fullNightAllSpindles.stdDev(1) ferrarelliSpindle.stats.fullNightAllSpindles.sampleSize];
        tableAllNight.maxPk2PkAmp(i,1:3) = [ferrarelliSpindle.stats.fullNightAllSpindles.mean(2) ferrarelliSpindle.stats.fullNightAllSpindles.stdDev(2) ferrarelliSpindle.stats.fullNightAllSpindles.sampleSize];
        tableAllNight.symmetry(i,1:3) = [ferrarelliSpindle.stats.fullNightAllSpindles.mean(3) ferrarelliSpindle.stats.fullNightAllSpindles.stdDev(3) ferrarelliSpindle.stats.fullNightAllSpindles.sampleSize];
        tableAllNight.power(i,1:3) = [ferrarelliSpindle.stats.fullNightAllSpindles.mean(4) ferrarelliSpindle.stats.fullNightAllSpindles.stdDev(4) ferrarelliSpindle.stats.fullNightAllSpindles.sampleSize];
        tableAllNight.peakFreq(i,1:3) = [ferrarelliSpindle.stats.fullNightAllSpindles.mean(5) ferrarelliSpindle.stats.fullNightAllSpindles.stdDev(5) ferrarelliSpindle.stats.fullNightAllSpindles.sampleSize];
    end
    % Assemble averages for each NREM period for all spindles:
    nremPresent = find(ferrarelliSpindle.stats.nremPeriods.category(:) == 1);
    if isempty(nremPresent)
    else
        nrem1.density(i) = ferrarelliSpindle.density(1);
        nrem1.duration(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(1,1) ferrarelliSpindle.stats.nremPeriods.stdDev(1,1) ferrarelliSpindle.stats.nremPeriods.sampleSize(1)];
        nrem1.maxPk2PkAmp(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(1,2) ferrarelliSpindle.stats.nremPeriods.stdDev(1,2) ferrarelliSpindle.stats.nremPeriods.sampleSize(1)];
        nrem1.symmetry(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(1,3) ferrarelliSpindle.stats.nremPeriods.stdDev(1,3) ferrarelliSpindle.stats.nremPeriods.sampleSize(1)];
        nrem1.power(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(1,4) ferrarelliSpindle.stats.nremPeriods.stdDev(1,4) ferrarelliSpindle.stats.nremPeriods.sampleSize(1)];
        nrem1.peakFreq(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(1,5) ferrarelliSpindle.stats.nremPeriods.stdDev(1,5) ferrarelliSpindle.stats.nremPeriods.sampleSize(1)];
    end
    
    nremPresent = find(ferrarelliSpindle.stats.nremPeriods.category(:) == 2);
    if isempty(nremPresent)
    else
        nrem2.density(i) = ferrarelliSpindle.density(nremPresent);
        nrem2.duration(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,1) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,1) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem2.maxPk2PkAmp(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,2) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,2) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem2.symmetry(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,3) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,3) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem2.power(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,4) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,4) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem2.peakFreq(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,5) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,5) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
    end
    
    nremPresent = find(ferrarelliSpindle.stats.nremPeriods.category(:) == 3);
    if isempty(nremPresent)
    else
        nrem3.density(i) = ferrarelliSpindle.density(nremPresent);
        nrem3.duration(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,1) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,1) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem3.maxPk2PkAmp(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,2) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,2) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem3.symmetry(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,3) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,3) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem3.power(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,4) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,4) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem3.peakFreq(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,5) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,5) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
    end
    
    nremPresent = find(ferrarelliSpindle.stats.nremPeriods.category(:) == 4);
    if isempty(nremPresent)
    else
        nrem4.density(i) = ferrarelliSpindle.density(nremPresent);
        nrem4.duration(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,1) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,1) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem4.maxPk2PkAmp(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,2) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,2) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem4.symmetry(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,3) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,3) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem4.power(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,4) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,4) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
        nrem4.peakFreq(i,1:3) = [ferrarelliSpindle.stats.nremPeriods.mean(nremPresent,5) ferrarelliSpindle.stats.nremPeriods.stdDev(nremPresent,5) ferrarelliSpindle.stats.nremPeriods.sampleSize(nremPresent)];
    end
end
matFile = fullfile(dataFolder,['assembledStatsFerrarelliSpindles' num2str(ferrarelliSpindle.lengthRange(1)) 'sTo' num2str(ferrarelliSpindle.lengthRange(2)) 's.mat']);    
save(matFile, 'tableAllNight', 'nrem1', 'nrem2', 'nrem3', 'nrem4', 'fileList');
end