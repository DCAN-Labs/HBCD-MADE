function[] = computeSME(EEG, eeg_file_name, json_file_name, task, output_location, participant_label, session_label, age)
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

% TM - new check for session label for choosing ERPs
if strcmp(session_label, 'ses-V04')
    %choose ses-v04 settings
    s1 = s.ses_V04;

elseif strcmp(session_label, 'ses-V03')
    %choose ses-v03 settings
    s1 = s.ses_V03;
end

%Grab task specific settings

scoreROIs = s1.score_ROIs;
scoreAges = s1.score_ages;
erp_dirs = s1.ERP_dirs; %NEW TM
erp_nameslist = s1.ERP_names; %NEW TM

if isempty(scoreAges)
    %Assert that the correct number of parameters are present
    scoreTimes = s1.score_times;
    assert(length(scoreTimes)== length(scoreROIs), "Must have the same number of score times and ROIs!")
    
else
 
    age_bin = 1;
    in_range = 0;
    for i=1:length(scoreAges)
        agemin = scoreAges(i,1);
        agemax = scoreAges(i,2);
        
        if age >= agemin && age < agemax
            age_bin = i;
            in_range = 1;
            break
        end    
        
    end 
    if in_range==0
        if age < scoreAges(1,1)
            age_bin=1; %less than 3 mo, less than 9 mo but still at v04 (ie.8.5)
    
        else
            age_bin=2; %older than 9 but still at v03 (ie 9.5 mo), older than 15 mo
        end
    end

    if age_bin == 1
        scoreTimes = s1.score_times1;
    elseif age_bin == 2
        scoreTimes = s1.score_times2;
    end


end

