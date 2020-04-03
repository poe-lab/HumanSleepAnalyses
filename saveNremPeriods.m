function a=saveNremPeriods(a)
working_dir=pwd;
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
matFile = fullfile(dataFolder,fileName);
nremPeriod=reshape(a, 2,4)';
a=[];
save(matFile, 'nremPeriod', '-append');
clear nremPeriod
end