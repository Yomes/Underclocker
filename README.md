# Underclocker  
Script to reduce CPU frequencies when temperature is too high  
I have a problem with my computer: it gets very hot. I've already done all the normal things: cleaning, changing the thermal paste (a quality one), adjusting the fan speed... But nothing: when I do something that requires power, it goes up to 90-98°C. It's designed this way: this processor has a "normal" working temperature of 95°C and a critical temperature of 105°C. "Throttle" was set by the manufacturer in the BIOS and cannot be modified. But I don't like it: it can damage other components.  
So... I got to work.  
  
CAUTION! CAUTION! BE CAREFUL!  
This is a work in progress, it's not finished. I've tested it on very few computers and I'm not responsible for any damage it may cause. I recommend running it on test computers, always under supervision.  
Note: As far as I know, it can't be used in virtual machines: they don't have sensors.  
  
I've written a script that measures the temperature of all cores every second:  
* If it goes above a certain value, it lowers the core's maximum frequency by a certain amount of MHz proportional to the current temperature and the desired temperature (to react quickly to heat spikes).  
* If it falls below another value, it raises the frequency slightly.  
For each frequency change, it waits 5 seconds for the heatsink to react and then repeats the cycle. Thus, the temperature eventually stabilizes at the desired value in a matter of seconds (10, 30, etc., depending on the number of "jumps" it must do), and it adapts to the needs of the moment.  
  
The script can generate a log with the frequency and temperature changes in a file and/or display notifications on the desktop, as well as via standard output (terminal, if it's running from one). The user can set the path and maximum length of the log.  
Additionally, it can be left running indefinitely (ideal for running as a auto-executable script) or a time period can be set (for stress and performance tests), as well as a delay.  
The script has rudimentary language support. It reads the output of _locale_ and uses a list of phrases in the matching language. English is the default. **You can contribute by adding languages**  
Reads the temperature of nVidia graphics cards (tested only with a GTX 950M, with proprietary drivers). It checks if nvidia-smi exists and runs without errors; otherwise, it will not attempt to read GPU temperatures. **Partial support:** It only reads the temperature to add it to the log; it cannot modify GPU frequencies; it has not been tested with free drivers, or with very new or very old graphics cards.  
When execution terminates (SIGINT signal, for example with Ctrl+C), it displays a message with the maximum temperature reached and restores the default maximum frequency.  
  
Variables can be set within the script, passed as arguments, or entered via graphical dialogs. It includes an -h argument for basic help.  
Arguments passed via the console take priority; if one is passed, the graphical mode will not prompt for it. In dialogs, the default value will be the one set in the script variables.  
Dialog configuration can be disabled from the $gui variable in the script.  
Additionally, if the $DISPLAY variable is not detected, it is assumed that the script is in non-graphical or non-interactive mode, so it neither displays notifications nor uses dialogs. The idea is to adapt as best as possible to these situations:  
* The user runs the script directly, without parameters and without touching the variables: The script asks if they want to set them graphically. If they want, it asks everything, using the default values ​​entered in the script. If they don't want, it uses those values ​​as valid.  
* The user runs the script from a non-interactive console (e.g., a distro without a desktop, just a terminal): There are no notifications or dialog boxes. Parameters can be used; otherwise, the default values ​​are used.  
* The script is configured to autostart: either by setting all values ​​as parameters or by overriding the GUI (by editing the variable $gui = false or using the -g parameter). In the latter case, the script will prioritize the parameters and use the default values ​​for the rest.  
  
**Two scripts in one**  
Reading the temperatures is easy, but setting the frequency value can only be done as superuser. For this reason, I split the script into two: underclocker.sh has normal user permissions, and when a change needs to be made, it calls the script /usr/bin/setfreq.sh with sudo.  
  
Underclocker detects if setfreq.sh exists. If it doesn't exist, it starts an installation of it:  
1. The cpufreq.sh script, which requires permissions, is created in /usr/bin/setfreq.sh, with owner root:root and permissions 755. All its content is already included in the Underclocker body, so there's no need to download it separately.  
2. To prevent it from prompting for a password every time (especially to be able to use it in a non-interactive shell), it needs to add passwordless sudo permissions for the second script. During installation, the line [ALL ALL=(ALL) NOPASSWD: /usr/bin/setfreq.sh] is added to the end of /etc/sudoers. To avoid duplication, it is first checked that this line does not already exist.  
  
Setfreq.sh has two functions:  
1. Change the core frequency. To do this, Underclocker sends the number of the core to be changed as the first parameter and the desired frequency as the second parameter.  
2. Change the "governor" (the processor's power consumption mode). Underclocker sends the string "governor" as the first parameter and the name of the desired governor as the second parameter.  
  
**Help**  
```This script monitors the CPU temperature, reduces the maximum frequency when it is too high and increases it when it is low enough. It can create a log with its actions, temperatures, frequencies, and the date and time of each event.  
  
List of valid parameters:  
-d <seconds>	Delay before running the script.  
-t <seconds>	Time in seconds to run the script. If 0, the script will not stop.  
-p <governor>	Power governor (use [-p list] to select one from a list)  
-l <ºC>		Maximum desired temperature.  
-r <ºC>		Minimum temperature to boost frequency.  
-f <file>	File to use as log.  
-s <size>	Maximum size, in rows, of the log file.  
-n <yes | no>	Enable or disable desktop notifications.  
-g		Disable graphical settings.  
  
Example: Limits the frequency when the temperature reaches 85°C, restores it when the temperature drops below 75°C, and displays desktop notifications:  
./underclocker.sh -l 85 -r 75 -n yes  
  
Example: Limits the frequency when the temperature reaches 70°C, restores it when the temperature drops below 50°C, waits 30 seconds before running the script, runs for 5 minutes (300 seconds), disables the graphical configuration, and saves the log to <HOME>/temper.txt:  
./underclocker.sh -l 70 -r 50 -d 30 -t 300 -g -f ~/temper.txt  
```