for i=1:length(scoreTimes)
    %select time window of interest
    scoreTime = scoreTimes(i,:);
    PeakStart = scoreTime(1);
    PeakEnd = scoreTime(2);
    %PeakStart = 100; %TEMP
    %PeakEnd = 200;%TEMP

    direction = erp_dirs(i);%NEW TM
    erp_name = erp_nameslist{i}; %NEW TM

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
            if EEG_ui.trials == 1 %exception for when there is only one trial retained for this condition
                EEG_ui_trialnums = {EEG_ui.event.TrialNum}';
                EEG_ui_roi = squeeze(mean(EEG_ui.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_ui_peak = squeeze(mean(EEG_ui_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_ui_peak';

                tab = array2table(Scores); %make table
                tab = renamevars(tab,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table


                % % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_ui, PeakRange, roi_ind, direction);%NEW TM
                % tab.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;

                tab.Condition(:) = "uprightInv"; %add condition variable
                tab.("TrialNum") = EEG_ui_trialnums; %add trial num variable
            else
                EEG_ui_trialnums = {EEG_ui.event.TrialNum}';
                EEG_ui_roi = squeeze(mean(EEG_ui.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_ui_peak = squeeze(mean(EEG_ui_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_ui_peak';
                tab = array2table(Scores); %make table
                tab = renamevars(tab,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_ui, PeakRange, roi_ind, direction);%NEW TM
                % tab.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;

                tab.Condition(:) = "uprightInv"; %add condition variable
                tab.("TrialNum") = EEG_ui_trialnums; %add trial num variable
            end
        end

        if sum(contains(conditions, '2'))==1
            EEG_i = pop_selectevent(EEG, 'Condition', '2', 'deleteevents','on'); %select only inverted trials
            EEG_i = eeg_checkset(EEG_i);
            if EEG_i.trials == 1
                EEG_i_trialnums = {EEG_i.event.TrialNum}';
                EEG_i_roi = squeeze(mean(EEG_i.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_i_peak = squeeze(mean(EEG_i_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_i_peak';
                tab2 = array2table(Scores); %make table
                tab2 = renamevars(tab2,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_i, PeakRange, roi_ind, direction);%NEW TM
                % tab2.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab2.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab2.Condition(:) = "inverted"; %add condition variable
                tab2.("TrialNum") = EEG_i_trialnums; %add trial num variable
            else
                EEG_i_trialnums = {EEG_i.event.TrialNum}';
                EEG_i_roi = squeeze(mean(EEG_i.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_i_peak = squeeze(mean(EEG_i_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_i_peak';
                tab2 = array2table(Scores); %make table
                tab2 = renamevars(tab2,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_i, PeakRange, roi_ind, direction);%NEW TM
                % tab2.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab2.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab2.Condition(:) = "inverted"; %add condition variable
                tab2.("TrialNum") = EEG_i_trialnums;
            end
        end

        if sum(contains(conditions, '3'))==1
            EEG_o = pop_selectevent(EEG, 'Condition', '3', 'deleteevents','on'); %select only object trials
            EEG_o = eeg_checkset(EEG_o);
            if EEG_o.trials == 1
                EEG_o_trialnums = {EEG_o.event.TrialNum}';
                EEG_o_roi = squeeze(mean(EEG_o.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_o_peak = squeeze(mean(EEG_o_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_o_peak';
                tab3 = array2table(Scores); %make table
                tab3 = renamevars(tab3,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % % TODO: Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_o, PeakRange, roi_ind, direction);%NEW TM
                % tab3.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab3.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab3.Condition(:) = "object"; %add condition variable
                tab3.("TrialNum") = EEG_o_trialnums; %add trial num variable
            else
                EEG_o_trialnums = {EEG_o.event.TrialNum}';
                EEG_o_roi = squeeze(mean(EEG_o.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_o_peak = squeeze(mean(EEG_o_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_o_peak';
                tab3 = array2table(Scores); %make table
                tab3 = renamevars(tab3,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_o, PeakRange, roi_ind, direction);%NEW TM
                % tab3.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab3.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab3.Condition(:) = "object"; %add condition variable
                tab3.("TrialNum") = EEG_o_trialnums;
            end
        end

        if sum(contains(conditions, '4'))==1
            EEG_uo = pop_selectevent(EEG, 'Condition', '4', 'deleteevents','on'); %select only uprightObj trials
            EEG_uo = eeg_checkset(EEG_uo);
            if EEG_uo.trials == 1
                EEG_uo_trialnums = {EEG_uo.event.TrialNum}';
                EEG_uo_roi = squeeze(mean(EEG_uo.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_uo_peak = squeeze(mean(EEG_uo_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_uo_peak';
                tab4 = array2table(Scores); %make table
                tab4 = renamevars(tab4,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % %Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_uo, PeakRange, roi_ind, direction);%NEW TM
                % tab4.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab4.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab4.Condition(:) = "uprightObj"; %add condition variable
                tab4.("TrialNum") = EEG_uo_trialnums; %add trial num variable
            else
                EEG_uo_trialnums = {EEG_uo.event.TrialNum}';
                EEG_uo_roi = squeeze(mean(EEG_uo.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_uo_peak = squeeze(mean(EEG_uo_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_uo_peak';
                tab4 = array2table(Scores); %make table
                tab4 = renamevars(tab4,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_uo, PeakRange, roi_ind, direction);%NEW TM
                % tab4.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                % tab4.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab4.Condition(:) = "uprightObj"; %add condition variable
                tab4.("TrialNum") = EEG_uo_trialnums;
            end
        end

        tabFull = [tab; tab2; tab3; tab4;];
        tabFull.ID(:) = convertCharsToStrings(participant_label);

    elseif strcmp(task, 'MMN')
        tab=[];
        tab2=[];
        tab3=[];

        conditions = unique({EEG.event.Condition}); %check which conditions exist

        if sum(contains(conditions, '1'))==1
            EEG_s = pop_selectevent(EEG, 'Condition', '1', 'deleteevents','on'); %select only standard trials
            EEG_s = eeg_checkset(EEG_s);
            if EEG_s.trials == 1 %exception for when there is only one trial retained for this condition
                EEG_s_trialnums = {EEG_s.event.TrialNum}';
                EEG_s_roi = squeeze(mean(EEG_s.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_s_peak = squeeze(mean(EEG_s_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_s_peak';
                tab = array2table(Scores); %make table
                tab = renamevars(tab,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % Insert peak latency function here
                [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_s, PeakRange, roi_ind, direction);%NEW TM
                %tab.(['Peak_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                %tab.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab.Condition(:) = "standard"; %add condition variable
                tab.("TrialNum") = EEG_s_trialnums;
            else
                EEG_s_trialnums = {EEG_s.event.TrialNum}';
                EEG_s_roi = squeeze(mean(EEG_s.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_s_peak = squeeze(mean(EEG_s_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_s_peak';
                tab = array2table(Scores); %make table
                tab = renamevars(tab,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_s, PeakRange, roi_ind, direction);%NEW TM
                %tab.(['Peak_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                %tab.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab.Condition(:) = "standard"; %add condition variable
                tab.("TrialNum") = EEG_s_trialnums;
            end
        end

        if sum(contains(conditions, '2'))==1
            EEG_p = pop_selectevent(EEG, 'Condition', '2', 'deleteevents','on'); %select only predeviant trials
            EEG_p = eeg_checkset(EEG_p);
            if EEG_p.trials == 1
                EEG_p_trialnums = {EEG_p.event.TrialNum}';
                EEG_p_roi = squeeze(mean(EEG_p.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_p_peak = squeeze(mean(EEG_p_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_p_peak';
                tab2 = array2table(Scores); %make table
                tab2 = renamevars(tab2,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_p, PeakRange, roi_ind, direction);%NEW TM
                %tab2.(['Peak_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                %tab2.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab2.Condition(:) = "predeviant"; %add condition variable
                tab2.("TrialNum") = EEG_p_trialnums;
            else
                EEG_p_trialnums = {EEG_p.event.TrialNum}';
                EEG_p_roi = squeeze(mean(EEG_p.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_p_peak = squeeze(mean(EEG_p_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_p_peak';
                tab2 = array2table(Scores); %make table
                tab2 = renamevars(tab2,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_p, PeakRange, roi_ind, direction);%NEW TM
                %tab2.(['Peak_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                %tab2.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab2.Condition(:) = "predeviant"; %add condition variable
                tab2.("TrialNum") = EEG_p_trialnums;
            end
        end

        if sum(contains(conditions, '3'))==1
            EEG_d = pop_selectevent(EEG, 'Condition', '3', 'deleteevents','on'); %select only deviant trials
            EEG_d = eeg_checkset(EEG_d);
            if EEG_d.trials == 1
                EEG_d_trialnums = {EEG_d.event.TrialNum}';
                EEG_d_roi = squeeze(mean(EEG_d.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_d_peak = squeeze(mean(EEG_d_roi(PeakRange))); %select and average across timerange of interest
                Scores = EEG_d_peak';
                tab3 = array2table(Scores); %make table
                tab3 = renamevars(tab3,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_d, PeakRange, roi_ind, direction);%NEW TM
                %tab3.(['Peak_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                %tab3.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab3.Condition(:) = "deviant"; %add condition variable
                tab3.("TrialNum") = EEG_d_trialnums;
            else
                EEG_d_trialnums = {EEG_d.event.TrialNum}';
                EEG_d_roi = squeeze(mean(EEG_d.data(roi_ind, :,:),1)); %select and average across channels of interest
                EEG_d_peak = squeeze(mean(EEG_d_roi(PeakRange, :),1)); %select and average across timerange of interest
                Scores = EEG_d_peak';
                tab3 = array2table(Scores); %make table
                tab3 = renamevars(tab3,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

                % Insert peak latency function here
                % [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_d, PeakRange, roi_ind, direction);%NEW TM
                %tab3.(['Peak_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
                %tab3.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


                tab3.Condition(:) = "deviant"; %add condition variable
                tab3.("TrialNum") = EEG_d_trialnums;
            end
        end

        tabFull = [tab; tab2; tab3];
        tabFull.ID(:) = convertCharsToStrings(participant_label);

    elseif strcmp(task, 'VEP')
        EEG_v = pop_selectevent(EEG, 'Condition', '1', 'deleteevents','on');
        EEG_v = eeg_checkset(EEG_v);
        if EEG_v.trials == 1
            EEG_v_trialnums = {EEG_v.event.TrialNum}';
            EEG_v_roi = squeeze(mean(EEG_v.data(roi_ind, :,:),1)); %select and average across channels of interest
            EEG_v_peak = squeeze(mean(EEG_v_roi(PeakRange))); %select and average across timerange of interest
            Scores = EEG_v_peak';
            tab = array2table(Scores); %make table
            tab = renamevars(tab,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

            % Insert peak latency function here
            [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_v, PeakRange, roi_ind, direction);%NEW TM
            tab.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
            tab.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


            tab.("TrialNum") = EEG_v_trialnums;
            tab.Condition(:) = "vep";
            tabFull = tab;
            tabFull.ID(:) = convertCharsToStrings(participant_label);
        else
            EEG_v_trialnums = {EEG_v.event.TrialNum}';
            EEG_v_roi = squeeze(mean(EEG_v.data(roi_ind, :,:),1)); %select and average across channels of interest
            EEG_v_peak = squeeze(mean(EEG_v_roi(PeakRange, :),1)); %select and average across timerange of interest
            Scores = EEG_v_peak';
            tab = array2table(Scores); %make table
            tab = renamevars(tab,["Scores"], ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]); %label table

            % Insert peak latency function here
            [AvgPeakScores, PeakLatencies] =  compute_peaks_latencies(EEG_v, PeakRange, roi_ind, direction);%NEW TM
            tab.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = AvgPeakScores;
            tab.(['Latency_' char(erp_name) '_' char(Cluster)]) = PeakLatencies;


            tab.("TrialNum") = EEG_v_trialnums;
            tab.Condition(:) = "vep";
            tabFull = tab;
            tabFull.ID(:) = convertCharsToStrings(participant_label);
        end

    else
        error("Not a scoreable task!")
    end

    %writetable(tabFull, [output_location filesep participant_label '_' session_label '_task-' task '_' num2str(PeakStart) '-' num2str(PeakEnd) '_ERP-Scores.csv']);

    tabFull = convertvars(tabFull,["Condition"],"categorical");
    % Group-wise sme calculations
    conditions2 = cellstr(unique(tabFull.Condition, 'stable'));
    sme = grpstats(tabFull, 'Condition', {@(x) std(x)/sqrt(numel(x))}, 'DataVars', ['MeanAmplitude_' char(erp_name) '_' char(Cluster)]);
    sme.Properties.VariableNames{3} = ['SME_' char(erp_name) '_' char(Cluster)];
    %sme(cellstr(conditions2), :) = sme
    [X,Y] = ismember(sme.Condition, conditions2);
    [~,Z] = sort(Y);
    sme2 = sme(Z,:);
    sme = sme2;

    ncond = height(sme);
    peakVals = zeros(ncond, 1);
    latVals = zeros(ncond, 1);
    meanVals = zeros(ncond, 1);
    conditions1 = unique({EEG.event.Condition}); %check which conditions exist
    
    for c=1:ncond
        EEG_c = pop_selectevent(EEG, 'Condition', conditions1{c}, 'deleteevents','on'); %select only inverted trials
        EEG_c = eeg_checkset(EEG_c);

        EEG_c_roi = squeeze(mean(EEG_c.data(roi_ind, :,:),1)); %select and average across channels of interest
        EEG_c_mean = mean(EEG_c_roi,2);
        EEG_roi_tw = EEG_c_mean(PeakRange);
        if direction==1
            EEG_peak_value = max(EEG_roi_tw);
        elseif direction==-1
            EEG_peak_value = min(EEG_roi_tw);
        end
       
        
        peak_index = find(EEG_c_mean== EEG_peak_value,1);
        peak_latency = EEG.times(peak_index);
        
        %window_ms is the variable determining the window around the
        %adaptive mean. DG edit on 7/8
        window_ms = 10;

        % Find index range within ±10 ms of the peak
        peakav_start = find(EEG.times >= peak_latency - window_ms, 1, 'first');
        peakav_end   = find(EEG.times <= peak_latency + window_ms, 1, 'last');

        if isempty(peakav_start)
            peakav_start = 1;
    
        elseif isempty(peakav_end)
            peakav_end = length(EEG.times);
    
        end
    
        AvgPeakRange = peakav_start:peakav_end;
    
        avg_peak_value = mean(EEG_c_mean(AvgPeakRange));

        mean_value = mean(EEG_c_mean(PeakRange));

        peakVals(c) = avg_peak_value;
        latVals(c) = peak_latency;
        meanVals(c) = mean_value;

    end

    if strcmp(task, 'FACE')
        sme.(['MeanAmp_' char(erp_name) '_' char(Cluster)]) = meanVals;
    elseif strcmp(task, 'MMN')
        sme.(['MeanAmp_' char(erp_name) '_' char(Cluster)]) = meanVals;
    else
        sme.(['AdaptiveMean_' char(erp_name) '_' char(Cluster)]) = peakVals;
        sme.(['Latency_' char(erp_name) '_' char(Cluster)]) = latVals;
        sme.(['MeanAmp_' char(erp_name) '_' char(Cluster)]) = meanVals;
    end

    %writetable(sme, [output_location filesep participant_label '_' session_label '_task-' task '_' num2str(PeakStart) '-' num2str(PeakEnd) '_SME.csv']);

    if i==1
        smeWide = sme;
        tabWide = tabFull;
    else
        smeWide = join(smeWide, sme);
        tabWide = join(tabWide, tabFull);
    end

end
smeWide.Properties.VariableNames{2} = 'NTrials';
%Add ID and visit as grouping vars
smeWide.ID = repmat({participant_label}, height(smeWide), 1);
smeWide.Visit = repmat({session_label}, height(smeWide), 1);

%Pivot data to wide format - TM 
% NOTE THIS WILL NEED TO MANUALLY CHANGE EVERY TIME THE VARIABLE NAMES
% CHANGE SORRY
if strcmp(session_label, 'ses-V03')
    if strcmp(task, 'FACE')
            smeWide = unstack(smeWide, {'NTrials', ...
                'SME_N290_p8','MeanAmp_N290_p8', ...
                'SME_N290_p7','MeanAmp_N290_p7', ...
                'SME_P1_oz','MeanAmp_P1_oz', ...
                'SME_N290_oz','MeanAmp_N290_oz', ...
                'SME_P400_oz','MeanAmp_P400_oz', ...
                'SME_NC_fcz','MeanAmp_NC_fcz',}, 'Condition');
    elseif strcmp(task, 'MMN')
            smeWide = unstack(smeWide, {'NTrials','SME_MMN_t7t8','MeanAmp_MMN_t7t8','SME_MMN_f7f8','MeanAmp_MMN_f7f8','SME_MMN_fcz','MeanAmp_MMN_fcz'}, 'Condition');
    elseif strcmp(task, 'VEP')
            smeWide = unstack(smeWide, {'NTrials','SME_N1_oz','AdaptiveMean_N1_oz','Latency_N1_oz','MeanAmp_N1_oz','SME_P1_oz','AdaptiveMean_P1_oz','Latency_P1_oz','MeanAmp_P1_oz','SME_N2_oz','AdaptiveMean_N2_oz','Latency_N2_oz','MeanAmp_N2_oz'}, 'Condition');
    end
end
if strcmp(session_label, 'ses-V04')
    if strcmp(task, 'FACE')
            smeWide = unstack(smeWide, {'NTrials', ...
                'SME_N1_oz','MeanAmp_N1_oz', ...
                'SME_N290_p8','MeanAmp_N290_p8', ...
                'SME_N290_p7','MeanAmp_N290_p7', ...
                'SME_N290_oz','MeanAmp_N290_oz', ...
                'SME_P400_p8','MeanAmp_P400_p8', ...
                'SME_P400_p7','MeanAmp_P400_p7', ...
                'SME_P400_oz','MeanAmp_P400_oz', ...
                'SME_NC_fcz','MeanAmp_NC_fcz' }, 'Condition');
    elseif strcmp(task, 'MMN')
            smeWide = unstack(smeWide, {'NTrials', ...
                'SME_MMN_t7t8','MeanAmp_MMN_t7t8', ...
                'SME_MMN_f7f8','MeanAmp_MMN_f7f8', ...
                'SME_MMN_f3f4','MeanAmp_MMN_f3f4', ...
                'SME_MMN_fcz','MeanAmp_MMN_fcz', ...
                'SME_MMR_t7t8','MeanAmp_MMR_t7t8', ...
                'SME_MMR_f7f8','MeanAmp_MMR_f7f8', ...
                'SME_MMR_f3f4','MeanAmp_MMR_f3f4', ...
                'SME_MMR_fcz','MeanAmp_MMR_fcz'}, 'Condition');
    elseif strcmp(task, 'VEP')
            smeWide = unstack(smeWide, {'NTrials','SME_N1_oz','AdaptiveMean_N1_oz','Latency_N1_oz','MeanAmp_N1_oz','SME_P1_oz','AdaptiveMean_P1_oz','Latency_P1_oz','MeanAmp_P1_oz','SME_N2_oz','AdaptiveMean_N2_oz','Latency_N2_oz','MeanAmp_N2_oz'}, 'Condition');
    end
end

writetable(smeWide, [output_location filesep 'processed_data' filesep participant_label '_' session_label '_task-' task '_ERPSummaryStats.csv']);
writetable(tabWide,  [output_location filesep 'processed_data' filesep participant_label '_' session_label '_task-' task '_ERPTrialMeasures.csv']);

