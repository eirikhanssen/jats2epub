<?xml version="1.0" encoding="UTF-8"?>
<!--
	Overview:
	
	This is a XProc pipeline designed to do the bulk of the work in creating ePub from a jats tagged input xml document.
	The current version of XProc lacks some features such as file system manipulation and zip/unzip functionality,
	so it has to be wrapped in a shellscript for the ePub generation to be automatic. These scripts should also be included in your package.
	This XProc pipeline needs to be run on an XProc processor such as xmlcalabash that in turn uses java runtime environment.
	
	To run this pipeline with calabash use the command: calabash -i source=path_to_jats_tagged_xml-file path_to_process-jats-xml.xpl
	The supplied scripts (jats2epub.bat for windows and jats2epub for linux utilize this command so that you don't have to'.)
	
	If the folder output_working doesn't exist, running this pipeline results in it being created.
	xml-documents resulting from each step in the xproc-pipeline will be stored in this folder for 
	inspection and troubleshooting purposes. When running jats2epub that is using this pipeline
	the contents of output_working folder will be deleted to prepare for a clean run.
	Note that you might have to change the path/filenames to the different stylesheets to match your system.
	because obviously, the stylesheets we use here are tailored to meet our needs.
	
	License:
	
	This file is part of jats2epub.

	jats2epub is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	jats2epub is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with jats2epub.  If not, see <http://www.gnu.org/licenses/gpl.html
	
	Contact: eirik hanssen at hioa dot no
-->

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" name="process-jats-xml" version="1.0">

<!-- 
	EH 2013-11-25: the source input to this xproc pipeline is given in the command prompt that calls the pipeline. 
-->

  <p:input port="source"/>
  <p:input port="parameters" kind="parameter"/>

<!-- 
	EH 2013-11-25: <p:output> displays all files that were saved to disk in <c:result> 
	elements that are output to the commandline
-->

  <p:output port="result" sequence="true">
    <p:pipe step="article-original" port="result"/>
    <p:pipe step="article-APAcit-formatted" port="result"/>
    <p:pipe step="article-APAcit-formatted-mixed-citation-bugfix" port="result"/>
    <p:pipe step="article-idfix" port="result"/>
    <p:pipe step="article-xhtml" port="result"/>
    <p:pipe step="article-xhtml-namespace-fixed" port="result"/>
    <p:pipe step="article-xhtml-web-version" port="result"/>
    <p:pipe step="content-opf" port="result"/>
    <p:pipe step="toc-ncx" port="result"/>
    <p:empty/>
  </p:output>
  
<!-- EH 2013-11-25: Stores the unchanged xml-->
<p:store href="output_working/00-original.xml" name="article-original"/>

  <p:xslt name="format-APA-citations" version="2.0">
    <!-- EH 24.11.2013: Citations are APA-formatted. -->
    <p:input port="source">
      <p:pipe step="process-jats-xml" port="source"/>
    </p:input>
    <p:input port="stylesheet">
      <!-- hioa-APAcit.xsl imports jats-APAcit.xsl -->
      <p:document href="assets/hioa-xslt/hioa-citations-prep-APAcit.xsl"/>
    </p:input>
  </p:xslt>

<!-- Stores the APAcit formatted xml-document -->
  <p:store href="output_working/10-article-APAcit-formatted.xml" name="article-APAcit-formatted"/>

<!--
	EH 2014-03-14: Fix <ref>elements that stem from book-chapter type references, 
	because of a bug with XSLT processing in the previous step the content's is not 
	wrapped in <mixed-citation>...</mixed-citation>
	This XSLT stylesheet remedies the problem and wraps the contents of <ref> element 
	with <mixed-citation> element if it is not already done
-->

  <p:xslt name="fix-mixed-citation-bug" version="1.0">
    <p:input port="source">
      <p:pipe step="format-APA-citations" port="result"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="assets/hioa-xslt/hioa-mixed-citations-bugfix.xsl"/>
    </p:input>
  </p:xslt>

<!-- Stores the APAcit formatted mixed-citation-bugfixed xml-document -->
<p:store href="output_working/20-article-APAcit-formatted-mixed-citation-bugfix.xml" name="article-APAcit-formatted-mixed-citation-bugfix"/>

<!-- 
	EH 2014-03-14: The xml arriving at this stage potentially has a problem with missing id on graphics.
	The id on graphics is required for the ePub to validate. Missing id, means that 
	the generated content.opf will fail to validate. This time we also demonstrate
	that you can include xslt inline in the xproc pipeline, instead of referencing 
	an external file. The xslt code here checks if graphic elements have an id, and 
	if it is not empty. If not, generate this id. Other elements are copied through unchanged.
