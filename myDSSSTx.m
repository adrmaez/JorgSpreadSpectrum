function DSSS_Trans = myDSSSTx(dataInput, phi_DSSS, randomYN)
%MYDSSSTX Summary of this function goes here
%   Detailed explanation goes here

% make the bits into size for adding the PN sequence 
dataSequence = repmat(dataInput, constants.PNlength, 1); 
dataSequence = reshape(dataSequence, 1, []); 

% make the pn code sequence and make it the length for adding 
if (randomYN == 1)
    codeSequence = randi([0 1], constants.PNlength, 1)'; 
else 
    codeSequence = [1 0 1 0 0 1 1 0 1 0]; 
end 
codeSequence = repmat(codeSequence, 1, length(dataSequence)./constants.PNlength); 

% add the data and code via XOR 
KSequence = double(xor(dataSequence, codeSequence)); 

% make the full length in time sequence for the DSSS 
dataDSSS = repmat(KSequence, constants.fs/length(KSequence), 1); 
dataDSSS = reshape(dataDSSS, 1, []); 

% DSSS BPSK modulation 
    y_DSSS = dataDSSS.*phi_DSSS; 
    temp = double(~dataDSSS).*(-phi_DSSS); 
    y_DSSS = y_DSSS + temp; 

% Save everything to output Structure 
    DSSS_Trans.y_DSSS = y_DSSS; 
    DSSS_Trans.codeSequence = codeSequence; 
    DSSS_Trans.KSequence = KSequence; 

end

