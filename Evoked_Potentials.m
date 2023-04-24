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

erpFolders = 'H:\Monkey-data\ERP Files';
%tfaFolder = 'H:\Monkey-data\TFA Files';%This does not have separate folders for each group!
tfaFolder = 'H:\Monkey-data\TFA Files\ChanIsolateTFA';%Here we have extracted the channels we want
%Define the output folders
erpAvgFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\ERP Grand Averages';
tfaAvgFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\TFA Grand Averages';
groupEFFTFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\ERP EFFT Grand Averages';
groupPlots = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\GroupPlots';
allPseudoERPs = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\AllPseudoERPs';
psuedoERPAverageFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\Grand Average Psuedo ERPs';
if exist(erpAvgFolder, 'dir')==0
    mkdir(erpAvgFolder);
end
if exist(tfaAvgFolder, 'dir')==0
    mkdir(tfaAvgFolder);
end
if exist(groupEFFTFolder, 'dir')==0
    mkdir(groupEFFTFolder);
end
if exist(allPseudoERPs, 'dir')==0
    mkdir(allPseudoERPs);
end
if exist(groupPlots, 'dir')==0
    mkdir(groupPlots);
end
eeglab


groups = {{'Nonket','AA','BF'},{'Nonket','AA','nBF'},{'Nonket','PA','nBF'},{'Preket','PA','nBF'}};
%Define the TFA types
tfaTypes = {'ITC','POW'};
%tfaTypes = {'ITC','POW','TFA'};

%%

%Load TFA Files from each folder
EFFTFolder = 'Evoked_Potentials';%This will store the efft files in each group's folder
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpFolders)
badFiles = {};
freqRangeName = {'theta','alpha','beta','alpha_and_beta','gamma'};
pseudoERPFolder = 'Pseudo_ERPs';

