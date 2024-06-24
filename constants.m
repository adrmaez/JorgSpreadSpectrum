classdef constants
    properties(Constant = true)
        PNlength = 20; % length of the pseudo random sequence for spreading code 
        
        dataLength = 6; % leave on 6 for now 
        chipRate = constants.PNlength*constants.dataLength; % number of chips per second 
        
        
        overSample = 23; % % the oversampling factor, needs to be >2 
        sps = 2*constants.overSample; % % samples per symbol, *not sure why the times 2 
        fs = constants.chipRate*constants.sps; % Hz % the sampling frequency 
        
        fc = constants.chipRate; % hz % the carrier frequency for the PSK wave 
        
    end
end

