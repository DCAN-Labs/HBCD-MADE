

%%
% Read the JSON file contents
jsonStr = fileread(json_settings_file);

% Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);


%%

subject_ID = participant_label;

Start = -(1000*settingsData.RS.pre_latency);
End = (1000*settingsData.RS.post_latency)-2; %It crashes if you put the maximum limit, is should be slightly below that %MA


%ROI for plotting ERPs
ROIname = settingsData.RS.ROI_of_interest;
ROI = settingsData.clusters.(ROIname)';


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

save_plot_name = strcat(IDnum, '_PSD_AllCh',  '.jpg');
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
%save(filename, 'channel_location', 'freqs_eo', 'spectra_eo_db');
save_name_whole = [strrep(event_struct.file_names{run}, 'eeg_filtered_data.set', 'ERP.mat')]
save([save_path filesep save_name_whole], 'channel_location', 'freqs_eo', 'spectra_eo_db')

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

save_plot_name = strcat(IDnum, '_PSD_AllCh_Avg',  '.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd_avg, full_save_path);
close all;

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

save_plot_name = strcat(IDnum, '_PSD_ROI',  '.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd_avg, full_save_path);
close all;