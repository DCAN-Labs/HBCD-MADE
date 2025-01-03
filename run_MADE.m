function run_MADE(output_dir_name, bids_dir, participant_label, ...
                  session_label, file_extension, ...
                  json_settings_file, save_interim_result)
                          
              
% ************************************************************************
% The Maryland Analysis of Developmental EEG (UMADE) Pipeline
% Version 1.0
% Developed at the Child Development Lab, University of Maryland, College Park

% Original Contributors to MADE pipeline:
% Ranjan Debnath (rdebnath@umd.edu)
% George A. Buzzell (gbuzzell@umd.edu)
% Santiago Morales Pamplona (moraless@umd.edu)
% Stephanie Leach (sleach12@umd.edu)
% Maureen Elizabeth Bowers (mbowers1@umd.edu)
% Nathan A. Fox (fox@umd.edu)

% Ongoing Contributors:
% Lydia Yoder (lyoder@umd.edu)
% Erik Lee (leex6144@umn.edu)
% Martin Antunez Garcia (mantunez@umd.edu )
% Marco McSweeney (mmcsw1@umd.edu)

% MADE uses EEGLAB toolbox and some of its plugins. Before running the pipeline, you have to install the following:
% EEGLab:  https://sccn.ucsd.edu/eeglab/downloadtoolbox.php/download.php

% You also need to download the following plugins/extensions from here: https://sccn.ucsd.edu/wiki/EEGLAB_Extensions

% Specifically, download:
% MFFMatlabIO: https://github.com/arnodelorme/mffmatlabio/blob/master/README.txt
% FASTER: https://sourceforge.net/projects/faster/
% ADJUST: https://www.nitrc.org/projects/adjust/
% Adjusted ADJUST (included in this pipeline):  https://github.com/ChildDevLab/MADE-EEG-preprocessing-pipeline

% After downloading these plugins (as zip files), you need to place it in the eeglab/plugins folder.
% For instance, for FASTER, you uncompress the downloaded extension file (e.g., 'FASTER.zip') and place it in the main EEGLAB "plugins" sub-directory/sub-folder.
% After placing all the required plugins, add the EEGLAB folder to your path by using the following code:

