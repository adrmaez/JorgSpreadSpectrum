%% DSSS code for MATLAB simulation 

clear; clc; close all; 

%% Constants 
% Constants are defined in the constants.m class file and will be called as
% such: constants.thingToBeCalled 
%% Setup and Parameters 
t = 0:1/constants.fs:1-1/constants.fs; 
phi_BPSK = sin(2*pi*constants.fc*t); 
phi_DSSS = sin(2*pi*constants.fc*t*constants.PNlength); 


dataInput = [1 0 0 1 1 0] % this is the data bits to be transmitted 



%% Transmitter 
% Use function and fill in the other's using output struct   
DSSS_Trans = myDSSSTx(dataInput, phi_DSSS); 
    y_DSSS = DSSS_Trans.y_DSSS; 
    codeSequence = DSSS_Trans.codeSequence; 
    KSequence = DSSS_Trans.KSequence; 
    
%% Add Impairments 
% add AWGN 
    y_DSSS = y_DSSS + 0.1*randn(1,length(t)); % gaussian noise to add to signals 
    
% add delay 
delay = 0.5; % seconds % delay before the receiver gets first info 
r_DSSS = zeros(1, length(y_DSSS) + length(y_DSSS).*delay); 
r_DSSS(1,length(y_DSSS)*delay:end-1) = y_DSSS; 

% add AWGN 
    r_DSSS = r_DSSS + 10*randn(1,length(r_DSSS)); % gaussian noise to add to signals 
    
%% Freq Domain Analysis 







%% Synchronization 







%% Receiver 
% Use function to demodulate the received signal 
DSSS_demod = myDSSSRx(y_DSSS,codeSequence, phi_DSSS, KSequence, dataInput); 

z = DSSS_demod.z; 
z


% %% Plotting 
% figure(); 
%     plot(t,phi_BPSK); hold on; 
%     plot(t,phi_DSSS); hold off; 
%         
% figure(); 
%     plot(t, y_DSSS); hold on; 
%     plot(t,phi_DSSS); hold off; 
%     








