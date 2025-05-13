%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% % Calculates resting state Absolute Power values using matlab pwelch function. Also uses 2 log transformations
% (natural log and dB power) and saves out a total of 5 files... 
% 3 .csv files with different power estimates for each electrode from 1hz to 50hz in 1hz bins -
% x_ses-V03_task-RS_AbsPowerSpectra.csv,
% x_ses-V03_task-RS_LogPowerSpectra.csv,
% x_ses-V03_task-RS_dbPowerSpectra.csv
%
% Also saves out PSD plot in dB = x_ses-V03_task-RS_desc-allCh_PSD.jpg, that shows
% the dB power for each electrode from 1-50hz and the average of all electrodes.
%
% Last file is the x_ses-V03_task-RS_spectra.mat that contains all this
% info in addition to epoch level power estimates. See below for more info (line 166).

%% START HERE - MM 05/05/2025
% Load data set
EEG = pop_loadset([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, '_desc-filtered_eeg.set', '_desc-filteredprocessed_eeg.set')]);

% Read the JSON file contents
jsonStr = fileread(json_settings_file);

% Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);
subject_ID = participant_label;

cd(save_path)

%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% For Testing only %%%%%%%%%%%%%%%%%%%
% subject_ID = 'S01';
% % IDnum = subject_ID;
% session_label = 'ses-V03';
% % FOR TESTING ONLY
% save_path = 'xx';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define frequency range of interest and run pwelch function
total = [1 50]; 

% get # of channels
num_channels = size(EEG.data, 1);
% get epoch count
n_epochs = size(EEG.data, 3);

winSize = length(EEG.data);
x  = EEG.data; 
% x = detrend(x);  % Optional - Remove linear trend or mean
Fs = EEG.srate;
WINDOW = winSize;
NOVERLAP = 0; % no overlap - 50% overlap hard coded in MADE pipeline so no need here
NFFT = WINDOW;
power_matrix = zeros(num_channels, NFFT/2 + 1, n_epochs); % Assuming the number of frequency bins is NFFT/2 + 1

% Compute pwelch for each channel and epoch
% Will give you up to nyquist in 1hz bins
for chan = 1:num_channels
    for trial = 1:n_epochs
        % x = EEG.data, WINDOW = epoch length, NOVERLAP = overlap,
        % Fs = sampling rate
        [spectra, freqs] = pwelch(x(chan, :, trial), WINDOW, NOVERLAP, NFFT, Fs);
        power_matrix(chan, :, trial) = spectra';
    end
end

