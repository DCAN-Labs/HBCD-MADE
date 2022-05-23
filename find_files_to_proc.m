function files = find_files_to_proc(bids_dir, participant_label, session_label, ...
task_label, file_extension, force_session_def)
% find_files_to_proc  Grab BIDS formatted EEG data
%   bids_dir = 'path/to/study
%   participant_label = 'sub-01'
%   session_label = '' or 'ses-01'
%   task_label = '' or 'oddball'
%   file_extension = '.set'
%   force_session_def = 0
%   files = eeg_files(bids_dir, participant_label, session_label, ...
%                     task_label, file_extension)
%
% If you want to grab the paths for all sessions that a subject has
% or all tasks, then set those variables to an empty string (i.e. ''),
% otherwise provide a string as input. The output of this function
% is formatted like the output of the "dir" function, and only
% contains data that correspond to the function's input. The task_label
% should follow BIDS formatting and only should have the name of the task
% ID (not the information about the subject/session or run number). If
% force_session_def is greater than 0, then the function will throw an
% error when session_label is blank and the subject has more than one
% session. 

%To make things easier for command line running,
%if the task label is a single underscore, that
%will be treated the same as 
if strcmp('_', task_label)
    task_label = '';
end

%Do the same for session also
if strcmp('_', session_label)
    session_label = '';
end

%Be sure that the provided task label
%doesn't have any underscores (this is unrelated
%to the the previous use case)
if length(split(task_label, '_')) > 1
    error(['Error: your task label ' task_label ' should not have underscores to be BIDS compliant!']);
end


subject_path = fullfile(bids_dir, participant_label);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Identify all EEG files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%In case when we don't have session information
if strcmp(session_label, '')
    pattern_1 = fullfile(subject_path, 'eeg', ['*' file_extension]);
    pattern_2 = fullfile(subject_path, 'ses-*', 'eeg', ['*' file_extension]);
    eeg_files_1 = dir(pattern_1);
    eeg_files_2 = dir(pattern_2);
    files = [eeg_files_1; eeg_files_2];

    %Make sure you have at least one file
    if isempty(files)
        error(['No files found identifying the patterns: ' pattern_1 ' and ' pattern_2]);
    end
    
    %If force_session_def > 0 and the subject has more than one session
    %then raise an error.
    sessions = dir(fullfile(subject_path, 'ses-*'));
    if length(sessions) > 1
        if force_session_def > 0
            error('Error: More than one session present in directory, but input configuration calls for data from one session. Try adding session definition.');
        end
    end

%In case when we have session information
else
    
    pattern = fullfile(subject_path, session_label, 'eeg', ['*' file_extension]);
    files = dir(pattern);
    
    %Make sure you have at least one file
    if isempty(files)
        error(['No files found identifying the pattern: ' pattern]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%If only a certain task is to be processed,
%find files with names conforming to that task label.
%If you have issues here be sure you don't have
%underscores within your task name!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(task_label, '') == 0
    
    temp_eeg_files = struct([]);
    ticker = 1;
    
    %Iterate through all eeg_files to find which ones correspond
    %to the task of interest
    for i = 1 : length(files)
        
        temp_name = files(i).name;
        temp_split = split(temp_name, 'task-');
        if length(temp_split) ~= 2
            error('Error: EEG file name should have the sequence of letters "task-" exactly once.');
        end
        post_task = temp_split{2};
        post_task_split = split(post_task, '_');
        if length(post_task_split) == 1
            post_task_split = split(post_task, '.');
        end
        temp_task_label = post_task_split{1};
        if strcmp(temp_task_label, task_label)
            temp_eeg_files = [temp_eeg_files; files(i)];
            ticker = ticker + 1;
        end
        
    end
    
    %Update eeg_files with the task relevant files
    files = temp_eeg_files;
    
    %Make sure you at least have one file
    if isempty(files)
        error(['Error, no files found with task label: ' task_label]);
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end