%% Load data
filename = 'sub-1_ses-1_task-MMN_run-1_acq-eeg_eeg_filtered_data_processed_data.set';
filepath = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/example_HBCD_output_container_v3/sub-1/ses-1/eeg/processed_data/';
EEG1 = pop_loadset('filename',filename,'filepath',filepath);

filename = 'sub-1_ses-1_task-MMN_run-2_acq-eeg_eeg_filtered_data_processed_data.set';
filepath = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/example_HBCD_output_container_v3/sub-1/ses-1/eeg/processed_data/';
EEG2 = pop_loadset('filename',filename,'filepath',filepath);

%% Make plot

electrode_num = 1;
corrs = zeros(105,1);
for i = 1 : 105
    single_electrode_ave1 = squeeze((mean(EEG1.data(i,:,:),3)));
    single_electrode_ave2 = squeeze((mean(EEG2.data(i,:,:),3)));
    corrs(i) = corr(single_electrode_ave1', single_electrode_ave2');
end
figure;
hist(corrs);

%ylim([-600,600]);