%% RS Plot PSD

EEG = pop_loadset([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, ext, '_processed_data.set')]);
%%
% Read the JSON file contents
jsonStr = fileread(json_settings_file);

% Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);
subject_ID = participant_label;

Start = -(1000*settingsData.RS.pre_latency);
End = (1000*settingsData.RS.post_latency)-2; %It crashes if you put the maximum limit, is should be slightly below that %MA

%ROI for plotting ERPs
ROIname = settingsData.RS.ROI_of_interest;
ROI = settingsData.clusters.(ROIname)';

if isempty(ROI) 
    ROI = {EEG.chanlocs.labels}; %default to all channels
end

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
title_figure = strcat('PSD AllCh', ' N=', num2str(n_epochs)); %IDnum, 
psd = figure;
[spectra_eo,freqs_eo] = spectopo(EEGa.data,length(EEGa.data),EEGa.srate,'freqrange',[1 50],'winsize',1000,'nfft',1000,'overlap',500);
spectra_eo_db = spectra_eo; % keep it in db
spectra_eo = 10.^(spectra_eo/10); % Convert Back to mV from dB

hold on;
title(title_figure, 'FontSize', 15);
hold off;

save_plot_name = strcat(IDnum, '_task-RS_desc-allCh_PSD',  '.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd, full_save_path);
close all;

avg_elec_eo_spectra = mean(spectra_eo,1); % get average power at each frequency across all electrodes

freqs_2_plot = freqs_eo';
freqs_2_plot = freqs_2_plot(:,2:50);
globalPSD_eo = avg_elec_eo_spectra(:,2:50);



%%%%%%%%%%%%%%%%%%%% Commented out Marco 12/19/2024
% % Create the filename with Subject_ID included
% filename = sprintf('%s_RS.mat', subject_ID);

% % Save the data into a .mat file with the specified filename
% save_name_whole = strrep(event_struct.file_names{run}, 'eeg_filtered_data.set', 'ERP.mat');
% save([save_path filesep save_name_whole], 'channel_location', 'freqs_eo', 'spectra_eo_db')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Calculate Absolute Power, SME, AVG Power across Trials & tiral level data

total = [1 50];

% get # of channels
num_channels = EEG.nbchan;
% get epoch count
num_trials = EEG.trials;

winSize = length(EEG.data);
x  = EEG.data;
Fs = EEG.srate;
NFFT = winSize;
WINDOW = winSize;
NOVERLAP = 0; % no overlap
NFFT = WINDOW;
power_matrix = zeros(num_channels, NFFT/2 + 1, num_trials); % Assuming the number of frequency bins is NFFT/2 + 1

% Compute pwelch for each channel and epoch
for chan = 1:num_channels
    for trial = 1:num_trials
        % x = EEG.data, WINDOW = epoch length, NOVERLAP = overlap,
        % Fs = sampling rate
        [spectra, freqs] = pwelch(x(chan, :, trial), WINDOW, NOVERLAP, NFFT, Fs);
        power_matrix(chan, :, trial) = spectra';
    end
end


% get index of frequency bins from 1hz to 50hz
totalIdx = dsearchn(freqs, total');
% get average across epochs
avg_abs_pow = squeeze(mean(power_matrix,3)); 
% save power values for 1 - 50hz only
avg_abs_pow = avg_abs_pow(:, totalIdx(1):totalIdx(2));
% Corresponding frequency values
freqs = freqs(totalIdx(1):totalIdx(2)); 

% Save out epoch level data
power_matrix2 = power_matrix(:, totalIdx(1):totalIdx(2), :); % Get power from 1-50hz
% Save epoch-level power as 3D matrix [channels x frequencies x epochs]
all_abs_power = power_matrix2; % Keep original matrix for saving


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the .csv file - ADDED Marco 12/19/2024

% Save channel location anmes to add to .csv file
chan_locs = EEG.chanlocs;
elec_names = {chan_locs.labels};

% Format frequency labels as strings for table column headers for .csv file
freq_labels = arrayfun(@(x) sprintf('%.1fHz', x), freqs, 'UniformOutput', false); % Convert to cell array of strings

% Combine channel names and spectra into a table
spectra_table = array2table(avg_abs_pow, 'VariableNames', freq_labels, 'RowNames', elec_names);

% % Not needed just for testing / can replace with IDnum
subject_ID = 'S01'; 

% Create the output file name with the subject_ID
output_file = sprintf([subject_ID,'_spectra_output.csv']); % E.g., "spectra_output_S01.csv"

% Save the table to a CSV file
writetable(spectra_table, output_file, 'WriteRowNames', true);

% disp(['Spectra saved to ' output_file]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare the .mat file - ADDED Marco 12/19/2024
% subject_ID = 'S01'; % Not needed just for testing

% Saves out avg_abs_pow (average absolute power across epochs), 
% all_abs_power (chans x power x epochs), epoch_level_pow (abs power for each epoch),
% channel locations file, freqs (frequency bins (1hz increments, 1-50hz)), 
% num_trials (number of epochs), and Fs (sampling rate) - for sanity check

% Save epoch-level power as separate variables
for epoch = 1:num_trials
    epoch_name = sprintf('epoch_power_%d', epoch); % Dynamically name variables
    epoch_data = squeeze(power_matrix2(:, :, epoch)); % Get power for the current epoch
    assignin('base', epoch_name, epoch_data); % Assign the matrix to the base workspace
    
    % Optionally, save each epoch as a separate field
    epoch_level_pow.(epoch_name) = epoch_data;
end

% Save the data into the .mat file
output_file_mat = sprintf([subject_ID, '_spectra_output.mat']); 

% Save the data, including the epoch-level power matrices
save(output_file_mat, 'subject_ID', 'num_trials', 'Fs', 'chan_locs', 'avg_abs_pow', 'freqs', 'all_abs_power', 'epoch_level_pow');

% disp(['Data saved to ' output_file_mat]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% this part looks OK Marco 12/19/2024
roi_ind=find(ismember({EEG.chanlocs.labels},ROI));
avg_chan_spec = squeeze(mean(power_matrix(roi_ind,:,:),1)); %average PSD over channels of interest

for ff = 1:50% size(avg_chan_spec,1)
    % Calculate the standard deviation of the column
    colStd = std(avg_chan_spec( ff,:));
    % Calculate the SME
    sme = colStd / sqrt(size(avg_chan_spec, 1));
    avg_pw = mean(avg_chan_spec(ff,:));
    
    sme_mat(ff,1) = ff;
    sme_mat(ff,2) = sme;
    sme_mat(ff,3) = avg_pw;
end

sme_tab = table(sme_mat);
sme_tab = splitvars(sme_tab);
sme_tab.Properties.VariableNames = {'Frequency', 'SME', 'Mean_Power'};
sme_tab.ID(:) = string(subject_ID);   
writetable(sme_tab, [output_location filesep 'processed_data' filesep participant_label '_' session_label '_task-' task '_Power-summaryStats.csv']);
    
%% Do transformation only for the db - 
% below is just for plotting so I thinks it's ok Marco 12/19/2024
avg_elec_eo_db_spectra = mean(spectra_eo_db,1); % get average power at each frequency across all electrodes

freqs_2_plot = freqs_eo';
freqs_2_plot = freqs_2_plot(:,2:50);
globalPSD_eo_db = avg_elec_eo_db_spectra(:,2:50);

% Save the power spectrum density to the lists
psd_all_subjects_db = [psd_all_subjects_db; globalPSD_eo_db]; % append the new data to the list of all subjects
% Plot PSD showing average of all electrodes / may also want to plot
% power @ each electrode when looking for noisy channels
title_figure = strcat('PSD AllCh Avg', ' N=', num2str(n_epochs)); %IDnum, 
psd_avg = figure;
plot(freqs_2_plot, globalPSD_eo_db,'LineWidth', 3)
hold on;
title(title_figure, 'FontSize', 15);
hold off;
%ylim([0, 15]);

save_plot_name = strcat(IDnum, '_task-RS_desc-allChAvg_PSD',  '.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd_avg, full_save_path);
close all;

%% Do transformation only for the db %Choosing ROI

roi_ind=find(ismember({EEG.chanlocs.labels},ROI));
ch = (spectra_eo_db(roi_ind,:));%64 FCz = 4, FZ = 6 %128 FCz = 6, Fz = 11 select channel(s) of interest Oz=75
avg_elec_eo_db_spectra = mean(ch,1)

freqs_2_plot = freqs_eo';
freqs_2_plot = freqs_2_plot(:,2:50);
globalPSD_eo_db = avg_elec_eo_db_spectra(:,2:50);

% Save the power spectrum density to the lists
psd_all_subjects_db = [psd_all_subjects_db; globalPSD_eo_db]; % append the new data to the list of all subjects
% Plot PSD showing average of all electrodes / may also want to plot
% power @ each electrode when looking for noisy channels
title_figure = strcat('PSD ROI ', ROIname , ' N=', num2str(n_epochs));
psd_avg = figure;
plot(freqs_2_plot, globalPSD_eo_db,'LineWidth', 3)
hold on;
title(title_figure, 'FontSize', 15);
hold off;
%ylim([0, 15]);

save_plot_name = strcat(IDnum, 'task-RS_desc-', ROIname,  '_PSD.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd_avg, full_save_path);
close all;