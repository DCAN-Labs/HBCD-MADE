
% clear
% 
% addpath(genpath('Y:\Toolbox\eeglab13_6_5b'));
% eeglab



%%
% Set the path for the settings file (optional if the file is in the current directory)
% addpath('R:\Projects\hbcd\EEG\Official_Pilot\testing for CBrain\Cbrain\HBCD-MADE');
% 
% % Specify the JSON settings file path
% json_settings_file = 'R:\Projects\hbcd\EEG\Official_Pilot\testing for CBrain\Cbrain\HBCD-MADE\proc_settings_HBCD_LY_MM_MA.json';

% Read the JSON file contents
jsonStr = fileread(json_settings_file);

% Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);


%%
%Here parameters to modify

% data_path = 'R:\Projects\hbcd\EEG\Official_Pilot\testing for CBrain\processed_data'
% file_name = 'sub-PIUMX0389_RS_processed_data.set'
% save_path = 'R:\Projects\hbcd\EEG\Official_Pilot\testing for CBrain\mat files'
% save_name = 'sub-PIUMX0389_RS_processed_data_RS.mat'
%
% save_path = 'R:\Projects\hbcd\EEG\Official_Pilot\testing for CBrain\jpg files'
% save_name_jpg = 'sub-PIUMX0389_RS_processed_data_RS.jpg'
%
%
% participant_label = 'sub-PIUMX0389';
subject_ID = participant_label

% Plot reg topo range
%PeakStart = 100;
%PeakEnd = 300;
%PeakStart = 1000*settingsData.RS.ERP_window_start
%PeakEnd = 1000*settingsData.RS.ERP_window_end %It crashes if you put the maximum limit, is should be slightly below that %MA

% Range for plotting ERPs
%Start = -100;
%End = 698;

Start = -(1000*settingsData.RS.pre_latency)
End = (1000*settingsData.RS.post_latency)-2 %It crashes if you put the maximum limit, is should be slightly below that %MA


%ROI for plotting ERPs

%ROI = {'E75', 'E74', 'E82', 'E70', 'E83'}
%ROIname = 'Oz'


ROIname = settingsData.RS.ROI_of_interest
ROI = settingsData.clusters.(ROIname)';

%Before here is to modify
%%
%load the preprocessed file
%     EEG = pop_loadset('filename', file_name,'filepath', data_path );
%     EEG = eeg_checkset(EEG);



%     EEG = pop_selectevent(EEG, 'type', {'o'}, 'deleteevents','on');
EEG = pop_selectevent(EEG, 'type', {'dummy_marker'}, 'deleteevents','on');



%% Define event markers
event_marker   = {'X'}; % markers in data
%% Load or initialize tables
table_file = 'tables.mat';
if exist(table_file, 'file')
    load(table_file, 'psd_all_subjects', 'psd_all_subjects_db', 'psd_subject', 'psd_subject_electrode', 'psd_subject_db', 'psd_subject_electrode_db');
else
    psd_all_subjects = [];
    psd_all_subjects_db = [];
    psd_subject = [];
    psd_subject_electrode = [];
    psd_subject_db = [];
    psd_subject_electrode_db = [];
end


%% Initialize PSD storage arrays

cd(save_path)
IDnum = subject_ID;




%% Get channel location from dataset and save to .mat file
channel_location = EEG.chanlocs;

%% loop through conditions / in this case only eyes open
%     for cond=1:length(event_marker)
%         try
%             EEGa = pop_selectevent( EEG, 'type', {'o'},'deleteevents','off','deleteepochs','on','invertepochs','off');
%             sizeEEGa = size(EEGa.data, 3);
%         catch %if there are no events of this type then catch the empty dataset error and set size(EEG.data,3) to zero
%             sizeEEGa = 0;
%         end
%     end

for cond=1:length(event_marker)
    try
        EEGa = pop_selectevent( EEG, 'type', {'dummy_marker'},'deleteevents','off','deleteepochs','on','invertepochs','off');
        sizeEEGa = size(EEGa.data, 3);
    catch %if there are no events of this type then catch the empty dataset error and set size(EEG.data,3) to zero
        sizeEEGa = 0;
    end
end



n_epochs = size(EEGa.epoch,2);

% compute pwelch using eeglab spectopo for eyes open condition with 0.5
title_figure = strcat(IDnum, ' PSD AllCh', ' N=', num2str(n_epochs));
psd = figure;
[spectra_eo,freqs_eo] = spectopo(EEGa.data,length(EEGa.data),EEGa.srate,'freqrange',[1 50],'winsize',1000,'nfft',1000,'overlap',500);
spectra_eo_db = spectra_eo; % keep it in db
spectra_eo = 10.^(spectra_eo/10); % Convert Back to mV from dB

