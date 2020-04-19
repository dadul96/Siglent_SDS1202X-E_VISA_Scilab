function [timeOut, dataOut, sRate] = acquireOscilloscopeData(connStr, channel)
//Acquires data from the Siglent SDS1202X-E oscilloscope.
//
//Dependencies :  - "determineAcquisitionSettings.m"
//
//[timeOut, dataOut] = acquireOscilloscopeData(connStr, channel)
//connStr  :  enter VISA USB resourcename 
//            (e.g. 'USB0::0xF4EC::0xEE38::0123456789::INSTR') 
//            or enter the IP address (e.g. '10.0.0.12')
//channel  :  enter 1 for 1st or 2 for 2nd channel
//
//timeOut  :  measured time values
//dataOut  :  measured data values
//sRate    :  sample rate
//
//Version: 0.0.1  |  Date: 18.04.2020  |  Daniel Duller

// define constants:
DATA_HEADER_LENGTH = 16;    // bytes
DATA_END_LENGTH = 2;        // bytes
DEFAULT_IP = '10.0.0.12';
DEFAULT_CHANNEL = 1;
TEMP_FILE_NAME = 'temp_data.bin';

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

// determine acquisition settings:
exec('determineAcquisitionSettings.sci');
[vDiv, tDiv, offs, sCount, sRate] = determineAcquisitionSettings(connStr, channel);
INPUT_BUFFER_SIZE = sCount + DATA_HEADER_LENGTH + DATA_END_LENGTH;

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

// acquire raw data:
if channel == 1
    [status, count] = viWrite(idDevice, "C1:WF? DAT2");
else
    [status, count] = viWrite(idDevice, "C2:WF? DAT2");
end
// workaround for reading binary data bigger 255 bytes:
// known issues:    *)USB connection: maximum sample count 7Mpts
//                  *)Ethernet connection: maximum sample count 28kpts
// already tried:   *)viSetBuf(idDevice, 1, INPUT_BUFFER_SIZE);
//                  *)viSetAttribute(idDevice, viGetDefinition("VI_ATTR_TMO_VALUE"), 5000)
[status, count] = viReadToFile(idDevice, 'temp_data.bin', INPUT_BUFFER_SIZE);
hFile=mopen(TEMP_FILE_NAME,'rb');
rawData = mget(count, "c", hFile);
mclose(hFile);
mdelete(TEMP_FILE_NAME);

// close VISA object
viClose(idDevice);
viClose(defaultRM);

// extract measured data:
data = rawData((DATA_HEADER_LENGTH+1):($-DATA_END_LENGTH));

// determine output array size:
outputSize = length(data);

// decode time:
timeOut = zeros(1, outputSize(1));
for i = 1:outputSize(1)
    timeOut(i) = -(tDiv*14/2) + ((i-1)*(1/sRate));
end

// decode raw data:
dataOut = zeros(1, outputSize(1));
for i = 1:outputSize(1)
    if data(i) > 127
        data(i) = data(i) - 255;
    end
    dataOut(i) = data(i)*(vDiv/25)-offs;
end

endfunction
