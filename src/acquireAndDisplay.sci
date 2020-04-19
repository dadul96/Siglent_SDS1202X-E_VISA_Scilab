function acquireAndDisplay(connStr, channel)
//Acquires data from the Siglent SDS1202X-E oscilloscope and plots it.
//
//Dependencies :  - "acquireOscilloscopeData.m"
//                - "determineAcquisitionSettings.m"
//
//acquireAndDisplay(connStr, channel)
//connStr  :  enter VISA USB resourcename 
//            (e.g. 'USB0::0xF4EC::0xEE38::0123456789::INSTR') 
//            or enter the IP address (e.g. '10.0.0.12')
//channel  :  enter 1 for 1st or 2 for 2nd channel
//            or enter 12 for both channels
//
//Version: 0.0.1  |  Date: 18.04.2020  |  Daniel Duller

// define constants:
DEFAULT_IP = '10.0.0.12';
DEFAULT_CHANNEL = 1;

// handle function attributes:
try 
    if isempty(connStr)
        connStr = DEFAULT_IP;
    end
catch
    connStr = DEFAULT_IP;
end
try 
    if isempty(channel)
        channel = DEFAULT_CHANNEL;
    end
catch
    channel = DEFAULT_CHANNEL;
end

// acquire data:
exec('acquireOscilloscopeData.sci');
[timeOut, dataOut] = acquireOscilloscopeData(connStr, channel);

// plot the acquired data:
figure('BackgroundColor', [1,1,1], 'Name', 'Acquired Scope Data');
plot(timeOut, dataOut);
xgrid();
title('Signal in Time Domain', 'fontsize', 4);
xlabel('Time [s]', 'fontsize', 2);
ylabel('Amplitude [V]', 'fontsize', 2);

// display signal properties:
dataLength = length(dataOut);
peak_peak = max(dataOut) - min(dataOut);
pTotal = (1/dataLength(1)) * sum(dataOut.^2);
rmsValue = sqrt(pTotal);
arvValue = (1/dataLength(1)) * sum(abs(dataOut));

mprintf("Minimum:     % f [V] \n", min(dataOut));
mprintf("Maximum:     % f [V] \n", max(dataOut));
mprintf("Peak-Peak:   % f [V] \n", peak_peak);
mprintf("Average:     % f [V] \n", mean(dataOut));
mprintf("RMS:         % f [V] \n", rmsValue);
mprintf("ARV:         % f [V] \n", arvValue);
mprintf("F:           % f     \n", rmsValue/arvValue);
mprintf("C:           % f     \n", abs(max(dataOut))/rmsValue);
mprintf("Total Power: % f [W] \n", pTotal);

endfunction
