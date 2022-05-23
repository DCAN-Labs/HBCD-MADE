function [tEEG] = update_for_single_task_proc(EEG,eeg_file_name, json_file_name)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Find the task label
s = grab_settings(eeg_file_name, json_file_name);

marker_names = s.marker_names;
pre_latency = s.pre_latency;
post_padding = s.post_latency;
make_dummy_events = s.make_dummy_events;


if pre_latency < 0
    error('Error: pre_latency should be defined as a positive value.');
end

if iscell(marker_names) == false
    error('Error: json value for marker_names should be a list/array');
end

if make_dummy_events == true
    if length(marker_names) ~= 1
        error('Error: there should be exactly one marker name for rest-like files, made to indicate the point to start creating dummy events.');
    end
    
    start_index = find(strcmp({EEG.event.type}, marker_names(1)));
    start_latency = (EEG.event(start_index).latency)/EEG.srate;
    if length(start_index) > 1
        error(['Error: there should only be one instance of ' marker_names(1) ' event in EEG file']);
    end
    
    num_dummy_events = s.num_dummy_events;
    dummy_event_spacing = s.dummy_event_spacing;

    for i = 1:num_dummy_events
        latency = start_latency + dummy_event_spacing*(i-1);
        type = 'resting_state_dummy_marker';
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' type},'changefield',{1 'latency' latency}); 
    end
    
    marker_names = {'resting_state_dummy_marker'};            
end
    
epoch_length=[-1*pre_latency post_latency]; % define Epoch Length
tEEG = eeg_checkset( tEEG );
tEEG = pop_epoch( tEEG, marker_names, epoch_length, 'epochinfo', 'yes');
tEEG = pop_selectevent( tEEG, 'latency','-.1 <= .1','deleteevents','on');



end

