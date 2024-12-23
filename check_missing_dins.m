
function [EEG] = check_missing_dins(EEG, task, siteinfo)

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
site_delay_file = 'C:\Users\tmahesh\Desktop\HBCD-MADE\mean_flag_delay_by_site.csv'; %change this to wherever it is saved

site_delays = readtable(site_delay_file);

% Pulls from scans.tsv or outEEGname for local files
try
    site = siteinfo(1); 
    [~,index] = ismember(site,site_delays.site);
catch
    error("Invalid site info, check again please.");
end

if strcmp(task, 'FACE')
    
    stms = find(strcmp({EEG.event.type}, 'stm+'));
    din3s = find(strcmp({EEG.event.type}, 'DIN3'));
    din4s = find(strcmp({EEG.event.type}, 'DIN4'));
    
    if length(din4s)>0
        for t=1:length(din4s)
            EEG.event(din4s(t)).type = 'DIN3';
            
        end
        din3s = find(strcmp({EEG.event.type}, 'DIN3'));
    end
    
    if length(din3s) < length(stms)
        sitedelay = site_delays(index,'mean_FACE_delay').mean_FACE_delay;
        missing = setdiff(stms,din3s);
        
        for t=1:length(missing)
            EEG.event(missing(t)).type = 'DIN3';
            
            EEG.event(missing(t)).latency = EEG.event(missing(t)).latency + sitedelay;
            
        end
    end
    
elseif strcmp(task, 'MMN')
    stms = find(strcmp({EEG.event.type}, 'stms'));
    din2s = find(strcmp({EEG.event.type}, 'DIN2'));
    
    if length(din2s) < length(stms)
        sitedelay = site_delays(index,'mean_MMN_delay').mean_MMN_delay;
        missing = setdiff(stms,din2s);
        
        for t=1:length(missing)
            EEG.event(missing(t)).type = 'DIN2';
            
            EEG.event(missing(t)).latency = EEG.event(missing(t)).latency + sitedelay;
            
        end
    end
    
elseif strcmp(task, 'VEP')
    
    stms1 = find(strcmp({EEG.event.type}, 'ch1+'));
    stms2 = find(strcmp({EEG.event.type}, 'ch2+'));
    
    stms = [ stms1 stms2 ];
    
    din3s = find(strcmp({EEG.event.type}, 'DIN3'));
    din4s = find(strcmp({EEG.event.type}, 'DIN4'));
    
    if length(din4s)>0
        for t=1:length(din4s)
            EEG.event(din4s(t)).type = 'DIN3';
        end
        din3s = find(strcmp({EEG.event.type}, 'DIN3'));
    end
    
    if length(din3s) < length(stms)
        sitedelay = site_delays(index,'mean_VEP_delay').mean_VEP_delay;
        missing = setdiff(stms,din3s);
        
        for t=1:length(missing)
            EEG.event(missing(t)).type = 'DIN3';
            
            EEG.event(missing(t)).latency = EEG.event(missing(t)).latency + sitedelay;
            
        end
    end
    
    
elseif strcmp(task, 'RS')
    stms = find(strcmp({EEG.event.type}, 'bas+'));
    din3s = find(strcmp({EEG.event.type}, 'DIN3'));
    din4s = find(strcmp({EEG.event.type}, 'DIN4'));

    if length(din4s)>0 & isempty(din3s)
        for t=1:length(din4s)
            EEG.event(din4s(t)).type = 'DIN3';
        end
        din3s = find(strcmp({EEG.event.type}, 'DIN3'));
    end

    if isempty(din3s)
        sitedelay = site_delays(index,'mean_FACE_delay').mean_FACE_delay;
        missing = setdiff(stms,din3s);

        for t=1:length(missing)
            EEG.event(missing(t)).type = 'DIN3';

            EEG.event(missing(t)).latency = EEG.event(missing(t)).latency + sitedelay;

        end
    end
end

end








