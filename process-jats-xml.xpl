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

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" name="process-jats-xml" version="1.0">

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
    <p:pipe step="step-00-original-xml" port="result"/>
    <p:pipe step="step-10-xml-article-APAcit-preprocessed" port="result"/>
    <p:pipe step="step-15-xml-book-chapter-bugfixed" port="result"/>
    <p:pipe step="step-20-xml-article-bugfix-book-chapter-mixed-citation" port="result"/>
    <p:pipe step="step-30-xml-article-bugfix-graphic-missing-id" port="result"/>
    <p:pipe step="step-40-xhtml-article-display" port="result"/>
	<!-- html-file used in the epub -->
    <p:pipe step="epub-index-html" port="result"/>
	<!-- Storing a copy for inspection -->
    <p:pipe step="step-50-xhtml-namespace-fixed-epub-version" port="result"/>
	<!-- html-file for upload in OJS -->
    <p:pipe step="article-webversion" port="result"/>
	<!-- Storing a copy for inspection -->
    <p:pipe step="step-60-webversion" port="result"/>
    <p:pipe step="content-opf" port="result"/>
	<!-- Storing a copy for inspection -->
	<p:pipe step="step-70-content-opf" port="result"/>
    <p:pipe step="toc-ncx" port="result"/>
	<!-- Storing a copy for inspection -->
    <p:pipe step="step-80-toc-ncx" port="result"/>
  </p:output>
  
<!-- EH 2013-11-25: Stores the unchanged xml-->
<p:store href="output_working/00-original.xml" name="step-00-original-xml"/>

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
  <p:store href="output_working/10-xml-article-APAcit-preprocessed.xml" name="step-10-xml-article-APAcit-preprocessed"/>

<!--
	EH 2014-03-14: Fix <ref>elements that stem from book-chapter type references, 
	because of a bug with XSLT processing in the previous step the content's is not 
	wrapped in <mixed-citation>...</mixed-citation>
	This XSLT stylesheet remedies the problem and wraps the contents of <ref> element 
	with <mixed-citation> element if it is not already done
-->

  <p:xslt name="fix-element-citation-to-mixed-citation-bug" version="1.0">
    <p:input port="source">
      <p:pipe step="format-APA-citations" port="result"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="assets/hioa-xslt/hioa-mixed-citations-bugfix.xsl"/>
    </p:input>
  </p:xslt>

<p:store name="step-15-xml-book-chapter-bugfixed" href="output_working/15-xml-article-APAcit-preprocessed-book-chapter-refs-bugfixed.xml"/>

<p:identity name="fixed-book-chapter-references">
  <p:input port="source">
    <p:pipe step="fix-element-citation-to-mixed-citation-bug" port="result"/>
  </p:input>
</p:identity>

<!-- EH 2014-04-14: Applying regex to fix some punctuation errors in <mixed-citation> elements where there are uri's at the end. -->
  
<!-- EH 2014-04-14: Delete only the last text nodes containing "." followed only by any number of whitespace in <mixed-citation> elements following directly after <uri> -->
<p:delete match="//mixed-citation/text()[position() = last()][preceding-sibling::uri][matches(., '^\.\s*$')]"/>
<!-- EH 2014-04-14: Replace the ", " with ". " _in_the_end_ of the text-node immediately followed by <uri>...</uri> in <mixed-citation> elements -->
<p:string-replace match="//mixed-citation/text()[following-sibling::*[1][self::uri]][matches(., ',\s$')]" replace="replace(., ',\s$', '. ')"/>

<!--
    EH 2014.04.23: We still have an issue with references with more than 7 authors. 
    According to the apa style APA Formatting and Style guide, there should be no more than 7 authors listed.
    After the sixth author's name, an ellipsis should be used, followed by the final author's name.
     -->

<p:identity name="fixed-mixed-citation-elements"/>

