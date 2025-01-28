
function [EEG] = check_missing_dins(EEG, task, siteinfo, json_file)

% Script checks dins for each task and adds in missing dins during needed
% trials. Takes in EEG struct and outputs editted struct. 
% task refers to current task called as found in make_MADE_epochs.
% outEEGname refers to PSCID of participant as found in run_MADE.

% Future updates will be made for data release to only call this file when
% site information is provided. This script in the pipeline will be used
% for internal HBCD processing. 

% This script relies on a mean_flag_delay_by_site.csv file that must be
% uploaded to CBrain. For local use, this path will be changed to where the
% downloaded file is stored.

% Original contributers to this code:
% Kira Ashton, kashton7@umd.edu
% Trisha Maheshwari, tmahesh@umd.edu
% Whitney Kasenetz, kasenetz@umd.edu

% This file path will change based on where the file is stored
site_delay_file = json_file.site_delay_file; %change this to wherever it is saved

site_delays = readtable(site_delay_file);

% Pulls from scans.tsv or outEEGname for local files
try
    site = siteinfo; 
    [~,index] = ismember(site,site_delays.site);
catch
    error("Invalid site info, check again please.");
end

if strcmp(task, 'FACE')

    % check for din4s and change them to din3s

    din4s = find(strcmp({EEG.event.type}, 'DIN4'));

    if length(din4s)>0
        for t=1:length(din4s)
            EEG.event(din4s(t)).type = 'DIN3';
        end
    end

    % count all the dins and stms
    events = find(strcmp({EEG.event.type}, 'stm+'));
    din3s = find(strcmp({EEG.event.type}, 'DIN3'));

    % if same number of dins and stms, nothing to fix 
    if length(din3s) < length(events)

        sitedelay = site_delays(index,'mean_FACE_delay').mean_FACE_delay;

        for t = events

            prev = EEG.event(t-1);
            next = EEG.event(t+1);
            % check if each stm has a din
            if strcmp(next.type, 'DIN3') | strcmp(prev.type, 'DIN3')
                continue
            % if not, rename stm to din3, add the site delay, and set the trialnum from trsp 
            elseif strcmp(next.type, 'TRSP')
                tnum = next.TrialNum;
                EEG.event(t).TrialNum = tnum;
                EEG.event(t).latency = EEG.event(t).latency + sitedelay;
                EEG.event(t).type = 'DIN3';
            end



        end

    end



    
elseif strcmp(task, 'MMN')

    % count all the dins and stms
    events = find(strcmp({EEG.event.type}, 'stms'));
    din2s = find(strcmp({EEG.event.type}, 'DIN2'));

    % if same number of dins and stms, nothing to fix 
    if length(din2s) < length(events)

        sitedelay = site_delays(index,'mean_MMN_delay').mean_MMN_delay;

        for t = events

            prev = EEG.event(t-1);
            next = EEG.event(t+1);
            % check if each stm has a din
            if strcmp(next.type, 'DIN2') | strcmp(prev.type, 'DIN2')
                continue
            % if not, rename stm to din2, add the site delay, and set the trialnum from trsp 
            elseif strcmp(next.type, 'TRSP')
                tnum = next.TrialNum;
                EEG.event(t).TrialNum = tnum;
                EEG.event(t).latency = EEG.event(t).latency + sitedelay;
                EEG.event(t).type = 'DIN2';
            end



        end
    end
    

    
elseif strcmp(task, 'VEP')
    

    % check for din4s and change them to din3s

    din4s = find(strcmp({EEG.event.type}, 'DIN4'));

    if length(din4s)>0
        for t=1:length(din4s)
            EEG.event(din4s(t)).type = 'DIN3';
        end
    end

    % count all the dins and stms
    stms1 = find(strcmp({EEG.event.type}, 'ch1+'));
    stms2 = find(strcmp({EEG.event.type}, 'ch2+'));
    
    events = [ stms1 stms2 ];
    din3s = find(strcmp({EEG.event.type}, 'DIN3'));

    % if same number of dins and stms, nothing to fix 
    if length(din3s) < length(events)

        sitedelay = site_delays(index,'mean_VEP_delay').mean_VEP_delay;
        
        trsps = find(strcmp({EEG.event.type}, 'TRSP'));
        if length(din3s) == 0 
            for k = 1:length(trsps) 
                %relabel trsp to be 2xtrialnum
                EEG.event(trsps(k)).TrialNum = str2num(EEG.event(trsps(k)).TrialNum)*2;
            end
        else
            for k = 1:length(trsps) 
                %relabel trsp to be trialnum
                EEG.event(trsps(k)).TrialNum = str2num(EEG.event(trsps(k)).TrialNum);
            end
        end

        for t = events

            prev = EEG.event(t-1);
            next = EEG.event(t+1);
            try
                nextnext = EEG.event(t+2);
            catch
                nextnext = EEG.event(t); %make it not a trsp but don't let it error
            end
            try
                next3 = EEG.event(t+3);
            catch
                next3 = EEG.event(t); %make it not a trsp but don't let it error
            end
            % check if each stm has a din
            if strcmp(next.type, 'DIN3')
                continue
            % if not, rename stm to din3, add the site delay, and set the trialnum from trsp 
            elseif strcmp(next.type, 'TRSP')
                tnum = next.TrialNum;
                EEG.event(t).TrialNum = num2str(tnum);
                EEG.event(t).latency = EEG.event(t).latency + sitedelay;
                EEG.event(t).type = 'DIN3';

            elseif strcmp(nextnext.type, 'TRSP')
                tnum = nextnext.TrialNum;
                EEG.event(t).TrialNum = num2str(tnum-1);
                EEG.event(t).latency = EEG.event(t).latency + sitedelay;
                EEG.event(t).type = 'DIN3';
            elseif strcmp(next3.type, 'TRSP')
                tnum = next3.TrialNum;
                EEG.event(t).TrialNum = num2str(tnum-1);
                EEG.event(t).latency = EEG.event(t).latency + sitedelay;
                EEG.event(t).type = 'DIN3';
            end

        end

    end


    
elseif strcmp(task, 'RS')

    din4s = find(strcmp({EEG.event.type}, 'DIN4'));

    if length(din4s)>0
        for t=1:length(din4s)
            EEG.event(din4s(t)).type = 'DIN3';
        end
    end

    events = find(strcmp({EEG.event.type}, 'bas+'));

    din3s = find(strcmp({EEG.event.type}, 'DIN3'));

    % if same number of dins and stms, nothing to fix 
    if length(din3s) < length(events)
        sitedelay = site_delays(index,'mean_FACE_delay').mean_FACE_delay;
        
        for t = events

            prev = EEG.event(t-1);
            next = EEG.event(t+1);
            % check if each stm has a din
            if strcmp(next.type, 'DIN3') | strcmp(prev.type, 'DIN3')
                continue
            % if not, rename stm to din3, add the site delay, and set the trialnum from trsp 
            elseif strcmp(next.type, 'TRSP')
                tnum = next.TrialNum;
                EEG.event(t).TrialNum = tnum;
                EEG.event(t).latency = EEG.event(t).latency + sitedelay;
                EEG.event(t).type = 'DIN3';
            end

        end


    end

end