%% FACE Plot ERPs and Topos

EEG = pop_loadset([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, '_desc-filtered_eeg.set', '_desc-filteredprocessed_eeg.set')]);

% % Read the JSON file contents
jsonStr = fileread(json_settings_file);
% 
% % Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);

%participant_label = 'sub-PIUMD0059';
subject_ID = participant_label;

% Plot reg topo range

PeakStart = 1000*settingsData.FACE.ERP_window_start; %final PeakStart is in MS
PeakEnd = 1000*settingsData.FACE.ERP_window_end; %It crashes if you put the maximum limit, is should be slightly below that %MA

Start = -(1000*settingsData.FACE.pre_latency);
End = (1000*settingsData.FACE.post_latency)-2;

ROIname = settingsData.FACE.ROI_of_interest;
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
    EEG_s = pop_selectevent(EEG, 'Stim_type', 1, 'deleteevents','on');
    EEG_s = eeg_checkset(EEG_s);
catch
    EEG_s = EEG;
    EEG_s.data(EEG_s.data <= 9999999) = 0;
    EEG_s.trials = 0;
end

%deviant tone
try
    EEG_d = pop_selectevent(EEG, 'Stim_type', 2, 'deleteevents','on');
    EEG_d = eeg_checkset(EEG_d);
catch
    EEG_d = EEG;
    EEG_d.data(EEG_d.data <= 9999999) = 0;
    EEG_d.trials = 0;
end
%novel tone
try
    EEG_n = pop_selectevent(EEG, 'Stim_type', 3, 'deleteevents','on');
    EEG_n = eeg_checkset(EEG_n);
catch
    EEG_n = EEG;
    EEG_n.data(EEG_n.data <= 9999999) = 0;
    EEG_n.trials = 0;
end

%standard2 tone
try
    EEG_s2 = pop_selectevent(EEG, 'Stim_type', 4, 'deleteevents','on');
    EEG_s2 = eeg_checkset(EEG_s2);
catch
    EEG_s2 = EEG;
    EEG_s2.data(EEG_s2.data <= 9999999) = 0;
    EEG_s2.trials = 0;
end


i = i+1;
meanEpoch_s = mean(EEG_s.data, 3); %average across epochs for each condition and participant
allData(1, :, :) = meanEpoch_s;

meanEpoch_d = mean(EEG_d.data, 3);
allData(2, :, :) = meanEpoch_d;

meanEpoch_n = mean(EEG_n.data, 3);
allData(3, :, :) = meanEpoch_n;

meanEpoch_s2 = mean(EEG_s2.data, 3);
allData(4, :, :) = meanEpoch_s2;

Conditions = {'Upright_1', 'Inverted_2', 'Object_3', 'Upright2_4'};
Channels = EEG.chanlocs;
Times = EEG.times;
save_name_whole = [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', 'ERP.mat')];
save([save_path filesep save_name_whole], 'Conditions', 'Channels', 'Times', 'allData')

%%
%%%TOPO BEGIN HERE
NumberOfConditions = size(allData,1);
NumberOfChannels = size(allData,2);
NumberOfPoints = size(allData,3);

PeakRange = find(EEG.times == PeakStart):find(EEG.times == PeakEnd);

PeakData = squeeze(allData(:,:,PeakRange)); % Selecting time of interest
PeakData = squeeze(mean(PeakData,3)); % Averaging across time of interest 


PeakData_Stan = squeeze(PeakData(1,:)); % Selecting condition Upright 
PeakData_Dev = squeeze(PeakData(2,:)); % Selecting condition Inverted
PeakData_Nov = squeeze(PeakData(3,:)); % Selecting condition Object
PeakData_Up2 = squeeze(PeakData(4,:)); % Selecting condition Upright2

set(0,'DefaultFigureVisible','off');

PeakStart_n = num2str(PeakStart);
PeakEnd_n = num2str(PeakEnd);

EEG_s_trials = num2str(EEG_s.trials);
EEG_d_trials = num2str(EEG_d.trials);
EEG_n_trials = num2str(EEG_n.trials);
EEG_s2_trials = num2str(EEG_s2.trials);
infoSafeTitle = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_s_trials,',',EEG_d_trials,',',EEG_n_trials,',',EEG_s2_trials);



