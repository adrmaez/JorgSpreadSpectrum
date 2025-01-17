%% DSSS code for MATLAB simulation 

clear; clc; close all; 

%% Constants 
% Constants are defined in the constants.m class file and will be called as
% such: constants.thingToBeCalled 
%% Setup and Parameters 
t = 0:1/constants.fs:1-1/constants.fs; 
phi_BPSK = sin(2*pi*constants.fcBPSK*t); 
phi_DSSS = sin(2*pi*constants.fc*t); 


dataInput = [1 0 0 1 1 0] % this is the data bits to be transmitted 

%% Transmitter 
% Use function and fill in the other's using output struct   
DSSS_Trans = myDSSSTx(dataInput, phi_DSSS, 0); % the last argument is 1 for 
                                               % random sequence of length
                                               % PNlength and 0 for not 
    y_DSSS = DSSS_Trans.y_DSSS; 
    codeSequence = DSSS_Trans.codeSequence; 
    KSequence = DSSS_Trans.KSequence; 
    
%% Add Impairments 
% add AWGN 
    y_DSSS = y_DSSS + 0*randn(1,length(t)); % gaussian noise to add to signals 
    
% add delay 
delay = 0.1; % seconds % delay before the receiver gets first info 
r_DSSS = zeros(1, length(y_DSSS) + length(y_DSSS).*delay); 
r_DSSS(1,length(y_DSSS)*delay:end-1) = y_DSSS; 
%r_DSSS = y_DSSS; 

% add AWGN 
    r_DSSS = r_DSSS + 0.001*randn(1,length(r_DSSS)); % gaussian noise to add to signals 
    


%% ~~~~ Receiver ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Carrier Removal 
    % will add carrier recovery later to deal with freq offset and phase 
% multiply received signal with carrier fc 
t_local = 0:1/constants.fs:(1+delay)-1/constants.fs; 
local_carrier = sin(2*pi*constants.fc*t_local); 
r_base = r_DSSS.*local_carrier; 

% grabbing some spectra for comparison things 
        phi_fourier = fft(phi_BPSK); 
        phiDSSS_fourier = fft(phi_DSSS); 
        received_fourier = fft(r_DSSS); 
        received_Carrier_fourier = fft(r_base); 

% use lowpass filter to filter out the higher frequency 
r_base_filtered = lowpass(r_base, constants.fc, constants.fs, ImpulseResponse="iir",Steepness=0.5); 
    r_filt_fourier = fft(r_base_filtered); 


%% Synchronization - Acquisition 
% make the code sequence full length and change the zeros to -1's 
codeSequenceFull = repmat(codeSequence, constants.fs/length(codeSequence), 1); 
codeSequenceFull = reshape(codeSequenceFull, 1, []); 
temp = double(~codeSequenceFull).*(-1); 
codeSequenceFull = (-1)*(codeSequenceFull + temp); % this is used to correlate 

%[correl_r_c, r_c_synced, correlSave, offsetFound] = AcquireDSSS(r_base_filtered, codeSequenceFull, delay); 

lam = 25; % lambda % corresponds to # of chips in PN sequence 
    % this lambda will determine how many half chip sets can be checked for
    % correlation 
Tc = 1/(constants.chipRate); % period of chip 

% received signal mult by code sequence for lambda # of chips 
n = 0; 
step = 0.5*(Tc*constants.fs); % make sure this is an integer 
for i = 1:step:(length(r_base_filtered) - lam*Tc*constants.fs)
n = n + 1; 
    r_c = r_base_filtered(i:i + lam*Tc*constants.fs - 1).*codeSequenceFull(1:lam*Tc*constants.fs); 
        figure(1); 
           plot(t_local, r_base_filtered); hold on; 
           %codeCompare = zeros(1,length(i:length(t_local))); 
           %codeCompare(i:length(codeSequenceFull)) = codeSequenceFull(1:length(codeSequenceFull)-i+1); 
           %plot(t_local(i:end), codeCompare); hold off; 
           plot(t_local(i:i + length(r_c) - 1), r_c); hold off; 

    correl_r_c = (trapz(r_c)).^2; 
        correlSave(1,n) = correl_r_c; 
        offsetFoundSave(1,n) = i; 
    if (correl_r_c >  4000) 
        offsetFoundFirst = i; 
        break
    end 
    