% addpath(genpath(('...')) % Enter the path of the EEGLAB folder in this line

% Please cite the following references for in any manuscripts produced utilizing MADE pipeline:

% EEGLAB: A Delorme & S Makeig (2004) EEGLAB: an open source toolbox for
% analysis of single-trial EEG dynamics. Journal of Neuroscience Methods, 134, 9?21.

% firfilt (filter plugin): developed by Andreas Widmann (https://home.uni-leipzig.de/biocog/content/de/mitarbeiter/widmann/eeglab-plugins/)

% FASTER: Nolan, H., Whelan, R., Reilly, R.B., 2010. FASTER: Fully Automated Statistical
% Thresholding for EEG artifact Rejection. Journal of Neuroscience Methods, 192, 152?162.

% ADJUST: Mognon, A., Jovicich, J., Bruzzone, L., Buiatti, M., 2011. ADJUST: An automatic EEG
% artifact detector based on the joint use of spatial and temporal features. Psychophysiology, 48, 229?240.
% Our group has modified ADJUST plugin to improve selection of ICA components containing artifacts

% This pipeline is released under the GNU General Public License version 3.

% ************************************************************************

%% User input: user provide relevant information to be used for data processing
% Preprocessing of EEG data involves using some common parameters for
% every subject. This part of the script initializes the common parameters.

%clear % clear matlab workspace
%clc % clear matlab command window

%addpath(genpath('/home/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline'))
%addpath(genpath('/home/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/eeglab2021.0'));% enter the path of the EEGLAB folder in this line

%% Read files to analyses
%datafile_names=dir(rawdata_location);

force_session_definition = 1; %Since ICA denoising happens at the session
                              %level, be sure either the session is defined
                              %or the participant has one session.
datafile_names = find_files_to_proc(bids_dir, participant_label, session_label, ...
                    '', file_extension, force_session_definition); %Commenting out task label because this should always be run at the session level
                
%datafile_names=dir([rawdata_location '/*.set']);
datafile_dirs={datafile_names.folder};
datafile_names={datafile_names.name};
[filepath,name,ext] = fileparts(char(datafile_names{1}));

%% Check whether EEGLAB and all necessary plugins are in Matlab path.
check_if_plugins_are_present(ext);

%% Loop over all data files
for run=1:length(datafile_names)
    
    rawdata_location = datafile_dirs{run}; %update the input path for the given run
    fprintf('\n\n\n*** Processing run %d (%s) ***\n\n\n', run, datafile_names{run});
    
    sub_id(run) = string(participant_label);
        
    %% STEP 1: Import EGI data file and relevant information
    EEG = pop_loadset('filename',datafile_names{run},'filepath',rawdata_location);
    temp_split = split(datafile_names{run}, '_task');
    subses = temp_split{end - 1}; %Its okay that this will get updated each iteration
                                  %since it will be the same each time.

    
    % Edit this data import function and use appropriate plugin from EEGLAB
    % for non-.mff data. For example, to import biosemi data, use biosig plugin.
    % The example codes for 64 channels biosemi data:
%     EEG = pop_biosig([rawdata_location, filesep, datafile_names{run}]);
%     EEG = eeg_checkset(EEG);
%     EEG = pop_select( EEG,'nochannel', 65:72); % delete redundant channels

    %% TM - 8/6/2024: Impedances catch
    % Check if impedances were turned on and off -- if so pop out the
    % section with impedances and save
    % will not catch if impdances was turned on before task was
    % started or aff after task was finished

    if numel(find(strcmp({EEG.event.type}, 'IBEG')))>0 && numel(find(strcmp({EEG.event.type}, 'IEND')))>0
        startidx = find(strcmp({EEG.event.type}, 'IBEG'));
        endidx = find(strcmp({EEG.event.type}, 'IEND'));
        if length(startidx) == 1 && length(endidx) == 1
            impstart = EEG.event(startidx).onset - 0.1;
            impend = EEG.event(endidx).onset;
        else
            error('multiple Impedance flags, check raw data and fix manually please');
        end

        EEG = pop_select(EEG, 'rmtime', [impstart impend]);
    end

    %% TM - 8/6/2024 Catch DRPS flag and throw error
    if numel(find(strcmp({EEG.event.type}, 'DrpS')))>0
        error('DrpS flag found, check raw data and fix manually please');
    end

    %% Step 1.25: Load settings for processing
    % 2. Enter the path of the folder where you want to save the processed data
    s = grab_settings(datafile_names{run}, json_settings_file);
    
    %NEW - to cover case where boundary marker changes
    boundary_marker = s.boundary_marker;
    
    %NEW - to cover case where EKG channel is present
    if isfield(s, 'ekg_channels')
        ekg_channels = s.ekg_channels;
    else
        ekg_channels = {};
    end

    % 3. Enter the path of the channel location file
    %channel_locations = ['path to eeglab folder' filesep 'sample_locs' filesep 'GSN128.sfp'];
    channel_locations = s.channel_locations;

    % 5. Do you want to down sample the data?
    down_sample = s.down_sample; % 0 = NO (no down sampling), 1 = YES (down sampling)
    sampling_rate = s.sampling_rate; % set sampling rate (in Hz), if you want to down sample

    % 6. Do you want to delete the outer layer of the channels? (Rationale has been described in MADE manuscript)
    %    This fnction can also be used to down sample electrodes. For example, if EEG was recorded with 128 channels but you would
    %    like to analyse only 64 channels, you can assign the list of channnels to be excluded in the 'outerlayer_channel' variable.    
    delete_outerlayer = s.delete_outerlayer; % 0 = NO (do not delete outer layer), 1 = YES (delete outerlayer);
    % If you want to delete outer layer, make a list of channels to be deleted
    outerlayer_channel = s.outerlayer_channel; % list of channels
    % recommended list for EGI 128 chanenl net: {'E17' 'E38' 'E43' 'E44' 'E48' 'E49' 'E113' 'E114' 'E119' 'E120' 'E121' 'E125' 'E126' 'E127' 'E128' 'E56' 'E63' 'E68' 'E73' 'E81' 'E88' 'E94' 'E99' 'E107'}

    % 7. Initialize the filters
    highpass = s.highpass; % High-pass frequency
    lowpass  = s.lowpass; % Low-pass frequency. We recommend low-pass filter at/below line noise frequency (see manuscript for detail)

    % 14. Do you want to rereference your data?
    rerefer_data = s.rerefer_data; % 0 = NO, 1 = YES
    reref=s.reref; % Enter electrode name/s or number/s to be used for rereferencing
    % For channel name/s enter, reref = {'channel_name', 'channel_name'};
    % For channel number/s enter, reref = [channel_number, channel_number];
    % For average rereference enter, reref = []; default is average rereference

    % 16. How do you want to save your data? .set or .mat
    output_format = s.output_format; % 1 = .set (EEGLAB data structure), 2 = .mat (Matlab data structure)
    
    %% Step 1.3 Create output folders to save data
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%Format the output path to be the same as the input path at %%%%%%%
    %%%%%the level of the run folder onwards %%%%%%%%%%%%%%%%%%%%%%%%%%
    partial_path_index = strfind(rawdata_location, '/sub');
    if length(partial_path_index) > 1
        partial_path_index = partial_path_index(end);
    end
    output_location = fullfile(output_dir_name, rawdata_location(partial_path_index:end));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ischar(save_interim_result)
        save_interim_result = str2double(save_interim_result);
    end
    
    if exist(output_location, 'dir') == 0
        mkdir(output_location);
    end
        
    if exist([output_location filesep 'filtered_data'], 'dir') == 0
        mkdir([output_location filesep 'filtered_data'])
    end
    if exist([output_location filesep 'ica_data'], 'dir') == 0
        mkdir([output_location filesep 'ica_data'])
    end

    if exist([output_location filesep 'processed_data'], 'dir') == 0
        mkdir([output_location filesep 'processed_data'])
    end
    
    if exist([output_location filesep 'merged_data'], 'dir') == 0
        mkdir([output_location filesep 'merged_data'])
    end
    
    cd(output_location); %Go to output dir
    %% Step 1.4: Save specification
    save_specification(s, output_location, datafile_names{run});
    
    %% STEP 1.5: Delete discontinuous data from the raw data file (OPTIONAL, but necessary for most EGI files)
    % Note: code below may need to be modified to select the appropriate markers (depends on the import function)
    % remove discontinous data at the start of the file
    disconMarkers = find(strcmp({EEG.event.type}, boundary_marker)); % boundary markers often indicate discontinuity
    if isempty(disconMarkers) == false
        EEG = eeg_eegrej( EEG, [1 EEG.event(disconMarkers(1)).latency] ); % remove discontinuous chunk... if not EGI, MODIFY BEFORE USING THIS SECTION
        EEG = eeg_checkset( EEG );
    end

    
    %% STEP 2: Import channel locations
    EEG=pop_chanedit(EEG, 'load',{channel_locations 'filetype' 'autodetect'});
    EEG = eeg_checkset( EEG );
    
    % Check whether the channel locations were properly imported. The EEG signals and channel numbers should be same.
    if size(EEG.data, 1) ~= length(EEG.chanlocs)
        error('The size of the data does not match with channel numbers.');
    end
    
    %% STEP 2.5: Delete EKG Channels if they are present
    
    %This chunk of code should be good but needs to be tested. Also, need
    %to be sure the check for the number of electrodes in step 2 isn't
    %thrown off by having the ekg channels.
    if size(ekg_channels, 2) > 0
        nbchans=cell(1,EEG.nbchan);
        for i=1:EEG.nbchan
            nbchans{i}= EEG.chanlocs(i).labels;
        end

        [~,chansidx] = ismember(ekg_channels, nbchans);
        RemChans_Idx = chansidx(chansidx ~= 0);

        EEG = eeg_checkset( EEG );
        EEG = pop_select( EEG,'nochannel', RemChans_Idx);
    end

    
    %% STEP 3: Adjust anti-aliasing and task related time offset
    %if adjust_time_offset==1
        % adjust anti-aliasing filter time offset
        %if filter_timeoffset~=0
        %    for aafto=1:length(EEG.event)
        %        EEG.event(aafto).latency=EEG.event(aafto).latency+(filter_timeoffset/1000)*EEG.srate;
        %    end
        %end
        % adjust stimulus time offset
        %if stimulus_timeoffset~=0
        %    for sto=1:length(EEG.event)
        %        for sm=1:length(stimulus_markers)
        %            if strcmp(EEG.event(sto).type, stimulus_markers{sm})
        %                EEG.event(sto).latency=EEG.event(sto).latency+(stimulus_timeoffset/1000)*EEG.srate;
        %            end
        %        end
        %    end
        %end
        % adjust response time offset
        %if response_timeoffset~=0
        %    for rto=1:length(EEG.event)
        %        for rm=1:length(response_markers)
        %            if strcmp(EEG.event(rto).type, response_markers{rm})
        %                EEG.event(rto).latency=EEG.event(rto).latency-(response_timeoffset/1000)*EEG.srate;
        %            end
        %        end
        %    end
        %end
    %end
    
    %% STEP 4: Change sampling rate
    if down_sample==1
        if floor(sampling_rate) > EEG.srate
            error ('Sampling rate cannot be higher than recorded sampling rate');
        elseif floor(sampling_rate) ~= EEG.srate
            EEG = pop_resample( EEG, sampling_rate);
            EEG = eeg_checkset( EEG );
        end
    end
    
    %% STEP 5: Delete outer layer of channels
    chans_labels=cell(1,EEG.nbchan);
    for i=1:EEG.nbchan
        chans_labels{i}= EEG.chanlocs(i).labels;
    end
    [chans,chansidx] = ismember(outerlayer_channel, chans_labels);
    outerlayer_channel_idx = chansidx(chansidx ~= 0);
    if delete_outerlayer==1
        if isempty(outerlayer_channel_idx)==1
            error(['None of the outer layer channels present in channel locations of data.'...
                ' Make sure outer layer channels are present in channel labels of data (EEG.chanlocs.labels).']);
        else
            EEG = pop_select( EEG,'nochannel', outerlayer_channel_idx);
            EEG = eeg_checkset( EEG );
        end
    end
    
    %% STEP 5.25: Label Task Variable and DIN conidtions if it is not already labeled
    
   if strcmp(EEG.event(3).Task, 'n/a')
       if contains(EEG.filename, 'MMN')
           task = 'MMN';
           din2s = find(strcmp({EEG.event.type}, 'DIN2'));
           for d =1:length(din2s) %label the DIN condition
               EEG.event(din2s(d)).Condition = EEG.event(din2s(d)-1).Condition;
           end
           
           num_stm = numel(find(strcmp({EEG.event.type}, 'stms')));
           num_din = length(din2s);
           if num_stm  < num_din %remove any extra DINs
               for w = 1:length(din2s)
                   if ~(strcmp({EEG.event(din2s(w)-1).type}, 'stms'))
                       EEG.event(din2s(w)).type = 'EXTRA_DIN';
                   end
               end
           end
       elseif contains(EEG.filename, 'RS')
           task = 'RS'; %no labeling needed
       elseif contains(EEG.filename, 'VEP')
           task = 'VEP';
           din3s = find(strcmp({EEG.event.type}, 'DIN3'));
           if din3s(1) == 1 %if the first flag in a file is a DIN remove it
               EEG.event(din3s(1)).type = 'EXTRA_DIN';
           end
           for d =1:length(din3s) %label the DIN conditions
               EEG.event(din3s(d)).Condition = EEG.event(din3s(d)-1).Condition;
           end
           
       elseif contains(EEG.filename, 'FACE')
           task = 'FACE';
           dins = find(strcmp({EEG.event.type}, 'DIN3'));
           %label Face Blocks
           if length(dins) >= 100
               block1 = EEG.event(1:dins(100));
           else
               block1 = EEG.event;
           end
           searchblock1_inverted = numel(find(strcmp({block1.Condition}, '2')))-1; %subtract 1 bc there is always 1 flag of each condition in the SESS rows
           if searchblock1_inverted >=1
               upright_condition_b1 = '1';
               upright_condition_b2 = '4';
           else
               upright_condition_b1 = '4';
               upright_condition_b2 = '1';
           end
           
           for d =1:length(dins)
               %The condition for the din is set equal to whatever the condition of preceding flag
               EEG.event(dins(d)).Condition = EEG.event(dins(d)-1).Condition;
               if d <=100
                   EEG.event(dins(d)).Block = 1;
                   if strcmp(EEG.event(dins(d)-1).Condition, '1')
                       EEG.event(dins(d)).Condition = upright_condition_b1;
                       EEG.event(dins(d)-1).Condition = upright_condition_b1;
                       EEG.event(dins(d)+1).Condition = upright_condition_b1;
                   end
               else
                   EEG.event(dins(d)).Block = 2;
                   if strcmp(EEG.event(dins(d)-1).Condition, '1')
                       EEG.event(dins(d)).Condition = upright_condition_b2;
                       EEG.event(dins(d)-1).Condition = upright_condition_b2;
                       EEG.event(dins(d)-2).Condition = upright_condition_b2;
                   end
               end
               
           end
           num_stm = numel(find(strcmp({EEG.event.type}, 'stm+')));
           num_din = length(dins);
           if num_stm  < num_din
               for w = 1:length(dins)
                   if ~strcmp({EEG.event(dins(w)-1).type}, 'stm+')
                       EEG.event(dins(w)).type = 'EXTRA_DIN';
                   end
               end
           end
           
       end
       
       for i = 1:length(EEG.event)
           EEG.event(i).Task = task; %label task variable
       end
       
    end
    
    %% STEP 5.5: Get Line Noise Measure
    % from HAPPE pipeline: see https://github.com/PINE-Lab/HAPPE for details
        lineNoiseIn = struct('lineNoiseMethod', 'clean', ...
            'lineNoiseChannels', 1:EEG.nbchan, 'Fs', EEG.srate, ...
            'lineFrequencies', [60 120], 'p', 0.01, 'fScanBandWidth', 2, ...
            'taperBandWidth', 2, 'taperWindowSize', 4, 'taperWindowStep', 4, ...
            'tau', 100, 'pad', 2, 'fPassBand', [0 EEG.srate/2], ...
            'maximumIterations', 10);
        
        [outEEG, ~]  = cleanLineNoise(EEG, lineNoiseIn);
        
        neighbors = [59,60,61];
        lnParams_harms_frequs = [];
        lnMeans = [];
        
        % LINE NOISE REDUCTION QM: Assesses the performance of line noise reduction.
        
        lnMeans = assessPipelineStep('line noise reduction', reshape(EEG.data, ...
            size(EEG.data, 1), []), reshape(outEEG.data, size(outEEG.data,1), ...
            []), lnMeans, EEG.srate, [neighbors lnParams_harms_frequs]) ;
        
        lineNoise{run,1} = lnMeans(3); %grab only the 60 hz pre/post r value
    
    %% STEP 6: Filter data
    % Calculate filter order using the formula: m = dF / (df / fs), where m = filter order,
    % df = transition band width, dF = normalized transition width, fs = sampling rate
    % dF is specific for the window type. Hamming window dF = 3.3
    
    high_transband = highpass; % high pass transition band
    low_transband = 10; % low pass transition band
    
    hp_fl_order = 3.3 / (high_transband / EEG.srate);
    lp_fl_order = 3.3 / (low_transband / EEG.srate);
    
    % Round filter order to next higher even integer. Filter order is always even integer.
    if mod(floor(hp_fl_order),2) == 0
        hp_fl_order=floor(hp_fl_order);
    elseif mod(floor(hp_fl_order),2) == 1
        hp_fl_order=floor(hp_fl_order)+1;
    end
    
    if mod(floor(lp_fl_order),2) == 0
        lp_fl_order=floor(lp_fl_order)+2;
    elseif mod(floor(lp_fl_order),2) == 1
        lp_fl_order=floor(lp_fl_order)+1;
    end
    
    % Calculate cutoff frequency
    high_cutoff = highpass/2;
    low_cutoff = lowpass + (low_transband/2);
    
    % Performing high pass filtering
    EEG = eeg_checkset( EEG );
    EEG = pop_firws(EEG, 'fcutoff', high_cutoff, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', hp_fl_order, 'minphase', 0);
    EEG = eeg_checkset( EEG );
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)
    
    % Performing low pass filtering
    EEG = eeg_checkset( EEG );
    EEG = pop_firws(EEG, 'fcutoff', low_cutoff, 'ftype', 'lowpass', 'wtype', 'hamming', 'forder', lp_fl_order, 'minphase', 0);
    EEG = eeg_checkset( EEG );
    
    % pop_firws() - transition band width: 10 Hz
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)
    
    %% Step 6.5: Save individual files
    if output_format==1
        EEG = eeg_checkset( EEG );
        EEG = pop_editset(EEG, 'setname', strrep(datafile_names{run}, ext, '_desc-filtered_eeg'));
        EEG = pop_saveset( EEG,'filename',strrep(datafile_names{run}, ext, '_desc-filtered_eeg.set'),'filepath', [output_location filesep 'filtered_data' filesep]); % save .set format
    elseif output_format==2
        save([[output_location filesep 'filtered_data' filesep ] strrep(datafile_names{run}, ext, '_desc-filtered_eeg.mat')], 'EEG'); % save .mat format
    end
    
end

%% Step 6.7: Merge Data (based off of shared script from lydia)
[EEG, event_struct] = merge_data(output_location, file_extension, subses);

%% Initialize output variables
reference_used_for_faster=[]; % reference channel used for running faster to identify bad channel/s
faster_bad_channels=[]; % number of bad channel/s identified by faster
ica_preparation_bad_channels=[]; % number of bad channel/s due to channel/s exceeding xx% of artifacted epochs
length_ica_data=[]; % length of data (in second) fed into ICA decomposition
total_ICs=[]; % total independent components (ICs)
ICs_removed=[]; % number of artifacted ICs
total_epochs_before_artifact_rejection=[];
total_epochs_after_artifact_rejection=[];
total_channels_interpolated=[]; % total_channels_interpolated=faster_bad_channels+ica_preparation_bad_channels

%% STEP 7: Run faster to find bad channels
% First check whether reference channel (i.e. zeroed channels) is present in data
% reference channel is needed to run faster
ref_chan=[]; FASTbadChans=[]; all_chan_bad_FAST=0;
ref_chan=find(any(EEG.data, 2)==0);
if numel(ref_chan)>1
    error(['There are more than 1 zeroed channel (i.e. zero value throughout recording) in data.'...
        ' Only reference channel should be zeroed channel. Delete the zeroed channel/s which is not reference channel.']);
elseif numel(ref_chan)==1
    list_properties = channel_properties(EEG, 1:EEG.nbchan, ref_chan); % run faster
    FASTbadIdx=min_z(list_properties);
    FASTbadChans=find(FASTbadIdx==1);
    FASTbadChans=FASTbadChans(FASTbadChans~=ref_chan);
    for i = 1 : run %since faster is the same for all runs
        reference_used_for_faster{i}={EEG.chanlocs(ref_chan).labels};
    end
    EEG = eeg_checkset(EEG);
    channels_analysed=EEG.chanlocs; % keep full channel locations to use later for interpolation of bad channels
elseif numel(ref_chan)==0
    warning('Reference channel is not present in data. Cz channel will be used as reference channel.');
    ref_chan=find(strcmp({EEG.chanlocs.labels}, 'Cz')); % find Cz channel index
    EEG_copy=[];
    EEG_copy=EEG; % make a copy of the dataset
    EEG_copy = pop_reref( EEG_copy, ref_chan,'keepref','on'); % rerefer to Cz in copied dataset
    EEG_copy = eeg_checkset(EEG_copy);
    list_properties = channel_properties(EEG_copy, 1:EEG_copy.nbchan, ref_chan); % run faster on copied dataset
    FASTbadIdx=min_z(list_properties);
    FASTbadChans=find(FASTbadIdx==1);
    channels_analysed=EEG.chanlocs;
    for i = 1 : run %since faster is the same for all runs
        reference_used_for_faster{i}={EEG.chanlocs(ref_chan).labels};
    end
end

if numel(FASTbadChans)==0 %LY moved this if statement to occur prior to channel rejection 6/5/2024
    for i = 1 : run
        faster_bad_channels{i}='0';
    end
else
    for i = 1 : run
        %LY change from using indexes to channel names 4/15/2024     
        bad_chan_labels = strjoin({EEG.chanlocs(FASTbadChans).labels}, ' ');
        %bad_chan_labels = strrep(bad_chan_labels, 'E', '');
        %faster_bad_channels{i}=num2str(FASTbadChans');
        faster_bad_channels{i}= bad_chan_labels;
    end
end


% If FASTER identifies all channels as bad channels, save the dataset
% at this stage and ignore the remaining of the preprocessing.
if numel(FASTbadChans)==EEG.nbchan || numel(FASTbadChans)+1==EEG.nbchan
    all_chan_bad_FAST=1;
    warning(['No usable data for datafile', datafile_names{run}]);
    if output_format==1
        EEG = eeg_checkset(EEG);
        EEG = pop_editset(EEG, 'setname',  strrep(datafile_names{run}, ext, '_no_usable_data_all_bad_channels'));
        EEG = pop_saveset(EEG, 'filename', strrep(datafile_names{run}, ext, '_no_usable_data_all_bad_channels.set'),'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
    elseif output_format==2
        save([[output_location filesep 'processed_data' filesep ] strrep(datafile_names{run}, ext, '_no_usable_data_all_bad_channels.mat')], 'EEG'); % save .mat format
    end
else
    % Reject channels that are bad as identified by Faster
    EEG = pop_select( EEG,'nochannel', FASTbadChans);
    EEG = eeg_checkset(EEG);
    if numel(ref_chan)==1
        ref_chan=find(any(EEG.data, 2)==0);
        EEG = pop_select( EEG,'nochannel', ref_chan); % remove reference channel
    end
end

% if numel(FASTbadChans)==0 %TEMP
%     for i = 1 : run
%         faster_bad_channels{i}='0';
%     end
% else
%     for i = 1 : run
%         %LY change from using indexes to channel names 4/15/2024     
%         bad_chan_labels = strjoin({EEG.chanlocs(FASTbadChans).labels}, ' ');
%         %bad_chan_labels = strrep(bad_chan_labels, 'E', '');
%         %faster_bad_channels{i}=num2str(FASTbadChans');
%         faster_bad_channels{i}= bad_chan_labels;
%     end
% end

if all_chan_bad_FAST==1
    for i = 1 : run
        faster_bad_channels{i}='0';
        ica_preparation_bad_channels{i}='0';
        length_ica_data(i)=0;
        total_ICs(i)=0;
        ICs_removed{i}='0';
        total_epochs_before_artifact_rejection(i)=0;
        total_epochs_after_artifact_rejection(i)=0;
        total_channels_interpolated(i)=0;
    end
end

%% STEP 8: Prepare data for ICA

EEG_copy=[];
EEG_copy=EEG; % make a copy of the dataset
EEG_copy = eeg_checkset(EEG_copy);

% Perform 1Hz high pass filter on copied dataset
transband = 1;
fl_cutoff = transband/2;
fl_order = 3.3 / (transband / EEG.srate);

if mod(floor(fl_order),2) == 0
    fl_order=floor(fl_order);
elseif mod(floor(fl_order),2) == 1
    fl_order=floor(fl_order)+1;
end

EEG_copy = pop_firws(EEG_copy, 'fcutoff', fl_cutoff, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', fl_order, 'minphase', 0);
EEG_copy = eeg_checkset(EEG_copy);

% Create 1 second epoch
EEG_copy=eeg_regepochs(EEG_copy,'recurrence', 1, 'limits',[0 1], 'rmbase', [NaN], 'eventtype', '999'); % insert temporary marker 1 second apart and create epochs
EEG_copy = eeg_checkset(EEG_copy);

% Find bad epochs and delete them from dataset
vol_thrs = [-1000 1000]; % [lower upper] threshold limit(s) in uV.
emg_thrs = [-100 30]; % [lower upper] threshold limit(s) in dB.
emg_freqs_limit = [20 40]; % [lower upper] frequency limit(s) in Hz.

% Find channel/s with xx% of artifacted 1-second epochs and delete them
chanCounter = 1; ica_prep_badChans = [];
numEpochs =EEG_copy.trials; % find the number of epochs
all_bad_channels=0;

for ch=1:EEG_copy.nbchan
    % Find artifaceted epochs by detecting outlier voltage
    EEG_copy = pop_eegthresh(EEG_copy,1, ch, vol_thrs(1), vol_thrs(2), EEG_copy.xmin, EEG_copy.xmax, 0, 0);
    EEG_copy = eeg_checkset( EEG_copy );

    % 1         : data type (1: electrode, 0: component)
    % 0         : display with previously marked rejections? (0: no, 1: yes)
    % 0         : reject marked trials? (0: no (but store the  marks), 1:yes)

    % Find artifaceted epochs by using thresholding of frequencies in the data.
    % this method mainly rejects muscle movement (EMG) artifacts
    EEG_copy = pop_rejspec( EEG_copy, 1,'elecrange',ch ,'method','fft','threshold', emg_thrs, 'freqlimits', emg_freqs_limit, 'eegplotplotallrej', 0, 'eegplotreject', 0);

    % method                : method to compute spectrum (fft)
    % threshold             : [lower upper] threshold limit(s) in dB.
    % freqlimits            : [lower upper] frequency limit(s) in Hz.
    % eegplotplotallrej     : 0 = Do not superpose rejection marks on previous marks stored in the dataset.
    % eegplotreject         : 0 = Do not reject marked trials (but store the  marks).

    % Find number of artifacted epochs
    EEG_copy = eeg_checkset( EEG_copy );
    EEG_copy = eeg_rejsuperpose( EEG_copy, 1, 1, 1, 1, 1, 1, 1, 1);
    artifacted_epochs=EEG_copy.reject.rejglobal;

    % Find bad channel / channel with more than 20% artifacted epochs
    if sum(artifacted_epochs) > (numEpochs*20/100)
        ica_prep_badChans(chanCounter) = ch;
        chanCounter=chanCounter+1;
    end
end

% If all channels are bad, save the dataset at this stage and ignore the remaining of the preprocessing.
if numel(ica_prep_badChans)==EEG.nbchan || numel(ica_prep_badChans)+1==EEG.nbchan
    all_bad_channels=1;
    warning(['No usable data for datafile', datafile_names{run}]);
    if output_format==1
        EEG = eeg_checkset(EEG);
        EEG = pop_editset(EEG, 'setname',  strrep(datafile_names{run}, ext, '_no_usable_data_all_bad_channels'));
        EEG = pop_saveset(EEG, 'filename', strrep(datafile_names{run}, ext, '_no_usable_data_all_bad_channels.set'),'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
    elseif output_format==2
        save([[output_location filesep 'processed_data' filesep ] strrep(datafile_names{run}, ext, '_no_usable_data_all_bad_channels.mat')], 'EEG'); % save .mat format
    end

else
    % Reject bad channel - channel with more than xx% artifacted epochs
    EEG_copy = pop_select( EEG_copy,'nochannel', ica_prep_badChans);
    EEG_copy = eeg_checkset(EEG_copy);
end

for i = 1 : run
    if numel(ica_prep_badChans)==0
        ica_preparation_bad_channels{i}='0';
    else
        ica_preparation_bad_channels{i}=num2str(ica_prep_badChans);
    end
end

if all_bad_channels == 1
    for i = 1 : run
        length_ica_data(i)=0;
        total_ICs(i)=0;
        ICs_removed{i}='0';
        total_epochs_before_artifact_rejection(i)=0;
        total_epochs_after_artifact_rejection(i)=0;
        total_channels_interpolated(i)=0;
    end
end

% Find the artifacted epochs across all channels and reject them before doing ICA.
EEG_copy = pop_eegthresh(EEG_copy,1, 1:EEG_copy.nbchan, vol_thrs(1), vol_thrs(2), EEG_copy.xmin, EEG_copy.xmax,0,0);
EEG_copy = eeg_checkset(EEG_copy);

% 1         : data type (1: electrode, 0: component)
% 0         : display with previously marked rejections? (0: no, 1: yes)
% 0         : reject marked trials? (0: no (but store the  marks), 1:yes)

% Find artifaceted epochs by using power threshold in 20-40Hz frequency band.
% This method mainly rejects muscle movement (EMG) artifacts.
EEG_copy = pop_rejspec(EEG_copy, 1,'elecrange', 1:EEG_copy.nbchan, 'method', 'fft', 'threshold', emg_thrs ,'freqlimits', emg_freqs_limit, 'eegplotplotallrej', 0, 'eegplotreject', 0);

% method                : method to compute spectrum (fft)
% threshold             : [lower upper] threshold limit(s) in dB.
% freqlimits            : [lower upper] frequency limit(s) in Hz.
% eegplotplotallrej     : 0 = Do not superpose rejection marks on previous marks stored in the dataset.
% eegplotreject         : 0 = Do not reject marked trials (but store the  marks).

% Find the number of artifacted epochs and reject them
EEG_copy = eeg_checkset(EEG_copy);
EEG_copy = eeg_rejsuperpose(EEG_copy, 1, 1, 1, 1, 1, 1, 1, 1);
reject_artifacted_epochs=EEG_copy.reject.rejglobal;
EEG_copy = pop_rejepoch(EEG_copy, reject_artifacted_epochs, 0);

%% STEP 9: Run ICA
for i = 1 : run
    length_ica_data(i)=EEG_copy.trials; % length of data (in second) fed into ICA
end
EEG_copy = eeg_checkset(EEG_copy);
%LY skip ICA for testing
EEG_copy = pop_runica(EEG_copy, 'icatype', 'runica', 'extended', 1, 'stop', 1E-7, 'interupt','off');

% Find the ICA weights that would be transferred to the original dataset
ICA_WINV=EEG_copy.icawinv;
ICA_SPHERE=EEG_copy.icasphere;
ICA_WEIGHTS=EEG_copy.icaweights;
ICA_CHANSIND=EEG_copy.icachansind;

% If channels were removed from copied dataset during preparation of ica, then remove
% those channels from original dataset as well before transferring ica weights.
EEG = eeg_checkset(EEG);
EEG = pop_select(EEG,'nochannel', ica_prep_badChans);

% Transfer the ICA weights of the copied dataset to the original dataset
EEG.icawinv=ICA_WINV;
EEG.icasphere=ICA_SPHERE;
EEG.icaweights=ICA_WEIGHTS;
EEG.icachansind=ICA_CHANSIND;
EEG = eeg_checkset(EEG);

%% STEP 10: Run adjust to find artifacted ICA components
badICs=[]; EEG_copy =[];
EEG_copy = EEG;
EEG_copy =eeg_regepochs(EEG_copy,'recurrence', 1, 'limits',[0 1], 'rmbase', [NaN], 'eventtype', '999'); % insert temporary marker 1 second apart and create epochs
EEG_copy = eeg_checkset(EEG_copy);

if size(EEG_copy.icaweights,1) == size(EEG_copy.icaweights,2)
    if save_interim_result==1
        badICs = adjusted_ADJUST(EEG_copy, [[output_location filesep 'ica_data' filesep] subses '_adjustReport']);
    else
        badICs = adjusted_ADJUST(EEG_copy, [[output_location filesep 'processed_data' filesep] strrep(datafile_names{run}, ext, '_adjustReport')]);
    end
    close all;
else % if rank is less than the number of electrodes, throw a warning message
    warning('The rank is less than the number of electrodes. ADJUST will be skipped. Artefacted ICs will have to be manually rejected for this participant');
end

% Mark the bad ICs found by ADJUST
for ic=1:length(badICs)
    EEG.reject.gcompreject(1, badICs(ic))=1;
    EEG = eeg_checkset(EEG);
end


for i = 1 : run
    total_ICs(i)=size(EEG.icasphere, 1);
    if numel(badICs)==0
        ICs_removed{i}='0';
    else
        ICs_removed{i}=num2str(double(badICs));
    end
end

%% Save dataset after ICA, if saving interim results was preferred
if save_interim_result==1
    if output_format==1
        EEG = eeg_checkset(EEG);
        EEG = pop_editset(EEG, 'setname',  [subses '_mergedICA_eeg']);
        EEG = pop_saveset(EEG, 'filename', [subses '_mergedICA_eeg.set'],'filepath', [output_location filesep 'ica_data' filesep ]); % save .set format
    elseif output_format==2
        save([output_location filesep 'ica_data' filesep subses '_mergedICA_eeg.mat'], 'EEG'); % save .mat format
    end
end

%% STEP 11: Remove artifacted ICA components from data
all_bad_ICs=0;
ICs2remove=find(EEG.reject.gcompreject); % find ICs to remove

% If all ICs and bad, save data at this stage and ignore rest of the preprocessing for this run.
if numel(ICs2remove)==total_ICs(run)
    all_bad_ICs=1;
    warning(['No usable data for datafile']);
    if output_format==1
        EEG = eeg_checkset(EEG);
        EEG = pop_editset(EEG, 'setname',  [participant_label '_' session_label '_no_usable_data_all_bad_ICs']);
        EEG = pop_saveset(EEG, 'filename', [participant_label '_' session_label '_no_usable_data_all_bad_ICs.set'],'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
    elseif output_format==2
        save([output_location filesep 'processed_data' filesep participant_label '_' session_label '_no_usable_data_all_bad_ICs.mat'], 'EEG'); % save .mat format
    end
else
    EEG = eeg_checkset( EEG );
    EEG = pop_subcomp( EEG, ICs2remove, 0); % remove ICs from dataset
end

if all_bad_ICs==1
    for i = 1 : run
        total_epochs_before_artifact_rejection(i)=0;
        total_epochs_after_artifact_rejection(i)=0;
        total_channels_interpolated(i)=0;
    end
end

%% STEP 11.5: Now seperate each task for remainder of processing
mEEG = deal(EEG);
for run = 1 : length(event_struct.file_names)  
    
    %% Step 11.75: Load task specific settings for processing
    % 2. Enter the path of the folder where you want to save the processed data
    s = grab_settings(event_struct.file_names(run), json_settings_file);

    % 10. Do you want to remove/correct baseline?
    remove_baseline = s.remove_baseline; % 0 = NO (no baseline correction), 1 = YES (baseline correction)
    baseline_window = s.baseline_window; % baseline period in milliseconds (MS) [] = entire epoch

    % 11. Do you want to remove artifact laden epoch based on voltage threshold?
    voltthres_rejection = s.voltthres_rejection; % 0 = NO, 1 = YES
    volt_threshold = s.volt_threshold; % lower and upper threshold (in uV)
    
    %12. Do you want to interpolate epochs
    interp_epoch = s.interp_epoch; % 0 = NO, 1 = YES.
    frontal_channels = s.frontal_channels; % If you set interp_epoch = 1, enter the list of frontal channels to check (see manuscript for detail)
    % recommended list for EGI 128 channel net: {'E1', 'E8', 'E14', 'E21', 'E25', 'E32', 'E17'}

    %13. Do you want to interpolate the bad channels that were removed from data?
    interp_channels = s.interp_channels; % 0 = NO (Do not interpolate), 1 = YES (interpolate missing channels)

    % 14. Do you want to rereference your data?
    rerefer_data = s.rerefer_data; % 0 = NO, 1 = YES
    reref=s.reref; % Enter electrode name/s or number/s to be used for rereferencing
    % For channel name/s enter, reref = {'channel_name', 'channel_name'};
    % For channel number/s enter, reref = [channel_number, channel_number];
    % For average rereference enter, reref = []; default is average rereference

    
    %Specify that you are only interested in events for the given task
    %EEG1 = pop_selectevent(mEEG, 'event', event_struct.indices{run},'deleteevents','on');
    EEG = pop_selectevent(mEEG, 'input_file', event_struct.file_names{run}, 'deleteevents', 'on');
    
    
    
    %% STEP 12: Segment data into fixed length epochs
    
    if contains(event_struct.file_names{run}, 'MMN')
        task = 'MMN';
    elseif contains(event_struct.file_names{run}, 'RS')
        task = 'RS';
    elseif contains(event_struct.file_names{run}, 'VEP')
        task = 'VEP';
    elseif contains(event_struct.file_names{run}, 'FACE')
        task = 'FACE';
    end

    Tasks(run) = string(task);
    
    %Pull site information from scans.tsv (site) - TM 12/20/2024
    %outEEGname = outEEG.setname;

    try
        %first try getting siteinfo from scans.tsv
        sitepath = [bids_dir filesep participant_label filesep session_label];
        sitetable = readtable([sitepath filesep participant_label '_' session_label '_scans.tsv'],"Filetype","text",'Delimiter','\t');
        try
            siteinfo=sitetable.site(contains(sitetable.filename,'eeg'));
            siteinfo = siteinfo(1);
        catch
            error("Site data is missing!")
        end
    catch
        %otherwise try getting site info from local PSCID
        try
            outEEGname = outEEG.setname;
            siteinfo = outEEGname(3:5);
        catch
            error("Site data is missing locally!")
        end
    end
    EEG = make_MADE_epochs(EEG, event_struct.file_names{run}, json_settings_file, task, siteinfo);
    total_epochs_before_artifact_rejection(run)=EEG.trials;
    
    %% STEP 13: Remove baseline
    if remove_baseline==1
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, baseline_window);
    end
    
    %% STEP 14: Artifact rejection
    all_bad_epochs=0;
    if voltthres_rejection==1 % check voltage threshold rejection
        if interp_epoch==1 % check epoch level channel interpolation
            chans=[]; chansidx=[];chans_labels2=[];
            chans_labels2=cell(1,EEG.nbchan);
            for i=1:EEG.nbchan
                chans_labels2{i}= EEG.chanlocs(i).labels;
            end
            [chans,chansidx] = ismember(frontal_channels, chans_labels2);
            frontal_channels_idx = chansidx(chansidx ~= 0);
            badChans = zeros(EEG.nbchan, EEG.trials);
            badepoch=zeros(1, EEG.trials);
            if isempty(frontal_channels_idx)==1 % check whether there is any frontal channel in dataset to check
                warning('No frontal channels from the list present in the data. Only epoch interpolation will be performed.');
            else
                % find artifaceted epochs by detecting outlier voltage in the specified channels list and remove epoch if artifacted in those channels
                for ch =1:length(frontal_channels_idx)
                    EEG = pop_eegthresh(EEG,1, frontal_channels_idx(ch), volt_threshold(1), volt_threshold(2), EEG.xmin, EEG.xmax,0,0);
                    EEG = eeg_checkset( EEG );
                    EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
                    badChans(ch,:) = EEG.reject.rejglobal;
                end
                for ii=1:size(badChans, 2)
                    badepoch(ii)=sum(badChans(:,ii));
                end
                badepoch=logical(badepoch);
            end
            
            % If all epochs are artifacted, save the dataset and ignore rest of the preprocessing for this run.
            if sum(badepoch)==EEG.trials || sum(badepoch)+1==EEG.trials
                all_bad_epochs=1;
                warning(['No usable data for datafile', event_struct.file_names{run}]);
                if output_format==1
                    EEG = eeg_checkset(EEG);
                    EEG = pop_editset(EEG, 'setname',  strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epoch'));
                    EEG = pop_saveset(EEG, 'filename', strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epoch.set'),'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
                elseif output_format==2
                    save([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs.mat')], 'EEG'); % save .mat format
                end
            else
                EEG = pop_rejepoch( EEG, badepoch, 0);
                EEG = eeg_checkset(EEG);
            end
            
            if all_bad_epochs==1
                warning(['No usable data for datafile', event_struct.file_names{run}]);
            else
                % Interpolate artifacted data for all reaming channels
                badChans = zeros(EEG.nbchan, EEG.trials);
                % Find artifacted epochs by detecting outlier voltage but don't remove
                for ch=1:EEG.nbchan
                    EEG = pop_eegthresh(EEG,1, ch, volt_threshold(1), volt_threshold(2), EEG.xmin, EEG.xmax,0,0);
                    EEG = eeg_checkset(EEG);
                    EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
                    badChans(ch,:) = EEG.reject.rejglobal;
                end
                tmpData = zeros(EEG.nbchan, EEG.pnts, EEG.trials);
                for e = 1:EEG.trials
                    % Initialize variables EEGe and EEGe_interp;
                    EEGe = []; EEGe_interp = []; badChanNum = [];
                    % Select only this epoch (e)
                    EEGe = pop_selectevent( EEG, 'epoch', e, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
                    badChanNum = find(badChans(:,e)==1); % find which channels are bad for this epoch
                    EEGe_interp = eeg_interp(EEGe,badChanNum); %interpolate the bad channels for this epoch
                    tmpData(:,:,e) = EEGe_interp.data; % store interpolated data into matrix
                end
                EEG.data = tmpData; % now that all of the epochs have been interpolated, write the data back to the main file
                
                % If more than 10% of channels in an epoch were interpolated, reject that epoch
                badepoch=zeros(1, EEG.trials);
                ii=1;
                goodepoch = [];
                for ei=1:EEG.trials
                    NumbadChan = badChans(:,ei); % find how many channels are bad in an epoch
                    if sum(NumbadChan) > round((10/100)*EEG.nbchan)% check if more than 10% are bad
                        badepoch (ei)= sum(NumbadChan);
                    else
                        goodepoch(ii)= ei; %LY 7/18/2023 for percent interpolated calc
                        ii=ii+1;
                    end
                end
                avginterp(run) = mean(sum(badChans(:,goodepoch),1));%LY 7/18/2023 for percent interpolated calc
                stdinterp(run) = std(sum(badChans(:,goodepoch),1));%LY 7/18/2023 for percent interpolated calc
                rangeinterp(run) = range(sum(badChans(:,goodepoch),1));%LY 7/18/2023 for percent interpolated calc
                %avginterp_byfile(run) = avginterp;%LY 7/18/2023 for percent interpolated calc
                badepoch=logical(badepoch);
            end
            % If all epochs are artifacted, save the dataset and ignore rest of the preprocessing for this run.
            if sum(badepoch)==EEG.trials || sum(badepoch)+1==EEG.trials
                all_bad_epochs=1;
                warning(['No usable data for datafile', event_struct.file_names{run}]);
                if output_format==1
                    EEG = eeg_checkset(EEG);
                    EEG = pop_editset(EEG, 'setname',  strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs'));
                    EEG = pop_saveset(EEG, 'filename', strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs.set'),'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
                elseif output_format==2
                    save([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs.mat')], 'EEG'); % save .mat format
                end
            else
                EEG = pop_rejepoch(EEG, badepoch, 0);
                EEG = eeg_checkset(EEG);
            end
        else % if no epoch level channel interpolation
            EEG = pop_eegthresh(EEG, 1, (1:EEG.nbchan), volt_threshold(1), volt_threshold(2), EEG.xmin, EEG.xmax, 0, 0);
            EEG = eeg_checkset(EEG);
            EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
        end % end of epoch level channel interpolation if statement
        
        % If all epochs are artifacted, save the dataset and ignore rest of the preprocessing for this run.
        if sum(EEG.reject.rejthresh)==EEG.trials || sum(EEG.reject.rejthresh)+1==EEG.trials
            all_bad_epochs=1;
            warning(['No usable data for datafile', event_struct.file_names{run}]);
            if output_format==1
                EEG = eeg_checkset(EEG);
                EEG = pop_editset(EEG, 'setname',  strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs'));
                EEG = pop_saveset(EEG, 'filename', strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs.set'),'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
            elseif output_format==2
                save([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, ext, '_no_usable_data_all_bad_epochs.mat')], 'EEG'); % save .mat format
            end
        else
            EEG = pop_rejepoch(EEG,(EEG.reject.rejthresh), 0);
            EEG = eeg_checkset(EEG);
        end
    end % end of voltage threshold rejection if statement
    
    % if all epochs are found bad during artifact rejection
    if all_bad_epochs==1
        total_epochs_after_artifact_rejection(run)=0;
        total_channels_interpolated(run)=0;
        continue % ignore rest of the processing and go to next datafile
    else
        if contains(event_struct.file_names{run}, 'FACE')
            FACE_UpInv(run) = {sum(strcmp({EEG.event.Condition}, '1'))};
            FACE_Inv(run) = {sum(strcmp({EEG.event.Condition}, '2'))};
            FACE_Object(run) = {sum(strcmp({EEG.event.Condition}, '3'))};
            FACE_UpObj(run) = {sum(strcmp({EEG.event.Condition}, '4'))};
            total_epochs_after_artifact_rejection(run)= EEG.trials;
            MMN_Standard(run) = {'n/a'};
            MMN_PreDev(run) = {'n/a'};
            MMN_Dev(run) = {'n/a'};
        elseif contains(event_struct.file_names{run}, 'MMN')
            FACE_UpInv(run) = {'n/a'};
            FACE_Inv(run) = {'n/a'};
            FACE_Object(run) = {'n/a'};
            FACE_UpObj(run) = {'n/a'};
            MMN_Standard(run) = {sum(strcmp({EEG.event.Condition}, '1'))};
            MMN_PreDev(run) = {sum(strcmp({EEG.event.Condition}, '2'))};
            MMN_Dev(run) = {sum(strcmp({EEG.event.Condition}, '3'))};
            total_epochs_after_artifact_rejection(run)= EEG.trials;
        else
            FACE_UpInv(run) = {'n/a'};
            FACE_Inv(run) = {'n/a'};
            FACE_Object(run) = {'n/a'};
            FACE_UpObj(run) = {'n/a'};
            MMN_Standard(run) = {'n/a'};
            MMN_PreDev(run) = {'n/a'};
            MMN_Dev(run) = {'n/a'};
            total_epochs_after_artifact_rejection(run)=EEG.trials;
        end
    end
    
    %% STEP 15: Interpolate deleted channels
    if interp_channels==1
        EEG = eeg_interp(EEG, channels_analysed);
        EEG = eeg_checkset(EEG);
    end
    if (numel(FASTbadChans)==0 && numel(ica_prep_badChans)==0) || (interp_channels == 0)
        total_channels_interpolated(run)=0;
    else
        total_channels_interpolated(run)=numel(FASTbadChans)+ numel(ica_prep_badChans);
    end
    
    %% STEP 16: Rereference data
    if rerefer_data==1
        if iscell(reref)==1
            reref_idx=zeros(1, length(reref));
            for rr=1:length(reref)
                reref_idx(rr)=find(strcmp({EEG.chanlocs.labels}, reref{rr}));
            end
            EEG = eeg_checkset(EEG);
            EEG = pop_reref( EEG, reref_idx);
        else
            EEG = eeg_checkset(EEG);
            EEG = pop_reref(EEG, reref);
        end
    end
    
    %% Save processed data
    if output_format==1
        EEG = eeg_checkset(EEG);
        EEG = pop_editset(EEG, 'setname',  strrep(event_struct.file_names{run}, ext, 'Processed_eeg'));
        EEG = pop_saveset(EEG, 'filename', strrep(event_struct.file_names{run}, ext, 'Processed_eeg.set'),'filepath', [output_location filesep 'processed_data' filesep ]); % save .set format
    elseif output_format==2
        save([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, ext, 'Processed_eeg.mat')], 'EEG'); % save .mat format
    end
    
    
    %For plots
    %name
    save_name = [name '.mat'];
    save_name_jpg = [name '.jpeg'];
    save_path = [output_location filesep 'processed_data' filesep ];

    try
        % on cbrain, look for scans.tsv
        tsvpath= [bids_dir filesep participant_label filesep session_label];
        agetable = readtable([tsvpath filesep participant_label '_' session_label '_scans.tsv'],"Filetype","text",'Delimiter','\t');
        try
            taskages=agetable.age(contains(agetable.filename,'eeg'));
            age = taskages(1)*12;   
        catch
            error("Age data is missing!")
        end
    
    catch
        % locally, use participants.tsv
        agetable = readtable([bids_dir filesep 'participants.tsv'],"Filetype","text",'Delimiter','\t');
        try
            age = agetable.age(strcmp(agetable.participant_id, participant_label))*12; %if age is given in years?
        catch
            error("Age data is missing!")
        end
    end
    
    if contains(event_struct.file_names{run}, 'MMN')
        try
            computeSME(EEG, event_struct.file_names{run}, json_settings_file, 'MMN', output_location, participant_label, session_label, age)
            MMN_ERP_Topo_Indv();
            clear allData;
        catch
            continue
        end
    elseif contains(event_struct.file_names{run}, 'RS')
        try
            RS_ERP_Topo_Indv();
            clear allData;
        catch
            continue
        end
    elseif contains(event_struct.file_names{run}, 'VEP')
        try
            computeSME(EEG, event_struct.file_names{run}, json_settings_file, 'VEP', output_location, participant_label, session_label, age)
            VEP_ERP_Topo_Indv();
            clear allData;
        catch
            continue
        end
    elseif contains(event_struct.file_names{run}, 'FACE')
        try
            computeSME(EEG, event_struct.file_names{run}, json_settings_file, 'FACE', output_location, participant_label, session_label, age)
            FACE_ERP_Topo_Indv();
            clear allData;
        catch
            continue
        end
    end
    
    
    
end % end of run loop


%% Create the report table for all the data files with relevant preprocessing outputs.
report_table=table(datafile_names', sub_id', Tasks', lineNoise, reference_used_for_faster', faster_bad_channels', ica_preparation_bad_channels', length_ica_data', ...
    total_ICs', ICs_removed', total_epochs_before_artifact_rejection', total_epochs_after_artifact_rejection',FACE_UpInv',FACE_Inv', FACE_Object', FACE_UpObj', MMN_Standard', MMN_PreDev', MMN_Dev', total_channels_interpolated', avginterp', stdinterp', rangeinterp');

report_table.Properties.VariableNames={'datafile_name','subject_id', 'task', 'line_noise','reference_for_faster', 'faster_bad_channels', ...
    'ica_prep_bad_channels', 'length_ica_data', 'total_ICs', 'ICs_removed', 'total_epochs_pre_artifact_rej', ...
    'total_epochs_post_artifact_rej', 'FACE_UpInv','FACE_Inv', 'FACE_Obj', 'FACE_UpObj', 'MMN_Standard', 'MMN_PreDev', 'MMN_Dev','total_channels_interp', 'avg_chan_interp_artifact_rej', 'std_chan_interp_artifact_rej', 'range_chan_interp_artifact_rej'};
writetable(report_table, fullfile(output_location, [participant_label '_' session_label '_acq-eeg_preprocessingReport.csv']));

%%% Delete the interem results if the user doesnt want them
if save_interim_result == 0
    if exist([output_location filesep 'filtered_data'], 'dir') > 0
        delete([output_location filesep 'filtered_data' filesep '*'])
        rmdir([output_location filesep 'filtered_data']);
    end
    if exist([output_location filesep 'ica_data'], 'dir') > 0
        delete([output_location filesep 'ica_data' filesep '*'])
        rmdir([output_location filesep 'ica_data']);
    end
    if exist([output_location filesep 'merged_data'], 'dir') > 0
        delete([output_location filesep 'merged_data' filesep '*'])
        rmdir([output_location filesep 'merged_data']);
    end
end

end
