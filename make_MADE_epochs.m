function [tEEG] = make_MADE_epochs(tEEG,eeg_file_name, json_file_name, task, siteinfo, site_delays, session_label)
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

%   TM - added in siteinfo to pull site information for
%   check_missing_dins

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

if isfield(s,'make_dummy_events') % TM -- this chunk runs for RS v08 but only certain parts for din3 (v03/4/6)
    if s.make_dummy_events
        if length(marker_names) ~= 1
            error('Error: there should be exactly one marker name for rest-like files, made to indicate the point to start creating dummy events.');
        end

        if strcmp(marker_names(1), 'DIN3') %add code to address error where there is an extra DIN3 in RS before the bas+ flag
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
        
        if strcmp(marker_names(1), 'DIN3') %adding check here just in case TM
            start_index = find(strcmp({tEEG.event.type}, marker_names(1)));
            if length(start_index) > 1 % TM add code to address error where there is an extra DIN3 at the end of RS (after TRSP)
                tEEG.event(start_index(2)).type = 'EXTRA DIN';
                start_index = find(strcmp({tEEG.event.type}, marker_names(1)));
            end
        else
            start_index = find(strcmp({tEEG.event.type}, marker_names(1))); %V08 find start index for bas+ or soc+
        end

        % TM TODO add an if for if marker names is din3 (ie. V03, V04, V06)
        % then run checkmissingdins code
        if strcmp(marker_names(1), 'DIN3')
            if length(start_index) < 1 % TM add code to check for missing RS din3 and add it in
                tEEG = check_missing_dins(tEEG, task, siteinfo, site_delays);
                start_index = find(strcmp({tEEG.event.type}, marker_names(1)));
            end
            start_latency = (tEEG.event(start_index).latency)/tEEG.srate;
        else
            start_latency = (tEEG.event(start_index).latency)/tEEG.srate; %V08 find start latency
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
    
%add kira's code here -- TM 8/1/24
% TM - add check, if v03/v04/v06 run check missing dins
if contains(session_label, 'V03') || contains(session_label, 'V04') || contains(session_label, 'V06')
    tEEG = check_missing_dins(tEEG, task, siteinfo, site_delays);
    tEEG = eeg_checkset(tEEG);
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

% --- Switch epoching style based on task ---
if contains(eeg_file_name, 'SL')

    % =========================
    % SL-SPECIFIC EPOCHING
    % =========================
    % TRIM DATA FROM FIRST 'stms'
    NumSyllablesPerEpoch = 36;
    interval_sec = 0.300;
    EpochLength  = NumSyllablesPerEpoch * interval_sec;   % seconds

    % Trim to first 'stms' event
    evt_types = {tEEG.event.type};
    stms_idx  = find(strcmp(evt_types, 'stms'), 1, 'first');
    if isempty(stms_idx)
        error('sl_epoch_overhauled: no ''stms'' event found.');
    end

    start_point = tEEG.event(stms_idx).latency;
    tEEG = pop_select(tEEG, 'point', [round(start_point) tEEG.pnts]);
    tEEG = eeg_checkset(tEEG);

    % Create latencies every 300 ms, at each theoretical syllable onset
    srate        = tEEG.srate;
    duration_sec = (tEEG.pnts - 1) / srate;
    times_sec    = 0:interval_sec:duration_sec;
    latencies    = (times_sec * srate) + 1;

    % Place NE markers directly every NumSyllablesPerEpoch 
    evt_idx = length(tEEG.event);
    for i = 1:numel(latencies)
        if mod(i-1, NumSyllablesPerEpoch) == 0
            evt_idx = evt_idx + 1;
            tEEG.event(evt_idx).latency = latencies(i);
            tEEG.event(evt_idx).type    = 'NE';
            tEEG.event(evt_idx).code    = 'NE';
        end
    end

    tEEG = eeg_checkset(tEEG, 'eventconsistency');

    % Keep only NE events
    keepEvents = arrayfun(@(e) strcmp(e.code, 'NE'), tEEG.event);
    tEEG.event = tEEG.event(keepEvents);
    tEEG = eeg_checkset(tEEG, 'makeur');

    % Epoch on 'NE' markers
    tEEG = pop_epoch(tEEG, {'NE'}, [0 EpochLength], ...
        'newname', tEEG.setname, 'epochinfo', 'yes');
    tEEG = eeg_checkset(tEEG);

    % Keep only the time-locking event in each epoch
    keepIdx = false(1, length(tEEG.event));
    for n = 1:tEEG.trials
        lats   = cell2mat(tEEG.epoch(n).eventlatency);
        evIdx  = tEEG.epoch(n).event;
        keepIdx(evIdx(lats == 0)) = true;
    end
    tEEG.event = tEEG.event(keepIdx);
    tEEG = eeg_checkset(tEEG);

    % Baseline correction
    tEEG = pop_rmbase(tEEG, [tEEG.times(1) tEEG.times(end)]);
    tEEG = eeg_checkset(tEEG);

    % Sanity check — verify epoch count matches expectation
    expected_epochs = floor((numel(latencies) - 1) / NumSyllablesPerEpoch);
    actual_epochs   = numel(tEEG.epoch);
    if actual_epochs < expected_epochs - 1
        error('Epoch count mismatch: expected %d epochs but got %d.', ...
            expected_epochs, actual_epochs);
    elseif actual_epochs == expected_epochs - 1
        fprintf('Note: last epoch dropped by pop_epoch (recording too short for full epoch window). Got %d of %d expected epochs.\n', ...
            actual_epochs, expected_epochs);
    end

    fprintf('sl_epoch_overhauled: %d epochs created.\n', actual_epochs);

else

    % =========================
    % DEFAULT EPOCHING (ALL OTHER TASKS)
    % =========================

    tEEG = pop_selectevent(tEEG, 'type', marker_names, 'deleteevents', 'on');
    tEEG = pop_epoch(tEEG, marker_names, epoch_length, 'epochinfo', 'yes');
    tEEG = pop_selectevent(tEEG, 'latency','-.1 <= .1','deleteevents','on');
end
