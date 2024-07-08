classdef constants
    properties(Constant = true)
        PNlength = 10; % length of the pseudo random sequence for spreading code 
        % !!! currently leave as 10 until myDSSSTx function can handle
        % different sizes using constants.PNlength 
        
        dataLength = 6; % leave on 6 for now 
        chipRate = constants.PNlength*constants.dataLength; % number of chips per second 
        
        
        periodsPerSymbol = 3; 
        


        overSample = 23; % % the oversampling factor, needs to be >2 
        sps = 5*constants.overSample; % % samples per symbol, *not sure why the times 2 
        %fs = constants.chipRate*constants.sps; % Hz % the sampling frequency 
        fs = 9000; 

        fcBPSK = constants.periodsPerSymbol*constants.dataLength; % hz % the carrier frequency for the PSK wave 
        
        fc = 2000; % Hz % the carrier frequency 

    end
end

