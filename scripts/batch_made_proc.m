output_dir_name = '/home/midb-ig/shared/data_sources/leex6144/UMD0012_546802_V03_MADE_OUTPUT_7_19_22/';
bids_dir = '/home/midb-ig/shared/data_sources/leex6144/UMD0012_546802_V03_bids/';
participant_label = 'sub-UMD0012';
session_label = '';
file_extension = '.set';
json_settings_file = '/panfs/roc/groups/12/midb-ig/shared/repositories/leex6144/HBCD-MADE/testing_settings.json';
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