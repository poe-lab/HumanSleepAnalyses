function spindleAutoDetection
samplingRate = 250; %250 samples/second. Replace with variable that extracts from header if needed.
working_dir=pwd;
[filename, pathname] = uigetfile({'*.edf','EDF+ files(*.edf)'},'Select the EDF+ file');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please try again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    edfFN = fullfile(pathname, filename);
end
[header signalHeader signalCell] = blockEdfLoad(edfFN);
signal = (signalCell{1,5});
matfileName = filename(1:8);
clear header signalHeader signalCell edfFN pathname filename

%% Filter signal for sigma band
sigmaHighpass = 11;
signmaLowpass = 16;
[z, p, k] = ellip(7,1,60, [sigmaHighpass signmaLowpass]/(samplingRate/2),'bandpass');
[sos, g] = zp2sos(z,p,k);
filtSignal = filtfilt(sos,g, signal);
clear z p k sos g signal

%% Load spindle annotations
[filename, pathname] = uigetfile({'*.txt','Spinde annotations(*.txt)'},'Select the spindle text file');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please try again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(working_dir);
    spindleFile = fullfile(pathname, filename);
end
clear pathname filename
%Define format of data in text file:
delimiter = ',';
startRow = 2;
%Format string for each line of text: 
formatSpec = '%s%f%s%[^\n\r]'; %column1=date strings(%s),column2=double(%f),column3=text(%s)
%Open the text file:
fileID = fopen(spindleFile,'r');
%Import the spindle data:
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
%Close the text file:
fclose(fileID);

%Convert the contents of column with dates to vector of date components:
dataArray{1} = datevec(dataArray{1}, 'HH:MM:SS.FFF');

%Allocate imported array to column variable names
Onset = dataArray{:, 1};
duration = dataArray{:, 2};
Annotation = dataArray{:, 3};
% Clear temporary variables
clearvars spindleFile delimiter startRow formatSpec fileID dataArray ans;

%Convert Onset to seconds from start of recording:
timestamp = Onset(:,4)*3600 + Onset(:,5)*60 + Onset(:,6);
clear Onset

%Convert spindle types to strings:
C = char(Annotation);
clear Annotation
spindle.type = C(:, 1);
clear C