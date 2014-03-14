@echo off
rem	Overview:
rem	
rem	This is a windows batch file that will display some useful commands available
rem in windows commandline.
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
echo SOME USEFUL BUILTIN COMMANDS IN CMD.EXE:
echo:
echo:
echo TIP - speed up command typing by using Tab:
echo 	When typing a command, filename or path you can usually begin typing and hitting the Tab key 
echo 	to get autocomplete suggestions. Try hitting the Tab key multiple times for other suggestions.
echo:
echo:
echo help
echo		When called with no parameters, will list all builtin commands available from cmd.exe
echo		When called with a builtin command as a parameter, will display help and detailed usage for that builtin command.
echo:
echo help dir
echo		Display help/detailed usage for the dir command
echo:
echo dir
echo		list files and subdirectories in a directory
echo:
echo cd
echo		change directory, use this to navigate in and out of folders.
echo:
echo 		cd ..\..
echo				move back two folders
echo 		cd output_working_folder\epub
echo				move into the epub-folder inside the output_working_folder
echo:
echo cls
echo		clear the screen of the command prompt
echo:
echo copy
echo		copy files/folders
echo:
echo xcopy
echo		copy files/folders with more control and options
echo:
echo mkdir
echo		make directory
echo:
echo rmdir
echo		remove directory - be careful when using this
echo:
echo del
echo		remove file - be careful when using this command
echo:
echo		del ^*.epub
echo			will delete all .epub files in the current directory ^(be very careful with this command^)
echo		del ^*
echo			will delete all files in the current directory ^(be very careful with this command^)
echo:
