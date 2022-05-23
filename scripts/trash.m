files = dir('/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/sub-1/ses-1/eeg/filtered_data/*.json');
json_path = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/proc_settings.json';
for i = 1 : length(files)
    %Find the task label
    s = grab_settings(files(i).name, json_file_name);

    %Grab task specific settings
    marker_names = s.marker_names;
end