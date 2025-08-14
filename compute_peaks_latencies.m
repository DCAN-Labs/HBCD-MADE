function [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG, PeakRange, roi_ind, direction)
%This function primarily does the individual trials,
% much of this information/calculations are done again
% in the main script

%% Find peak, avg around it 

EEG_ui_roi = squeeze(mean(EEG.data(roi_ind, :,:),1)); %select and average across channels of interest
EEG_roi_tw = EEG_ui_roi(PeakRange, :);
if direction==1
    EEG_peak_values = squeeze(max(EEG_roi_tw));
elseif direction==-1
    EEG_peak_values = squeeze(min(EEG_roi_tw));
end

EEG_avg_peak_values = zeros((length(EEG_peak_values)),1);
EEG_peak_latencies = zeros((length(EEG_peak_values)),1);

for i=1:length(EEG_peak_values)
    
    peak_index = find(EEG_ui_roi(:,i)== EEG_peak_values(i),1);
    peak_latency = EEG.times(peak_index);
    
    % Define fixed window size around the peak (±10 ms)
    % This is our adaptive mean
    window_ms = 10;

    % Find index range within ±10 ms of the peak
    peakav_start = find(EEG.times >= peak_latency - window_ms, 1, 'first');
    peakav_end   = find(EEG.times <= peak_latency + window_ms, 1, 'last');

    % Fallback to ensure indices exist
    if isempty(peakav_start)
        peakav_start = 1;
    end
    if isempty(peakav_end)
        peakav_end = length(EEG.times);
    end


    AvgPeakRange = peakav_start:peakav_end;

    avg_peak_value = squeeze(mean(EEG_ui_roi(AvgPeakRange, i),1)); %select and average across timerange of interest
    
    EEG_avg_peak_values(i) = avg_peak_value;
    EEG_peak_latencies(i) = peak_latency;
end

AvgPeakScores = EEG_avg_peak_values;
PeakLatencies = EEG_peak_latencies;
%% === Sanity check on Window lengths: Average ERP across trials ===
%This will compute the windows for EACH subject's INDIVIDUAL components
% 3 figures per subject for VEP

% avg_signal = mean(EEG_ui_roi, 2);  % average over trials
% if direction == 1
%     [peak_value, peak_idx] = max(avg_signal(PeakRange));
% elseif direction == -1
%     [peak_value, peak_idx] = min(avg_signal(PeakRange));
% end
% 
% peak_idx = PeakRange(1) + peak_idx - 1;
% peak_latency = EEG.times(peak_idx);
% 
% % ±10 ms window around peak
% peakav_start = find(EEG.times >= peak_latency - window_ms, 1, 'first');
% peakav_end   = find(EEG.times <= peak_latency + window_ms, 1, 'last');
% AvgPeakRange = peakav_start:peakav_end;

% Plot average signal and peak window
% figure;
% plot(EEG.times, avg_signal, 'b', 'LineWidth', 1.5); hold on;
% plot(peak_latency, peak_value, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
% area(EEG.times(AvgPeakRange), avg_signal(AvgPeakRange), ...
%      'FaceColor', [0.9 0.6 0.6], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
% xlabel('Time (ms)');
% ylabel('Amplitude (μV)');
% title(sprintf('Average ERP across trials — Peak at %.1f ms', peak_latency));
% legend('ERP Avg', 'Peak', '±10 ms Window');
% grid on; hold off;
end
