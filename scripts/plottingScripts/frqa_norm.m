% This functions computes the SNR based on adjacent frequency bins 
%
% INPUTS
%   PS      input data (channels, frequecies, trials)
%   freq    second dimention values for the data (frequecies)
% OPTIONAL INPUTS:
%   fband       range of frequecies to use for the normalization (SNR)
%               If not proveded all are used. Default []
%   ftarget     frequencies to exclude to compute the SNR for other
%               freqency bins. Default []
%   noutliers   when computing SNR exclude outliers bigger than noutSNR*std
%               Default 2
%   binsnorm    bins to use for the normlaization. Indexes around each 
%               frequnecy bin or 'all'. Default [-5 -4 -3 -2 -1 1 2 3 4 5 ]
%   typeSNR     type of SNR correction. 'zscore' 'mean' 'linear'. 
%               Default 'zscore'
%
% OUTPUTS
%   PSn         SNR corrected data
%
% Usage e.g.
% 
%   PSn = frqa_plvpwr(PS, freq, 'fband', [0.2 15], 'typeSNR','linear',...
%               'binsnorm',[-4 -3 -2 2 3 4]) 
%
% Ana Flo, February 2021, NeuroSpin, CEA



function [ PSn ] = frqa_norm( PS , freq, varargin )

%% ------------------------------------------------------------------------
%% Parameters

% Default parameters
P.fband = [];
P.ftarget = [];
P.noutliers = 2.0;  
P.binsnorm = [(-5:-1) (1:5)];
P.typeSNR = 'zscore';
P.silent = 0;

[P, OK, extrainput] = eega_getoptions(P, varargin);
if ~OK
    error('frqa_norm: Non recognized inputs')
end

if isempty(P.fband)
    P.fband =[freq(1) freq(end)];
end

if ischar(P.binsnorm) && strcmp(P.binsnorm,'all')
    doall = 1;
else
    doall = 0;
end
%% ------------------------------------------------------------------------
%% Normalize the data

if ~P.silent
    fprintf(sprintf('Normalization\n'))
end

% find the indexes of the target frequencies to exclude
idxftarget=nan(1,length(P.ftarget));
for i=1:length(P.ftarget)
    [~,idxftarget(i)]=min(abs(freq-P.ftarget(i)));
end
ftarget=freq(idxftarget);

% find the indexes of the frequencies for normalization
f_idx = (freq>=P.fband(1)) & (freq<=P.fband(end)) & ~ismember(freq, ftarget);

% normalize
PSn = nan(size(PS));
if doall
    switch P.typeSNR
        case 'zscore'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    f_idx_f = f_idx;
                    y = PS(el,f_idx_f,i);
                    y = y(:);
                    y = removeoutliers(y, P.noutliers);
                    mu = nanmean(y);
                    sd = nanstd(y);
                    PSn(el,:,i) = (PS(el,:,i) - mu) / sd;
                end
            end
        case 'mean'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    f_idx_f = f_idx;
                    y = PS(el,f_idx_f,i);
                    y = y(:);
                    y = removeoutliers(y, P.noutliers);
                    mu = nanmean(y);
                    PSn(el,:,i) = (PS(el,:,i) - mu);
                end
            end
        case 'linear'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    f_idx_f = f_idx;
                    x = freq(f_idx_f);
                    x = x(:);
                    y = PS(el,f_idx_f,i);
                    y = y(:);
                    [x, y] = removeoutlierslfit(x, y, P.noutliers);
                    p = polyfit(x,y,1);
                    Y = polyval(p,freq);
                    PSn(el,:,i) = PS(el,:,i) - Y;
                end
            end
        case 'linearzscore'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    f_idx_f = f_idx;
                    x = freq(f_idx_f);
                    x = x(:);
                    y = PS(el,f_idx_f,i);
                    y = y(:);
                    [x, y] = removeoutlierslfit(x, y, P.noutliers);
                    p = polyfit(x,y,1);
                    Y = polyval(p,freq);
                    noise = std(PS(el,:,i) - Y);
                    PSn(el,:,i) = (PS(el,:,i) - Y) ./ noise;
                end
            end
    end