<!-- Stores the APAcit formatted mixed-citation-bugfixed xml-document -->
<p:store href="output_working/20-xml-article-bugfix-book-chapter-mixed-citation.xml" name="step-20-xml-article-bugfix-book-chapter-mixed-citation"/>

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
    <p:pipe step="fixed-mixed-citation-elements" port="result"/>
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
<p:store href="output_working/30-xml-article-bugfix-graphic-missing-id.xml" name="step-30-xml-article-bugfix-graphic-missing-id"/>

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
<p:store omit-xml-declaration="true" indent="true" href="output_working/40-xhtml-article-display.html" name="step-40-xhtml-article-display"/>

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
<p:store omit-xml-declaration="true" indent="true" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" href="output_working/epub/OEBPS/index.html" name="epub-index-html"/>
<!-- EH 2014-03-22: Storing a copy for inspeciton -->
<p:store omit-xml-declaration="true" 
	indent="true" encoding="utf-8" 
	doctype-public="-//W3C//DTD XHTML 1.1//EN" 
	doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" 
	href="output_working/50-xhtml-namespace-fixed-epub-version.html" 
	name="step-50-xhtml-namespace-fixed-epub-version">
	<p:input port="source">
		<p:pipe step="cast-to-xhtml" port="result"/>
	</p:input>
</p:store>

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

<!-- Removing xhtml namespace -->
<p:namespace-rename from="http://www.w3.org/1999/xhtml" to="" name="namespace-removed">
	<p:input port="source">
		<p:pipe step="cast-to-xhtml-and-remove-xml-processing-instruction" port="result"/>
	</p:input>
</p:namespace-rename>


<!--
	EH 2014-03-24: OJS-compatibility complicates things. Have to add an id that will 
	be used to target css rules. This is because the html-file will be included 
	in another webpage in the OJS system.
	
	Prefixing all css rules of the css stylesheet with this id ensures that the rules
	in the stylesheet won't afffect the rest of the webpage this html-file is embedded in
	
	First I tried adding this id to body. When the DOM is created, however, it will be in 
	'tag-soup' mode since the OJS webpage won't validate.
	
	(OJS version 2.3.8 simply includes the whole uploaded html-file witin a div 
	tag in the webpage). I tried a solution where I extracted the body from the 
	article html file and renamed it to a div tag and uploaded this html-fragment file.
	This works in OJS 2.3.8, because OJS recognizes it as a html-file based on the filename ending.
	However, when I tried in the latest stable version of OJS, OJS seems to check for 
	<!DOCTYPE ..> tag also. Therefore, a html-fragment like I tried first is detected 
	as plaintext by the OJS system. When viewing a file OJS recognizes as text/plain,
	OJS simply displays this file fragment without embedding it in its own page.
	
	Because of this inconsistent behaviour with OJS, I have decided to abandon 
	trying to make the OJS webpage with the HTML file validate for now. The HTML
	file uploaded to OJS should still validate by itself though.
	
	But still the css needs to be targeted right, so I decided to add this div to 
	the first child div of the article html version intended for display in OJS.
-->

<p:xslt name="wrap-body-contents-in-div">
	<p:input port="source"/>
	<p:input port="stylesheet">
		<p:inline>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Special treatment of body-element, need to wrap contents in a div with id (for OJS compatibility reasons) -->
	<xsl:template match="html/body">
	<body>
		<div id="pp-ojs-article">
			<xsl:apply-templates/>
		</div><!-- pp-ojs-article -->
	</body>
	</xsl:template>

	<!-- Copy over all other elements unchanged (identity transform) -->
	<!-- EH: 2014-05-14: Trying a different identity transform to keep comments -->
	  <xsl:template match="@*|*|comment()">
      <xsl:copy>
        <xsl:apply-templates select="*|@*|text()|comment()"/>
      </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
		</p:inline>
	</p:input>
</p:xslt>

<!-- Removing css-reference from the html file for web upload. The rules will be in 
the same css as in OJS for that journal. This is to prevent a bug with OJS handling 
of relative url referenced css in the html fulltext that will make css validation fail and 
prevent css from functioning. -->
<p:delete match="//link[contains(@href,'css/hioa-epub.css')]"/>