hold on;
title(title_figure, 'FontSize', 15);
hold off;

save_plot_name = strcat(IDnum, ' PSD AllCh',  '.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd, full_save_path);
close all;

avg_elec_eo_spectra = mean(spectra_eo,1); % get average power at each frequency across all electrodes



freqs_2_plot = freqs_eo';
freqs_2_plot = freqs_2_plot(:,2:50);
globalPSD_eo = avg_elec_eo_spectra(:,2:50);



% Create the filename with Subject_ID included
filename = sprintf('%s_RS.mat', subject_ID);

% Save the data into a .mat file with the specified filename
save(filename, 'channel_location', 'freqs_eo', 'spectra_eo_db');

%% Do transformation only for the db
avg_elec_eo_db_spectra = mean(spectra_eo_db,1); % get average power at each frequency across all electrodes

freqs_2_plot = freqs_eo';
freqs_2_plot = freqs_2_plot(:,2:50);
globalPSD_eo_db = avg_elec_eo_db_spectra(:,2:50);

% Save the power spectrum density to the lists
psd_all_subjects_db = [psd_all_subjects_db; globalPSD_eo_db]; % append the new data to the list of all subjects
% Plot PSD showing average of all electrodes / may also want to plot
% power @ each electrode when looking for noisy channels
title_figure = strcat(IDnum, ' PSD AllCh Avg', ' N=', num2str(n_epochs));
psd_avg = figure;
plot(freqs_2_plot, globalPSD_eo_db,'LineWidth', 3)
hold on;
title(title_figure, 'FontSize', 15);
hold off;
%ylim([0, 15]);

save_plot_name = strcat(IDnum, ' PSD AllCh Avg',  '.jpg')
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd_avg, full_save_path);
close all;

%     %% Save the power spectrum density to the lists
%     psd_all_subjects = [psd_all_subjects; globalPSD_eo]; % append the new data to the list of all subjects
%
%     % Plot PSD showing average of all electrodes / may also want to plot
%     % power @ each electrode when looking for noisy channels
%     title_figure = strcat(IDnum, ' AVG PSD HAPPE', ' N=', num2str(n_epochs));
%     psd_avg = figure;
%     plot(freqs_2_plot, globalPSD_eo,'LineWidth', 3)
%     hold on;
%     title(title_figure, 'FontSize', 15);
%     hold off;
%     %ylim([0, 15]);
%
%     save_plot_name = strcat(IDnum, ' N=', num2str(n_epochs), ' AVG PSD HAPPE',  '.jpg')
%     full_save_path = fullfile(save_path, save_plot_name);
%     saveas(psd_avg, full_save_path);
%     close all;


%% Do transformation only for the db %Choosing ROI
%avg_elec_eo_db_spectra = mean(spectra_eo_db,1); % get average power at each frequency across all electrodes


%ch = allData(:,:,1:length(Range)); %1:length(Range) instead of Range
%p8_ind=find(ismember({EEG.chanlocs.labels},{'E75', 'E83', 'E70', 'E71', 'E76'})); %{'E75', 'E83', 'E70', 'E71', 'E76'}
p8_ind=find(ismember({EEG.chanlocs.labels},ROI));
ch = (spectra_eo_db(p8_ind,:));%64 FCz = 4, FZ = 6 %128 FCz = 6, Fz = 11 select channel(s) of interest Oz=75
avg_elec_eo_db_spectra = mean(ch,1)


freqs_2_plot = freqs_eo';
freqs_2_plot = freqs_2_plot(:,2:50);
globalPSD_eo_db = avg_elec_eo_db_spectra(:,2:50);

% Save the power spectrum density to the lists
psd_all_subjects_db = [psd_all_subjects_db; globalPSD_eo_db]; % append the new data to the list of all subjects
% Plot PSD showing average of all electrodes / may also want to plot
% power @ each electrode when looking for noisy channels
title_figure = strcat(IDnum, ' PSD ROI ', ROIname , ' N=', num2str(n_epochs));
psd_avg = figure;
plot(freqs_2_plot, globalPSD_eo_db,'LineWidth', 3)
hold on;
title(title_figure, 'FontSize', 15);
hold off;
%ylim([0, 15]);

save_plot_name = strcat(IDnum, ' PSD ROI',  '.jpg')
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd_avg, full_save_path);
close all;