@echo off && PUSHD "%~dp0" && SETLOCAL EnableExtensions EnableDelayedExpansion
rem	Overview:
rem	
rem	This is a windows batch script that can be used to generate .epub, .html, .mobi 
rem	(and in a later version also .pdf output) from NISO JATS tagged .xml input
rem	This script relies on the XProc pipeline process-jats.xpl to do the xml
rem	transformation work. This script takes care of all the steps that couldn't 
rem	be implemented in the XProc pipeline process-jats.xpl alone.
rem
rem	Author: 
rem
rem	Eirik Hanssen, Oslo and Akershus University College of Applied Sciences
rem
rem	Contact:
rem
rem	eirik dot hanssen at hioa dot no
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

cd .\
rem find number of argments passed to this script
set /a args_count=0
for %%a in (%*) do set /a args_count+=1
rem echo %args_count% arguments were passed!

rem setting datetime using output from date.exe in UnxUtils. We can't reliably use windows command builtin date because the output is locale dependent, and might break this script.
rem source: http://stackoverflow.com/questions/203090/how-to-get-current-datetime-on-windows-command-line-in-a-suitable-format-for-us
for /f "tokens=*" %%i in ('programs\UnxUtils\date.exe +"%%Y%%m%%d-%%H%%M%%S"') do set datetime=%%i
rem echo datetime: %datetime%

set epubfilename=%~n1-%datetime%.epub
rem echo epubfilename was set to: %epubfilename%
set mobifilename=%~n1-%datetime%.mobi
rem echo mobifilename was set to: %mobifilename%
set pdffilename=%~n1-%datetime%.pdf
rem echo PDFfilename was set to: %pdffilename%
set htmlfilename=%~n1-%datetime%.html
rem echo htmlfilename was set to: %htmlfilename%

 
:main
if "%args_count%" == "0" (
	call :usage && exit /b
) else if "%args_count%" GTR "2" (
	echo "%args_count%" arguments used. Was expecting 1 or 2. && call :usage && exit /b
) else if "%args_count%" == "1" (
	if not exist "%1" (
		rem one parameter and it was not found
		echo Error^(1^): %1 - FILE NOT FOUND^^! - && call :usage && exit /b
	) else (
		rem one parameter and it was found
		echo Found: %~nx1. Getting ready to generate .epub and .mobi
		call :get-user-confirmation
		call :prepare-and-process-files %1
		call :pack-epub-archive %epubfilename%
		call :validate-epub %epubfilename%
		call :mobiconvert %epubfilename% %mobifilename%
		call :pdf-generation %pdffilename%
		call :endnotice
	)
	exit /b
) else if "%args_count%" == "2" (
	if not exist "%2" (
		rem two params and %2 was not found
		if not exist "%1" (
		rem two params and %2 and %1 was not found
			echo Error^(2^): %1 - FILE NOT FOUND^^! -
		) else ( 
			rem %1 found
			echo Found: %1 - OK -
			)
		echo Error^(3^): %2 - DIRECTORY NOT FOUND^^! - && call :usage && exit /b
	) else (
		rem two params and %2 was found
		if not exist "%1" (
		rem two params, %2 was found but %1 was not found
			echo Error^(4^): %1 - FILE NOT FOUND^^! - && echo Found %2 - OK - && call :usage && exit /b
		)
		rem two params, %2 and %1 was found
		echo Found: %~nx1 and %2. Getting ready to generate .epub and .mobi ...
		call :get-user-confirmation
		call :prepare-and-process-files %1 %2
		call :copy-extra-folder %2
		call :pack-epub-archive %epubfilename%
		call :validate-epub %epubfilename%
		call :mobiconvert %epubfilename% %mobifilename%
		call :pdf-generation %pdffilename%
		call :endnotice
	)
)
exit /b

:usage
setlocal
	echo:
	echo:
	echo USAGE:
	echo 	jats2epub xmlfile [folder-with-extras]
	echo:
	echo:
	echo PARAMETERS:
	echo:
	echo xmlfile ^(required^)
	echo 	Must be a valid xmlfile according to the NISO JATS 1.0 xml dtd or xsd
	echo:
	echo folder-with-extras  ^(optional^)
	echo 	If used should be the path to a folder with folders and files that needs to be copied into the OEBPS folder 
	echo 	in the epub file structure. Script will copy folder-with-extras\* to output_working\epub\OEBPS\
	echo 	Use the folder parameter if the article uses images for figures. 
	echo 	Images should be placed inside an images folder that is child of this folder.
	echo:
	echo 	See examples below and inspect files and folders inside the folder source-xml\
	echo:
	echo:
	echo EXAMPLES:
	echo:
	echo A test case using an article by Mike Saks, located in the source-xml folder
	echo (^includes no extra images to be copied^)
	echo:
	echo Example 1:
	echo:
	echo 	jats2epub source-xml\saks.xml				^<-- try this command^!
	echo:
	echo:
	echo A test case using the provided article by Ivan Spehar and Lars Ivar Kjekshus, located in the source-xml folder
	echo ^(includes extra images to be copied into epub structure^)
	echo:
	echo Example 2:
	echo:
	echo 	jats2epub source-xml\spehar.xml source-xml\spehar		^<-- try this command^!
	echo:
	echo:
	echo You will see output messages from this script and the components used.
	echo:
	echo If all goes well .epub and .mobi ^(if enabled^) files will appear in the folder output_final\
