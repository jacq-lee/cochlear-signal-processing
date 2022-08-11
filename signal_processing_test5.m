clear all;
clear clc;
close all;

sound1 = 'BME 252 Phase 1 Audio Files\1.mp3';
exportFileName = 'sound1Export.wav';
resampledFrequency = 16e3;

numChannels = 20;

[y, Fs] = phase1(sound1, exportFileName, resampledFrequency);

[lowCutOff, highCutOff, rectified] = phase2(y, numChannels);

phase3(rectified, lowCutOff, highCutOff, numChannels);

function [yMonoResampled, Fs] = phase1(soundClip, newFile, rFs)
%%
    [y, Fs] = audioread(soundClip);
    
    info = audioinfo(soundClip);
%%
    % 3.2
    [~, n] = size(y);

    if n == 2
        yMono = sum(y, 2) / size(y, 2);
    else
        yMono = y;
    end
%%
    %3.3
%     sound(yMono, Fs);
%%
    %3.4
    audiowrite(newFile, yMono, Fs);
%% 
    %3.5
    plot(yMono);
    title('Sound Waveform');
    xlabel('Sample Number');
    ylabel('Amplitude');
%%
    %3.6
    [P, Q] = rat(rFs/Fs);

    yMonoResampled = resample(yMono, P, Q);

%     sound(yMonoResampled, rFs);

%% 
    % 3.7
    [m, ~] = size(yMonoResampled);

    t = 0:info.Duration/m:info.Duration-1;
    x = cos(t*2*pi*1000);
 
%     sound(x, 1000);

    tShort = 0:info.Duration/m:1/500;
    xShort = cos(tShort*2*pi*1000);

    figure;
    plot(tShort, xShort);
    title('Cosine Function Signal (Two Periods)');
    xlabel('Time (s)');
    ylabel('Amplitude');
%%
end

function [lowPassFreq, highPassFreq, rectifiedSignal] = phase2(soundClip, nChannels)
    clear sound

    %4
%     lowPassFreq =  [188, 313, 438, 563, 688, 813, 938, 1063, 1188, 1313, 1563, 1813, 2063, 1313, 2688, 3063, 3563, 4063, 4688, 5313, 6063, 6938];
%     highPassFreq = [313, 438, 563, 688, 813, 938, 1063, 1188, 1313, 1563, 1813, 2063, 1313, 2688, 3036, 3563, 4063, 4688, 5313, 6063, 6938, 7938];

    lowPassFreq = [125, 225, 325, 420, 530, 655, 790, 940, 1105, 1285, 1505, 1745, 2005, 2345, 2705, 3145, 3705, 4255, 4815, 5385];
    highPassFreq = [175, 275, 375, 480, 605, 745, 890, 1060, 1235, 1455, 1695, 1955, 2295, 2655, 3095, 3655, 4205, 4765, 5335, 5915];

    %5
    soundClipLength = length(soundClip);
    filteredSignal = zeros(soundClipLength, nChannels);

    for j = 1:1:nChannels
        filteredSignal(:,j) = filter( bandpassFilter( lowPassFreq(j), highPassFreq(j) ), soundClip);
    end

    %6
    figure;
    plot(filteredSignal(:,1));
    title('Phase 2: Lowest and Highest Frequency Channels');
    xlabel('Sample Number');
    ylabel('Amplitude');
    hold on

    plot(filteredSignal(:,nChannels));
    legend('Lowest', 'Highest')
    hold off
%% 
    %7
    rectifiedSignal = abs(filteredSignal);   

    %8
    rectifiedEnvelope = zeros(soundClipLength, nChannels);

    for k = 1:1:nChannels
        rectifiedEnvelope(:,k) = filter(lowpassFilter, rectifiedSignal(:,k));
    end
   
    %9
    figure;
    plot(rectifiedEnvelope(:,1));
    title('Phase 2: Rectified Envelope');
    xlabel('Sample Number');
    ylabel('Amplitude');
    hold on

    plot(rectifiedEnvelope(:,nChannels));
    legend('Lowest Frequency Channel', 'Highest Frequency Channel')
    hold off
end

function phase3(rectifiedSignal, lowCutOff, highCutOff, nChannels)

    centerFreq = zeros(1, nChannels);

    for n = 1:1:nChannels
        centerFreq(n) = sqrt(lowCutOff(n).*highCutOff(n));
    end

    cosFunctions = zeros(1, nChannels);

    [numRows, ~] = size(rectifiedSignal);

    for m = 1:1:nChannels
        cosFunctions(m) = cos(numRows*2*pi*centerFreq(n));
    end

    for k = 1:1:nChannels
        ampModulated(:, k) = ammod(rectifiedSignal(:,k), centerFreq(k), 16000);
    end

    outputSignal = ampModulated(:,1);

    for j = 2:1:nChannels
        outputSignal = outputSignal + ampModulated(:, j);
    end

    outputSignal = outputSignal/max(abs(outputSignal));

%     sound(outputSignal);

    audiowrite('Output_Signal_test5.wav', outputSignal, 16000);

end


function Hd = bandpassFilter(Freqpass1, Freqpass2)
    %FILTERATTEMPT2 Returns a discrete-time filter object.
    
    % MATLAB Code
    % Generated by MATLAB(R) 9.12 and Signal Processing Toolbox 9.0.
    % Generated on: 10-Jul-2022 21:31:06
    
    % Equiripple Bandpass filter designed using the FIRPM function.
    
    % All frequency values are normalized to 1.
    
    fs = 16000;

    nyquistFreq = fs/2;

    stopRange = (Freqpass1/nyquistFreq)*0.2;    

    Fpass1 = Freqpass1/nyquistFreq;         % First Passband Frequency
    Fpass2 = Freqpass2/nyquistFreq;         % Second Passband Frequency
    Fstop1 = Fpass1 - stopRange;            % First Stopband Frequency
    Fstop2 = Fpass2 + stopRange;            % Second Stopband Frequency
    Dstop1 = 0.001;                         % First Stopband Attenuation
    Dpass  = 0.057501127785;                % Passband Ripple
    Dstop2 = 0.0001;                        % Second Stopband Attenuation
    dens   = 20;                            % Density Factor
    
    % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2], [0 1 0], ...
                              [Dstop1 Dpass Dstop2]);
    
    % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
    
    % [EOF]
end

function Hd = lowpassFilter
    %LOWPASS Returns a discrete-time filter object.
    
    % MATLAB Code
    % Generated by MATLAB(R) 9.12 and Signal Processing Toolbox 9.0.
    % Generated on: 16-Jul-2022 12:12:52
    
    % Equiripple Lowpass filter designed using the FIRPM function.
    
    % All frequency values are normalized to 1.
    
    Fpass = 0.05;           % Passband Frequency
    Fstop = 0.0625;         % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
    
    % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop], [1 0], [Dpass, Dstop]);
    
    % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
    
    % [EOF]
end
