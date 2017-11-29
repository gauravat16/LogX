# LogX
A logging framework for bash.

## Example
![Example](https://github.com/gauravat16/LogX/blob/master/Example_Shot.png)

## How to use

Add the following lines in the script where you want to use LogX.

        source $PATH_TO_LOGX_SH

        log_init $PATH_TO_PROPERTIES_FILE

And create the properties file with the following entries

        ScriptName=<Name of the log file>

        LogLocation=<location of log to be created in>

        MaxLogFileSize=<max size of individual log file in bytes>

        CompressLogs=<compression of old logs : true or false>

        options=<options for LogX>

#### Following options are available

* **-nocolor** - LogX has color coded logs, this disables that
* **-nolog** - Disables file logging
* **-debug** - Enables console logging

  
#### Functions

* **log_warn** 

  Displays logs with WARN tag and blue in -debug mode.

  **Parameters** 
  * Log TAG
  * Log Message
  
* **log_info** 

  Displays logs with INFO tag and green in -debug mode.

  **Parameters** 
  * Log TAG
  * Log Message
  
* **log_error** 

  Displays logs with ERROR tag and red in -debug mode.

  **Parameters** 
  * Log TAG
  * Log Message
  



