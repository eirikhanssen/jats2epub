@echo off
rem	Overview:
rem	
rem	This is a windows batch file used to run xmlcalabash, an XProc processor
rem	It is used by the jats2epub.bat windows batch script that should also be
rem	included
rem
@java -jar "%bin%\..\xmlcalabash\xmlcalabash.jar" %*
