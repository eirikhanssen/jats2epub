@echo off
rem	Overview:
rem	
rem	This is a windows batch script that can be used to generate .epub, .mobi 
rem	(and in a later version also .pdf output) from NISO JATS tagged .xml input
rem	Created by Eirik Hanssen, Oslo and Akershus University College
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
if not exist "programs\kindlegen\kindlegen.exe" (
	echo ######################################################################
	echo ###                                                                ###
	echo ### NOTICE:                                                        ###
	echo ### Amazon Kindlegen is disabled by default due to licencing.      ###
	echo ### See readme if you want to enable kindlegen for .mobi creation. ###
	echo ### .mobi format for kindle was NOT created^^!                       ###
	echo ###                                                                ###
	echo ######################################################################
) else (
	"programs\kindlegen\kindlegen.exe" %*
)
