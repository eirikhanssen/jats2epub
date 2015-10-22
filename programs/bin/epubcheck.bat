@echo off
rem	Overview:
rem	
rem	This is a windows batch file used to run epubcheck for epub validation and packing
rem	It is used by the jats2epub.bat windows batch script that should also be
rem	included
rem
@java -jar "%bin%\..\epubcheck\epubcheck.jar" %*
