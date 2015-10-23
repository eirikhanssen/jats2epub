@echo off
rem	Overview:
rem	
rem	This is a windows batch file used to run b2fslash - converting dos style paths to unix style paths
rem     by replacing backslash with forward slash.
rem     this is needed to avoid path problems with java and xmlcalabash
rem
@java -jar "%bin%\..\b2fslash\b2fslash.jar" %*
