@echo off && SETLOCAL EnableExtensions EnableDelayedExpansion
rem	Overview:
rem	
rem	This is a windows batch script that can be used to generate .epub, .html, .mobi 
rem	(and in a later version also .pdf output) from NISO JATS tagged .xml input
rem	This script relies on the XProc pipeline jats2epub.xpl to do the xml
rem	transformation work. This script takes care of all the steps that couldn't 
rem	be implemented in the XProc pipeline jats2epub.xpl alone.
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

rem find number of argments passed to this script
set current_dir=%cd%
set input_file=%1%
set /a args_count=0
for %%a in (%*) do set /a args_count+=1
rem echo %args_count% arguments were passed!

rem using timestamp.bat that runs jats2epub\programs\j2etimestamp.jar with java to generate a timestamp to be used in the generated filenames
for /f "delims=" %%i in ('timestamp') do @set datetime=%%i

set epubfilename=%~n1-%datetime%.epub
set mobifilename=%~n1-%datetime%.mobi
set pdffilename=%~n1-%datetime%.pdf
set htmlfilename=%~n1-%datetime%.html
set xmlfilename=%~n1-%datetime%.xml
 
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
		call :mobiconvert %epubfilename% %mobifilename%
		rem call :pdf-generation %pdffilename%
		call :copy-input-xml
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
		call :mobiconvert %epubfilename% %mobifilename%
		rem call :pdf-generation %pdffilename%
		call :copy-input-xml
		call :endnotice
	)
)
exit /b

:usage
setlocal
	echo:
	echo:
	echo USAGE:
	echo 	jats2epub xmlfile [required] folder-with-extras [optional]
	echo:
	echo:
	echo PARAMETERS:
	echo:
	echo xmlfile ^(required^)
	echo 	Must be a valid xmlfile according to the NISO JATS 1.0 xml dtd or xsd
	echo:
	echo folder-with-extras  ^(optional^)
	echo 	Contents of this folder will be put directly in the EPUB folder within the epub archive.
	echo    This is needed if the article has figures such as images.
	echo:
	echo:
	echo EXAMPLES:
	echo:
	echo Try converting these two sample documents to epub. 
	echo:
	echo ^(1^) Convert a paper by Mike Saks, located in the source-xml folder:
	echo:
	echo 	jats2epub source-xml\saks.xml
	echo:
	echo:
	echo ^(2^) Convert a paper with images by Ivan Spehar and Lars Ivar Kjekshus ^(need to use the second parameter^):
	echo:
	echo 	jats2epub source-xml\spehar.xml source-xml\spehar
	echo:
	echo:
	echo If all goes well, the converted .epub and .mobi ^(if enabled^) files will appear in %converted_dir%
endlocal && exit /b

:get-user-confirmation
setlocal
	echo:
	echo WARNING^^! Script needs to clear out ^(DELETE^) files from latest-run to continue
	echo This is normal operation, but if you need to back up the files in latest-run ^(after a previous run^), please abort.
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
	call :clear-latest-run
	call :create-if-not-exists-converted-files
	call :epub-template-copy %2
	call :process-xproc-pipeline %1
	echo:
	echo # DONE # Preparing and processing files
	echo:
	echo Copying %latest_dir%\article-webversion.html to %converted_dir%\%htmlfilename%
	copy %latest_dir%\article-webversion.html %converted_dir%\%htmlfilename% /Y
endlocal && exit /b

:create-if-not-exists-converted-files
setlocal
	if not exist "%converted_dir%" (
		echo Creating directory to hold finished ebooks: converted-files
		mkdir %converted_dir%
	)
endlocal && exit /b

:epub-template-copy
setlocal
	echo:
	echo # START # Copying over epub-template from assets\epub-template to latest-run\epub
	echo:
	xcopy %j2e_dir%\assets\epub-template %latest_dir%\epub\ /S /F /I
	echo:
	echo # DONE # Copying over epub-template from assets\epub-template to %latest_dir%\epub
endlocal && exit /b

:clear-latest-run
setlocal
	echo:
	echo # START # Clearing out old files
	echo:
	echo deleting folder %latest_dir%
	rmdir /S /Q %latest_dir%
	echo creating folder %latest_dir%
	mkdir %latest_dir%
	echo:
	echo # DONE # Clearing out old files
endlocal && exit /b

:copy-extra-folder
setlocal
	echo:
	echo # START # Copying over extra files from %1 to %latest_dir%\epub\EPUB
	echo:
	xcopy %1\* %latest_dir%\epub\EPUB\ /S /F /I
	echo:
	echo # DONE # Copying over extra files from %1 to %latest_dir%\epub\EPUB
endlocal && exit /b

:process-xproc-pipeline
setlocal
	echo:
	echo # START # XProc pipeline processing with XMLCalabash on %1
	echo:
	call calabash -i source=%1 -p transform="github.com/eirikhanssen/jats2epub - based on github.com/ncbi/JATSPreviewStylesheets" work_dir=%work_dir% %jats2epub_xpl%
	echo:
	echo # DONE # XProc pipeline processing with XMLCalabash on %1
endlocal && exit /b

:pack-epub-archive
setlocal
	echo:
	echo # START # Epub validation and packing attempt
	echo:
    call epubcheck %latest_dir%\epub -mode exp -save
	echo:
	echo # DONE # Epub validation and packing attempt
	echo:
	echo moving %latest_dir%\epub.epub to converted-files\%1
	move %latest_dir%\epub.epub %converted_dir%\%1
	cd ..\..
endlocal && exit /b

:mobiconvert
setlocal
echo:
if not exist "%bin%\..\kindlegen\kindlegen.exe" (
	echo #######################################################################
	echo ###                                                                 ###
	echo ### NOTICE:                                                         ###
	echo ### Amazon Kindlegen is disabled by default due to licencing.       ###
	echo ### Please download kindlegen and put kindlegen.exe in              ###
	echo ### jats2epub\programs\kindlegen to be able to generate mobi format.###
	echo ### Search google for amazon kindlegen or try this url:             ###
	echo ### http://www.amazon.com/gp/feature.html?docId=1000765211          ###
	echo ###                                                                 ###
	echo ### .mobi format was NOT created due to missing kindlegen           ###
	echo ###                                                                 ###
	echo #######################################################################
) else (
	echo # START # Converting %1 to %2 with KindleGen
	echo:
	call kindlegen %converted_dir%\%1 -o %2
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

:endnotice
setlocal
	echo:
	echo SCRIPT HAS COMPLETED^^!
	echo Check out the converted-files folder for newly created files if all went well.
	echo:
	echo You might also want to browse files in latest-run, as all intermediate files created by the pipeline are there.
	echo ALL intermediate files in latest-run WILL BE ERASED after a warning on the next run.
	echo:
	echo If something went wrong, please read the output from the script and consult readme-win.html.
endlocal && exit /b

:exit-script
setlocal
rem generates a syntax error and forces the script to exit immediately
()
endlocal && exit /b

:copy-input-xml
setlocal
	copy %latest_dir%\00-original.xml %converted_dir%\%xmlfilename%
	echo copying original xml file to %converted_dir%\%xmlfilename%
endlocal && exit /b