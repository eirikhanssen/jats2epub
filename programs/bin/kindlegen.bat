@echo off
rem	Overview:
rem	
rem	This is a windows batch file used to call amazon kindlegen.
rem kindlegen is used by jats2epub.bat to convert epub file to mobi file
rem you have to download kindlegen yourself and put kindlegen.exe in the jats2epub\programs\kindlegen folder
rem search google for kindlegen or try this url: http://www.amazon.com/gp/feature.html?docId=1000765211
%bin%\..\kindlegen\kindlegen.exe %*