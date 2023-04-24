%Created by Adithya Shastry
%ams2590@columbia.edu

%This script will do the following: Average TFA,ERP, and generate EFFTs for
%each group. Then it will plot all of these and add them to a directory


%Clear everything, add required paths, and start up eeglab

clear
close all
pack
clc

% Paths
addpath('C:\Users\ams2590\Documents\MATLAB\eeglab2021.1');
addpath('C:\Users\ams2590\Documents\MATLAB\ColumbiaScripts');

tfaFolder = 'H:\Monkey-data\TFA Files';%This does not have separate folders for each group!
%Define the output folders
chanIsolateTFAFolder = 'H:\Monkey-data\TFA Files\ChanIsolateTFA';
if exist(chanIsolateTFAFolder, 'dir')==0
    mkdir(chanIsolateTFAFolder);
end



eeglab

%Load in the csv file and iterate through each of the file names
channelFile = readtable(['H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Monkey_MMN_PA.csv']);
channelFileSize = size(channelFile);


%Convert the files
tfaFiles = dir(tfaFolder);
folderflag = ~[tfaFiles.isdir];%We want to know if the item is a directory
tfaFiles = {tfaFiles(folderflag).name};
cd(tfaFolder)
badFiles = {};


for row=1:channelFileSize(1)
    rowentry = table2array(channelFile(row,1));
    fullFilename = split(rowentry{1},'@');
	filename = fullFilename{1};
    filename = filename(2:end);
	channels = table2array(channelFile(row,2:7));
	for f=1:length(tfaFiles)
		if contains(lower(tfaFiles{f}),lower(filename)) && ~contains(lower(tfaFiles{f}),'pow') && ~contains(lower(tfaFiles{f}),'itc')
			%Then we want to do the channel isolate function
			TFA = loadTFA('filename',tfaFiles{f},'filepath',tfaFolder);
            saveFilename = split(tfaFiles{f},'.');
            saveFilename = saveFilename{1};
            saveFilename = saveFilename(1:end-4);
			% For power
			TFA = TFA_chanIsolate(TFA, channels,{'S-top','S-bot', 'G-top' 'G-bot','I-top', 'I-bot'}, 0);

			tfasetname  = [ saveFilename '_LFPchans'];
			filenameTFA = fullfile(chanIsolateTFAFolder, [tfasetname '.tfa']); 
			TFA.setname  = tfasetname;
			save(filenameTFA, 'TFA');

			%For ITC
			TFA = TFA_chanIsolate(TFA,channels,{'S-top','S-bot', 'G-top' 'G-bot','I-top', 'I-bot'}, 1);



			tfasetname  = [ saveFilename '_LFPchans_ITC'];


			filenameTFA = fullfile(chanIsolateTFAFolder, [tfasetname '.tfa']); 
			TFA.setname  = tfasetname;
			save(filenameTFA, 'TFA');


		end	

	end
end


%%
%Do the same for ERPs
%Created by Adithya Shastry
%ams2590@columbia.edu

%This script will do the following: Average TFA,ERP, and generate EFFTs for
%each group. Then it will plot all of these and add them to a directory


%Clear everything, add required paths, and start up eeglab

clear
close all
pack
clc

% Paths
addpath('C:\Users\ams2590\Documents\MATLAB\eeglab2021.1');
addpath('C:\Users\ams2590\Documents\MATLAB\ColumbiaScripts');




tfaFolder = 'H:\Monkey-data\Missing Monkey Data\ERPs';%This does not have separate folders for each group!
%Define the output folders
chanIsolateTFAFolder = 'H:\Monkey-data\Missing Monkey Data\ERPs\ChanIsolateTFA';
if exist(chanIsolateTFAFolder, 'dir')==0
    mkdir(chanIsolateTFAFolder);
end


eeglab

%Load in the csv file and iterate through each of the file names
channelFile = readtable(['H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Monkey_MMN_PA.csv']);
channelFileSize = size(channelFile);


%Convert the files
tfaFiles = dir(tfaFolder);
folderflag = ~[tfaFiles.isdir];%We want to know if the item is a directory
tfaFiles = {tfaFiles(folderflag).name};
cd(tfaFolder)
badFiles = {};


for row=1:channelFileSize(1)
    rowentry = table2array(channelFile(row,1));
    fullFilename = split(rowentry{1},'@');
	filename = fullFilename{1};
    filename = filename(2:end);
	channels = table2array(channelFile(row,2:7));
	for f=1:length(tfaFiles)
		if contains(lower(tfaFiles{f}),lower(filename)) && ~contains(lower(tfaFiles{f}),'pow') && ~contains(lower(tfaFiles{f}),'itc')
			%Then we want to do the channel isolate function
			ERP = pop_loaderp( 'filename', tfaFiles{f}, 'filepath', tfaFolder);
            saveFilename = split(tfaFiles{f},'.');
            saveFilename = saveFilename{1};
            saveFilename = saveFilename(1:end-4);
			% For power
            ERP = pop_erpchanoperator( ERP, { ...
                char(strcat('nch1 = ch', string(channels(1)), ' label  S-top')),...
                char(strcat('nch2 = ch', string(channels(2)), ' label S-bot')),...
                char(strcat('nch3 = ch' ,string(channels(3)), ' label G-top')),...
                char(strcat('nch4 = ch' ,string(channels(4)), ' label G-bot')),...
                char(strcat('nch5 = ch' ,string(channels(5)),' label I-top')),...
                char(strcat('nch6 = ch' ,string(channels(6)),' label I-bot'))} , 'ErrorMsg', 'popup', 'KeepLocations',  0, 'Warning', 'on' );

            
            erpname = [saveFilename '_LFPchans.erp'];
            ERP  = pop_savemyerp(ERP, 'erpname', erpname, 'filename', [erpname], 'filepath', chanIsolateTFAFolder);
%     



		end	

	end
end
disp('Done')