<!-- EH 2014-09-03: for the html-file that will be uploaded to a server, we're linking to the cc by image hosted from creativecommons.org as well as linking to the license. -->
<p:replace match="//img[@src='images/cc-license.png']">
	<p:input port="replacement">
		<p:inline><a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons - Attribution 3.0 Unported  (CC BY 3.0)"><img alt="Attribution 3.0 Unported (CC BY 3.0)" src="http://i.creativecommons.org/l/by/3.0/88x31.png"/></a></p:inline>
	</p:input>
</p:replace>

<p:identity name="webversion-for-ojs-upload"/>

<!-- Saves a version for web display in OJS with html4.01 doctype -->
<p:store omit-xml-declaration="true"
	indent="true" encoding="utf-8"
	method="html"
	version="4.0"
	doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	doctype-system="http://www.w3.org/TR/html4/loose.dtd"
	href="output_working/article-webversion.html"
	name="article-webversion"/>

<!-- 
    EH 2014-03-27. The html fulltext version cannot reference css, and images must 
    be relative in the same folder as the html-file because of OJS
    compatibility reasons. I still want to inspect the html fulltext copy and view
    it in a way that represents the way it is displayed in the OJS context. Therefore
    I change the reference to the css and images used in the article so that 
    the fulltext html copy can be viewed in a browser in output_working.  -->
    
<p:identity><p:input port="source"><p:pipe step="wrap-body-contents-in-div" port="result"/></p:input></p:identity>

<!-- EH 2014-03-27: changing the css stylesheet reference. -->
<p:string-replace match="//link[contains(@href,'css/hioa-epub.css')]/@href" replace="'../assets/web-template/css/pp-just-article.css'"/>

<!--EH 2014-03-27: changing the image references to the html fulltext copy to 
    facilitate easier troubleshooting -->

<!-- EH 2014-03-27: changing the img src references. -->
<p:string-replace match="*[exists(//img/@src)]/@src" replace="concat('epub/OEBPS/', .)"/>

<p:identity name="webversion-for-ojs-upload-copy-with-css-and-image-ref"/>

<!-- EH 2014-03-22: Storing the html fulltext copy for inspeciton -->
<p:store omit-xml-declaration="true" 
	indent="true" encoding="utf-8"
	method="html"
	version="4.0"
	doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	doctype-system="http://www.w3.org/TR/html4/loose.dtd"
	href="output_working/60-webversion.html" 
	name="step-60-webversion"/>

<!-- EH 2013-12-02: Generate content.opf, a required file in an epub publication -->
<p:xslt name="generate-content-opf" version="1.0">
  <p:input port="source">
    <p:pipe step="fix-missing-id-on-graphics" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <p:document href="assets/hioa-xslt/epub-content.opf.xsl"/>
    </p:input>
  </p:xslt>

<!-- EH 2014-03-22: storing content.opf in epub structure -->
<p:store href="output_working/epub/OEBPS/content.opf" indent="true" name="content-opf"/>

<!-- EH 2014-03-22: storing a copy for inspection -->
<p:store href="output_working/70-content.opf" indent="true" name="step-70-content-opf">
	<p:input port="source"><p:pipe step="generate-content-opf" port="result"/></p:input>
</p:store>
  
  <!-- EH 2013-12-02: Generate toc.ncx, a required file in an epub publication -->
<p:xslt name="generate-toc-ncx" version="1.0">
  <p:input port="source">
    <p:pipe step="format-APA-citations" port="result"/>
  </p:input>
    <p:input port="stylesheet">
      <p:document href="assets/hioa-xslt/epub-toc.ncx.xsl"/>
    </p:input>
  </p:xslt>

<!-- EH 2014-03-22: storing content.opf in epub structure -->
<p:store href="output_working/epub/OEBPS/toc.ncx" indent="true" name="toc-ncx"/>

<!-- EH 2014-03-22: storing a copy for inspection -->
<p:store href="output_working/80-toc.ncx" indent="true" name="step-80-toc-ncx">
	<p:input port="source"><p:pipe step="generate-toc-ncx" port="result"/></p:input>
</p:store>

</p:declare-step>

