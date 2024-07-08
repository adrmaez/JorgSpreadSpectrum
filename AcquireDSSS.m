function [correl_r_c, r_c_synced, correlSave, offsetFound] = AcquireDSSS(r_DSSS, codeSequenceFull, delay)
%ACQUIREDSSS Summary of this function goes here
%   Detailed explanation goes here

lam = 20; % lambda % corresponds to # of chips in PN sequence 
    % this lambda will determine how many half chip sets can be checked for
    % correlation 
Tc = 1/(constants.chipRate); % period of chip 

% received signal mult by code sequence for lambda # of chips 
n = 0; 
step = 0.5*(Tc*constants.fs + 1); % plus one needed to make it integer 
for i = 1:step:length(r_DSSS) - lam*Tc*constants.fs
n = n + 1; 
    r_c = r_DSSS(i:i + lam*Tc*constants.fs - 1).*codeSequenceFull(1:lam*Tc*constants.fs); 
    correl_r_c = trapz(r_c); 
    correlSave(1,n) = correl_r_c;
    if (correl_r_c >  200)
        offsetFound = i; 
    end 
end 

lam = 60; 
    r_c_synced = r_DSSS(length(codeSequenceFull)*delay:lam*Tc*constants.fs).*codeSequenceFull(1:end-length(codeSequenceFull)*delay+1); 






%     lam = 0.5; % lambda for how much of a chip to do integral of 
%     Tc = 1/(constants.chipRate); % period of chip 
%     thres = 1; 
% 
% for i = 1:Tc:length(r_base_filtered) % loop goes thru the received signal with the code 
%     r_c_mixed = r_base_filtered((i:i + lam*constants.fs/Tc - 1)).*codeSequenceFull((i:i + lam*constants.fs/Tc - 1)); 
%     integ = trapz(r_c_mixed); 
%     if (integ > thres) 
%         acquire1 = 1; 
%         continue 
%     end 
%     if (acquire1 == 1) && (integ > thres) 
%         break 
%     end 
% end 


end

