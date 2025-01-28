function [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG, PeakRange, roi_ind)


%% Find peak, avg around it 

EEG_ui_roi = squeeze(mean(EEG.data(roi_ind, :,:),1)); %select and average across channels of interest
EEG_roi_tw = EEG_ui_roi(PeakRange, :);
EEG_peak_values = squeeze(max(EEG_roi_tw));

EEG_avg_peak_values = zeros((length(EEG_peak_values)),1);
EEG_peak_latencies = zeros((length(EEG_peak_values)),1);

for i=1:length(EEG_peak_values)
    
    peak_index = find(EEG_ui_roi(:,i)== EEG_peak_values(i),1);
    peak_latency = EEG.times(peak_index);
    
    sd = fix(std(EEG.times));

    peakav_start = find(EEG.times == peak_latency-sd);
    peakav_end = find(EEG.times == peak_latency+sd);

    if isempty(peakav_start)
        peakav_start = 1;

    elseif isempty(peakav_end)
        peakav_end = length(EEG.times);

    end

    AvgPeakRange = peakav_start:peakav_end;

    avg_peak_value = squeeze(mean(EEG_ui_roi(AvgPeakRange, i),1)); %select and average across timerange of interest
    
    EEG_avg_peak_values(i) = avg_peak_value;
    EEG_peak_latencies(i) = peak_latency;
    
end

AvgPeakScores = EEG_avg_peak_values;
PeakLatencies = EEG_peak_latencies;

































end