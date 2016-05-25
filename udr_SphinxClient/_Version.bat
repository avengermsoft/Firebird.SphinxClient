@echo off
SET BRCC="C:\PROGRA~2\EMBARC~1\RADSTU~1\8.0\bin\brcc32.exe"
SET INCVERRCFILE="D:\Install\Project\New\AutoNewFileVerInfo\IncVerRcFile\IncVerRcFile.exe"
Set PROJECTNAME=udr_SphinxClient

del %PROJECTNAME%.res >nul 2>nul
%INCVERRCFILE% -f%PROJECTNAME%.rc 
%BRCC% %PROJECTNAME%.rc
