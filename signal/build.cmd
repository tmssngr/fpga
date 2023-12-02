@echo off
setlocal

call C:\oss-cad-suite\environment.bat
set NAME=top
set SYNTH_JSON=%NAME%-synth.json
set PNR_JSON=%NAME%-pnr.json
set FAMILY=GW1N-9C
set DEVICE=GW1NR-LV9QN88PC6/I5

yosys -p "read_verilog %NAME%.v; portlist top"
if  errorlevel 1 goto ERROR

yosys -p "read_verilog %NAME%.v; synth_gowin -top top -json %SYNTH_JSON%"
if  errorlevel 1 goto ERROR

nextpnr-gowin --json %SYNTH_JSON% --write %PNR_JSON% --freq 27 --device %DEVICE% --family %FAMILY% --cst tangnano9k.cst
if  errorlevel 1 goto ERROR

gowin_pack -d %FAMILY% -o %NAME%.fs %PNR_JSON%
if  errorlevel 1 goto ERROR

:ERROR
pause