else
    switch P.typeSNR
        case 'zscore'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    for f=1:length(freq)
                        binsnorm = findbinsnorm(freq, P.binsnorm, f);
                        f_idx_f = binsnorm & freq~=freq(f) & f_idx;
                        if sum(f_idx_f)>2
                            y = PS(el,f_idx_f,i);
                            y = y(:);
                            y = removeoutliers(y, P.noutliers);
                            mu = nanmean(y);
                            sd = nanstd(y);
                            PSn(el,f,i) = (PS(el,f,i) - mu) / sd;
                        end
                    end
                end
            end
        case 'mean'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    for f=1:length(freq)
                        binsnorm = findbinsnorm(freq, P.binsnorm, f);
                        f_idx_f = binsnorm & freq~=freq(f) & f_idx;
                        if sum(f_idx_f)>2
                            y = PS(el,f_idx_f,i);
                            y = y(:);
                            y = removeoutliers(y, P.noutliers);
                            mu = nanmean(y);
                            PSn(el,f,i) = (PS(el,f,i) - mu);
                        end
                    end
                end
            end
        case 'linear'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    for f=1:length(freq)
                        binsnorm = findbinsnorm(freq, P.binsnorm, f);
                        f_idx_f = binsnorm & freq~=freq(f) & f_idx;
                        if sum(f_idx_f)>2
                            x = freq(f_idx_f);
                            x = x(:);
                            y = PS(el,f_idx_f,i);
                            y = y(:);
                            [x, y] = removeoutlierslfit(x, y, P.noutliers);
                            p = polyfit(x,y,1);
                            Y = polyval(p,freq(f));
                            PSn(el,f,i) = PS(el,f,i) - Y;
                        end
                    end
                end
            end
        case 'linearzscore'
            for i=1:size(PS,3)
                for el=1:size(PS,1)
                    for f=1:length(freq)
                        binsnorm = findbinsnorm(freq, P.binsnorm, f);
                        f_idx_f = binsnorm & freq~=freq(f) & f_idx;
                        if sum(f_idx_f)>2
                            x = freq(f_idx_f);
                            x = x(:);
                            y = PS(el,f_idx_f,i);
                            y = y(:);
                            [x, y] = removeoutlierslfit(x, y, P.noutliers);
                            p = polyfit(x,y,1);
                            Yf = polyval(p,freq(f));
                            Y = polyval(p,freq(f_idx_f));
                            noise = std(PS(el,f_idx_f,i) - Y);
                            PSn(el,f,i) = (PS(el,f,i) - Yf) / noise;
                        end
                    end
                end
            end
    end
end

if ~P.silent; fprintf('\n'); end

end

function binsnorm = findbinsnorm(freq, nbins, f)
binsnorm = zeros(size(freq));
idxbinsnorm = nbins + f;
idxbinsnorm(idxbinsnorm<1)=[];
idxbinsnorm(idxbinsnorm>length(freq))=[];
binsup = idxbinsnorm>f;
binsdown = idxbinsnorm<f;
if sum(binsup)~=sum(binsdown)
    if sum(binsdown)==0
        if length(idxbinsnorm)>1
            idxbinsnorm = idxbinsnorm(1:2);
        end
    elseif sum(binsup)==0
        if length(idxbinsnorm)>1
            idxbinsnorm = idxbinsnorm(end-1:end);
        end
    elseif sum(binsup)<sum(binsdown)
        n = sum(binsup);
        idxbinsnorm(1:sum(binsdown)-n) = [];
    elseif sum(binsup)>sum(binsdown)
        n = sum(binsdown);
        idxbinsnorm(2*n+1:end) = [];
    end
end
binsnorm(idxbinsnorm) = 1;

end

function [y] = removeoutliers(y, n)

mu = mean(y);
sigma = std(y);
thrs = [mu-n*sigma mu+n*sigma];

idx = y<thrs(1)  | y>thrs(2);
y = y(~idx);

end

function [x, y] = removeoutliers2(x, y, n)

mu = mean(y);
sigma = std(y);
thrs = [mu-n*sigma mu+n*sigma];

idx = y<thrs(1)  | y>thrs(2);
y = y(~idx);
x = x(~idx);

end

function [x, y] = removeoutlierslfit(x, y, n)

p = polyfit(x,y,1);
Y = polyval(p,x);
res = Y-y;

mu = mean(res);
sigma = std(res);
thrs = [mu-n*sigma mu+n*sigma];

idx = res<thrs(1)  | res>thrs(2);
y = y(~idx);
x = x(~idx);

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