end 
    offsetFound = offsetFoundSave(1, find(correlSave == max(correlSave))); 

% this is a test 
% lam = 60; 
%     r_c_synced = r_base_filtered(length(codeSequenceFull)*delay:length(r_base_filtered)-1).*codeSequenceFull; 
%     zDemod_syncTest = lowpass(r_c_synced, 10, constants.fs, ImpulseResponse="iir",Steepness=0.8); 




r_DSSS_Acquired = zeros(1,length(codeSequenceFull)); 
r_DSSS_Acquired = r_base_filtered(1,offsetFoundFirst:end); 

%% Synchronization - Tracking 


%% Demodulation 
% Use function to demodulate the received signal 
    % this function is currently doing the code correlation and BPSK demod 
DSSS_demod = myDSSSRx(r_DSSS_Acquired,codeSequence, phi_DSSS, KSequence, dataInput); 

z = DSSS_demod.z; 
z

receive_correl_Ex = r_DSSS_Acquired.*codeSequenceFull; 
    demod_fourier = fft(receive_correl_Ex); 



%% Plotting 
figure(); % this will require the corresponding spectra to be uncommented as well 
subplot(3,2,1); 
    plot((0:length(received_fourier)-1)*constants.fs/(length(received_fourier)-1), abs(received_fourier)); 
    title('Original Received Spectrum'); 
subplot(3,2,2); 
    plot((0:length(received_Carrier_fourier)-1)*constants.fs/(length(received_Carrier_fourier)-1), abs(received_Carrier_fourier)); 
    title('Received*Carrier Spectrum'); 
subplot(3,2,3); 
    plot((0:length(r_filt_fourier)-1)*constants.fs/(length(r_filt_fourier)-1), abs(r_filt_fourier)); 
    title('Carrier Removed/Lowpass Filtered'); 
subplot(3,2,4); 
    plot(1:length(phiDSSS_fourier), abs(phiDSSS_fourier)); 
    title('Carrier Spectrum'); 
subplot(3,2,5); 
    plot(1:length(demod_fourier), abs(demod_fourier)); 
        title('Demodulated Signal Spectrum'); 
subplot(3,2,6); 
    

% figure(); 
%     plot(t,phi_BPSK); hold on; 
%     plot(t,phi_DSSS); hold off; 
%         
% figure(); 
%     plot(t, y_DSSS); hold on; 
%     plot(t,phi_DSSS); hold off; 
%     

figure(); 
subplot(1,2,1); 
    plot(t_local, r_DSSS); 
    xticks(0:0.1:1.1); 
    xlabel('Time (s)'); 
    title('Received Signal'); 
subplot(1,2,2); 
    plot(t_local,r_DSSS); 
    title('Received Signal Zoomed In'); 
    xlim([delay-0.01 delay+0.01]); 
    ylim([-1.5 1.5]); 


figure(); 
    plot(t_local, r_base_filtered+0.5); 
    hold on; 
    ylim([-1 1]);
        %plot(t(1:length(r_c_synced)), r_c_synced); plot(t,zDemod_syncTest); 
        %plot(t_local, r_DSSS); 
    plot(t(1:length(r_DSSS_Acquired)), r_DSSS_Acquired); 
    plot(t, receive_correl_Ex-0.5); 
    legend('Received w/ Carrier Removed', 'Received and Acquired', 'Acquired and Correlated'); 
    xticks(0:0.1:1.1); 
    xlabel('Time (s)'); 
    hold off; 






