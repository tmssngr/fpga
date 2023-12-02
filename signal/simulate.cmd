@echo off
setlocal

call C:\oss-cad-suite\environment.bat

:repeat
cls
call :simulate PWM
call :simulate UpDownCounter
call :simulate top

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

iverilog -o %NAME_TB%.o -s test %NAME_TB%.v
vvp %NAME_TB%.o
echo:
goto :eof
