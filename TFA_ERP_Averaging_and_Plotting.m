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
tfaFolder = 'H:\Monkey-data\TFA Files';%This does not have separate folders for each group!
%Define the output folders
erpAvgFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\ERP Grand Averages';
tfaAvgFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\TFA Grand Averages';
groupEFFTFolder = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\Grand Averages\ERP EFFT Grand Averages';
groupPlots = 'H:\Monkey-data\Analysis_Files\Adi Averaging and Plotting\GroupPlots';
if exist(erpAvgFolder, 'dir')==0
    mkdir(erpAvgFolder);
end
if exist(tfaAvgFolder, 'dir')==0
    mkdir(tfaAvgFolder);
end
if exist(groupEFFTFolder, 'dir')==0
    mkdir(groupEFFTFolder);
end
if exist(groupPlots, 'dir')==0
    mkdir(groupPlots);
end
eeglab

groups = {{'Nonket','AA','BF'},{'Nonket','AA','nBF'},{'Nonket','PA','nBF'},{'Preket','PA','nBF'}};
%Define the TFA types
tfaTypes = {'ITC','POW','TFA'};
%%
%TODO:Create EFFT for each individual and then do a grand average
EFFTFolder = 'EFFTFiles';%This will store the efft files in each group's folder
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpFolders)
badFiles = {};
for e=3:length(erpFiles)
    allErpFiles = {dir(erpFiles{e}).name};
    for f=1:length(allErpFiles)
        if contains(allErpFiles{f},'.erp')
            outfolder = [erpFiles{e} '\' EFFTFolder];
            if exist(outfolder, 'dir')==0
                mkdir(outfolder);
            end
            %Load the erp file
            try
                [ERP ALLERP] = pop_loaderp( 'filename', allErpFiles{f}, 'filepath', erpFiles{e});
                %compute the efft 
                EFFT = pop_averager( ERP , 'Compute', 'EFFT', 'Criterion', 'good', 'TaperWindow', {'hanning' [ -500 1498]} );%Some of the files were created from older versions of Matlab
            catch
                %If this doesn't work add it to a list and continue
                badFiles{end + 1} = erpFiles{e};
                continue;
            end

            %and save the file
            EFFT = pop_savemyerp(EFFT, 'erpname', [allErpFiles{f} '_EFFT'], 'filename', [allErpFiles{f} '_EFFT' '.erp'], 'filepath', outfolder, 'Warning', 'on');% GUI: 29-Jun-2022 11:56:28
        end
    end
end
disp("Completed EFFT File Creation")
disp(badFiles)
%EFFT Group Averaging
%ERP Averaging 
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpFolders)
badFiles = {};
for e=3:length(erpFiles)
    EFFTFolder = [erpFiles{e} '\' EFFTFolder];
    %list out all of the files in this folder
    allErpFiles = {dir(EFFTFolder).name};
    grandAvgFiles = {};
    for f=1:length(allErpFiles)
        if contains(allErpFiles{f},'.erp')
            %Then we want to add it to the grand average list
            grandAvgFiles{end + 1} = allErpFiles{f};
        end
    end
    
    %Now that we have added everything, average the ERP files
    try
        [ERP ALLERP] = pop_loaderp( 'filename', grandAvgFiles, 'filepath', EFFTFolder);
    catch

        %If this doesn't work add it to a list and continue
        badFiles{end + 1} = erpFiles{e};
        continue;

    end
    %Compute and save the normal ERP grand average
    ERP = pop_gaverager( ALLERP , 'Erpsets', 1:length(grandAvgFiles), 'ExcludeNullBin', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', erpFiles{e}, 'filename', [erpFiles{e} '.erp'], 'filepath',groupEFFTFolder , 'Warning', 'on');% GUI: 29-Jun-2022 11:56:28
    
    %Compute and save the EFFT
    %EFFT = pop_averager( ALLERP , 'Compute', 'EFFT', 'Criterion', 'good', 'TaperWindow', {'hanning' [ -500 1498]} );
    %EFFT = pop_savemyerp(EFFT, 'erpname', [erpGroups{e} 'EFFT'], 'filename', [erpGroups{e} 'EFFT' '.erp'], 'filepath', erpEFFTFolder, 'Warning', 'on');% GUI: 29-Jun-2022 11:56:28
end
disp("Done with the ERP Averaging");
disp(badFiles)

%%
%ERP Averaging 
erpFiles = dir(erpFolders);
folderflag = [erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpFolders)
badFiles = {};
for e=3:length(erpFiles)
    
    %list out all of the files in this folder
    allErpFiles = {dir(erpFiles{e}).name};
    grandAvgFiles = {};
    for f=1:length(allErpFiles)
        if contains(allErpFiles{f},'.erp')
            %Then we want to add it to the grand average list
            grandAvgFiles{end + 1} = allErpFiles{f};
        end
    end
    
    %Now that we have added everything, average the ERP files
    try
        [ERP ALLERP] = pop_loaderp( 'filename', grandAvgFiles, 'filepath', erpFiles{e});
    catch

        %If this doesn't work add it to a list and continue
        badFiles{end + 1} = erpFiles{e};
        continue;

    end
    %Compute and save the normal ERP grand average
    ERP = pop_gaverager( ALLERP , 'Erpsets', 1:length(grandAvgFiles), 'ExcludeNullBin', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', erpFiles{e}, 'filename', [erpFiles{e} '.erp'], 'filepath',erpAvgFolder , 'Warning', 'off');% GUI: 29-Jun-2022 11:56:28
    
    %Compute and save the EFFT
    %EFFT = pop_averager( ALLERP , 'Compute', 'EFFT', 'Criterion', 'good', 'TaperWindow', {'hanning' [ -500 1498]} );
    %EFFT = pop_savemyerp(EFFT, 'erpname', [erpGroups{e} 'EFFT'], 'filename', [erpGroups{e} 'EFFT' '.erp'], 'filepath', erpEFFTFolder, 'Warning', 'on');% GUI: 29-Jun-2022 11:56:28
end
disp("Done with the ERP Averaging");
disp(badFiles)


%%
% Average TFAs for the groups

%Find the folder with the files
tfaFiles = dir(tfaFolder);
folderflag = ~[tfaFiles.isdir];%We want to know if the item is a directory
tfaFiles = {tfaFiles(folderflag).name};
cd(tfaFolder)
badFiles = {};
disp([groups{1}])
%We need to iterate through each group, find the files that match in name
%and then add them to the list of files to average
for g=1:length(groups)
    for tfatype=1:length(tfaTypes)
        grandAvgFiles = {};%Store files to average
        for t=1:length(tfaFiles)
            if ~contains(lower(tfaFiles{t}),'.tfa') 
                continue;%we aren't looking at a tfa file, so continue
            end
            
            filenameOnly = split(tfaFiles{t},'.');
            if ~contains(lower(filenameOnly{1}),lower(tfaTypes{tfatype}))
                continue;
            end
            matchFlag = true;
        	for w=1:length(groups{g})
                %We want to check if all of the words match, if not
                %break

                if contains(lower(filenameOnly{1}),lower(groups{g}{w})) 
                    matchFlag = true;
                else
                    matchFlag = false;
                end
            end
            if matchFlag
                grandAvgFiles{end + 1} = tfaFiles{t};
            else
                continue;
            end
        end
        %Do the averaging
        try
            TFA = GrandAveragerTFA(grandAvgFiles, 0); %type of data to work on specified after comma: 0=power; 1=phase; 2=amplitude; 3=ITC 
        catch
            %We can try to see if we can use 3=ITC
            try 

                TFA = GrandAveragerTFA(grandAvgFiles,3);
            catch
                %If this doesn't work add it to a list and continue
                badFiles{end + 1} = [tfaTypes{tfatype} '_' strjoin(groups{g},'_')];
                disp([tfaTypes{tfatype} '_' strjoin(groups{g},'_')]);
                continue;
            end
        end
        tfasetname = ['Group_' strjoin(groups{g},'_'),'_' tfaTypes{tfatype} '_grandAverage']; %ITC, Baselined_TPower
        filenameTFA = fullfile(tfaAvgFolder, [tfasetname '.tfa']); 
        TFA.setname  = tfasetname;
        save(filenameTFA, 'TFA');
    end

end

disp("Done with TFA Averaging")




%%
%TFA Plotting

tfaFiles = dir(tfaAvgFolder);
folderflag = ~[tfaFiles.isdir];%We want to know if the item is a directory
tfaFiles = {tfaFiles(folderflag).name};
cd(tfaAvgFolder)
badFiles = {};
for tfatype=1:length(tfaTypes)
    for t=1:length(tfaFiles)
        fileNameOnly = split(tfaFiles{t},'.');
        %Check to see if we are actually looking at a tfa file
        if ~contains(lower(tfaFiles{t}),'.tfa') || ~contains(lower(fileNameOnly{1}),lower(tfaTypes{tfatype}))
            disp(tfaTypes{tfatype})
            disp(tfaFiles{t})
            continue;
        end
        
        %Now we can plot
        
        TFA = loadTFA('filename',tfaFiles{t},'filepath',tfaAvgFolder); %load TFA file to plot
        %We want to set this setting differently based on the type of TFA
        %we are looking at, this will be based on the tfaTypes variable
        %above
        %tfaTypes = {'ITC','POW','TFA'}; For reference
        if contains(tfaFiles{t},tfaTypes{1})
            datatype = 3; % 0=power; 1=phase; 2=amplitude; 3=ITC (you can specify more than one value)
        else
            datatype = 0;
        end
        binArray = [1]; % Bin indices to plot
        chanArray = [5]; % Maximum number of channels = TFA.nchan
        if contains(tfaFiles{t},tfaTypes{3})
            %500 BL
            amprange = [-0.01 0.09]; % Amplitude range (Z-scale) (displayed as colormap) to plot.
        elseif contains(tfaFiles{t},tfaTypes{2})
            %Evoked Power
             amprange = [0 3]; % Amplitude range (Z-scale) (displayed as colormap) to plot.
        elseif contains(tfaFiles{t},tfaTypes{1})
             % ITC
             amprange = [0 0.5]; % Amplitude range (Z-scale) (displayed as colormap) to plot.
        else
            amprange = [0 1];
        end
        twindow = [-200 1000 -200:250:1000]; % Time window where the first two numbers are the min and max and then remaining numbers designate the ticks
        fwindow = [0 28    2 4 7 12.5 30 ]; % Time frequency window structured similarly to the twindow
        blcwin = [-500 0]; % Baseline correction window
        blctype = 'None'; % 'Divisive','none', or subtractive are the other types
        fshading = 'interp'; % Controls of color shading. Can be 'flat' or  'interp'.
        fcontour = 'off'; % displays isolines calculated from matrix Z and fills the areas between the isolines using constant colors corresponding to the current figure's colormap. Can be 'on' or  'off'.
        Ylog = 1; % Logarithmic scale for frequency range (fwindow). Can be 1 (means apply log scale)  or  0 (means apply linear scale).
        plotype = 1; % Plotting style: 0 means topographic; 1 means rectangular array. IMPORTANT: if you enter chanArray as a cell array then this 'plotype' option will be ignored.
        % clrbar =0; % 0 = colorbar off, 1 = on
        % fontsize = 16;
        % fontname = 'Arial';
        % % x_axis_width = .6;
        % % y_axis_height = .8;
        % electrode_title = 0;
        %Make our plot
%         subplot(2,3,i);
        plotTFA(TFA, datatype, binArray, chanArray, amprange, twindow, fwindow, blcwin, blctype,fshading,fcontour,Ylog,plotype);
        
        title(fileNameOnly{1},'interpreter', 'none')
        %title('hello','interpreter', 'none');
        colorbar
        ax = gca;
        saveas(ax,[groupPlots '\' tfaFiles{t} '.png'])


    end
end 
disp("Done Plotting TFA")
close all

%%
%ERP plotting




erpFiles = dir(erpAvgFolder);
folderflag = ~[erpFiles.isdir];%We want to know if the item is a directory
erpFiles = {erpFiles(folderflag).name};
cd(erpAvgFolder)
badFiles = {};
files = {};
fileNameOnly = {};
for t=1:length(erpFiles)
     f = split(erpFiles{t},'.');
     fileNameOnly{end+1} = f{1};
    %Check to see if we are actually looking at a erp file
    
    if contains(lower(erpFiles{t}),'.erp') 
        files{end+1} = erpFiles{t};
    end
end
%Now we can plot
[ERP ALLERP] = pop_loaderp( 'filename', files, 'filepath', erpAvgFolder);
singleFileBins = ERP.nbin;
ERP = pop_appenderp( ALLERP , 'Erpsets',1:4,'Prefixes',fileNameOnly );

nbins = ERP.nbin;
nchans = ERP.nchan;
for bin=1:singleFileBins
    %plot all of the bins separately
    ERP = pop_ploterps(ERP,bin:singleFileBins:nbins,1:nchans , 'Maximize', 'on', 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 2], 'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',1, 'Maximize', 'on', 'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, 'xscale', [ -200 1000 -200:250:1000 ], 'YDir', 'normal' );
    title(['AllGroupsErp'],'interpreter', 'none')
    ax = gca;
    filename = strcat(groupPlots,'\AllGroupsErp_Bin_',string(bin),'.png');
    saveas(ax,filename)
end

%Filer the ERP
[ERP ALLERP] = pop_loaderp( 'filename', files, 'filepath', erpAvgFolder);
ERP = pop_appenderp( ALLERP , 'Erpsets',1:4,'Prefixes',fileNameOnly );
ERP = pop_filterp( ERP,1, 'Cutoff', [ 0.1 40], 'Design', 'butter', 'Filter', 'bandpass', 'Order',2 );% GUI: 06-Jul-2022 12:42:26



nbins = ERP.nbin;
nchans = ERP.nchan;
for bin=1:singleFileBins
    %plot all of the bins separately
    ERP = pop_ploterps(ERP,bin:singleFileBins:nbins,1:nchans , 'Maximize', 'on', 'AutoYlim', 'on','Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 2], 'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',1, 'Maximize', 'on', 'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, 'xscale', [ -200 1000 -200:250:1000 ], 'YDir', 'normal' );
    title(['AllGroupsErpFiltered_[0.1,40]'],'interpreter', 'none')
    ax = gca;
    filename = strcat(groupPlots,'\AllGroupsErp_Filtered_Bin_',string(bin),'.png');
    saveas(ax,filename)
end


disp("Done Plotting ERP")
close all





% ERP = pop_ploterps( ERP,  1:4:13,  1:6 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 2], 'ChLabel',...
%  'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' }, 'LineWidth',...
%   1, 'Maximize', 'on', 'Position', [ 79.5 6.15385 106.9 31.9231], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
%  [ -200.0 998.0   -200:200:800 ], 'YDir', 'normal' );













