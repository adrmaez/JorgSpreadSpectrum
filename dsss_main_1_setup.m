%% DSSS code for MATLAB simulation 

clear; clc; close all; 

%% Constants 
% Constants are defined in the constants.m class file and will be called as
% such: constants.thingToBeCalled 
%% Setup and Parameters 
t = 0:1/constants.fs:1-1/constants.fs; 
phi_BPSK = sin(2*pi*constants.fcBPSK*t); 
phi_DSSS = sin(2*pi*constants.fc*t); % fc is the carrier freq 


%% Transmitter 
dataInput = [1 0 0 1 1 0] % this is the data bits to be transmitted 
% dataInput = randi([0 1], constants.dataLength, 1)'; 

% make the bits into size for adding the PN sequence 
dataSequence = repmat(dataInput, constants.PNlength, 1); 
dataSequence = reshape(dataSequence, 1, []); 

% make the full length array for the BPSK in time 
dataBPSK = repmat(dataInput, constants.fs/length(dataInput), 1); 
dataBPSK = reshape(dataBPSK, 1, []); 

% make the pn code sequence and make it the length for adding 
codeSequence = randi([0 1], constants.PNlength, 1)'; 
codeSequence = repmat(codeSequence, 1, length(dataSequence)./constants.PNlength); 

% add the data and code via XOR 
KSequence = double(xor(dataSequence, codeSequence)); 

% make the full length in time sequence for the DSSS 
dataDSSS = repmat(KSequence, constants.fs/length(KSequence), 1); 
dataDSSS = reshape(dataDSSS, 1, []); 


% normal bpsk modulation 
    y_BPSK = dataBPSK.*phi_BPSK; 
    temp = double(~dataBPSK).*(-phi_BPSK); 
    y_BPSK = y_BPSK + temp; 
    
% DSSS BPSK modulation 
    y_DSSS = dataDSSS.*phi_DSSS; 
    temp = double(~dataDSSS).*(-phi_DSSS); 
    y_DSSS = y_DSSS + temp; 


    
%% Add Impairments 
% add AWGN 
    y_DSSS = y_DSSS + 0*randn(1,length(t)); % gaussian noise to add to signals 
    
% add delay 
delay = 0.1; % seconds % delay before the receiver gets first info 
r_DSSS = zeros(1, length(y_DSSS) + length(y_DSSS).*delay); % r_DSSS is the received signal 
r_DSSS(1,length(y_DSSS)*delay:end-1) = y_DSSS; 

% add AWGN 
    noise = 5*randn(1,length(r_DSSS)); 
    r_DSSS = r_DSSS + noise; % gaussian noise to add to signals 


%% Acquisition 
% make the code sequence full length and change the zeros to -1 
codeSequenceFull = repmat(codeSequence, constants.fs/length(codeSequence), 1); 
codeSequenceFull = reshape(codeSequenceFull, 1, []); 





%ah = reshape(z_DSSS, [], length(KSequence)); % KSequence is the chirp
% % sequence and this uses the correlation over the chirp, not the bit
% % period 
%phi_Vert = reshape(phi_DSSS, [], length(KSequence)); 

%% Receiver 
% make the code sequence full length and change the zeros to -1 
codeSequenceFull = repmat(codeSequence, constants.fs/length(codeSequence), 1); 
codeSequenceFull = reshape(codeSequenceFull, 1, []); 
temp = double(~codeSequenceFull).*(-1); 
codeSequenceFull = codeSequenceFull + temp; % this is used to correlate 

z_DSSS = (-1).*y_DSSS.*codeSequenceFull; % correlate with code sequence 

ah = reshape(z_DSSS, [], length(KSequence)); 
phi_Vert = reshape(phi_DSSS, [], length(KSequence)); 
z = trapz(ah.*phi_Vert) - trapz(ah.*-phi_Vert); % correlatre with basis vectors for BPSK demod

% evaluate threshold for decision 
for i = 1:length(z)
    if (z(1,i) > 0) 
        z(1,i) = 1;  
    else 
        z(1,i) = 0; 
    end 
end 

% turn output z into bits 
z = reshape(z, [], length(dataInput)); 
z = reshape(z(1,:), 1, []) 

%% Freq Domain Analysis 
% take fourier of unspread example 
US_fourier = fft(y_BPSK); 

% take fourier of spread example 
SS_fourier = fft(y_DSSS); 

% take fourier of despread example? 
DeS_fourier = fft(z_DSSS); 

% of noise 
n_fourier = fft(noise); 



%% Plotting 
doPlot = 0; 
if (doPlot == 1)

figure(); 
plot(1:length(US_fourier), abs(US_fourier)); hold on; 
plot(1:length(SS_fourier), abs(SS_fourier)); 
plot(1:length(DeS_fourier), abs(DeS_fourier)); 
plot(1:length(n_fourier), abs(n_fourier)); hold off; 

figure(); plot(1:length(n_fourier), abs(n_fourier)); 

figure(); 
    plot(t,phi_BPSK); hold on; 
    plot(t,phi_DSSS); hold off; 
    
figure(); 
    plot(t, y_BPSK); 
    
figure(); 
    plot(t, y_DSSS); hold on; 
    plot(t,phi_DSSS); hold off; 
    
end 







