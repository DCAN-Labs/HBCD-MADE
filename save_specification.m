function save_specification(s, output_folder, eeg_file_name)
%SAVE_SPECIFICATION helper function to save processing parameters used for
%individual tasks within the MADE pipeline

% s is a struct with task specific settings

%Final json will be saved in output folder
%with the same name as eeg_file_name, except
%with MADE appended to the end and the extension
%switched to json
[a,filename, extension] = fileparts(eeg_file_name);
output_path = fullfile(output_folder, strrep(filename, '_eeg', '_MADEspecification.json'));
fid = fopen(output_path, 'w');
json_content = jsonencode(s, PrettyPrint=true);
fprintf(fid, json_content);
fclose(fid);
end

