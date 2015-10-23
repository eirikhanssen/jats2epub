jats2epub
=========

**jats2epub v1.0-RC1 does not work out of the box! You need to follow the simple install instructions found in the README folder.**

## Purpose
Create valid EPUB documents from journal articles marked up using the NISO JATS XML tagset.

## Background
My collegues started this project, with the aim of creating a a new, xml-based workflow to publish articles in the EPUB format in electronic Open Access journals.

This work resulted in a paper published in Code4lib: EPUB as publication format in Open Access journals: Tools and workflow. By Trude Eikebrokk, Tor Arne Dahl and Siri Kessel, Oslo and Akershus University College of Applied Sciences. http://journal.code4lib.org/articles/9462

## Input and output

Windows users MUST use the ClickMeToStart.bat file to set up their environment - this will start cmd.exe (terminal look-alike) where jats2epub can be invoked using commands.

Gnu/Linux, Unix and MacOSX users simply need to open a shell/terminal to start using jats2epub provided the install instructions are followed.

### Typical use
```jats2epub article.xml [required] folder-with-extras [optional]```

### Input arguments

    1) [required] - A document tagged as JATS XML
    2) [optional] - A folder. The contents of this folder will be copied into the epub structure in the EPUB folder

### Outputs
- article.xml (this is just a copy of the xml input file)
- article.html 
- article.epub
- article.mobi (requires amazon kindlegen to be installed)

## Journal Article Tag Suite (JATS)
JATS is a XML vocabulary for research papers.
- JATS overview: http://jats.nlm.nih.gov/publishing/ 
- JATS Tag Library: http://jats.nlm.nih.gov/publishing/tag-library/ 

## Technical overview at a glance
jats2epub is a script, jats2epub.bat used on windows and jats2epub (shellscript) used on Gnu/Linux, Unix and MacOSX systems.

The jats2epub script takes care of file copying and calling the different utilities needed to do the conversion.

jats2epub uses xmlcalbash, a java based XProc processor, to run a XProc pipeline (jats2epub.xpl). 

This pipeline (jats2epub.xpl) defines in what order and how the xml document should be transformed in several stages to produce most of the files needed to build an epub archive.

Then jats2epub will use epubcheck, a java based epub validation tool and packager to pack the .epub archive.

The process is automated, all you need to type to use the jats2epub tool is this single command: 

```jats2epub path/to/article.xml [required] path/to/folder [optional]```

Demo examples to try out first:

```jats2epub source-xml/saks.xml```

```jats2epub source-xml/spehar.xml source-xml/spehar```

Windows users need to use the backslash (\\) as a path separator instead of the slash (/) used in these examples.

# Install instructions
Since 3rd party applications are no longer distributed as part of jats2epub, it will not work out of the box!

The user will need to download and and install the following if not present on the system:
- java
- xmlcalabash
- epubcheck
- kindlegen

Find detalied install instructions in the install files:
- README/install-windows.txt
- README/install-linux-all-users.txt
- README/install-linux-single-user.txt

## Authors
- The initial XSLT-stylesheets were written by Tor-Arne Dahl, Trude Eikebrokk and Eirik Hanssen at Oslo and Akershus University College of Applied Sciences.
- The windows batch-files, GNU/Linux shellscripts, and the xproc-pipeline are written by Eirik Hanssen. 
- Several XSLT stylesheets used are from JATS tools developed by Wendell Piez for National Library of Medicine
    - these are in the folder: jats2epub/pipeline/jats-xslt
    - source: https://github.com/ncbi/JATSPreviewStylesheets
- Several of the stylesheets used are vertical customization of JATS tools. This means that several of the JATS XSLT stylesheets have been imported, and several rules have been overridden or extended to suit our workflow.
    - these are in the folder: jats2epub/pipeline/hioa-xslt

## Maintainer and official website
jats2epub is hosted on: https://github.com/eirikhanssen/jats2epub
Maintainer: Eirik Hanssen, Oslo and Akershus University College of Applied Sciences
Contact: eirik dot hanssen at hioa dot no

## Releases
### v0.9 (2014-04-16)
This is the working version that was ready at the time of submitting the article. It should work out of the box if java is installed. Some limitations that have been fixed later are: 
- Only possible to run the jats2epub command from within the source folder
- Incomplete toc.ncx (navigation aid)
- Many 3rd party applications were included, this increased the download size but also allowed jats2epub to run 'out of the box'

