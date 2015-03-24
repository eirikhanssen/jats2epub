jats2epub
=========

## Purpose
Create validating ePub publications from journal articles marked up using the NISO JATS xml tagset.

## Background
This package was created in a project to create a new, xml-based workflow to publish OpenAccess articles in electronic journals in the ePub format.
You might be interested in reading about this project in the article that is published in Code4lib: EPUB as publication format in Open Access journals: Tools and workflow. By Trude Eikebrokk, Tor Arne Dahl and Siri Kessel, Oslo and Akershus University College of Applied Sciences. Read the article at Code4lib: http://journal.code4lib.org/articles/9462

## Input and output
As input it takes an article tagged in the Journal Archive Tag Suite (JATS) XML format, and optionally a folder with extra content to be copied into to the epub-structure (such as images). As output an ePub file and html-file is generated and optionally also a .mobi file converted from the epub file.

## Technical overview
This package uses XML Calabash (a java-based XProc processor built on top of saxon) to process the XProc pipeline, process-jats.xpl, that transforms the xml-document in stages using a mix of XSLT and XProc steps. Since a full automation from JATS xml to final ePub can't be done in XProc yet, calling the XProc pipeline has been wrapped in a script. 
For windows, a .bat batchfile and for linux a shellscript. 
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

### Current
Several improvements have been made: Code has been cleaned up for better readability and several bugs have been fixed.
It is now easier to troubleshoot, because all intermediate documents are saved in output_working folder after each run.
To preview html-file that will be used for upload to html fulltext, just open output_working/60-webversion.html. All 
href/src links to stylesheets and images have been altered to work from this location.

## Future possible addons/changes
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

## Known bugs
- Issue is formatted within square brackets [issue] when it should be in paranthesis (issue)
    - **Condition that trigger the bug**: element citation for journal articles where issue is marked up, but no volume.
