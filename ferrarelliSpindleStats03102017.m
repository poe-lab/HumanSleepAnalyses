function ferrarelliSpindleStats03102017(batchProcess)
%% Load MATLAB data generated from 'ferrarelli_spindle_detection.m':
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

%% Load and calculate statistics for each variable in each .MAT file:
for i = 1:numberOfDataFiles
    if batchProcess
        fileName = strtrim(fileList(i,:)); %Removes any whites space at end of file name string.
    end
    matFile = fullfile(dataFolder,fileName);
    load(matFile);
    ferrarelliSpindle.lengthRange = [0.5 3];
    % Find spindles that meet minimum length requirement in seconds:
    realSpindles = logical(ferrarelliSpindle.duration >=  ferrarelliSpindle.lengthRange(1) & ferrarelliSpindle.duration <=  ferrarelliSpindle.lengthRange(2));
%     type = spindle.type(realSpindles);
    duration = ferrarelliSpindle.duration(realSpindles);
    maxP2pAmp = ferrarelliSpindle.maxP2pAmp(realSpindles);
    timestamp = ferrarelliSpindle.timestamp(realSpindles);
    symmetry = ferrarelliSpindle.symmetry(realSpindles);
    power = ferrarelliSpindle.power(realSpindles);
    peakFreq = ferrarelliSpindle.peakFreq(realSpindles);
    clear realSpindles
    
    % Calculate averages for whole night for all spindles:
    catVector = ones(length(duration),1);
    dataArray = [duration maxP2pAmp' symmetry' power' peakFreq'];
    ferrarelliSpindle.stats.fullNightAllSpindles = StatsByCategory(catVector,dataArray);
    
    % Find time stamps for target stages:
    targetStageTS = stages.timestamp(logical(stages.type == '2')); % 2 = NREM Stage 2
    
    % Calculate averages and spindle density for each NREM period for all spindles:
    ferrarelliSpindle.density = zeros(1,4);
    for m = 1:4
        % Find indices of all spindles within the NREM period:
        targetIdx = timestamp >= nremPeriod(m, 1) & timestamp <= nremPeriod(m, 2);
        %periodData = dataArray(targetIdx, :); % characteristics of spindles within NREM period
        catVector(targetIdx) = m;
        % Find number of spindles in each NREM period:
        numSpindles = sum(targetIdx);
        % Find number of NREM stage 2 sleep in each NREM period:
        numTargetStage = sum(targetStageTS >= nremPeriod(m, 1) & targetStageTS <= nremPeriod(m, 2));
        % Calculate spindle density:
        ferrarelliSpindle.density(m) = numSpindles/numTargetStage;
    end
    ferrarelliSpindle.stats.nremPeriods = StatsByCategory(catVector,dataArray);
    save(matFile, 'ferrarelliSpindle', '-append');
end
end