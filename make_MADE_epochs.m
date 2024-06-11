function [tEEG] = make_MADE_epochs(tEEG,eeg_file_name, json_file_name, task)
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
erp_filter = s.erp_filter;
erp_lowpass = s.erp_lowpass;

%Make copy of EEG file
tEEG = deal(tEEG);

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

        if strcmp(marker_names(1), 'DIN3') %add code to address error where there are multiple DIN3 in RS
            if numel(find(strcmp({tEEG.event.type}, 'DIN3')))>1
                bas_lat = find(strcmp({tEEG.event.type}, 'bas+'));
                din_lat = find(strcmp({tEEG.event.type}, 'DIN3'));
                if numel(bas_lat) == 1
                    for i=din_lat
                        if i < bas_lat
                            tEEG.event(i).type = 'EXTRA DIN';
                        end
                    end
                end
            end
        end
        
        start_index = find(strcmp({tEEG.event.type}, marker_names(1)));
        if length(start_index) > 1
            error(['Error: there should only be one instance of ' marker_names(1) ' event in EEG file']);
        end
        start_latency = (tEEG.event(start_index).latency)/tEEG.srate;


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
%if ~strcmp(task, 'RS')
%    tEEG = pop_selectevent( tEEG, 'Task', task,'deleteevents','on');
%end

% This section ONLY does low pass, NOT high pass
% Remember to change the value of lowpass
if erp_filter == 1
% 7. Initialize the filters
  %highpass = s.highpass; % High-pass frequency
  %lowpass  = s.lowpass; % Low-pass frequency. We recommend low-pass filter at/below line noise frequency (see manuscript for detail)
  lowpass  = erp_lowpass;
  % STEP 6: Filter data
    % Calculate filter order using the formula: m = dF / (df / fs), where m = filter order,
    % df = transition band width, dF = normalized transition width, fs = sampling rate
    % dF is specific for the window type. Hamming window dF = 3.3
    
    %high_transband = highpass; % high pass transition band
    low_transband = 10; % low pass transition band
    
    %hp_fl_order = 3.3 / (high_transband / EEG.srate);
    lp_fl_order = 3.3 / (low_transband / tEEG.srate);
    
    % Round filter order to next higher even integer. Filter order is always even integer.
%     if mod(floor(hp_fl_order),2) == 0
%         hp_fl_order=floor(hp_fl_order);
%     elseif mod(floor(hp_fl_order),2) == 1
%         hp_fl_order=floor(hp_fl_order)+1;
%     end
    
    if mod(floor(lp_fl_order),2) == 0
        lp_fl_order=floor(lp_fl_order)+2;
    elseif mod(floor(lp_fl_order),2) == 1
        lp_fl_order=floor(lp_fl_order)+1;
    end
    
    % Calculate cutoff frequency
    %high_cutoff = highpass/2;
    low_cutoff = lowpass + (low_transband/2);
    
%     % Performing high pass filtering
%     EEG = eeg_checkset( EEG );
%     EEG = pop_firws(EEG, 'fcutoff', high_cutoff, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', hp_fl_order, 'minphase', 0);
%     EEG = eeg_checkset( EEG );
    
    
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)
    
    % Performing low pass filtering
    tEEG = eeg_checkset( tEEG );
    tEEG = pop_firws(tEEG, 'fcutoff', low_cutoff, 'ftype', 'lowpass', 'wtype', 'hamming', 'forder', lp_fl_order, 'minphase', 0);
    tEEG = eeg_checkset( tEEG );
    
    % pop_firws() - transition band width: 10 Hz
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)    
    
end %if erp filter is turned on

tEEG = pop_selectevent(tEEG, 'type', marker_names, 'deleteevents', 'on'); %LY TEMP
tEEG = pop_epoch( tEEG, marker_names, epoch_length, 'epochinfo', 'yes');
tEEG = pop_selectevent( tEEG, 'latency','-.1 <= .1','deleteevents','on');



end