endlocal && exit /b

:get-user-confirmation
setlocal
	echo:
	echo WARNING^^! Script needs to clear out ^(DELETE^) files from output_working to continue
	echo This is normal operation, but if you need to back up the files in output_working ^(after a previous run^), please abort.
	echo:
set /p confirm_value=Type Y to continue or N to abort ^(Y/N^):%=%
if "%confirm_value%" == "y" (
	echo Confirmed^^! && exit /b
) else if "%confirm_value%" == "Y" (
	echo Confirmed^^! && exit /b
) else (
	echo Aborting script^^!
	rem exit-script generates a syntax error. Script aborts. std err redirects to nul
	call:exit-script 2> nul
)
endlocal && exit /b

:prepare-and-process-files
setlocal
	echo:
	echo # START # Preparing and processing files
	call :clear-output_working
	call :create-if-not-exists-output_final
	call :epub-template-copy %2
	call :process-xproc-pipeline %1
	echo:
	echo # DONE # Preparing and processing files
	echo:
	echo Copying output_working\article-webversion.html to output_final\%htmlfilename%
	copy output_working\article-webversion.html output_final\%htmlfilename% /Y
endlocal && exit /b

:create-if-not-exists-output_final
setlocal
	if not exist "output_final" (
		echo Creating directory to hold finished ebooks: output_final
		mkdir output_final
	)
endlocal && exit /b

:epub-template-copy
setlocal
	echo:
	echo # START # Copying over epub-template from assets\epub-template to output_working\epub
	echo:
	xcopy assets\epub-template output_working\epub\ /S /F /I
	echo:
	echo # DONE # Copying over epub-template from assets\epub-template to output_working\epub
endlocal && exit /b

:clear-output_working
setlocal
	echo:
	echo # START # Clearing out old files
	echo:
	echo deleting folder output_working
	rmdir /S /Q output_working
	echo creating folder output_working
	mkdir output_working
	echo:
	echo # DONE # Clearing out old files
endlocal && exit /b

:copy-extra-folder
setlocal
	echo:
	echo # START # Copying over extra files from %1 to output_working\epub\OEBPS
	echo:
	xcopy %1\* output_working\epub\OEBPS\ /S /F /I
	echo:
	echo # DONE # Copying over extra files from %1 to output_working\epub\OEBPS
endlocal && exit /b

:process-xproc-pipeline
setlocal
	echo:
	echo # START # XProc pipeline processing with XMLCalabash on %1
	echo:
	call calabash -i source=%1 process-jats-xml.xpl
	echo:
	echo # DONE # XProc pipeline processing with XMLCalabash on %1
endlocal && exit /b

:pack-epub-archive
setlocal
	echo:
	echo # START # Packing epub archive: %1
	echo:
	cd output_working\epub
	echo creating %1 and adding mimetype with 0 compression
	call ..\..\programs\zip3-win32\zip.exe -0 -X %1 mimetype
	echo adding the remaining files to %1
	call ..\..\programs\zip3-win32\zip.exe -r -9 -X %1 .\* -x mimetype *Thumbs.db
	echo:
	echo # DONE # Packing epub archive
	echo:
	echo moving %1 to output_final\%1
	move %1 ..\..\output_final
	cd ..\..
endlocal && exit /b

:mobiconvert
setlocal
echo:
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
	echo # START # Converting %1 to %2 with KindleGen
	echo:
	call programs\kindlegen\kindlegen.exe output_final\%1 -o %2
	echo:
	echo # DONE # Converting %1 to %2 with KindleGen
)
endlocal && exit /b

:pdf-generation
setlocal
	echo:
	echo #########################################################
	echo ###                                                   ###
	echo ### NOTICE:                                           ###
	echo ### PDF-generation is not implemented yet^^!            ###
	echo ### PDF generation will be added in a future version. ###
	echo ###                                                   ###
	echo #########################################################	
	echo:
	echo %pdffilename% was not created.
	echo:
endlocal && exit /b

:validate-epub
setlocal
	echo:
	echo # START # Epub validation
	echo:
	echo Validating epub: %1 using epubcheck ...
	call epubcheck output_final\%1
	echo:
	echo # DONE # Epub validation
endlocal && exit /b

:endnotice
setlocal
	echo:
	echo SCRIPT HAS COMPLETED^^!
	echo Check out the output_final folder for newly created files if all went well.
	rem check if output_final\%epubfilename% and output_final\%mobifilename% exists
	rem if it exists output message about those files being there.
	rem if not, something went wrong
	echo:
	echo You might also want to browse files in output_working, as all intermediate files created by the pipeline are there.
	echo ALL intermediate files in output_working WILL BE ERASED after a warning on the next run.
	echo:
	echo If something went wrong, please read the output from the script and consult readme-win.html.
endlocal && exit /b

:exit-script
setlocal
rem generates a syntax error and forces the script to exit immediately
()
endlocal && exit /b
