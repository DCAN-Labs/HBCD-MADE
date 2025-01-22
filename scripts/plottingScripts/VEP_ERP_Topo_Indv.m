%% VEP Plot ERP and Topos

EEG = pop_loadset([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, '_desc-filtered_eeg.set', '_desc-filteredprocessed_eeg.set')]);

% Read the JSON file contents
jsonStr = fileread(json_settings_file);

% Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);
subject_ID = participant_label;

% Plot reg topo range
PeakStart = 1000*settingsData.VEP.ERP_window_start;
PeakEnd = 1000*settingsData.VEP.ERP_window_end; %It crashes if you put the maximum limit, is should be slightly below that %MA

Start = -(1000*settingsData.VEP.pre_latency);
End = (1000*settingsData.VEP.post_latency)-2 ;%It crashes if you put the maximum limit, is should be slightly below that %MA

ROIname = settingsData.VEP.ROI_of_interest;
ROI = settingsData.clusters.(ROIname)';

EEG = pop_selectevent(EEG, 'type', {'DIN3'}, 'deleteevents','on');

%This small chunk of code would get rid of NaN in Condition and select only the one of interest
T = struct2table( EEG.event );
[R,TF] = rmmissing(T,'DataVariables',{'Condition'});
G = table2struct(R);
Xt = G';
EEG.event = Xt;

events = find(strcmp({EEG.event.type}, 'DIN3'));

for t = events
    EEG.event(t).type =  EEG.event(t).Condition;
    EEG.event(t).stim =  EEG.event(t).Condition; %MA
    EEG.event(t).Stim_type =  EEG.event(t).Condition;
end

%standard tone
try
    %EEG_s = pop_selectevent(EEG, 'mffkey_cel', '1', 'deleteevents','on');
    EEG_s = pop_selectevent(EEG, 'Stim_type', 1, 'deleteevents','on');
    EEG_s = eeg_checkset(EEG_s);
catch
    EEG_s = EEG;
    EEG_s.data(EEG_s.data <= 9999999) = 0;
    EEG_s.trials = 0;
end


i = i+1;
meanEpoch_s = mean(EEG_s.data, 3); %average across epochs for each condition and participant
allData(1, :, :) = meanEpoch_s;


Conditions = {'VEP_1'};
Channels = EEG.chanlocs;
Times = EEG.times;

%save([save_path filesep save_name], 'Conditions', 'Channels', 'Times', 'allData')
save_name_whole = [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', 'ERP.mat')];
save([save_path filesep save_name_whole], 'Conditions', 'Channels', 'Times', 'allData')

%%
%%%TOPO BEGIN HERE
NumberOfConditions = size(allData,1);
NumberOfChannels = size(allData,2);
NumberOfPoints = size(allData,3);

PeakRange = find(EEG.times == PeakStart):find(EEG.times == PeakEnd);

PeakData = squeeze(allData(:,:,PeakRange)); % Selecting time of interest
PeakData = squeeze(mean(PeakData,2)); % Averaging across time of interest
%PeakData = squeeze(mean(PeakData,1)); % Averaging across participants #No participants

PeakData_Stan = PeakData; %There are no conditions

set(0,'DefaultFigureVisible','off');

PeakStart_n = num2str(PeakStart);
PeakEnd_n = num2str(PeakEnd);

EEG_s_trials = num2str(EEG_s.trials);

infoSafeTitle = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_s_trials);



erp = figure;
topoplot(PeakData_Stan, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('VEP',infoSafeTitle), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));


cd(save_path)
Plot_Name = 'task-VEP_topo.jpg';
merged_Plot_Name = [subject_ID, '_', session_label, '_',Plot_Name]; % 
saveas(erp, merged_Plot_Name);


%%
%%Individual ERPs starts here

name = [subject_ID,'_', session_label];

end_ind = interp1(EEG.times,1:length(EEG.times),End,'nearest');
start_ind = interp1(EEG.times,1:length(EEG.times),Start,'nearest');
Range = start_ind:end_ind;


ch = allData(:,:,1:length(Range)); %1:length(Range) instead of Range
p8_ind=find(ismember({EEG.chanlocs.labels},ROI));
ch = (ch(:,p8_ind,:));%64 FCz = 4, FZ = 6 %128 FCz = 6, Fz = 11 select channel(s) of interest Oz=75

ch = squeeze(mean(ch,2));

standard = ch;

blue = [0  0 1];
grey = [.5 .5 .5];
red = [1 0 0];
grey2 = [.2 .2 .2];


set(0,'DefaultFigureVisible','off');

title_figure = strcat(ROIname, '- N=', num2str(EEG_s.trials)); %name, '-', 
erp = figure;
hold on
plot(EEG.times(Range), standard, 'color', grey, 'LineWidth', 1.5);
xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
title(title_figure, 'FontSize', 15);
legendHandle = legend('VEP');
set(legendHandle, 'box', 'off', 'FontSize', 10);
hold off;



cd(save_path)
save_plot_name = strcat(name, '_task-VEP_desc-', ROIname, '_ERP.jpg'); %name, '_
saveas(erp, save_plot_name);

