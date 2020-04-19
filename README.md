# Siglent_SDS1202X-E_VISA_Scilab
Scilab 6.0.2 functions for easy, data acquisition from the Siglent SDS1202X-E oscilloscope via USB or Ethernet. **The input-buffer size automatically scales depending on the oscilloscope's sampling settings!**

### Supported models
- SDS1xxxCFL - series
- SDS1xxxA - series
- SDS1xxxCML+/CNL+/DL+/E+/F+ - series
- SDS2xxx/2xxxX - series
- SDS1xxxX/1xxxX+ - series
- SDS1xxxX-E/X-C - series

### Known issues
* Since Scilab 6.0.2 and Visa Toolbox 0.9.1 don't support a single stream of binary data, a temporary workaround has to be used. 
  This workaround somehow limits the sample count to:
    * USB connection: 7Mpts
    * Ethernet connection: 28kpts

### Installation
There is no installation required. Just download the Scilab files (\*.sci-files from [Releases](https://github.com/dadul96/Siglent_SDS1202X-E_VISA_Scilab/releases)) and move them into your work folder.

### Requirements
* [NI-VISA 19.5](https://www.ni.com/en-us/support/downloads/drivers/download.ni-visa.html#329456)
* [Scilab 6.0.2](https://www.scilab.org/)
* [VISA Toolbox 0.9.1](https://atoms.scilab.org/toolboxes/visa/0.9.1)

### How to use
Following functions can be called:
* **[vDiv, tDiv, offs, sCount, sRate] = determineAcquisitionSettings(connStr, channel)**
    - **vDiv** - Volts/Devition
    - **tDiv** - Time/Devition
    - **offs** - Vertical offset
    - **sCount** - Number of samples
    - **sRate** - Sampling rate
    - **connStr** - Enter VISA USB resourcename (e.g. `'USB0::0xF4EC::0xEE38::0123456789::INSTR'`) or enter the IP address (e.g. `'10.0.0.12'`). If you don't enter anything or just `''` the IP address stored in the DEFAULT_IP-variable will be used.
    - **channel** - Enter the oscilloscope channel (e.g. `1`). If you don't enter anything or just `''` the channel stored in the DEFAULT_CHANNEL-variable will be used.
* **[timeOut, dataOut, sRate] = acquireOscilloscopeData(connStr, channel)** (uses `determineAcquisitionSettings`)
    - **timeOut** - Array containing the time axis
    - **dataOut** - Array containing the meassured data
    - **sRate** - Sampling rate
    - **connStr** - Same as in the functions above.
    - **channel** - Same as in the functions above.
* **acquireAndDisplay(connStr, channel)** (uses `acquireOscilloscopeData`)
    - Plots the acquired data into a new figure. Besides that, it returns the most important signal properties to the command window (see example below).
    - **connStr** - Same as in the functions above.
    - **channel** - Same as in the functions above.

### Example
#### Screenshot of the signal displayed on the oscilloscope:
![](/pictures/scope_screenshot.png)
#### Screenshot of the Scilab command window:
![](/pictures/acquireAndDisplay_properties_screenshot.png)
#### Screenshot of the plotted data:
![](/pictures/acquireAndDisplay_plot_screenshot.png)

### Author
**Daniel Duller** - [dadul96](https://github.com/dadul96)

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
