function DSSS_demod = myDSSSRx(r_DSSS, codeSequence, phi_DSSS, KSequence, dataInput)
%MYDSSSRX Summary of this function goes here
%   Detailed explanation goes here

% force the received signal input to be the same length as codeSequence 
r_DSSS_temp = r_DSSS; 
r_DSSS = zeros(size(phi_DSSS)); 
r_DSSS = r_DSSS_temp(1:length(phi_DSSS)); 


% make the code sequence full length and change the zeros to -1 
codeSequenceFull = repmat(codeSequence, constants.fs/length(codeSequence), 1); 
codeSequenceFull = reshape(codeSequenceFull, 1, []); 
temp = double(~codeSequenceFull).*(-1); 
codeSequenceFull = (-1)*(codeSequenceFull + temp); % this is used to correlate 

z_DSSS = (-1).*r_DSSS.*codeSequenceFull; % correlate with code sequence 

%ah = reshape(z_DSSS, [], length(KSequence)); % KSequence is the chirp
% % sequence and this uses the correlation over the chirp, not the bit
% % period 
%phi_Vert = reshape(phi_DSSS, [], length(KSequence)); 
ah = reshape(z_DSSS, [], length(dataInput)); % this is for the integrate over bit period 
phi_Vert = reshape(phi_DSSS, [], length(dataInput)); 
z = trapz(ah.*phi_Vert) - trapz(ah.*-phi_Vert); % correlatre with basis vectors for BPSK demod

% evaluate threshold for decision 
for i = 1:length(z)
    if (z(1,i) < 0) 
        z(1,i) = 1;  
    else 
        z(1,i) = 0; 
    end 
end 

% turn output z into bits 
%z = reshape(z, [], length(dataInput)); 
%z = reshape(z(1,:), 1, []); 

DSSS_demod.z = z; 


end

