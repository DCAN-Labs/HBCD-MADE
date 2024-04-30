function[] = computeSME(EEG, eeg_file_name, json_file_name, task, output_location, participant_label, session_label)
% COMPUTE ERP SCORES AND SME BY CONDITION: Function which computes the erp scores for a give
% task given specified chennels and timepoints of interest.
% The json_file_name is the path to the json configuration file. The eeg_file_name is the (absolute or relative)
% path to the EEG file and will be used to extract the task name. Task is
% the task label.
EEG=eeg_checkset(EEG);

%Find the task label
s = grab_settings(eeg_file_name, json_file_name);
% % Read the JSON file contents
jsonStr = fileread(json_file_name);
% % Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);

%Grab task specific settings
scoreTimes = s.score_times;
scoreROIs = s.score_ROIs;

%Assert that the correct number of parameters are present
assert(length(scoreTimes)== length(scoreROIs), "Must have the same number of score times and ROIs!")

for i=1:length(scoreTimes)
    %select time window of interest
    scoreTime = scoreTimes(i,:);
    PeakStart = scoreTime(1);
    PeakEnd = scoreTime(2);
    %PeakStart = 100; %TEMP
    %PeakEnd = 200;%TEMP
    
    PeakRange = find(EEG.times == PeakStart):find(EEG.times == PeakEnd);
    
    %select ROI
    Cluster = scoreROIs{i};
    ROI = settingsData.clusters.(Cluster)';
    
    if isempty(ROI)
        ROI = {EEG.chanlocs.labels}; %default to all channels
    end

    %ROI = ["E75"]%, "E70", "E83"]; %TEMP
    roi_ind = find(ismember({EEG.chanlocs.labels},ROI));
    
    if strcmp(task, 'FACE')
        tab=[];
        tab2=[];
        tab3=[];
        tab4=[];
        conditions = unique({EEG.event.Condition}); %check which conditions exist
        if sum(contains(conditions, '1'))==1
            EEG_ui = pop_selectevent(EEG, 'Condition', '1', 'deleteevents','on'); %select only uprightInv trials
            EEG_ui = eeg_checkset(EEG_ui);
            EEG_ui_trialnums = {EEG_ui.event.TrialNum}';
            EEG_ui_roi = squeeze(mean(EEG_ui.data(roi_ind, :,:),1)); %select and average across channels of interest
            EEG_ui_peak = squeeze(mean(EEG_ui_roi(PeakRange, :),1)); %select and average across timerange of interest
            Scores = EEG_ui_peak';
            tab = array2table(Scores); %make table
            tab = renamevars(tab,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
            tab.Condition(:) = "uprightInv"; %add condition variable
            tab.("TrialNum") = EEG_ui_trialnums; %add trial num variable
        end
        
        if sum(contains(conditions, '2'))==1
            EEG_i = pop_selectevent(EEG, 'Condition', '2', 'deleteevents','on'); %select only inverted trials
            EEG_i = eeg_checkset(EEG_i);
            EEG_i_trialnums = {EEG_i.event.TrialNum}';
            EEG_i_roi = squeeze(mean(EEG_i.data(roi_ind, :,:),1)); %select and average across channels of interest
            EEG_i_peak = squeeze(mean(EEG_i_roi(PeakRange, :),1)); %select and average across timerange of interest
            Scores = EEG_i_peak';
            tab2 = array2table(Scores); %make table
            tab2 = renamevars(tab2,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
            tab2.Condition(:) = "inverted"; %add condition variable
            tab2.("TrialNum") = EEG_i_trialnums;
        end
        
        if sum(contains(conditions, '3'))==1
            EEG_o = pop_selectevent(EEG, 'Condition', '3', 'deleteevents','on'); %select only object trials
            EEG_o = eeg_checkset(EEG_o);
            EEG_o_trialnums = {EEG_o.event.TrialNum}';
            EEG_o_roi = squeeze(mean(EEG_o.data(roi_ind, :,:),1)); %select and average across channels of interest
            EEG_o_peak = squeeze(mean(EEG_o_roi(PeakRange, :),1)); %select and average across timerange of interest
            Scores = EEG_o_peak';
            tab3 = array2table(Scores); %make table
            tab3 = renamevars(tab3,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
            tab3.Condition(:) = "object"; %add condition variable
            tab3.("TrialNum") = EEG_o_trialnums;
        end
        
        if sum(contains(conditions, '4'))==1
            EEG_uo = pop_selectevent(EEG, 'Condition', '4', 'deleteevents','on'); %select only uprightObj trials
            EEG_uo = eeg_checkset(EEG_uo);
            EEG_uo_trialnums = {EEG_uo.event.TrialNum}';
            EEG_uo_roi = squeeze(mean(EEG_uo.data(roi_ind, :,:),1)); %select and average across channels of interest
            EEG_uo_peak = squeeze(mean(EEG_uo_roi(PeakRange, :),1)); %select and average across timerange of interest
            Scores = EEG_uo_peak';
            tab4 = array2table(Scores); %make table
            tab4 = renamevars(tab4,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
            tab4.Condition(:) = "uprightObj"; %add condition variable
            tab4.("TrialNum") = EEG_uo_trialnums;
        end
        
        tabFull = [tab; tab2; tab3; tab4;];
        tabFull.ID(:) = convertCharsToStrings(participant_label);
        
    elseif strcmp(task, 'MMN')
        tab=[];
        tab2=[];
        tab3=[];

        EEG_s = pop_selectevent(EEG, 'Condition', '1', 'deleteevents','on'); %select only standard trials
        EEG_s = eeg_checkset(EEG_s);
        EEG_s_trialnums = {EEG_s.event.TrialNum}';
        EEG_s_roi = squeeze(mean(EEG_s.data(roi_ind, :,:),1)); %select and average across channels of interest
        EEG_s_peak = squeeze(mean(EEG_s_roi(PeakRange, :),1)); %select and average across timerange of interest
        Scores = EEG_s_peak';
        tab = array2table(Scores); %make table
        tab = renamevars(tab,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
        tab.Condition(:) = "standard"; %add condition variable
        tab.("TrialNum") = EEG_s_trialnums;
        
        EEG_p = pop_selectevent(EEG, 'Condition', '2', 'deleteevents','on'); %select only predeviant trials
        EEG_p = eeg_checkset(EEG_p);
        EEG_p_trialnums = {EEG_p.event.TrialNum}';
        EEG_p_roi = squeeze(mean(EEG_p.data(roi_ind, :,:),1)); %select and average across channels of interest
        EEG_p_peak = squeeze(mean(EEG_p_roi(PeakRange, :),1)); %select and average across timerange of interest
        Scores = EEG_p_peak';
        tab2 = array2table(Scores); %make table
        tab2 = renamevars(tab2,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
        tab2.Condition(:) = "predeviant"; %add condition variable
        tab2.("TrialNum") = EEG_p_trialnums;
        
        EEG_d = pop_selectevent(EEG, 'Condition', '3', 'deleteevents','on'); %select only deviant trials
        EEG_d = eeg_checkset(EEG_d);
        EEG_d_trialnums = {EEG_d.event.TrialNum}';
        EEG_d_roi = squeeze(mean(EEG_d.data(roi_ind, :,:),1)); %select and average across channels of interest
        EEG_d_peak = squeeze(mean(EEG_d_roi(PeakRange, :),1)); %select and average across timerange of interest
        Scores = EEG_d_peak';
        tab3 = array2table(Scores); %make table
        tab3 = renamevars(tab3,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
        tab3.Condition(:) = "deviant"; %add condition variable 
        tab3.("TrialNum") = EEG_d_trialnums;
        
        tabFull = [tab; tab2; tab3];
        tabFull.ID(:) = convertCharsToStrings(participant_label);
        
    elseif strcmp(task, 'VEP')
        EEG_v = pop_selectevent(EEG, 'Condition', '1', 'deleteevents','on');
        EEG_v = eeg_checkset(EEG_v);
        EEG_v_trialnums = {EEG_v.event.TrialNum}';
        EEG_v_roi = squeeze(mean(EEG_v.data(roi_ind, :,:),1)); %select and average across channels of interest
        EEG_v_peak = squeeze(mean(EEG_v_roi(PeakRange, :),1)); %select and average across timerange of interest
        Scores = EEG_v_peak';
        tab = array2table(Scores); %make table
        tab = renamevars(tab,["Scores"], ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]); %label table
        tab.("TrialNum") = EEG_v_trialnums;
        tab.Condition(:) = "vep";
        tabFull = tab;
        tabFull.ID(:) = convertCharsToStrings(participant_label);
    else
        error("Not a scoreable task!")
    end
    
    %writetable(tabFull, [output_location filesep participant_label '_' session_label '_task-' task '_' num2str(PeakStart) '-' num2str(PeakEnd) '_ERP-Scores.csv']);
    
    tabFull = convertvars(tabFull,["Condition"],"categorical");
    % Group-wise sme calculations
    sme = grpstats(tabFull, 'Condition', {@(x) std(x)/sqrt(numel(x))}, 'DataVars', ['MeanAmplitude_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)]);
    sme.Properties.VariableNames{3} = ['SME_' num2str(PeakStart) '-' num2str(PeakEnd) '_' char(Cluster)];
    
    %writetable(sme, [output_location filesep participant_label '_' session_label '_task-' task '_' num2str(PeakStart) '-' num2str(PeakEnd) '_SME.csv']);
    
    if i==1
        smeWide = sme;
        tabWide = tabFull;
    else
        smeWide = join(smeWide, sme);
        tabWide = join(tabWide, tabFull);
    end
    
end
writetable(smeWide, [output_location filesep 'processed_data' filesep participant_label '_' session_label '_task-' task '_ERP-summaryStats.csv']);
writetable(tabWide,  [output_location filesep 'processed_data' filesep participant_label '_' session_label '_task-' task '_ERP-trialMeasures.csv']);

