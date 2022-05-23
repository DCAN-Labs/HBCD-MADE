function s = grab_settings(eeg_file_name, json_file_name)
% GRAB_SETTING Given eeg_file_name, find settings from json file
%
% EEG_FILE_NAME will be used to identify the task label for the
% current file being analyzed. The file found at json_file_name
% is then loaded. Once loaded, the global parameters are first
% identified, and these parameters are then updated/overwritten
% by the parameters for the specific task. If the task name is not
% found in the json, then the script will throw an error.

%Load the json file contents
fid = fopen(json_file_name, 'r');
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
json_contents = jsondecode(str);

%Find the task label
temp_split = split(eeg_file_name, 'task-');
if length(temp_split) ~= 2
    error('Error: EEG file name should have the sequence of letters "task-" exactly once.');
end
post_task = temp_split{2};
post_task_split = split(post_task, '_');
task_label = post_task_split{1};

%Check if the task label is present in the json
if isfield(json_contents, task_label) == 0
    error(['Error: the task ' task_label ' is not defined in the json structure ' json_file_name ', and therefore can not be processed.']);
end


%Initialize params file with global settings,
%and then update the params with task-specific
%settings. In the case where they overlap, task
%specfic params are taken.
params = json_contents.global_parameters;
task_params = json_contents.(task_label);
task_field_names = fieldnames(task_params);
for i = 1 : length(task_field_names)
    temp_name = task_field_names(i);
    temp_name = temp_name{1};
    params.(temp_name) = task_params.(temp_name);
end
s = params;
end
