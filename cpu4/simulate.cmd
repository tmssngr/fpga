@echo off
setlocal

call C:\oss-cad-suite\environment.bat

:repeat
cls
call :simulate SoC

pause
goto :repeat
exit

:: ======================
:simulate
set NAME=%~1
set NAME_TB=%NAME%_tb

echo %NAME%
echo -------------
if exist %NAME%.vcd del %NAME%.vcd

:: Usage: iverilog [-EiRSuvV] [-B base] [-c cmdfile|-f cmdfile]
::                 [-g1995|-g2001|-g2005|-g2005-sv|-g2009|-g2012] [-g<feature>]
::                 [-D macro[=defn]] [-I includedir] [-L moduledir]
::                 [-M [mode=]depfile] [-m module]
::                 [-N file] [-o filename] [-p flag=value]
::                 [-s topmodule] [-t target] [-T min|typ|max]
::                 [-W class] [-y dir] [-Y suf] [-l file] source_file(s)
iverilog -o %NAME_TB%.o -s test%NAME% %NAME%.v %NAME_TB%.v
if  %ERRORLEVEL% NEQ 0 (
    echo FAILURE
    goto continue
)
:: Usage: vvp [options] input-file [+plusargs...]
:: Options:
::  -h             Print this help message.
::  -i             Interactive mode (unbuffered stdio).
::  -l file        Logfile, '-' for <stderr>
::  -M path        VPI module directory
::  -M -           Clear VPI module path
::  -m module      Load vpi module.
::  -n             Non-interactive ($stop = $finish).
::  -N             Same as -n, but exit code is 1 instead of 0
::  -s             $stop right away.
::  -v             Verbose progress messages.
::  -V             Print the version information.
vvp %NAME_TB%.o > %NAME%.txt
type %NAME%.txt

:continue
echo:
goto :eof
