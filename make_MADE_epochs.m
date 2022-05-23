function [tEEG] = make_MADE_epochs(EEG,eeg_file_name, json_file_name)
%MAKE_MADE_EPOCHS Function that epochs EEG data for MADE pipeline
%   The function takes EEG, which is an EEGLAB structure with data
%   for one EEG task. The eeg_file_name is the (absolute or relative)
%   path to the EEG file and will be used to extract the task name.
%   The json_file_name is the path to the json configuration file
%   that will be used to guide the extraction of epochs from EEG.
%   The json file should have a field corresponding to the task
%   name for the file of interest. Within that field, there should
%   be an array for marker_names (the markers to extract epochs around),
%   pre_latency and post_latency (both positive and in units seconds).
%   If there is no intrinsic task structure to the EEG acquisition,
%   the additional task related field make_dummy_events, num_dummy_events,
%   and dummy_events_spacing can be used to insert dummy markers that
%   epochs will be constructed around. In the case where dummy markers are
%   used, marker_names should be set as an array containing the first
%   marker to occur within the scan. All subsequent dummy markers will then
%   be placed following the initial instance of the marker named
%   marker_names(1).

%   The returned output is a variable tEEG which contains the epoched data.

%Find the task label
s = grab_settings(eeg_file_name, json_file_name);

%Grab task specific settings
marker_names = s.marker_names;
pre_latency = s.pre_latency;
post_latency = s.post_latency;

%Make copy of EEG file
tEEG = deal(EEG);

if pre_latency < 0
    error('Error: pre_latency should be defined as a positive value.');
end

if iscell(marker_names) == false
    error('Error: json value for marker_names should be a list/array');
end

if isfield(s,'make_dummy_events')
    if s.make_dummy_events
        if length(marker_names) ~= 1
            error('Error: there should be exactly one marker name for rest-like files, made to indicate the point to start creating dummy events.');
        end

        start_index = find(strcmp({tEEG.event.type}, marker_names(1)));
        start_latency = (tEEG.event(start_index).latency)/tEEG.srate;
        if length(start_index) > 1
            error(['Error: there should only be one instance of ' marker_names(1) ' event in EEG file']);
        end

        num_dummy_events = s.num_dummy_events;
        dummy_event_spacing = s.dummy_event_spacing;

        for i = 1:num_dummy_events
            latency = start_latency + dummy_event_spacing*(i-1);
            type = 'dummy_marker';
            tEEG = pop_editeventvals(tEEG,'insert',{1 [] [] []},'changefield',{1 'type' type},'changefield',{1 'latency' latency}); 
        end

        marker_names = {'dummy_marker'};   
    end
end
    
epoch_length=[-1*pre_latency post_latency]; % define Epoch Length
tEEG = eeg_checkset( tEEG );
tEEG = pop_epoch( tEEG, marker_names, epoch_length, 'epochinfo', 'yes');
tEEG = pop_selectevent( tEEG, 'latency','-.1 <= .1','deleteevents','on');



end

