function [vDiv, tDiv, offs, sCount, sRate] = determineAcquisitionSettings(connStr, channel)
//Returns the acquisition settings of the Siglent SDS1202X-E oscilloscope.
//
//[vDiv, tDiv, offs, sCount, sRate] = determineAcquisitionSettings(connStr, channel)
//connStr  :  enter VISA USB resourcename 
//            (e.g. 'USB0::0xF4EC::0xEE38::0123456789::INSTR') 
//            or enter the IP address (e.g. '10.0.0.12')
//channel  :  enter 1 for 1st or 2 for 2nd channel
//
//vDiv     :  voltage per devision
//tDiv     :  time    per devision
//offs     :  signal offset
//sCount   :  sample count
//sRate    :  sample rate
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

// generate VISA object depending on the connection type:
[status, defaultRM] = viOpenDefaultRM();
if (strstr(connStr,'USB')) ~= ''
    [status, idDevice] = viOpen(defaultRM, connStr, viGetDefinition("VI_NULL"), viGetDefinition("VI_NULL"));
else
    deviceAddrs = strcat(['TCPIP0::', connStr, '::INSTR']);
    [status, idDevice] = viOpen(defaultRM, deviceAddrs, viGetDefinition("VI_NULL"), viGetDefinition("VI_NULL"));
end

// set response header to OFF:
[status, count] = viWrite(idDevice, "CHDR OFF");

// get acquisition settings:
if channel == 1
    [status, bufferOut] = viRequest(idDevice, "C1:VDIV?");
    vDiv = strtod(bufferOut);
    
    [status, bufferOut] = viRequest(idDevice, "C1:OFST?");
    offs = strtod(bufferOut);
    
    [status, bufferOut] = viRequest(idDevice, "SANU? C1");
    sCount = strtod(bufferOut);
else
    [status, bufferOut] = viRequest(idDevice, "C2:VDIV?");
    vDiv = strtod(bufferOut);
    
    [status, bufferOut] = viRequest(idDevice, "C2:OFST?");
    offs = strtod(bufferOut);
    
    [status, bufferOut] = viRequest(idDevice, "SANU? C2");
    sCount = strtod(bufferOut);
end
[status, bufferOut] = viRequest(idDevice, "TDIV?");
tDiv = strtod(bufferOut);

[status, bufferOut] = viRequest(idDevice, "SARA?");
sRate = strtod(bufferOut);

// close VISA object
viClose(idDevice);
viClose(defaultRM);

endfunction