for e=3:length(erpFiles)
    allErpFiles = {dir(erpFiles{e}).name};
    for f=1:length(allErpFiles)
        if contains(allErpFiles{f},'.erp')
            outfolder = [erpFiles{e} '\' EFFTFolder];
            if exist(outfolder, 'dir')==0
                mkdir(outfolder);
            end
            
            %load ERP
            try
                % Load ERP
                %load current datat set
                ERP = pop_loaderp( 'filename', allErpFiles{f}, 'filepath', erpFiles{e});
            catch 
               badFiles{end+1} = allErpFiles{f};%Log the bad file
               %Then we want to skip the file
               continue
            end        
            %Convert to evoked tfa
            omega = 5;  % # of cycles. 3 is good for lower frequency, 6 is better for higher
            binArray = 1:ERP.nbin; % all = 1:ERP.nbin
            chanArray = 1:ERP.nchan; % for all
            blcwin = [0 0]; % in ms
            blctype = 'none'; %'subtractive', 'divisive', or 'none'
            freqRange = [0.5 50]; % TRY [0.5 100] to compare upper freq's
            incluphase = 1; %besides Power, include estimation of Phase (1=yes;  0=no)
            %data_type = 0; % 0=power; 1=phase; 2=amplitude; 3=ITC %data_type = 0; % 0=power; 1=phase; 2=amplitude; 3=ITC
            %(last value in TFA function. You can specify more than
            %one value.)
            % Process TF analysis for all bins (all channels)
            TFA = GetEvokedTimeFrequency(ERP, binArray, chanArray, freqRange, omega, blcwin, blctype, incluphase);
            
            filename = split(allErpFiles{f},'.');
            tfasetname = sprintf('%s_Evoked_power', filename{1});
            filenameTFA = fullfile(outfolder, [tfasetname '.tfa']); % now including whole path and extension .vhdr
            TFA.setname  = tfasetname;
            save(filenameTFA, 'TFA');
            %Pseudo ERP Frequency Ranges and Names
            freqRangeName = {'theta','alpha_Only','beta_Only','alpha_and_beta','delta'};
            freqRange = {4:8;8:12;12:30;8:30;1:4};
            %Generate the pseudo erp with the frequency ranges required
            for i=1:length(freqRange)
                disp(freqRange{i})
                ERP = tfa2erp(TFA, freqRange{i}, 0);% option  - 0 for POWER;  1 for PHASE
                %Save the ERP
                outfolderERP = [erpFiles{e} '\' pseudoERPFolder];
                if exist(outfolderERP, 'dir')==0
                    mkdir(outfolderERP);
                end              
                ERP = pop_savemyerp(ERP, 'erpname', [tfasetname freqRangeName{i}], 'filename', [tfasetname '_' freqRangeName{i} '.erp'], 'filepath',outfolderERP , 'Warning', 'off');% GUI: 29-Jun-2022 11:56:28
                
            end
        end

    end
end
disp("Done")


%%

%Average the groups
EFFTFolder = 'Evoked_Potentials';%This will store the evoked TFA files in each group's folder
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpFolders)
badFiles = {};

for e=3:length(erpFiles)
    cd(erpFolders)
    allErpFiles = {dir([erpFiles{e} '\'  EFFTFolder]).name};
    cd([erpFiles{e} '\'  EFFTFolder])
    grandAvgFiles = {};
    for f=1:length(allErpFiles)
        if contains(allErpFiles{f},'.tfa')
            grandAvgFiles{end+1} = allErpFiles{f};
        end
    end
    %cd([erpFiles{e} '\'  'Evoked_Potentials']);
    TFA = GrandAveragerTFA(grandAvgFiles,0);%Average TFAs
    outfolder = 'GrandAvg';
    if exist(outfolder, 'dir')==0
        mkdir(outfolder);
    end
    colorbar
    tfasetname = [erpFiles{e} '_GrandAverage']; %ITC, Baselined_TPower
    filenameTFA = fullfile(outfolder, [tfasetname '.tfa']); 
    TFA.setname  = tfasetname;
    save(filenameTFA, 'TFA');
    
    %We can also plot and save the plot now
    % plotTFA(TFA, datatype, binArray, chanArray, amprange, twindow, fwindow, 
    %           blcwin, blctype, fshading, fcontour, Ylog, plotype, surfacetype, cbname, cbscale)
    for i=1:TFA.nbin
        plotTFA(TFA, 0, [i], [1:TFA.nchan] ,[-.01 .01],...
                [-100 500], [1 30 1 3 5 7 10  15 20 30 80 100], [-100 0],'subtractive', 'interp','off',1,1);

        TitleH = title(strcat(TFA.bindescr{i},'_',tfasetname),'interpreter', 'none');

        set(TitleH, 'Position', [0, 0.4],'VerticalAlignment', 'bottom','HorizontalAlignment', 'right')
        colorbar
        ax = gca;
        fileloc = strcat(groupPlots,'\',TFA.bindescr{i},'_',tfasetname, '.png');
        saveas(ax,fileloc)
    end
end
close all
disp("Done")



%%
%Average the group Pseudo ERPs
pseudoERPFolder = 'Pseudo_ERPs';
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpFolders)
badFiles = {};
freqRangeName = {'theta','alpha_Only','beta_Only','alpha_and_beta','delta'};
for e=3:length(erpFiles)
    for freq=1:length(freqRangeName)
        cd(erpFolders)
        allErpFiles = {dir([erpFiles{e} '\'  pseudoERPFolder]).name};
        cd([erpFiles{e} '\'  pseudoERPFolder])
        grandAvgFiles = {};
        for f=1:length(allErpFiles)
            if contains(allErpFiles{f},'.erp') && contains(allErpFiles{f},freqRangeName{freq})
                display(allErpFiles{f})
                grandAvgFiles{end+1} = allErpFiles{f};
            end
        end
        pwd
        outfolder = [erpFolders '\' erpFiles{e} '\' pseudoERPFolder '\grandAvg'] ;
        if exist(outfolder, 'dir')==0
            mkdir(outfolder);
        end
        try
            [ERP ALLERP] = pop_loaderp( 'filename', grandAvgFiles, 'filepath', [erpFiles{e} '\'  pseudoERPFolder]);
        catch

            %If this doesn't work add it to a list and continue
            badFiles{end + 1} = freqRangeName{freq};
            continue;

        end



        %Compute and save the normal ERP grand average
        ERP = pop_gaverager( ALLERP , 'Erpsets', 1:length(grandAvgFiles), 'ExcludeNullBin', 'on', 'SEM', 'on' );
        ERP = pop_savemyerp(ERP, 'erpname', [erpFiles{e} '_' freqRangeName{freq} '_grandAvg'], 'filename', [erpFiles{e} '_' freqRangeName{freq} '_grandAvg.erp'], 'filepath',outfolder , 'Warning', 'off');% GUI: 29-Jun-2022 11:56:28
        %Also Save it here
        ERP = pop_savemyerp(ERP, 'erpname', [erpFiles{e} '_' freqRangeName{freq} '_grandAvg'], 'filename', [erpFiles{e} '_' freqRangeName{freq} '_grandAvg.erp'], 'filepath',psuedoERPAverageFolder , 'Warning', 'off');% GUI: 29-Jun-2022 11:56:28
        

    end
end
close all
disp("Done")

%%
%Plot the ERPs such that all the groups are shown on the same plot

erpFiles = dir(psuedoERPAverageFolder);
%folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles.name};
cd(psuedoERPAverageFolder)
badFiles = {};
freqRangeName = {'theta','alpha_Only','beta_Only','alpha_and_beta','delta'};
for freq=1:length(freqRangeName)
    plotFiles = {};
    for e=1:length(erpFiles)
        if contains(erpFiles{e},'.erp') && contains(erpFiles{e},freqRangeName{freq})
            disp(erpFiles{e})
            plotFiles{end + 1} = erpFiles{e};
        end
    end
    %Plot the ERPs
    %Now we can plot
    [ERP ALLERP] = pop_loaderp( 'filename', plotFiles, 'filepath', psuedoERPAverageFolder);
    singleFileBins = ERP.nbin;
    binDesc = ERP.bindescr;
    ERP = pop_appenderp( ALLERP , 'Erpsets',1:length(plotFiles),'Prefixes','erpname' );

    nbins = ERP.nbin;
    nchans = ERP.nchan;
    for bin=1:singleFileBins
        %plot all of the bins separately
        ERP = pop_ploterps(ERP,bin:singleFileBins:nbins,1:nchans , 'Maximize', 'on', 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 2], 'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-','-m' }, 'LineWidth',1, 'Maximize', 'on', 'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, 'xscale', [ -200 1000 -200:250:1000 ], 'YDir', 'normal' );
        title(['AllGroupsErp_' freqRangeName{freq}],'interpreter', 'none');
        ax = gca;
        filename = strcat(groupPlots,'/AllGroupsErp_Bin_',string(binDesc{bin}),'Freq_Range_',freqRangeName{freq},'.png');
        saveas(ax,filename)
    end 
    clear ALLERP
    clear ERP
end

close all

%%
%Peak Picking



% Create a function to copy over all frequency picked erp files into one
% big directory
% Define the main directory where the source directories are located
main_dir = erpFolders;

% Get a list of all the subdirectories under the main directory
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
all_dirs = erpFiles(3:end);

% Define the directory where you want to copy the '.erp' files
destination_dir = allPseudoERPs;

% Loop over the subdirectories
for i = 1:numel(all_dirs)
    source_dir = [erpFolders '\' all_dirs{i} '\' pseudoERPFolder] ;
    % Get a list of all the files in the source directory
    source_files = dir(source_dir);
    % Loop over the files in the source directory
    for j = 1:numel(source_files)
        source_file = source_files(j);
        if ~contains(source_file.name,'.erp')
            continue;
        end
        % Check if the file name contains '.erp'
        if ~isempty(strfind(source_file.name, '.erp'))
            % If it does, copy the file to the destination directory
            source_file_path = fullfile(source_dir, source_file.name);
            destination_file_path = fullfile(destination_dir, source_file.name);
            copyfile(source_file_path, destination_file_path);
        end
    end
end
%%
% Iterate over all files in the directory and generate the peak value
% information that we are looking for
erpFiles = dir(allPseudoERPs);
%folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles.name};
cd(allPseudoERPs)
badFiles = {};
%We want a list of just the participant codes
pcodes = {};
for e=erpFiles
    if contains(e,'.erp')
        p = split(e,'Evoked');
        pcodes{end+1} = p{1};
    end
end
createdTable = false;
freqRangeName = {'theta','alpha_Only','beta_Only','alpha_and_beta','delta'};
mainPeakPickTable = table();
for p=pcodes
    %add the particapant code and heading 
    header = {'Participant_Code'};
    data = {p{1}};
    for e=1:length(erpFiles)
        if contains(erpFiles{e}, '.erp') && contains(erpFiles{e},p)
            peakInfoFile = 'C:\Users\ams2590\Desktop\kjoji.txt';
            if contains(lower(erpFiles{e}),'preket')
                disp(erpFiles{e})
            end
            ERP = pop_loaderp( 'filename', erpFiles{e}, 'filepath',allPseudoERPs );

            for timeRange={[100 200], [25 75]}
                disp(timeRange)
                ALLERP = pop_geterpvalues( ERP, timeRange{1},  1:4,  1:6 , 'Baseline', 'none', 'Binlabel', 'on', 'FileFormat', 'long', 'Filename',...
                 peakInfoFile, 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',  3, 'PeakOnset',  1, 'Peakpolarity',...
                 'positive', 'Peakreplace', 'absolute', 'Resolution',  3, 'SendtoWorkspace', 'on', 'warning', 'off');

                % Append this information to a running csv file that stores all of the peak
                % picking information that we have collected.

                %Figure out a way to store the data correctly
                channelFile = readtable(peakInfoFile);
                channelFileSize = size(channelFile);

                for row=1:channelFileSize(1)
                    %Find value
                    value = sprintf('%.3f',table2array(channelFile(row,1)));
                    
                    %find channel label
                    chlabel = table2array(channelFile(row,3));%This will give a cell array
                    chlabel = chlabel{1};%This will return a string
                    
                    %Find latencies
                    latencies = sprintf('[%d %d]', timeRange{1}(1), timeRange{1}(2));
                    
                    %find bin label
                    binlabel = table2array(channelFile(row,5));%This will give a cell array
                    binlabel = binlabel{1};%This will return is back a string
                    
                    if contains(lower(binlabel),lower("aud"))
                        %change it
                        audVis = 'aud';
                    
                    elseif contains(lower(binlabel),lower("vis"))
                        audVis = 'vis';
                    end
                    
                    if contains(lower(binlabel),lower('standard')) || contains(lower(binlabel),lower('std'))
                        stdDev = 'std';
                    elseif contains(lower(binlabel),lower('Deviant')) || contains(lower(binlabel),lower('dev'))
                        stdDev = 'dev';
                    end
                    
                    binlabel = strcat(audVis,stdDev);
                        
                    
                    %Find ERP name
                    erpname = table2array(channelFile(row,6));%This will give a cell array
                    erpname = erpname{1};
                    

                    %Now we want to extract information from the erp name
                    ket = {'nonket','preket'};
                    ketlabel = '';
                    for k=ket
                        %check if the name of the file contains it
                        if contains(lower(erpname),lower(k{1}))
                            ketlabel = k;
                            break;
                        end
                    end
                    
                    %result = ismember(ketlabel, data);
                    result = any(strcmp(header,'ket'));
                    % Only add the element if it doesn't exist
                    if ~result
                        data{end +1} = ketlabel{1};
                        header{end + 1} = 'ket';
                    end
                    AAorPA = {'AA','PA'};
                    AAorPAlabel = '';
                    for a=AAorPA
                        %check if the name of the file contains it
                        if contains(lower(erpname),lower(a{1}))
                            AAorPAlabel = a;
                            break;
                        end
                    end

                    result = any(strcmp(header,'AA_or_PA'));
                    % Only add the element if it doesn't exist
                    if ~result
                        data{end +1} = AAorPAlabel{1};
                        header{end+1} = 'AA_or_PA';
                    end


                    BFornBF = {'nBF','BF'};
                    BFornBFlabel = '';
                    for a=BFornBF
                        %check if the name of the file contains it
                        if contains(lower(erpname),lower(a{1}))
                            BFornBFlabel = a;
                            break;
                        end
                    end
                    result = any(strcmp(header,'BF_or_nBF'));

                    % Only add the element if it doesn't exist
                    if ~result
                        data{end +1} = BFornBFlabel{1};
                        header{end+1} = 'BF_or_nBF';
                    end
                    %Find the frequency band
                    frequency = '';
                    for f=freqRangeName
                        if contains(lower(erpname),lower(f))
                            frequency = f{1};
                            break;
                        end
                    end
                    %Now add the datapoint that we have extracted
                    data{end +1} = value;
                    label = strcat(chlabel,'_',binlabel,'_',latencies,'_',frequency);
                    disp(label)
                    header{end+1} = label;
                    clear label;
                    
                end
            end
        end
    end
    %Now we can append the data to the Table
    %First check if we have created a table
    if ~createdTable
        if contains(lower(erpname),lower('preket'))
            disp(mainPeakPickTable);
        end
        mainPeakPickTable = cell2table(data,'VariableNames', header);%Then we want to make an empty table with the header we have
        %Then set the createdTable flag to true
        createdTable = true;
        
    else
        try
            %Now we can actually add the data
            newDataTable = cell2table(data, 'VariableNames', header);
            mainPeakPickTable = [mainPeakPickTable; newDataTable];

        catch ME
            % Check which variable name is not in common
            not_in_common = setdiff(mainPeakPickTable.Properties.VariableNames, newDataTable.Properties.VariableNames);
            disp(['Variable names not in common: ', not_in_common{:}]);
        end
    end
    clear data
    clear header
    disp("Table");
    %disp(mainPeakPickTable);
    

end


%Now we can save the file
writetable(mainPeakPickTable,[allPseudoERPs '/AllPeakPickData.csv'],'Delimiter',',');

disp("All Done")


%%





