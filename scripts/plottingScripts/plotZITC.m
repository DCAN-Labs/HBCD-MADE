function plotZITC(zscorePLV, freqvals, locsfile)
% plotZITC  Plot Z-scored ITC for a single subject.
%
% INPUTS
%   zscorePLV  - nChannels x nFreqs matrix (output of computeSubjectITC)
%   freqvals   - 1 x nFreqs frequency vector (EEGfrq_true.freqs)
%   locsfile   - path to channel locations file (.locs or .sfp)

freqIdx     = freqvals <= 5;
meanZITC    = mean(zscorePLV, 1, 'omitnan');

[~, WordFreq]     = min(abs(freqvals - 1.1111));
[~, SyllableFreq] = min(abs(freqvals - 3.3333));

% --- Frequency spectrum ---
figure;
plot(freqvals(freqIdx), meanZITC(freqIdx), 'r');
xline(1.111, '--'); xline(2.222, '--'); xline(3.333, '--');
yline(0, 'k-', 'LineWidth', 1);
ylabel('ZITC'); xlabel('Frequency (Hz)');

% --- Topoplots at word and syllable frequency ---
figure;
subplot(1,2,1);
topoplot(zscorePLV(:, WordFreq), locsfile, 'style', 'map', 'colormap', jet, ...
    'maplimits', [-1 1], 'shading', 'interp'); colorbar;
title('ZITC Word Freq (1.11 Hz)');

subplot(1,2,2);
topoplot(zscorePLV(:, SyllableFreq), locsfile, 'style', 'map', 'colormap', jet, ...
    'maplimits', [-8 8], 'shading', 'interp'); colorbar;
title('ZITC Syllable Freq (3.33 Hz)');

end