-->

<p:xslt name="fix-missing-id-on-graphics">
  <p:input port="source">
<!--    <p:pipe step="format-APA-citations" port="result"/> -->
    <p:pipe step="fix-mixed-citation-bug" port="result"/>
  </p:input>
  <p:input port="stylesheet">
    <p:inline>
        <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

        <xsl:template match="/">
           <xsl:apply-templates/>
        </xsl:template>

        <!-- Special treatment of //graphic elements. They need to have unique id -->
       <xsl:template match="//graphic">
          <xsl:element name="{local-name()}" namespace="{namespace-uri(.)}">
            <xsl:copy-of select="@*"/>
          <xsl:choose>
             <!-- Do nothing if id is present and not empty -->
             <xsl:when test="boolean(./@id and ./@id != '')"/>
             <!-- Otherwise, add an id attribute and generate an id for it --> 
             <xsl:otherwise>
                <xsl:attribute name="id">
                   <xsl:value-of select="generate-id()"/>
                </xsl:attribute>
             </xsl:otherwise>
          </xsl:choose>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:template> 
        
        <!-- Copy over all other elements unchanged (identity transform) -->
        <xsl:template match="*">
          <xsl:element name="{local-name()}" namespace="{namespace-uri(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:template>
        </xsl:stylesheet>
    </p:inline>
  </p:input>
</p:xslt>

<!-- Stores xml where potential missing id is fixed on graphic elements ) -->
<p:store href="output_working/30-article-APAcit-formatted-mixed-citations-bugfix-idfix.xml" name="article-idfix"/>

  <p:xslt name="display-xhtml" version="2.0">
  <p:input port="source">
    <p:pipe step="fix-missing-id-on-graphics" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <!-- hioa-xhtml.xsl imports jats-html.xsl -->
      <p:document href="assets/hioa-xslt/hioa-xhtml.xsl"/>
    </p:input>
  </p:xslt>

<!-- Stores the xhtml display document for use in ePub ( at this stage we have problems with elements that have no namespace - xmlns="" ) -->
<p:store href="output_working/40-article-display.html" name="article-xhtml"/>

<!-- Casts all elements to xhtml namespace. This remedies the problem where some elements get no namespace (xmlns="").-->
<p:xslt name="cast-to-xhtml" version="1.0">
  <p:input port="source">
    <p:pipe step="display-xhtml" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <!-- hioa-xhtml-namespace-fix.xsl imports the default xhtml-ns.xsl -->
      <p:document href="assets/hioa-xslt/hioa-xhtml-namespace-fix.xsl"/>
    </p:input>
  </p:xslt>
  
<!-- EH 2013.11.25: Stores the xhtml-casted display document for use in ePub in the ePub-folder-structure-->
<!-- EH 2013.11.25: Adding the correct doctype required for the ePub format-->
<p:store omit-xml-declaration="true" indent="true" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" href="output_working/epub/OEBPS/index.html" name="article-xhtml-namespace-fixed"/>

<!-- EH 2014-03-14: For the web-version we don't want the xml processing instruction at the beginning -->
<p:xslt name="cast-to-xhtml-and-remove-xml-processing-instruction" version="1.0">
  <p:input port="source">
    <p:pipe step="display-xhtml" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <!-- this xslt stylesheet removes xml processing instruction and imports assets/jats-xhtml/post/xhtml-ns.xsl -->
      <p:document href="assets/hioa-xslt/hioa-fix-ns-and-remove-xml-processing-instruction.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-- Saves a version for web display -->
<p:store omit-xml-declaration="true" indent="true" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" href="output_working/article.html" name="article-xhtml-web-version"/>

<!-- EH 2013-12-02: Generate content.opf-->
<p:xslt name="generate-content-opf" version="1.0">
  <p:input port="source">
    <p:pipe step="fix-missing-id-on-graphics" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <p:document href="assets/hioa-xslt/epub-content.opf.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:store href="output_working/epub/OEBPS/content.opf" indent="true" name="content-opf"/>
  
  <!-- EH 2013-12-02: Generate content.opf-->
<p:xslt name="generate-toc-ncx" version="1.0">
  <p:input port="source">
    <p:pipe step="format-APA-citations" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <p:document href="assets/hioa-xslt/epub-toc.ncx.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:store href="output_working/epub/OEBPS/toc.ncx" indent="true" name="toc-ncx"/>
  
</p:declare-step>

