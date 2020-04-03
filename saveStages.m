function saveStages(batchProcess)
%% Load MATLAB data generated from 'spindleAnalysesEdf.m':
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
%% Select folder containing the text version of the scored files:
 fileType = '*.txt';
[annotationFolder, ~, ~] = batchLoadFiles(fileType);
%% Load and calculate statistics for each variable in each .MAT file:
for i = 1:numberOfDataFiles
    if batchProcess
        fileName = strtrim(fileList(i,:)); %Removes any whites space at end of file name string.
    end
    matFile = fullfile(dataFolder,fileName);
    load(matFile);
    
    %% Load scored stages:
    % Initialize variables.
    annotationFileName = strrep(fileName, '.mat', '_edited_annotations.txt');
    annotationFile = fullfile(annotationFolder,annotationFileName);
    delimiter = ',';
    startRow = 2;

    % Format string for each line of text:
    %   column1: text (%s)
    %	column2: double (%f)
    %   column3: text (%s)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%s%f%s%[^\n\r]';

    % Open the text file.
    fileID = fopen(annotationFile,'r');

    % Read columns of data according to format string.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

    % Close the text file.
    fclose(fileID);
    
    %Convert the contents of column with dates to vector of date components:
    dataArray{1} = datevec(dataArray{1}, 'HH:MM:SS.FFF');

    % Allocate imported array to column variable names
    Onset = dataArray{:, 1};
    Annotation = dataArray{:, 3};

    % Clear temporary variables
    clearvars annotationFileName annotationFile delimiter startRow formatSpec fileID dataArray ans;
    
    %Convert Onset to seconds from start of recording:
    stages.timestamp = Onset(:,4)*3600 + Onset(:,5)*60 + Onset(:,6);
    clear Onset

    %Convert spindle types to strings:
    C = char(Annotation);
    clear Annotation
    stages.type = C(:, 1);
    clear C

    save(matFile, 'stages', '-append');
end
end