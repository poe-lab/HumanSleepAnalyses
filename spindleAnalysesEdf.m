function spindleAnalysesEdf
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
spindle.duration = dataArray{:, 2};
Annotation = dataArray{:, 3};
% Clear temporary variables
clearvars spindleFile delimiter startRow formatSpec fileID dataArray ans;

%Convert Onset to seconds from start of recording:
spindle.timestamp = Onset(:,4)*3600 + Onset(:,5)*60 + Onset(:,6);
clear Onset

%Convert spindle types to strings:
C = char(Annotation);
clear Annotation
spindle.type = C(:, 1);
clear C

% %Find spindles that meet minimum length requirement in seconds:
% realSpindles = logical(spindles.duration >= 0.5);
% spindle.type = spindle.type(realSpindles);
% spindles.timestamp = spindles.timestamp(realSpindles);
% clear Duration realSpindles

% %Separate time stamps by spindle type:
% spindles.timestampA = spindles.timestamp(logical(spindleType == 'A'));
% spindles.timestampB = spindles.timestamp(logical(spindleType == 'B'));
% spindles.timestampC = spindles.timestamp(logical(spindleType == 'C'));
% clear spindleType spindles.timestamp

%% Calculate Spindle Characteristics
startIdx = floor(spindle.timestamp.*samplingRate) + 1;
stopIdx = startIdx + floor(spindle.duration.*samplingRate);
numSpindles = length(spindle.timestamp);
for i = 1:numSpindles
    x = filtSignal(startIdx(i):stopIdx(i)); % pull out spindle from signal
    
    % Find the max peak-to-peak amplitude
    [~, absIdx] = findpeaks(abs(x)); % finds all of the peaks and troughs
    xPeaks = x(absIdx); % Gets values of peaks and troughs
    p2pAmp = abs(diff(xPeaks)); % finds all peak-to-peak amplitudes
    [spindle.maxP2pAmp(i), p2pMaxIdx] = max(p2pAmp); 
    spindle.symmetry(i) = absIdx(p2pMaxIdx)/length(x);
    clear absIdx xPeaks p2pAmp p2pMaxIdx
    
    % Compute the power spectrum of the Hann tapered data:
    dt = 1/samplingRate; % Define the sampling interval.
    df = 1/spindle.duration(i); % Determine the frequency resolution.
    fNyquist = samplingRate/2; % Determine the Nyquist frequency.
    faxis = (0:df:fNyquist); % Construct the frequency axis.
    xh = hann(length(x)).*x;
    Sxx = 2*dt^2/spindle.duration(i) * fft(xh).*conj(fft(xh)); % Compute the power spectrum of Hann tapered data.
    Sxx = real(Sxx); %Ignores imaginary component.
    Sxx = Sxx(1:length(faxis));
    clear dt df fNyquist xh
    
    % Calculate bandpower
    spindle.power(i) = bandpower(Sxx, faxis, [11 16], 'psd');
    
    % Find peak frequency 
    range = faxis>=10 & faxis<=17;
    Sxx = Sxx(range);
    faxis = faxis(range);   
    [~, idxMax] = max(Sxx);
    spindle.peakFreq(i) = faxis(idxMax);
    clear faxis Sxx range idxMax
end
%% Save data to MATLAB file:
save(matfileName, 'spindle');
