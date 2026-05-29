%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Computes raw Inter-Trial Coherence (ITC / PLV) for the Statistical
% Learning paradigm. No surrogate generation or z-scoring.
%
% CSV output (channels x frequencies, 0.6-10 Hz):
%   *_truePLV.csv        - raw PLV per electrode x frequency
%
% Plot output:
%   *_desc-allCh_ITC.jpg - ITC spectrum per channel + grand average,
%                          with dashed lines at SL syllable and word frequencies
%
% .mat output:
%   *_ITC.mat            - truePLV, freqs, chan_locs, subject_ID, n_epochs,
%                          EEGfrq_true (full frqa_plvpwr output struct)

%% Load epoched EEG data
EEG = pop_loadset([[output_location filesep 'processed_data' filesep] ...
    strrep(event_struct.file_names{run}, '_desc-filtered_eeg.set', '_desc-filteredprocessed_eeg.set')]);

% Read JSON settings
jsonStr = fileread(json_settings_file);
settingsData = jsondecode(jsonStr);
subject_ID = participant_label;

cd(save_path)

%% Compute raw ITC
EEGfrq_true = frqa_plvpwr(EEG, ...
    'foutput',    [0.6 10], ...
    'fband',      [0.2 15], ...
    'binsSNR',    [-5 -4 -3 -2 -1 1 2 3 4 5], ...
    'typeSNRPWR', 'linear', ...
    'typeSNRPLV', 'none', ...
    'zscorePWR',  0, ...
    'zscorePLV',  0);

% Extract summary matrices and metadata
truePLV    = EEGfrq_true.plv;    % nChan x nFreqs
freqs      = EEGfrq_true.freqs;  % 1 x nFreqs frequency vector (Hz)
n_epochs   = EEG.trials;
chan_locs  = EEG.chanlocs;
elec_names = {chan_locs.labels};

%% Save CSV - true PLV
freq_labels = arrayfun(@(x) sprintf('%.3fHz', x), freqs, 'UniformOutput', false);
spectra_table = array2table(truePLV, 'VariableNames', freq_labels, 'RowNames', elec_names);
spectra_table.Properties.DimensionNames{1} = 'Electrode';
output_file = strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', 'truePLV.csv');
writetable(spectra_table, output_file, 'WriteRowNames', true);

%% Plot ITC spectrum (per channel + grand average)
avg_plv = mean(truePLV, 1);
title_figure = strcat(subject_ID, ' ITC N epochs = ', num2str(n_epochs));
itc_fig = figure;
plot(freqs, truePLV', 'LineWidth', 3);
hold on;
pltAvg = plot(freqs, avg_plv, 'k', 'LineWidth', 6);
xline(1.1111, '--', 'Word (1.11 Hz)',     'FontSize', 12, 'LabelHorizontalAlignment', 'left');
xline(3.3333, '--', 'Syllable (3.33 Hz)', 'FontSize', 12, 'LabelHorizontalAlignment', 'left');
set(itc_fig, 'Position', get(0, 'Screensize'));
title(title_figure, 'FontSize', 18, 'FontWeight', 'bold');
xlabel('Frequency (Hz)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('ITC (PLV)', 'FontSize', 16, 'FontWeight', 'bold');
legend_handle = legend(pltAvg, 'Channels Average', 'FontSize', 16);
set(legend_handle, 'TextColor', 'k', 'FontWeight', 'bold');
ax = gca;
set(ax, 'FontSize', 14, 'FontWeight', 'bold');
hold off;

saveas(itc_fig, strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', 'desc-allCh_ITC.jpg'));
close all;

%% Save .mat file
% truePLV     - nChan x nFreqs raw PLV
% EEGfrq_true - full frqa_plvpwr output struct
% freqs       - frequency bins (Hz)
% chan_locs   - EEGLAB channel location struct
% subject_ID  - subject identifier string
% n_epochs    - number of epochs
output_file_mat = strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', 'ITC.mat');
save(output_file_mat, 'subject_ID', 'n_epochs', 'chan_locs', 'freqs', ...
    'truePLV', 'EEGfrq_true');