erp = figure;
infoSafeTitle_s = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_s_trials);
topoplot(PeakData_Stan, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Upright',infoSafeTitle_s), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-FACE_desc-upright_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
infoSafeTitle_d = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_d_trials);
topoplot(PeakData_Dev, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Inverted',infoSafeTitle_d), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-FACE_desc-inverted_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
infoSafeTitle_n = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_n_trials);
topoplot(PeakData_Nov, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Object',infoSafeTitle_n), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-FACE_desc-object_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
infoSafeTitle_s2 = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_s2_trials);
topoplot(PeakData_Up2, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Upright2',infoSafeTitle_s2), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-FACE_desc-upright2_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

% Difference wave

erp = figure;
topoplot(PeakData_Dev - PeakData_Stan,EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Inverted vs Upright',infoSafeTitle), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-FACE_desc-diffInvVsUpr_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
topoplot(PeakData_Nov - PeakData_Up2, EEG.chanlocs, 'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Object vs Upright2',infoSafeTitle), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));


cd(save_path)
Plot_Name = 'task-FACE_desc-diffObjVsUp2_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

%%%TOPO ENDS HERE


%%
%%Individual ERPs starts here

name = subject_ID;

end_ind = interp1(EEG.times,1:length(EEG.times),End,'nearest');
start_ind = interp1(EEG.times,1:length(EEG.times),Start,'nearest');
Range = start_ind:end_ind;

ch = allData(:,:,1:length(Range)); %1:length(Range) instead of Range
p8_ind=find(ismember({EEG.chanlocs.labels},ROI));
ch = (ch(:,p8_ind,:));%64 FCz = 4, FZ = 6 %128 FCz = 6, Fz = 11 select channel(s) of interest Oz=75

%average across channels (unless there is only one channel of interest
ch = squeeze(mean(ch,2));

standard = squeeze(ch(1,:,:));
deviant = squeeze(ch(2,:));
novel = squeeze(ch(3,:));
standard2 = squeeze(ch(4,:,:));

blue = [0  0 1];
grey = [.5 .5 .5];
red = [1 0 0];
grey2 = [.2 .2 .2];


set(0,'DefaultFigureVisible','off');

title_figure = strcat(ROIname, '- N=', num2str(EEG_s.trials), ',',  num2str(EEG_d.trials), ',', num2str(EEG_n.trials), ',',  num2str(EEG_s2.trials), ' '); %name, 
erp = figure;
hold on
plot(EEG.times(Range), standard, 'color', grey, 'LineWidth', 1.5);
plot(EEG.times(Range), deviant, 'color', red, 'LineWidth', 1.5);
plot(EEG.times(Range), novel, 'color', blue, 'LineWidth', 1.5);
plot(EEG.times(Range), standard2, 'color', grey2, 'LineWidth', 1.5);
xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
title(title_figure, 'FontSize', 15);
legendHandle = legend('Upright', 'Inverted', 'Object', 'Upright2');
set(legendHandle, 'box', 'off', 'FontSize', 10);
hold off;

cd(save_path)
save_plot_name = strcat(name, '_task-FACE_desc-', ROIname, '_ERP.jpg');
saveas(erp, save_plot_name);

%Diference
novMinusstand = novel-standard2; % 3 minus 4 %Object Vs Upright2
novMinusdeviant = deviant-standard; %2 minus 1 %Inverted vs Upright
baseline = standard-standard;
Upright2vs1 = standard2-standard;


erp = figure;
hold on
plot(EEG.times(Range), novMinusstand, 'color', blue, 'LineWidth', 1.5);
plot(EEG.times(Range), novMinusdeviant, 'color', red, 'LineWidth', 1.5);
plot(EEG.times(Range), Upright2vs1, 'color', grey2, 'LineWidth', 1.5);
plot(EEG.times(Range), baseline, 'color', grey, 'LineWidth', 1.5);
xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
title(title_figure, 'FontSize', 20);
legendHandle = legend('Object vs Upright Face', 'Inverted vs Upright Face', 'Upright 2 vs 1');
set(legendHandle, 'box', 'off', 'FontSize', 10);
hold off;

cd(save_path)
save_plot_name = strcat(name, '_task-FACE_desc-', ROIname, '_diffERP.jpg');
saveas(erp, save_plot_name);

%%Individual ERPs ends here

