%% Compute Raw and Z-scored PLV and ERP analyses for a single epoched SL file 
%
%   PLV and ERP analyses for the HBCD Statistical Learning (SL) paradigm. 
%   Should be run as a script within MADE pipeline
%   Expects a pre-epoched EEG .set file and a JSON settings file to already 
%   exist in the output directory.
%
%   The SL stimulus is a continuous stream of syllables (3.333 Hz) grouped
%   into 3 syllable words (1.111 Hz). Neural entrainment to these frequencies is
%   captured via ITC (technically phase locking value/PLV). 
%
%   Each epoch's data is circularly shifted by a random amount across n_surrogate 
%   iterations to create a null distribution, which is used to calculated 
%   Z-scored ITC, which helps control for non-phase-locked broadband power.
%
%   PLV spectrum plots are created for both raw and Z-scored ITC. Individual 
%   channel PLV spectrum data are saved as a .csv file
%
%   Scalp topography plots are created for ITC and ZITC at the syllable (3.333 Hz) 
%   and word (1.111 Hz) frequencies
% 
%   ERPs are computed separately for syllable-onset and word-onset events
%   by converting the SL epochs back to continuous data and re-epoching around
%   individual syll/word markers.
%
%   Expects workspace variables: output_location, event_struct, run,
%                                json_settings_file, participant_label, save_path
%
%   Requires on MATLAB path: EEGLAB, frqa_plvpwr.m, frqa_norm.m, frqa_powernorm.m,
%                            nan_mean.m (should be included in EEGLAB)
%
%   CSV output:
%     *_PLV.csv  - long-format table: Electrode, Frequency, raw_ITC, ZITC
%     *_ERP.csv  - long-format table: condition, epoch, time_ms, amplitude_uV
%
%   Plot output (.png):
%     *_desc-allCh_ITC   - ITC spectrum per channel + grand average
%     *_desc-allCh_ZITC  - Z-scored ITC spectrum per channel + grand average
%     *_desc-ITC_topo    - ITC topoplot at word (1.11 Hz) and syllable (3.33 Hz)
%     *_desc-ZITC_topo   - Z-scored ITC topoplot at word and syllable frequencies
%     *_desc-allCh_ERP   - ERP overlay by word / syllable condition

%% Load epoched EEG data
EEG = pop_loadset([[output_location filesep 'processed_data' filesep] ...
    strrep(event_struct.file_names{run}, '_desc-filtered_eeg.set', '_desc-filteredprocessed_eeg.set')]);

% Read JSON settings
jsonStr = fileread(json_settings_file);
settingsData = jsondecode(jsonStr);
subject_ID = participant_label;

cd(save_path)

%% CONFIG
n_iterations = 10;   % surrogate iterations for ZITC
rng_seed     = 0;    % random seed for reproducible surrogate shuffling

%% COMPUTE RAW AND Z-SCORED ITC
[raw_plv, freqs] = compute_itc(EEG);
n_epochs   = EEG.trials;
zscore_plv = compute_zscore_itc(EEG, raw_plv, n_iterations, rng_seed);
plv_table  = make_plv_table(raw_plv, zscore_plv, freqs, EEG.chanlocs);
writetable(plv_table, fullfile(save_path, sprintf('%s_PLV.csv', subject_ID)));


