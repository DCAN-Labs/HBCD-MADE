function [EEG, event_struct] = merge_data(output_location, extension, subses)
%MERGE_DATA Internal function to assist running the MADE pipeline
%   Folder takes the output_location variable for this subject/session
%   and the EEG file type extension, and uses this to load all the EEG
%   data within filtered_data. This data is then merged and saved. The
%   function also returns a copy of the merged EEG data along with a 
%   struct that has the name of the different tasks that make up the
%   merged file, along with the event indices in the merged file that
%   belong to that run. This info is also saved as a json in the 
%   merged folder.

filtered_files = dir(fullfile(output_location, 'filtered_data', ['sub*' extension]));
ALLEEG = [];
EEG_idx = [];
CURRENTSET = [];
task_specific_event_indices = {};
task_names = {};
temp_index = 0;

if exist(fullfile(output_location, 'merged_data')) == 0
    mkdir(fullfile(output_location, 'merged_data'));
end

for i = 1 : length(filtered_files)
    
    %Load data
    EEG = [];
    EEG = pop_loadset('filename', filtered_files(i).name,'filepath',filtered_files(i).folder);
    
    %Add extra field to the event with the file name
    for j = 1 : length(EEG.event)
        EEG.event(j).input_file = filtered_files(i).name;
    end
    
    %Record indices
    task_specific_event_indices{i} = (temp_index + 1): (temp_index + length(EEG.event)); %-1);
    task_names{i} = filtered_files(i).name;
    temp_index = temp_index + length(EEG.event) + 1;%Extra increment here since
                                                     %EEGLAB puts in extra
                                                     %boundary event
                                                     %between tasks
    
    %Merge data
    [ALLEEG, EEG] = eeg_store( ALLEEG, EEG, i);
    EEG_idx(i) = i;
    
end


%If there is more than one element to merge then do so, otherwise load the
%single EEG file for the participant/session.
if length(filtered_files) > 1
    EEG = pop_mergeset(ALLEEG,EEG_idx);
    EEG = eeg_checkset( EEG );
else
    EEG = ALLEEG(1);
end

EEG = eeg_checkset( EEG );
EEG = pop_editset(EEG, 'setname', [subses '_desc-merged_eeg']);
EEG = pop_saveset(EEG, 'filename',[subses '_desc-merged_eeg.set'],'filepath', [output_location filesep 'merged_data']); 
%[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); %NOT SURE IF THIS DOES ANYTHING???

event_struct = struct();
event_struct.file_names = task_names;
event_struct.indices = task_specific_event_indices;

event_struct_path = fullfile(output_location, 'merged_data', [subses '_desc-merged_eeg.json']);
fid = fopen(event_struct_path, 'w');
json_contents = jsonencode(event_struct, PrettyPrint = true);
fprintf(fid, json_contents);
fclose(fid)

end