% Get index of frequency bins from 1hz to 50hz
totalIdx = dsearchn(freqs, total');
% Corresponding frequency values from 1hz to 50hz
freqs = freqs(totalIdx(1):totalIdx(2)); 

%% Changed MM 05/05/2025
% Get absolute power from 1-50hz and use later to save out epoch level data [channels x frequencies x epochs]
% µV²/Hz (microvolts squared per Hertz)
all_abs_pow = power_matrix(:, totalIdx(1):totalIdx(2), :);
% Get average absolute power across epochs for 1-50hz freq range
avg_abs_pow = squeeze(mean(power_matrix(:, totalIdx(1):totalIdx(2), :), 3));

% Added MM 05/05/2025
% Use natural log transformation for better distribution [channels x frequencies x epochs]
% Always do this to orignal pwelch absolute values before averaging - log = non-linear operation
% log10(1+x), where x is the absolute power values & 1+ ensures that values close to zero don't cause an error
all_log_pow = log10(1+all_abs_pow);
% Get average natural log power across epochs for 1-50hz freq range
avg_log_pow = mean(all_log_pow, 3);

% Added MM 05/07/2025
% Transform absolute power values to dB [channels x frequencies x epochs]
% Again do this to orignal pwelch absolute values before averaging
% PowerdB =10⋅log10(µV²/Hz)
all_db_pow = 10 * log10(all_abs_pow);
% Get average dB power across epochs for 1-50hz freq range
avg_db_pow = mean(all_db_pow,3);
% Get average across electrodes for plotting
avg_elec_db_pow = mean(avg_db_pow, 1);

%% Added MM 05/07/2025
% PLOT PSD HERE
% Plot PSD in dB power
title_figure = strcat(subject_ID, ' PSD N epochs = ', num2str(n_epochs));
psd = figure;
% Plot each channel PSD
plot(freqs, avg_db_pow,'LineWidth', 3); 
hold on;
% Plot the average of all channels PSD
pltAvg = plot(freqs, avg_elec_db_pow,'k', 'LineWidth', 6);
set(psd, 'Position', get(0, 'Screensize'));  % Maximize figure window
title(title_figure, 'FontSize', 18, 'FontWeight', 'bold');
xlabel('Frequency (Hz)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Power Spectral Density (dB μV²/Hz)', 'FontSize', 16, 'FontWeight', 'bold');
% Create the plot and legend
legend_handle = legend(pltAvg, ['Channels ', 'Average'], 'FontSize', 16);
% Set the legend text color to black
set(legend_handle, 'TextColor', 'k', 'FontWeight', 'bold');
% Set x and y axis tick labels
ax = gca; 
set(ax, 'FontSize', 14, 'FontWeight', 'bold');

hold off;

% Save PSD plot
save_plot_name = strcat(subject_ID, '_', session_label, '_task-RS_desc-allCh_PSD',  '.jpg');
full_save_path = fullfile(save_path, save_plot_name);
saveas(psd, full_save_path);
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prepare for the .csv file - ADDED Marco 12/19/2024

% Get channel location names to add to .csv file
chan_locs = EEG.chanlocs;
elec_names = {chan_locs.labels};

% Format frequency labels as strings for table column headers for .csv file
freq_labels = arrayfun(@(x) sprintf('%.1fHz', x), freqs, 'UniformOutput', false); % Convert to cell array of strings

%% For absolute power values
% Combine channel names and spectra into a table
spectra_table = array2table(avg_abs_pow, 'VariableNames', freq_labels, 'RowNames', elec_names);
% Add 'Electrode' label to top-left corner of the table for CSV export
spectra_table.Properties.DimensionNames{1} = 'Electrode';
% Create the output file name with the subject_ID
output_file = sprintf([subject_ID,'_', session_label, '_task-RS_AbsPowerSpectra', '.csv']); 
% Save the table to a CSV file
writetable(spectra_table, output_file, 'WriteRowNames', true);
% disp(['Spectra saved to ' output_file]);

%% For natural Log power values 
% Combine channel names and spectra into a table
spectra_table = array2table(avg_log_pow, 'VariableNames', freq_labels, 'RowNames', elec_names);
% Add 'Electrode' label to top-left corner of the table for CSV export
spectra_table.Properties.DimensionNames{1} = 'Electrode';
% Create the output file name with the subject_ID
output_file = sprintf([subject_ID,'_', session_label, '_task-RS_LogPowerSpectra', '.csv']); 
% Save the table to a CSV file
writetable(spectra_table, output_file, 'WriteRowNames', true);

%% For dB power values
% Combine channel names and spectra into a table
spectra_table = array2table(avg_db_pow, 'VariableNames', freq_labels, 'RowNames', elec_names);
% Add 'Electrode' label to top-left corner of the table for CSV export
spectra_table.Properties.DimensionNames{1} = 'Electrode';
% Create the output file name with the subject_ID
output_file = sprintf([subject_ID,'_', session_label, '_task-RS_dbPowerSpectra', '.csv']); 
% Save the table to a CSV file
writetable(spectra_table, output_file, 'WriteRowNames', true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare the .mat file - ADDED Marco 12/19/2024
% Saves out... 
% avg_abs_pow = average absolute power across epochs,
% avg_log_pow = average natural log power across epochs
% avg_db_pow = average power in decibels (db) across epochs
% all_abs_power = chans x abs power x epochs,
% all_log_pow = chans x log power x epochs,
% all_db_pow = chans x db power x epochs,
% epoch_level_abs_pow = abs power for each epoch,
% epoch_level_log_pow = log power for each epoch,
% epoch_level_db_pow = db power for each epoch,
% channel locations, 
% freqs (frequency bins (1hz increments, 1-50hz)), 
% n_epochs (number of epochs), 
% Fs (sampling rate) - for sanity check
% num_channels (number of channels) for sanity check

% Save epoch level abs and natural log and dB power as separate variables
for epoch = 1:n_epochs
    epoch_name = sprintf('epoch_power_%d', epoch); 
    epoch_data = squeeze(all_abs_pow(:, :, epoch)); % Get power for the current epoch
    assignin('base', epoch_name, epoch_data); % Assign the matrix
    % Save each epoch as a separate field
    epoch_level_abs_pow.(epoch_name) = epoch_data;

    % Added MM 05/05/2025 save out log transform power as well
    log_data = squeeze(all_log_pow(:, :, epoch));
    epoch_level_log_pow.(epoch_name) = log_data;

    % Added MM 05/07/2025 save out dB power as well
    db_data = squeeze(all_db_pow(:, :, epoch));
    epoch_level_db_pow.(epoch_name) = db_data;
end

% Save the data into the .mat file
output_file_mat = sprintf([subject_ID,'_', session_label, '_task-RS_spectra.mat']); 

% Save the data, including the epoch-level power matrices
save(output_file_mat, 'subject_ID', 'n_epochs', 'Fs', 'chan_locs', 'avg_abs_pow',...
    'avg_log_pow', 'avg_db_pow', 'freqs', 'all_abs_pow', 'all_log_pow', 'all_db_pow',...
    'epoch_level_abs_pow','epoch_level_log_pow', 'epoch_level_db_pow', 'num_channels');

% disp(['Data saved to ' output_file_mat]);
