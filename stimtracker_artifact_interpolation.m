function [EEG, artifact_detected, stimtracker_interp_applied] = stimtracker_artifact_interpolation( ...
    EEG, task_label, interpolate_all, plot_debug)

% =========================================================
% Detect + interpolate known stimulus artifact
%
% INPUTS
% ---------------------------------------------------------
% EEG                EEGLAB struct
% filename           filename for plotting
% task_label         task-MMN / task-VEP / task-FACE
% interpolate_all    true  = interpolate all files
%                    false = interpolate only detected files
% plot_debug         true/false for before-after ERP plots
%
% OUTPUTS
% ---------------------------------------------------------
% EEG                interpolated EEG
% artifact_detected  logical
% =========================================================

% ---------------------------------------------------------
% Defaults
% ---------------------------------------------------------

if nargin < 3
    interpolate_all = true;
end

if nargin < 4
    plot_debug = false;
end
stimtracker_interp_applied = 0;
% ---------------------------------------------------------
% SETTINGS
% ---------------------------------------------------------

spike_times = [0, 260];

window_ms = 10;

slope_thresh = 0.5;
amp_thresh = 1.0;

epoch_tmin = -0.1;
epoch_tmax = 0.6;

interp_N = 10;
interp_method = 'linear';
filename = EEG.filename;
% ---------------------------------------------------------
% Determine trigger type from task
% ---------------------------------------------------------

if strcmp(task_label, 'task-MMN')

    trigger_type = 'DIN2';

elseif any(strcmp(task_label, {'task-VEP', 'task-FACE'}))

    trigger_type = 'DIN3';

else

    error('Unsupported task label: %s', task_label);

end

% ---------------------------------------------------------
% Epoch data
% ---------------------------------------------------------

fs = EEG.srate;

EEG_ep = pop_epoch(EEG, {trigger_type}, ...
    [epoch_tmin, epoch_tmax], ...
    'epochinfo', 'yes');

EEG_ep = pop_rmbase(EEG_ep, []);

if EEG_ep.trials < 10

    fprintf('Too few trials for detection.\n');

    artifact_detected = NaN;

    return;

end

% ---------------------------------------------------------
% Compute ERP
% ---------------------------------------------------------

erp = mean(EEG_ep.data, 3);

chan_idx = find(strcmp({EEG_ep.chanlocs.labels}, 'E55'));

if isempty(chan_idx)

    warning('Channel E55 not found.');

    artifact_detected = false;

    return;

end

global_erp = erp(chan_idx, :);

times_ms = EEG_ep.times;

erp_diff = diff(global_erp);

window_samples = round(window_ms / 1000 * fs);

combined_flags = false(1, length(spike_times));

% ---------------------------------------------------------
% Detect artifacts
% ---------------------------------------------------------

for s = 1:length(spike_times)

    spike_time = spike_times(s);

    [~, idx_center] = min(abs(times_ms - spike_time));

    idx_before = max(1, idx_center - window_samples);
    idx_after  = min(length(global_erp), idx_center + window_samples);

    % Amplitude detection
    diff_before = abs(global_erp(idx_center) - global_erp(idx_before));

    diff_after  = abs(global_erp(idx_after) - global_erp(idx_center));

    max_diff = max(diff_before, diff_after);

    % Slope detection
    idx_slope = idx_center - 1;

    if idx_slope - 1 < 1 || idx_slope + 1 > length(erp_diff)

        max_slope = 0;

    else

        slope_window = erp_diff(idx_slope - 1 : idx_slope + 1);

        max_slope = max(abs(slope_window));

    end

    amp_flag = max_diff > amp_thresh;

    slope_flag = max_slope > slope_thresh;

    combined_flags(s) = amp_flag || slope_flag;

end

artifact_detected = all(combined_flags);

fprintf('Artifact detected: %d\n', artifact_detected);

% ---------------------------------------------------------
% Decide whether to interpolate
% ---------------------------------------------------------

do_interpolation = interpolate_all || artifact_detected;

if ~do_interpolation

    fprintf('Skipping interpolation.\n');

    return;

end

% ---------------------------------------------------------
% Save ERP before interpolation
% ---------------------------------------------------------

if plot_debug

    erp_before = global_erp;

end

% ---------------------------------------------------------
% Artifact windows (samples)
% ---------------------------------------------------------

main_artifact = round([0, 10] * fs / 1000);

offset_artifact = round([256, 266] * fs / 1000);

n_channels = size(EEG.data, 1);

% ---------------------------------------------------------
% Interpolate artifact
% ---------------------------------------------------------

fprintf('Applying known artifact interpolation...\n');
stimtracker_interp_applied = 1;
for i = 1:length(EEG.event)

    if strcmp(EEG.event(i).type, trigger_type)

        event_sample = round(EEG.event(i).latency);

        % Main artifact
        s1 = event_sample + main_artifact(1);
        e1 = event_sample + main_artifact(2);

        % Offset artifact
        s2 = event_sample + offset_artifact(1);
        e2 = event_sample + offset_artifact(2);

        for ch = 1:n_channels

            % -----------------------------
            % Main artifact interpolation
            % -----------------------------

            x_known1 = [s1-interp_N:s1-1, e1+1:e1+interp_N];

            y_known1 = EEG.data(ch, x_known1);

            xi1 = s1:e1;

            EEG.data(ch, xi1) = interp1( ...
                x_known1, ...
                y_known1, ...
                xi1, ...
                interp_method, ...
                'extrap');

            % -----------------------------
            % Offset artifact interpolation
            % -----------------------------

            x_known2 = [s2-interp_N:s2-1, e2+1:e2+interp_N];

            y_known2 = EEG.data(ch, x_known2);

            xi2 = s2:e2;

            EEG.data(ch, xi2) = interp1( ...
                x_known2, ...
                y_known2, ...
                xi2, ...
                interp_method, ...
                'extrap');

        end
    end
end

% ---------------------------------------------------------
% Debug plot
% ---------------------------------------------------------

if plot_debug

    EEG_after_ep = pop_epoch(EEG, {trigger_type}, ...
        [epoch_tmin, epoch_tmax], ...
        'epochinfo', 'yes');

    EEG_after_ep = pop_rmbase(EEG_after_ep, []);

    erp_after = mean(EEG_after_ep.data(chan_idx,:,:), 3);

    figure('Visible','off','Color','w','Name',filename);

    plot(times_ms, erp_before * 1e6, ...
        'r', 'LineWidth', 1.5);

    hold on;

    plot(times_ms, erp_after * 1e6, ...
        'b', 'LineWidth', 1.5);

    xline(0, '--k');

    legend({'Before', 'After'});

    xlabel('Time (ms)');

    ylabel('\muV');

    title(sprintf('Artifact Interpolation Debug\n%s', ...
        filename), ...
        'Interpreter', 'none');

    saveas(gcf, fullfile(pwd, [filename '_stimtrackerQC.png']));
    close(gcf);

end

end