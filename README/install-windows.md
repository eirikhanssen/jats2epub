Install instructions - Windows users
====================================
Contents:

1. Jats2epub (required)
2. Java (required)
3. XMLCalabash (required)
4. Epubcheck (required)
5. Kindlegen (optional)
6. First run

## 1. Jats2epub
There are two options in getting jats2epub on windows:

    1) download a zip archive
    2) using git

### Get jats2epub from a zip-archive
- Get the latest zip-archive and extract it to a chosen folder
- Note that jats2epub might not work if you extract it to a network drive.

### Get jats2epub using git
If you have git installed, you can open cmd.exe, navigate to your chosen folder and type:

```git clone https://github.com/eirikhanssen/jats2epub.git```

### IMPORTANT: How to use jats2epub once this install guide has been completed
- From windows explorer, navigate to the jats2epub folder and double click **ClickMeToStart.bat**
    - this bat-file will set up the environment and open cmd.exe from this folder so that you can run jats2epub from any folder
        - the most important thing done by ClickMeToStart.bat is **adding jats2epub\programs\bin to the path environment variable**.
        - then all .bat files in jats2epub\programs\bin can be run from any folder you navigate to in the cmd.exe terminal opened by **ClickMeToStart.bat**
    - jats2epub will *not* work if you start cmd.exe by other means.

## 2. Java
A java runtime environment is required by xmlcalabash, epubcheck and some helper utilities used by jats2epub.
Start cmd.exe from the start menu and type java followed by enter.

- If this command is recognized, you're good to go. 
- If not, download and install a Java Runtime Environment (JRE) from http://www.oracle.com/technetwork/java/javase/downloads/index.html
the JRE is required. JDK is not needed by jats2epub. It is can used to create your own java programs. JRE is used to run java programs.

If you have installed Java and open cmd.exe and the java command is unrecognized, this means that the folder containing the java executable files is not in the path.
You could then try to restart your OS and see if it works then, and if that fails, manually add the directory to the path environment variable.

## 3. XMLCalabash
XMLCalabash is a XProc processor written in java. It needs JRE to run.
XProc is an XML pipeline language, and XMLCalabash can run the source article.xml file against jats2epub.xpl.
This file contains instructions on how the document should be prosessed to create most of the files needed for the epub archive.

### 3.1 Getting XMLCalabash
- XMLCalabash can be freely downloaded from: http://xmlcalabash.com/download/
- Latest version: https://github.com/ndw/xmlcalabash1/releases/latest
- Direct link (may be outdated in the future): https://github.com/ndw/xmlcalabash1/releases/download/1.1.9-96/xmlcalabash-1.1.9-96.zip
- Download the zip-archive: xmlcalabash-1.1.9-96.zip, or any later version

### 3.2 Installing XMLCalabash
- Extract xmlcalabash-1.1.9-96.zip
- Navigate inside until you find the file xmlcalabash-1.1.9-96.jar (or later version)
- Rename this file to xmlcalabash.jar (stripping away the version part of the name)
- Rename the folder xmlcalabash.jar is located in to xmlcalabash (also stripping away the version part of the name)
- Move this folder (xmlcalabash) inside the jats2epub\programs folder.
    - The reason for this renaming is that in jats2epub\programs\bin there is a calabash.bat file that looks for calabash.jar in the location ..\xmlcalabash\xmlcalabash.jar, that is up one folder and into the xmlcalabash folder
    - calabash.bat is called by jats2epub.bat

## 4. Epubcheck
Epubcheck is a utility to validate .epub files and expanded EPUB archives as well as packaging expanded EPUB archives to .epub files.
Epubcheck is written in java and distributed as a executable jar file.
In jats2epub\programs\bin there is file called epubcheck.bat that will look for epubcheck.jar in the location ..\epubcheck\epubcheck.jar, so that's where it has to be installed.

### 4.1 Getting Epubcheck
- Download from: https://github.com/idpf/epubcheck
- Latest release: https://github.com/IDPF/epubcheck/releases/latest
- Direct link (may be outdated in the future): https://github.com/IDPF/epubcheck/releases/download/v4.0.0/epubcheck-4.0.0.zip
- Download this zip file.

### 4.2 Installing Epubcheck
- Extract epubcheck-4.0.0.zip (or later)
- Navigate inside until you find epubcheck.jar
- Rename the folder containing epubcheck.jar to epubcheck (stripping away the version part of the name)
- Move the epubcheck folder inside jats2epub\programs
    - as mentioned before then jats2epub\programs\bin\epubcheck.bat can find epubcheck.jar in ..\epubcheck\epubcheck.jar

## 5. Kindlegen
Amazon kindlegen is a utility used to convert .epub files to .mobi files so that they can be read on kindle devices.
If you're not interested in generating .mobi files, you don't need to install kindlegen, then .mobi generation will simply be skipped.

### 5.1 Getting kindlegen
- Search google for amazon kindlegen
- Download page (might be outdated in the future): http://www.amazon.com/gp/feature.html?docId=1000765211
- Direct link (might be outdated in the future): http://kindlegen.s3.amazonaws.com/kindlegen_win32_v2_9.zip
- Download the zip file

### 5.2 Installing kindlegen
In jats2epub\programs\bin, there is a kindlegen.bat file that looks for kindlegen.exe in ..\kindlegen\kindlegen.exe, so that's where it needs to be.
The kindlegen zip archive has all the files at the top level, so to avoid littering the folder when you extract, do this:

- Navigate to jats2epub\programs
- Create a folder named kindlegen
- Move kindlegen_win32_v2_9.zip to jats2epub\programs\kindlegen
- Extract here

## 6. First run
If you made it this far, you're ready to start using jats2epub on windows.

Don't be scared of all the text that flows on the screen ;)

It can be helpful for troubleshooting

- Navigate to the jats2epub folder with windows explorer
- Double click the file **ClickMeToStart.bat**
- Then you should se cmd.exe, a black window with command line popping up.

### 6.1 Convert an article with no figures
Try this command to convert an article with no figures to epub:

``` jats2epub source-xml\saks.xml ```

### 6.2 Convert an article with figures
Try this command to convert an article with figures to epub::

``` jats2epub source-xml\spehar.xml source-xml\spehar ```

### 6.3 Converted files
- The converted files will be in jats2epub\converted
- Temporary files will be in jats2epub\latest-run