%% PLOT ITC
% ITC spectrum (all channels + grand average)
plot_itc_spectrum(freqs, raw_plv);
title(strcat(subject_ID, ' ITC N epochs = ', num2str(n_epochs)), 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
ylabel('ITC (PLV)', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, fullfile(save_path, sprintf('%s_desc-allCh_ITC', subject_ID)), 'png');

% ITC scalp topoplot at word and syllable frequencies
plot_itc_topoplot(raw_plv, freqs, EEG.chanlocs);
sgtitle(strcat(subject_ID, ' ITC (PLV)'), 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
saveas(gcf, fullfile(save_path, sprintf('%s_desc-ITC_topo', subject_ID)), 'png');

%% PLOT ZITC
% Z-scored ITC spectrum (all channels + grand average)
plot_itc_spectrum(freqs, zscore_plv);
title(strcat(subject_ID, ' Z-scored ITC N epochs = ', num2str(n_epochs)), 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
ylabel('Z-scored ITC', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, fullfile(save_path, sprintf('%s_desc-allCh_ZITC', subject_ID)), 'png');

% Z-scored ITC scalp topoplot at word and syllable frequencies
plot_itc_topoplot(zscore_plv, freqs, EEG.chanlocs);
sgtitle(strcat(subject_ID, ' Z-scored ITC'), 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
saveas(gcf, fullfile(save_path, sprintf('%s_desc-ZITC_topo', subject_ID)), 'png');



%% TEMPORARILY COMMENTING OUT THE ERP ANALYSIS BECAUSE WE ARE USING THE OLD EPOCHING FUNCTION

% %% RE-EPOCH AND COMPUTE WORD AND SYLL ERPS
% [erp_times, avg_syll, avg_word, n_syll, n_word, erp_table] = compute_erp(EEG);
% writetable(erp_table, fullfile(save_path, sprintf('%s_ERP.csv', subject_ID)));
% 
% %% PLOT WORD AND SYLLABLE ERP BY CHANNEL
% plot_erp(erp_times, avg_syll, avg_word, n_syll, n_word, subject_ID);
% saveas(gcf, fullfile(save_path, sprintf('%s_desc-allCh_ERP', subject_ID)), 'png');


%% ========== FUNCTIONS ==========

% ---- PLV / ITC ---------------------------------------------------------------

function [raw_plv, freqs] = compute_itc(EEG)
    EEG_frq = frqa_plvpwr(EEG, ...
        'foutput',    [0.6 10], ...
        'fband',      [0.2 15], ...
        'binsSNR',    [-5 -4 -3 -2 -1 1 2 3 4 5], ...
        'typeSNRPWR', 'linear', ...
        'typeSNRPLV', 'none', ...
        'zscorePWR',  0, ...
        'zscorePLV',   0);
    raw_plv = EEG_frq.plv;
    freqs   = EEG_frq.freqs;
end

function zscore_plv = compute_zscore_itc(EEG, raw_plv, n_iterations, rng_seed)
    rng('default')
    rng(rng_seed);
    shuffling_window_min = -900 / (1000 / EEG.srate);
    shuffling_window_max =  900 / (1000 / EEG.srate);

    fprintf('Generating %d surrogate datasets...\n', n_iterations);
    for iter = 1:n_iterations
        fprintf('  Surrogate iteration %d / %d\n', iter, n_iterations);
        EEG_iter = EEG;
        for trial = 1:EEG.trials
            shift = round(shuffling_window_min + (shuffling_window_max - shuffling_window_min) .* rand(1));
            EEG_iter.data(:, :, trial) = circshift(EEG.data(:, :, trial), shift, 2);
        end
        [surr_plv, ~] = compute_itc(EEG_iter);
        if iter == 1
            surrogate_datasets_mtx = zeros(n_iterations, size(surr_plv, 1), size(surr_plv, 2));
        end
        surrogate_datasets_mtx(iter, :, :) = surr_plv;
    end

    fprintf('Computing Z-scored ITC...\n');
    mean_surrogate_plv = squeeze(mean(surrogate_datasets_mtx, 1));
    std_surrogate_plv  = squeeze(std(surrogate_datasets_mtx,  0, 1));
    zscore_plv        = (raw_plv - mean_surrogate_plv) ./ std_surrogate_plv;
    fprintf('Done. zscore_plv is %d channels x %d frequencies.\n', size(zscore_plv, 1), size(zscore_plv, 2));
end

function plv_table = make_plv_table(raw_plv, zscore_plv, freqs, chanlocs)
    elec_names           = {chanlocs.labels};
    n_chan                = numel(elec_names);
    n_freqs               = numel(freqs);
    [chan_idx, freq_idx] = ndgrid(1:n_chan, 1:n_freqs);
    plv_table = table( ...
        elec_names(chan_idx(:))', ...
        freqs(freq_idx(:))', ...
        raw_plv(sub2ind(size(raw_plv),     chan_idx(:), freq_idx(:))), ...
        zscore_plv(sub2ind(size(zscore_plv), chan_idx(:), freq_idx(:))), ...
        'VariableNames', {'Electrode', 'Frequency', 'raw_ITC', 'ZITC'});
end

% ---- ERP ---------------------------------------------------------------------

function [erp_times, avg_syll, avg_word, n_syll, n_word, erp_table] = compute_erp(EEG)
    EEG_cont = eeg_epoch2continuous(EEG);
    EEG_cont.event(strcmp({EEG_cont.event.type}, 'boundary')) = [];

    EEG_syll = pop_epoch(EEG_cont, {'syll'}, [-0.3 0.9], 'newname', 'syll', 'epochinfo', 'yes');
    EEG_syll = pop_rmbase(EEG_syll, [-300 0]);
    EEG_word = pop_epoch(EEG_cont, {'word'}, [-0.3 0.9], 'newname', 'word', 'epochinfo', 'yes');
    EEG_word = pop_rmbase(EEG_word, [-300 0]);

    n_syll    = EEG_syll.trials;
    n_word    = EEG_word.trials;
    erp_times = EEG_syll.times;
    avg_syll  = mean(EEG_syll.data, 3);
    avg_word  = mean(EEG_word.data, 3);
    fprintf('ERP: N syll epochs = %d, N word epochs = %d\n', n_syll, n_word);

    trials_syll = squeeze(mean(EEG_syll.data, 1));   % nTime x nTrials
    trials_word = squeeze(mean(EEG_word.data, 1));   % nTime x nTrials

    n_samp    = numel(erp_times);
    condition = [repmat({'syll'}, n_syll*n_samp, 1); repmat({'word'}, n_word*n_samp, 1)];
    epoch_num = [repelem((1:n_syll)', n_samp);        repelem((1:n_word)', n_samp)];
    time_ms   = [repmat(erp_times(:), n_syll, 1);   repmat(erp_times(:), n_word, 1)];
    amplitude = [trials_syll(:); trials_word(:)];

    erp_table = table(condition, epoch_num, time_ms, amplitude, ...
        'VariableNames', {'condition', 'epoch', 'time_ms', 'amplitude_uV'});
end

% ---- Plots -------------------------------------------------------------------

function plot_itc_spectrum(freqs, plv)
    avg_plv = mean(plv, 1, 'omitnan');
    itc_fig = figure;
    plot(freqs, plv', 'LineWidth', 0.5);
    hold on;
    plt_avg = plot(freqs, avg_plv, 'k', 'LineWidth', 4);
    xline(1.1111, '--', 'Word (1.11 Hz)',     'FontSize', 12, 'LabelHorizontalAlignment', 'left');
    xline(3.3333, '--', 'Syllable (3.33 Hz)', 'FontSize', 12, 'LabelHorizontalAlignment', 'left');
    set(itc_fig, 'Position', get(0, 'Screensize'));
    xlabel('Frequency (Hz)', 'FontSize', 16, 'FontWeight', 'bold');
    legend_handle = legend(plt_avg, 'Channels Average', 'FontSize', 16);
    set(legend_handle, 'TextColor', 'k', 'FontWeight', 'bold');
    set(gca, 'FontSize', 14, 'FontWeight', 'bold');
    xlim([0 5]);
    hold off;
end

function plot_itc_topoplot(plv_matrix, freqs, chanlocs, varargin)
    p = inputParser;
    addRequired(p,  'plv_matrix');
    addRequired(p,  'freqs');
    addRequired(p,  'chanlocs');
    addParameter(p, 'maplimits', []);
    addParameter(p, 'colormap',  jet);
    parse(p, plv_matrix, freqs, chanlocs, varargin{:});

    maplimits  = p.Results.maplimits;
    cmap       = p.Results.colormap;

    target_freqs = [1.1111, 3.3333];
    freq_labels  = {'Word (1.11 Hz)', 'Syllable (3.33 Hz)'};
    freq_indices = arrayfun(@(f) find(abs(freqs - f) == min(abs(freqs - f)), 1), target_freqs);
    plv_matrix   = plv_matrix(:, freq_indices);

    if isempty(maplimits)
        absmax    = max(abs(plv_matrix(:)));
        maplimits = [-absmax, absmax];
    end

    n_plots  = size(plv_matrix, 2);
    topo_fig = figure;
    set(topo_fig, 'Position', get(0, 'Screensize'));

    for i = 1:n_plots
        subplot(1, n_plots, i);
        topoplot(plv_matrix(:, i), chanlocs, ...
            'style',     'map', ...
            'colormap',  cmap, ...
            'maplimits', maplimits, ...
            'shading',   'interp');
        title(freq_labels{i}, 'Interpreter', 'none', 'FontSize', 14, 'FontWeight', 'bold');
    end

    colorbar;
end

function plot_erp(erp_times, avg_syll, avg_word, n_syll, n_word, subject_id)
    erp_fig = figure;
    set(erp_fig, 'Position', get(0, 'Screensize'));
    h_syll = plot(erp_times, avg_syll', 'Color', [0.2 0.4 1 0.4], 'LineWidth', 0.5);
    hold on;
    h_word = plot(erp_times, avg_word', 'Color', [1 0.2 0.2 0.4], 'LineWidth', 0.5);
    xline(0, '--k', 'LineWidth', 1.5);
    yline(0,  '-k', 'LineWidth', 0.5);
    xlabel('Time (ms)',        'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Amplitude (\muV)', 'FontSize', 16, 'FontWeight', 'bold');
    title(sprintf('%s ERP (%d channels)', subject_id, size(avg_syll, 1)), ...
        'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
    legend([h_syll(1) h_word(1)], ...
        sprintf('Syllable (N=%d)', n_syll), sprintf('Word (N=%d)', n_word), ...
        'FontSize', 14);
    set(gca, 'FontSize', 14, 'FontWeight', 'bold');
    hold off;
end
