@echo off
rem	Overview:
rem	
rem	This is a windows batch file used to run epubcheck to validate a created
rem	ePub file. It requires java to be installed and epubcheck-3.0.1.jar to 
rem be installed in the correct folder.
rem
rem Optionally:
rem
rem For system wide installation this script can be put somewere in windows PATH
rem	and the path to epubcheck-3.0.1.jar here must be changed to the absolute 
rem file path on your file system.
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
@java -jar "programs\epubcheck-3.0.1\epubcheck-3.0.1.jar" %*
