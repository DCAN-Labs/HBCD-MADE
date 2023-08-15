%run_MADE(output_dir_name, bids_dir, participant_label, ...
%                  session_label, file_extension, ...
 %                 json_settings_file, save_interim_result)

addpath('C:\Users\lyoder\Documents\HBCD-MADE')
 
output_dir_name = 'C:\Users\lyoder\Documents\MADE_output'; 
bids_dir = 'C:\Users\lyoder\Documents\PIUMD0042_225728_V03_bids'; 
participant_label = 'sub-PIUMD0042';
session_label = 'ses-V03';
file_extension = '.set';
json_settings_file = 'C:\Users\lyoder\Documents\HBCD-MADE\proc_settings_HBCD_LY_MM_MA.json';

run_MADE(output_dir_name, bids_dir, participant_label, ...
                 session_label, file_extension, ...
                 json_settings_file, 1)