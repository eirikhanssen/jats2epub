jats2epub
=========

## Purpose
Create validating ePub publications from journal articles marked up using the NISO JATS xml tagset.

## Background
This package was created in a project to create a new, xml-based workflow to publish OpenAccess articles in electronic journals in the ePub format.
You might be interested in reading about this project in the article that is published in Code4lib: EPUB as publication format in Open Access journals: Tools and workflow. By Trude Eikebrokk, Tor Arne Dahl and Siri Kessel, Oslo and Akershus University College of Applied Sciences. Read the article at Code4lib: http://journal.code4lib.org/articles/9462

## Input and output
As input it takes an article tagged in the Journal Archive Tag Suite (JATS) XML format, and optionally a folder with extra content to be copied into to the epub-structure (such as images). As output an ePub file and html-file is generated and optionally also a .mobi file converted from the epub file.

### JATS
JATS or Journal Archiving Tag Suite (Publishing) is an xml-based tagset for describing journal articles. See the following resources:
- http://jats.nlm.nih.gov/publishing/ - Journal Publishing Tag Set
- http://jats.nlm.nih.gov/publishing/tag-library/ - Journal Publishing Tag Library

## Technical overview
This package uses XML Calabash (a java-based XProc processor built on top of saxon) to process the XProc pipeline, process-jats.xpl, that transforms the xml-document in stages using a mix of XSLT and XProc steps. Since a full automation from JATS xml to final ePub can't be done in XProc yet, calling the XProc pipeline has been wrapped in a script. 
For windows, a jats2epub.bat (batchfile) and for Gnu/Linux, Unix and MacOSX, jats2epub (shellscript).
The whole process is automated, all you need to type to use the jats2epub tool is this single command: 

```jats2epub path-to-xmlfile path-to-folder[optional]```

Please see html readmes for more information.

## Authors
- XSLT-stylesheets are written by Tor-Arne Dahl, Trude Eikebrokk and Eirik Hanssen at Oslo and Akershus University College of Applied Sciences.
- The windows batch-files, GNU/Linux shellscripts, and the xproc-pipeline are written by Eirik Hanssen. 
- This package also uses JATS tools that contains XSLT stylesheets developed by Wendell Piez for National Library of Medicine. The scripts from the JATS tools package are located in the assets/jats-xslt folder.

## Maintainer and official website
This package is hosted on github: https://github.com/eirikhanssen/jats2epub
ssh-clone url: git@github.com:eirikhanssen/jats2epub.git
Author and maintainer of this readme and the jats2epub package on GitHub is Eirik Hanssen, Oslo and Akershus University College of Applied Sciences

Contact: eirik dot hanssen at hioa dot no

## Releases
### 0.9 pre-release.
This is the working version that was ready at the time of submitting the article.

### 1.0-RC1 
This is the first release where it is possible to run jats2epub from any folder.
Version 1.0, Release Candidate 1, there are still some quirks that should be figured out, and the documentation needs updating.

# Status 2015-10-22
## New 'version': 1.0-RC1

### Run from any folder
jats2epub has now been reworked so that it can be run from any folder on linux and windows if the installation instructions are followed.

Windows users MUST use the ClickMeToStart.bat file to set up their environment and open the cmd.exe terminal.

Gnu/Linux, unix and MacOSX users simply need to open a shell/terminal to start using jats2epub provided jats2epub install instructions are followed.

### Removed 3rd party programs from the package
I have also removed 3rd party tools from the package, and instead I have provided instrucitons on how to install on windows and Gnu/Linux like systems.
This means that xmlcalabash, epubcheck and UnixUtils date.exe is no longer distributed in this package.

The user has to download and set up xmlcalabash, epubcheck and kindlegen according to instructions to get jats2epub working.

I met a problem where I couldn't run UnixUtils date.exe on windows because of group policies enforced by the system admins. 
Unix Utils date.exe was used to provide a proper timestamp for filename generation. I have since learned to create executable java jar files,
and created a short simple jar program to generate this timestamp string for use in Windows since that OS doesn't have a standard sane way of 
generating a timestamp. This jar is included for the benefit of Windows users, and is automatically used by jats2epub.bat.

