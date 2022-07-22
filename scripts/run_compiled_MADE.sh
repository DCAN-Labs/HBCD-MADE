#!/bin/bash

output_dir_name=/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v111_ekg/testing_output/
bids_dir=/home/midb-ig/shared/data_sources/leex6144/UMD0012_546802_V03_bids/
participant_label=sub-UMD0012
session_label=_
file_extension=.set
json_settings_file=/home/midb-ig/shared/repositories/leex6144/HBCD-MADE/testing_settings.json
save_interim_result=1

/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v111_ekg/run_MADE/for_testing/run_run_MADE.sh \
/home/midb-ig/shared/repositories/leex6144/v910/ $output_dir_name $bids_dir $participant_label $session_label $file_extension $json_settings_file $save_interim_result
