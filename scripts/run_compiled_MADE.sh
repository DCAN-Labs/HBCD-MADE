#!/bin/bash

output_dir_name=/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/example_HBCD_output_compiled/
bids_dir=/panfs/roc/groups/8/faird/shared/data/HBCD_Style_UMD_EEG_Pilot/BIDS_manual/
participant_label=sub-1
session_label=ses-1
file_extension=.set
json_settings_file=/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v104_for_sharing/proc_settings_fast.json
save_interim_result=1

./run_MADE/for_testing/run_run_MADE.sh /home/midb-ig/shared/repositories/leex6144/v910/ $output_dir_name $bids_dir $participant_label $session_label $file_extension $json_settings_file $save_interim_result