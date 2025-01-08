%run_MADE(output_dir_name, bids_dir, participant_label, ...
%                  session_label, file_extension, ...
%                 json_settings_file, save_interim_result)

addpath('C:\Users\lyoder\Documents\HBCD-MADE')
addpath 'C:\Users\lyoder\Documents\HBCD-MADE\scripts\plottingScripts' 
addpath 'C:\Users\lyoder\Documents\HBCD-MADE\scripts\getLineNoise'
addpath 'C:\Users\lyoder\Documents\HBCD-MADE\adjusted_adjust_scripts'
addpath 'C:\Users\lyoder\Documents\HBCD-MADE\scripts'

output_dir_name = 'C:\Users\lyoder\Documents\test_file\MADE_output_updates'; 
bids_dir = 'C:\Users\lyoder\Documents\test_file'; 
participant_label = 'sub-ID';
session_label = 'ses-session';
file_extension = '.set';
json_settings_file = 'C:\Users\lyoder\Documents\HBCD-MADE\proc_settings_HBCD.json';

run_MADE(output_dir_name, bids_dir, participant_label, ...
                 session_label, file_extension, ...
                 json_settings_file, 1)