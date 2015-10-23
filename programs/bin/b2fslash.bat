@echo off
rem	Overview:
rem	
rem	This is a windows batch file used to run b2fslash - converting dos style paths to unix style paths
rem     by replacing backslash with forward slash.
rem     this is needed to avoid dos/windows path problems with java and xmlcalabash
rem     this script is intended to be called from another script where the path has been stored in the %infile% variable
rem
@java -jar "%bin%\..\b2fslash\b2fslash.jar" %infile%