### 1.0-RC1 (2015-10-23)
There are still some quirks that should be figured out, and the documentation needs to be updated.
- Now possible to run jats2epub from any folder, provided it is installed correctly.
- Now toc.ncx (navigation aid) will include navigation links to all the headings in the article
- Tweaking of the typography of the epub.
- 3rd party applications have to be downloaded separately (see install instructions):
  	- xmlcalabash
    - epubcheck
    - kindlegen

# Status updates
## 1.0-RC1 (2015-10-23)

### Removed 3rd party programs from the package
I have also removed 3rd party tools from the package, and instead I provide instructions on how to get/install the 3rd party applications on windows and Gnu/Linux like systems.

This means that xmlcalabash and epubcheck  is no longer distributed in this package.

Some of the utils previously included for windows compatibility are no longer necessary.

In the v0.9 release, i used a commandline zip-utility to pack the epub-archive. Later I have learned that epubcheck that is used to validate an epub archive, can also be used to pack the expanded epub archive to a .epub file. date.exe from unix utils was needed on windows to generate a timestamp for filename creation.

I had some issues where I couldn't run this in a work environment because of group policies enforced by administrators, so I wrote a small java .jar program to generate a timestamp. This is included and used by the jats2epub.bat file for windows users.

### Changes in where files are stored

#### Windows
converted files are stored in jats2epub\converted
temporary files are stored in jats2epub\latest-run (these are cleaned out when a new conversion run is initiated)

#### Gnu/Linux, unix, MacOSX
converted files will be copied to two places:

    1) to the current directory where you run the command from
    2) a backup of the files is copied to ~/.jats2epub/converted

temporary files will be stored in ~/.jats2epub/latest-run (these will be cleaned out when a new conversion run is initiated)

## Status update (2015-04-17)
Several improvements have been made: Code has been cleaned up for better readability and several bugs have been fixed.
It is now easier to troubleshoot, because all intermediate documents are saved in output_working folder after each run.
To preview html-file that will be used for upload to html fulltext, just open output_working/60-webversion.html. All 
href/src links to stylesheets and images have been altered to work from this location.

## Related projects
I am also working on an automatic tagging solution where after finishing the manuscript it can be automatically tagged to JATS XML.

I am currently working with two xml-based formats for the automatic tagging solution:

### odf2jats
https://github.com/eirikhanssen/odf2jats
A semi automatic tagging conversion from Open Documen Format (.odt) to JATS (.xml)
Using odf2jats makes it possible to dramatically decrease the time it takes to produce JATS .xml.

### ooxml2jats
https://github.com/eirikhanssen/ooxml2jats
Same objective as odf2jats but with the Office Open Xml (.docx) as a source to generate JATS (.xml)
I started with ooxml2jats, but took the ideas and built odf2jats. ooxml2jats hasn't been worked on much, but could share most of the logic from odf2jats.

## Future possible improvements to jats2epub
- Process <given-names> elements with regexp to make sure the initials are properly punctuated. 
    - If the xml file is tagged using only letters with no punctuation, if there is only one author, a dot is added to the end of the initial in the reference list, but if there are more authors, only the last author's initial will get a dot after the initial. This is a bug. Now it is important that the initials in <given-names> are given proper punctuation by the person tagging the xml-file. It would be better if the process_jats.xpl pipeline took care of it. Also we could allow to markup initials where an author has several given names using only initials and no punctuation, and let process_jats.xpl take care of the rest.
- Further code cleanup:
    - Some issues have been fixed downstream instead of upstream. (A problem that has been fixed by modifying the 
      erronous document instead of preventing the error from happening in the first place).
      It would be better to make sure the error didn't happen in the first place:
          - Problem with empty namespaces.
          - Problem with using element-citation elements for book-chapter type references.
- Implement PDF generation from JATS xml source using XSL-FO and ApacheFOP or LaTeX as an intermediary format.
- Enhancements to html fulltext display:
    - In the web browser context: When hovering above a footnote reference or a cited reference in the text, display a popup with the full contents of the footnote / reference in question. This could be implemented using JavaScript/CSS.
    - Generate a clickable linked list with a table of contents (TOC) based on the document outline for easier navigation. The linked list TOC could be accessible as a drop-down menu with fixed CSS positioning.
        - This could be implemented using JavaScript/CSS.
- ePub enhancements:
    - Review ePub css based on WAI guidelines for readability. Speficically look at line height and space between pharagraphs/tables.
    - Look at css for displaying tables and bring it into APA6 standards.

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