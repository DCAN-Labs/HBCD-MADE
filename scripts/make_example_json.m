s = struct();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Global parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NEW - to cover case where boundary marker changes
s.global_parameters.boundary_marker = 'boundary';

s.global_parameters.ekg_channels = {'E125', 'E126', 'E127', 'E128'};

% 3. Enter the path of the channel location file
%channel_locations = ['path to eeglab folder' filesep 'sample_locs' filesep 'GSN128.sfp'];
s.global_parameters.channel_locations = '/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/eeglab2021.0/sample_locs/GSN129.sfp';

% 5. Do you want to down sample the data?
s.global_parameters.down_sample = 0; % 0 = NO (no down sampling), 1 = YES (down sampling)
s.global_parameters.sampling_rate = 250; % set sampling rate (in Hz), if you want to down sample

% 6. Do you want to delete the outer layer of the channels? (Rationale has been described in MADE manuscript)
%    This fnction can also be used to down sample electrodes. For example, if EEG was recorded with 128 channels but you would
%    like to analyse only 64 channels, you can assign the list of channnels to be excluded in the 'outerlayer_channel' variable.    
s.global_parameters.delete_outerlayer = 1; % 0 = NO (do not delete outer layer), 1 = YES (delete outerlayer);
% If you want to delete outer layer, make a list of channels to be deleted
s.global_parameters.outerlayer_channel = {'E17' 'E38' 'E43' 'E44' 'E48' 'E49' 'E113' 'E114' 'E119' 'E120' 'E121' 'E56' 'E63' 'E68' 'E73' 'E81' 'E88' 'E94' 'E99' 'E107'}; % list of channels
% recommended list for EGI 128 chanenl net: {'E17' 'E38' 'E43' 'E44' 'E48' 'E49' 'E113' 'E114' 'E119' 'E120' 'E121' 'E125' 'E126' 'E127' 'E128' 'E56' 'E63' 'E68' 'E73' 'E81' 'E88' 'E94' 'E99' 'E107'}

% 7. Initialize the filters
s.global_parameters.highpass = 0.3; % High-pass frequency
s.global_parameters.lowpass  = 40; % Low-pass frequency. We recommend low-pass filter at/below line noise frequency (see manuscript for detail)

% 10. Do you want to remove/correct baseline?
s.global_parameters.remove_baseline = 1; % 0 = NO (no baseline correction), 1 = YES (baseline correction)
s.global_parameters.baseline_window = [-100 0]; % baseline period in milliseconds (MS) [] = entire epoch

% 11. Do you want to remove artifact laden epoch based on voltage threshold?
s.global_parameters.voltthres_rejection = 1; % 0 = NO, 1 = YES
s.global_parameters.volt_threshold = [-125 125]; % lower and upper threshold (in uV)

% 12. Do you want to perform epoch level channel interpolation for artifact laden epoch? (see manuscript for detail)
s.global_parameters.interp_epoch = 1; % 0 = NO, 1 = YES.
s.global_parameters.frontal_channels = {'E1', 'E8', 'E14', 'E21', 'E25', 'E32', 'E17'}; % If you set interp_epoch = 1, enter the list of frontal channels to check (see manuscript for detail)
% recommended list for EGI 128 channel net: {'E1', 'E8', 'E14', 'E21', 'E25', 'E32', 'E17'}

%13. Do you want to interpolate the bad channels that were removed from data?
s.global_parameters.interp_channels = 1; % 0 = NO (Do not interpolate), 1 = YES (interpolate missing channels)

% 14. Do you want to rereference your data?
s.global_parameters.rerefer_data = 1; % 0 = NO, 1 = YES
s.global_parameters.reref=[];

% 16. How do you want to save your data? .set or .mat
s.global_parameters.output_format = 1; % 1 = .set (EEGLAB data structure), 2 = .mat (Matlab data structure)
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Task specific parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.rest.make_dummy_events = true;
s.rest.pre_latency = 0.5;
s.rest.post_latency = 1;
s.rest.num_dummy_events = 180;
s.rest.dummy_event_spacing = 1;
s.rest.marker_names = {'bas+'};

s.VEP.pre_latency = 0.5;
s.VEP.post_latency = 1;
s.VEP.marker_names = {'ch1+', 'ch2+'};

s.MMN.pre_latency = 0.5;
s.MMN.post_latency = 1;
s.MMN.marker_names = {'stms', 'stms'};

s.face.pre_latency = 0.5;
s.face.post_latency = 1;
s.face.marker_names = {'fix+'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


json_contents = jsonencode(s, PrettyPrint=true);
fid = fopen('/panfs/roc/groups/12/midb-ig/shared/repositories/leex6144/HBCD-MADE/testing_settings.json', 'w');
fprintf(fid, json_contents);
fclose(fid);

