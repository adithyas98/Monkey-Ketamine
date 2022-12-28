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
chanIsolateTFAFolder = 'H:\Monkey-data\TFA Files\ChanIsolateTFA'
if exist(chanIsolateTFAFolder, 'dir')==0
    mkdir(chanIsolateTFAFolder);
end




eeglab




%%
%Convert the files
tfaFiles = dir(tfaFolder);
folderflag = ~[tfaFiles.isdir];%We want to know if the item is a directory
tfaFiles = {tfaFiles(folderflag).name};
cd(tfaFolder)
badFiles = {};

%Load in the csv file and iterate through each of the file names
channelFile = readmatrix('Monkey_MMN_PA.csv');
for row=1:size(ChannelFile)(1)
	filename = split(ChannelFile(row,1),'@')(1)
	channels = ChannelFile(row,2:7)
	for f=1:length(tfaFiles)
		if contains(lower(tfaFiles{f}),lower(filename))
			%Then we want to do the channel isolate function
			TFA = loadTFA('filename',tfaFiles{f},'filepath',tfaFolder);

			% For power
			TFA = TFA_chanIsolate(TFA, channels,{'S-top','S-bot', 'G-top' 'G-bot','I-top', 'I-bot'}, 0)

			tfasetname  = [ tfaFiles{f} '_LFPchans_Pow'];
			filenameTFA = fullfile(chanIsolateTFAFolder, [tfasetname '.tfa']); 
			TFA.setname  = tfasetname;
			save(filenameTFA, 'TFA');

			%For ITC
			TFA = TFA_chanIsolate(TFA,channels,{'S-top','S-bot', 'G-top' 'G-bot','I-top', 'I-bot'}, 1)



			tfasetname  = [ tfaFiles{f} '_LFPchans_ITC'];


			filenameTFA = fullfile(chanIsolateTFAFolder, [tfasetname '.tfa']); 
			TFA.setname  = tfasetname;
			save(filenameTFA, 'TFA');


		end	

	end
end













