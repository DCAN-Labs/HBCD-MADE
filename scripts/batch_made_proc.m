output_dir_name = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/example_HBCD_output';
bids_dir = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/HBCD_Style_UMD_EEG_Pilot/BIDS_manual';
participant_label = 'sub-1';
session_label = '';
file_extension = '.set';
json_settings_file = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/proc_settings_fast.json';
save_interim_result = char('1');

output_dir_name = char(output_dir_name);
bids_dir = char(bids_dir);
participant_label = char(participant_label);
session_label = char(session_label);
file_extension = char(file_extension);
json_settings_file = char(json_settings_file);



run_MADE(output_dir_name, bids_dir, participant_label, ...
          session_label, file_extension, ...
          json_settings_file, save_interim_result)