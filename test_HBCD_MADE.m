%run_MADE(output_dir_name, bids_dir, participant_label, ...
%                  session_label, file_extension, ...
%                 json_settings_file, save_interim_result)

addpath('C:\Users\kasenetz\Documents\GitHub\HBCD-MADE')
addpath 'C:\Users\kasenetz\Documents\GitHub\HBCD-MADE\scripts\plottingScripts' 
addpath 'C:\Users\kasenetz\Documents\GitHub\HBCD-MADE\scripts\getLineNoise'
addpath 'C:\Users\kasenetz\Documents\GitHub\HBCD-MADE\adjusted_adjust_scripts'
addpath 'C:\Users\kasenetz\Documents\GitHub\HBCD-MADE\scripts'

output_dir_name = 'C:\Users\kasenetz\Documents\QIUCS0026_512994_P06_bids\MADE_output_updates'; 
bids_dir = 'C:\Users\kasenetz\Documents\QIUCS0026_512994_P06_bids'; 
participant_label = 'sub-512994';
session_label = 'ses-P06';
file_extension = '.set';
json_settings_file = 'C:\Users\kasenetz\Documents\GitHub\HBCD-MADE\proc_settings_HBCD.json';

run_MADE(output_dir_name, bids_dir, participant_label, ...
                 session_label, file_extension, ...
                 json_settings_file, 1)