### Changes in where files are stored
Since jats2epub no longer has to be run from the folder where it is installed, I have changed where files are stored.

#### Windows
converted files are stored in jats2epub\converted
temporary files are stored in jats2epub\latest-run (these are cleaned out when a new conversion run is initiated)

#### Gnu/Linux, unix, MacOSX
converted files will be copied to two places:

1) to the current directory where you run the command from
2) a backup of the files is copied to ~/.jats2epub/converted

temporary files will be stored in ~/.jats2epub/latest-run (these will be cleaned out when a new conversion run is initiated)


## Status 2015-04-17
Several improvements have been made: Code has been cleaned up for better readability and several bugs have been fixed.
It is now easier to troubleshoot, because all intermediate documents are saved in output_working folder after each run.
To preview html-file that will be used for upload to html fulltext, just open output_working/60-webversion.html. All 
href/src links to stylesheets and images have been altered to work from this location.

## Related projects
I am also working on an automatic tagging solution where after finishing the manuscript it can be automatically tagged to JATS XML.

I am currently working with two xml-based formats for the automatic tagging solution:

- https://github.com/eirikhanssen/odf2jats - automatic tagging using Open Document Format as a base
- https://github.com/eirikhanssen/ooxml2jats - automatic tagging using Office Open XML as a base

## Future possible addons/changes to jats2epub
- Process <given-names> elements with regexp to make sure the initials are properly punctuated. 
    - If the xml file is tagged using only letters with no punctuation, if there is only one author, a dot is added to the end of the initial in the reference list, but if there are more authors, only the last author's initial will get a dot after the initial. This is a bug. Now it is important that the initials in <given-names> are given proper punctuation by the person tagging the xml-file. It would be better if the process_jats.xpl pipeline took care of it. Also we could allow to markup initials where an author has several given names using only initials and no punctuation, and let process_jats.xpl take care of the rest.
- Further code cleanup:
    - Some issues have been fixed downstream instead of upstream. (A problem that has been fixed by modifying the 
      erronous document instead of preventing the error from happening in the first place).
      It would be better to make sure the error didn't happen in the first place:
          - Problem with empty namespaces.
          - Problem with using element-citation elements for book-chapter type references.
- Implement a module to generate PDF from the base xml-file by using XSL-FO and ApacheFOP.
    - This was in scope for the original project proposal, but has been put on hold for now. The journals provide PDF which
      they have converted from the .docx version of the article. Later with time permitting, a PDF-module could 
      improve the consistency of the generated PDFs.
- Enhancements to html fulltext display:
    - In the web browser context: When hovering above a footnote reference or a cited reference in the text, display a popup with the full contents of the footnote / reference in question. This could be implemented using JavaScript/CSS.
    - Generate a clickable linked list with a table of contents (TOC) based on the document layout for easier navigation. The linked list TOC could be accessible as a drop-down menu with fixed CSS positioning.
        - This could be implemented using JavaScript/CSS.
- ePub enhancements:
    - Review ePub css based on WAI guidelines for readability. Speficically look at line height and space between pharagraphs/tables.
    - Look at css for displaying tables.

## Todo
- style footnote links better to improve visibility and click-/touchability
    ```sup a[href^='#ftn']:link, sup a[href^='#ftn']:visited {
           border-radius: 25%;
           width: 2em; 
           font-weight: bold; 
           padding: .1em .25em; 
           background-color: yellow; border: 1px solid blue;
       }
       sup a[href^='#ftn']:link:hover {
           box-shadow: 0 0 .5em gray;
       }```

## Known bugs
- Issue is formatted within square brackets [issue] when it should be in paranthesis (issue)
    - **Condition that trigger the bug**: element citation for journal articles where issue is marked up, but no volume.
- Windows only: if using backslashes in the first parameter in the path for the input xml-file, there will be a java-error, the backslash will be reported as an illegal character.
    - workaround is to replace backslashes in path to the input-xml file with forward slashes or to run jats2epub from the same folder as the xml input file.
    - note that windows users must still use backslashes in the path of the asset folder when using two parameters
