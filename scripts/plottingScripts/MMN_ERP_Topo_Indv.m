%% MMN Plot ERP and Topos

EEG = pop_loadset([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, ext, '_processed_eeg.set')]);

%%
% Read the JSON file contents
jsonStr = fileread(json_settings_file);

% Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);

%%
subject_ID = participant_label;

% Plot reg topo range
PeakStart = 1000*settingsData.MMN.ERP_window_start;
PeakEnd = 1000*settingsData.MMN.ERP_window_end;

% Range for plotting ERPs

Start = -(1000*settingsData.MMN.pre_latency);
End = (1000*settingsData.MMN.post_latency)-2; %It crashes if you put the maximum limit, is should be slightly below that %MA

%ROI for plotting ERPs
ROIname = settingsData.MMN.ROI_of_interest;
ROI = settingsData.clusters.(ROIname)';


EEG = pop_selectevent(EEG, 'type', {'DIN2'}, 'deleteevents','on');

%This small chunk of code would get rid of NaN in Condition and select only the one of interest
T = struct2table( EEG.event );
[R,TF] = rmmissing(T,'DataVariables',{'Condition'});
G = table2struct(R);
Xt = G';
EEG.event = Xt;

events = find(strcmp({EEG.event.type}, 'DIN2'));

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


i = i+1;
meanEpoch_s = mean(EEG_s.data, 3); %average across epochs for each condition and participant
allData(1, :, :) = meanEpoch_s;

meanEpoch_d = mean(EEG_d.data, 3);
allData(2, :, :) = meanEpoch_d;

meanEpoch_n = mean(EEG_n.data, 3);
allData(3, :, :) = meanEpoch_n;

size(allData)

Conditions = {'Standard_1', 'PreDeviant_2', 'Deviant_3'};
Channels = EEG.chanlocs;
Times = EEG.times;

save_name_whole = [strrep(event_struct.file_names{run}, 'eeg_desc-filtered_eeg.set', 'ERP.mat')];
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

set(0,'DefaultFigureVisible','off');

PeakStart_n = num2str(PeakStart);
PeakEnd_n = num2str(PeakEnd);

EEG_s_trials = num2str(EEG_s.trials);
EEG_d_trials = num2str(EEG_d.trials);
EEG_n_trials = num2str(EEG_n.trials);

infoSafeTitle = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_s_trials,',',EEG_d_trials,',',EEG_n_trials);

erp = figure;
infoSafeTitle_s = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_s_trials);
topoplot(PeakData_Stan, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Standard',infoSafeTitle_s), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-MMN_desc-standard_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
infoSafeTitle_d = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_d_trials);
topoplot(PeakData_Dev, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('PreDeviant',infoSafeTitle_d), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-MMN_desc-preDeviant_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
infoSafeTitle_n = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_n_trials);
topoplot(PeakData_Nov, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Deviant',infoSafeTitle_n), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-MMN_desc-deviant_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

% Difference wave

erp = figure;
topoplot(PeakData_Nov - PeakData_Stan,EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Deviant vs Standard',infoSafeTitle), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'task-MMN_desc-diffDevVsSta_topo.jpg';
merged_Plot_Name = [subject_ID, '_', Plot_Name];
saveas(erp, merged_Plot_Name);

erp = figure;
topoplot(PeakData_Nov - PeakData_Dev, EEG.chanlocs, 'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Deviant vs PreDeviant',infoSafeTitle), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));


cd(save_path)
Plot_Name = 'task-MMN_desc-diffDevVsPre_topo.jpg';
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

standard = squeeze(ch(1,:));
deviant = squeeze(ch(2,:));
novel = squeeze(ch(3,:));

%devMinusstand = deviant-standard;

blue = [0  0 1];
grey = [.5 .5 .5];
red = [1 0 0];
grey2 = [.2 .2 .2];


set(0,'DefaultFigureVisible','off');

title_figure = strcat(ROIname, '- N=', num2str(EEG_s.trials), ',',  num2str(EEG_d.trials), ',', num2str(EEG_n.trials)); %name, '-', 
erp = figure;
hold on
plot(EEG.times(Range), standard, 'color', grey, 'LineWidth', 1.5);
plot(EEG.times(Range), deviant, 'color', red, 'LineWidth', 1.5);
plot(EEG.times(Range), novel, 'color', blue, 'LineWidth', 1.5);
%plot(EEG.times(Range), standard2, 'color', grey2, 'LineWidth', 1.5);
xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
title(title_figure, 'FontSize', 15);
legendHandle = legend('Standard', 'PreDeviant', 'Deviant');
set(legendHandle, 'box', 'off', 'FontSize', 10);
hold off;

cd(save_path)
save_plot_name = strcat(name, '_task-MMN_desc-', ROIname, '_ERP.jpg');
saveas(erp, save_plot_name);

%Difference
novMinusstand = novel-standard; % 3 minus 4 %Object Vs Upright2 %3 vs 1 Deviant vs Standard
novMinusdeviant = novel-deviant; %2 minus 1 %Inverted vs Upright % 3 vs 2 Deviant vs PreDeviant
baseline = standard-standard;

erp = figure;
hold on
plot(EEG.times(Range), novMinusstand, 'color', blue, 'LineWidth', 1.5);
plot(EEG.times(Range), novMinusdeviant, 'color', red, 'LineWidth', 1.5);
plot(EEG.times(Range), baseline, 'color', grey, 'LineWidth', 1.5);
xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
title(title_figure, 'FontSize', 20);
legendHandle = legend('Deviant vs Standard MMN', 'Deviant vs PreDeviant MMN');
set(legendHandle, 'box', 'off', 'FontSize', 10);
hold off;

cd(save_path)
save_plot_name = strcat(name, '_task-MMN_desc-', ROIname, '_diffERP.jpg');
saveas(erp, save_plot_name);


%%Individual ERPs ends here

