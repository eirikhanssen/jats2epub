@echo off
rem	Overview:
rem	
rem	This is a windows batch file that will display usage of the jats2epub.bat 
rem batch script used to create ePub.
rem
rem Created by Eirik Hanssen, Oslo and Akershus University College
rem
rem	License:
rem	
rem	This file is part of jats2epub.
rem
rem	jats2epub is free software: you can redistribute it and/or modify
rem	it under the terms of the GNU General Public License as published by
rem	the Free Software Foundation, either version 3 of the License, or
rem	(at your option) any later version.
rem
rem	jats2epub is distributed in the hope that it will be useful,
rem	but WITHOUT ANY WARRANTY; without even the implied warranty of
rem	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem	GNU General Public License for more details.
rem
rem	You should have received a copy of the GNU General Public License
rem	along with jats2epub.  If not, see http://www.gnu.org/licenses/gpl.html
rem	
rem	Contact: eirik dot hanssen at hioa dot no
mode con:cols=140 lines=1000
echo NOTICE:
echo    As long as you started the command shell by using the batch file ClickMeToStart.bat,
echo    the folder %bin% has been added to the path variable and some new commands can be used.
echo:
echo AVAILABLE COMMANDS:
echo:
echo jats2epub
echo    Use this script to create .epub and .mobi from a JATS tagged .xml file.
echo    When called with no parameters, will display usage of this script
echo:
echo startupguide
echo    Display this screen.
echo:
echo commandhelp
echo    Display some useful commands for cmd.exe ^(like how to change dir and copy files etc ...^)
echo:
echo epubcheck [filename]
echo    Validate an epub using epubcheck. ^(Done automatically by jats2epub^).
echo    Note that you must also download epubcheck.jar for this command to work. Consult the README.
echo:
echo calabash [filename]
echo    Run an XProc pipeline. ^(Done automatically by jats2epub^)..
echo    Note that you must also download calabash.jar this command to work. Consult the README.
echo:
echo kindlegen [filename]
echo    Convert an epub file to a mobi file. ^(Done automatically by jats2epub^).
echo    Note that you must also download kindlegen.exe for this command to work. Consult the README.
echo:
