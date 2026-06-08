% This functions computes the FFT of the data and aftewards the PLV and
% power
%
% INPUTS:
%   EEG     EEGLAB structure
% OPTIONAL INPUTS:
%   condition   indexes for different conditions (size Nepochs x 1 )
%               If not proveded or empty it is computed for all trials
%               Default []
%   foutput     range for the output frequnecies to keep. 
%               If not proveded all are kept. Default []
%   fband       range of frequecies to use for the normalization (SNR)
%               If not proveded all are used. Default []
%   ftarget     frequencies to exclude to compute the SNR for other
%               freqency bins. Default []
%   noutSNR     when computing SNR exclude outliers bigger than noutSNR*std
%               Default 2
%   binsSNR     bins to use for the normlaization. Default [-5 -4 -3 -2 -1 1 2 3 4 5 ]
%   typeSNRPWR  type of SNR correction for the power.  
%               Default 'linear' (linearly fits log(power) log(frq) usin 
%               the frequnecy bins surronding each bin)
%   typeSNRPLV  type of SNR correction  for the PLV. Defalut 'none'
%   zscorePWR   logical value indicting if the output power has to be 
%               z-score across all the output frequency bins. Default 0
%   zscorePLV   logical value indicting if the output PLV has to be 
%               z-score across all the output frequency bins. Default 0
%
% Usage e.g.
% 
%   EEGfrq = frqa_plvpwr(EEG, 'condition', [1 1 1 2 2 2], 'foutput', [0.5 10],...
%               'fband', [0.2 15], 'typeSNRPWR','linear','typeSNRPLV','linear',...
%               'zscorePWR',1,'zscorePLV',1) 
%
% Ana Flo, February 2021, NeuroSpin, CEA


function EEGfrq = frqa_plvpwr(EEG, varargin)

%% ------------------------------------------------------------------------
%% Parameters

% Power Spectrum
P.condition     = [];
P.foutput       = [];
P.fband         = [];
P.ftarget       = [];
P.noutSNR       = 2.0;
P.binsSNR       = [(-5:-1) (1:5)];
P.typeSNRPWR    = 'linear';   % 'linear' | 'mean' | 'none'
P.typeSNRPLV    = [];   % 'linear' | 'mean' | 'none'
P.zscorePWR     = 0;
P.zscorePLV     = 0;

[P, OK, extrainput] = eega_getoptions(P, varargin);
if ~OK
    error('frqa_plvpwr: Non recognized inputs')
end

[Ne, Ns, Nt] = size(EEG.data);
if isempty(P.condition)
    P.condition = ones(Nt,1);
end
Ncnd = length(unique(P.condition));

%% ------------------------------------------------------------------------
%% Compute
if ~isempty(EEG.data)
    
    fprintf('Computing FFT, power, PLV...\n')
    
    % FFT
    Y = EEG.data;
    Y = Y - repmat(mean(Y,2), [1 Ns 1]); 
    f_res = EEG.srate / Ns;             % resolution (Hz)
    freq  = (0:floor(Ns/2))*f_res;  % frequencies
    Nfrq = length(freq);
    Ydft = fft(Y,Ns,2);
    Ydft = Ydft(:,1:floor(Ns/2)+1,:);
    
    % Power Spectrum per condition
    data_power = nan(Ne,Nfrq,Ncnd);
    for i=1:Ncnd
        ydftavg = nan_mean( Ydft(:,:,P.condition==i), 3); %LB modified nan_mean insted of nanmean
        data_power(:,:,i) = single( ydftavg .* conj(ydftavg) );  % Power Spectrum
    end
    
    % PLV per condition
    data_plv = nan(Ne,Nfrq,Ncnd);
    for i=1:Ncnd
        data_plv(:,:,i) = abs( nan_mean( Ydft(:,:,P.condition==i) ./ abs(Ydft(:,:,P.condition==i)) , 3 ) ); %LB modified nan_mean insted of nanmean
    end
   
    % Power: SNR
    if ~strcmp(P.typeSNRPWR, 'none')
        fprintf('Power SNR %s...\n',P.typeSNRPWR)
        data_power = frqa_powernorm( data_power, freq, 'binsnorm', P.binsSNR,'fband',P.fband,'ftarget',P.ftarget,...
            'typeSNR',P.typeSNRPWR,'noutliers',P.noutSNR);
    end
    
    % PLV: SNR
    if ~strcmp(P.typeSNRPLV, 'none')
        fprintf('PLV SNR %s...\n',P.typeSNRPLV)
        data_plv = frqa_norm( data_plv, freq, 'binsnorm', P.binsSNR,'fband',P.fband,'ftarget',P.ftarget,...
            'typeSNR',P.typeSNRPLV,'noutliers',P.noutSNR,'silent',1);
    end
    
    
    % POWER: Z-score to be sure it is centered at zero
    if P.zscorePWR
        fprintf('Power Z-score...\n')
        data_power = frqa_norm( data_power, freq, 'fband', P.foutput, 'ftarget', P.ftarget,...
            'binsnorm','all','typeSNR','zscore','noutliers',P.noutSNR,'silent',1);
    end
    
    % PLV: Z-score to be sure it is centered at zero
    if P.zscorePLV
        fprintf('PLV Z-score...\n')
        data_plv = frqa_norm( data_plv, freq, 'fband', P.foutput, 'ftarget', P.ftarget,...
            'binsnorm','all','typeSNR','zscore','noutliers',P.noutSNR,'silent',1);
    end
    
    % Keep the freqeuncies in the output frequency range
    if ~isempty(P.foutput)
        idx_freq_out = freq>=P.foutput(1) & freq<=P.foutput(end);
        freq = freq(idx_freq_out);
        data_plv = data_plv(:,idx_freq_out,:);
        data_power = data_power(:,idx_freq_out,:);
    end
    
    fprintf('\n')
else
    fprintf('No data, nothing done\n')
    data_plv = [];
    data_power = [];
    freq = [];
end

%% ------------------------------------------------------------------------
%% Store the data
if isfield(EEG,'filename')
    EEGfrq.filename = EEG.filename;
end
if isfield(EEG,'chaninfo')
    EEGfrq.chaninfo = EEG.chaninfo;
end
if isfield(EEG,'chanlocs')
    EEGfrq.chanlocs = EEG.chanlocs;
end
EEGfrq.srate = EEG.srate;
EEGfrq.freqs = freq;
EEGfrq.pwr = data_power;
EEGfrq.plv = data_plv;
    

end


function [P, OK, extrainput] = eega_getoptions(P, inputs)

if mod(length(inputs),2)==1
    error('eega_getoptions: Optional parameters come by pairs')
end

fP = fieldnames(P);
fV = inputs(1:2:end);
vV = inputs(2:2:end);
fVfP = any(strcmpi(repmat(fV(:),[1 length(fP)]),repmat(fP(:)',[length(fV(:)) 1])),2);
Pop = [];
for i=1:length(fV)
    Pop.(fV{i}) = vV{i};
end
extrainput = {};
j=1;
if ~all(fVfP)
    badinput = find(~fVfP);
    for i=1:length(badinput)
        extrainput{j} = inputs{badinput(i)*2-1};
        extrainput{j+1} = inputs{badinput(i)*2};
        j=j+2;
    end
    OK = 0; 
else
    OK = 1;
end
for f=1:numel(fP)
    if isfield(Pop,fP{f})
        P.(fP{f}) = Pop.(fP{f});
    end
end

end

