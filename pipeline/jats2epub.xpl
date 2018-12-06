<?xml version="1.0" encoding="UTF-8"?>
<!--
	Overview:
	
	This is a XProc pipeline designed to do the bulk of the work in creating various files needed to build an ePub from a JATS tagged input xml document.
	This XProc pipeline needs to be run on an XProc processor such as xmlcalabash.

	If you're new to XProc, there is a good guide at http://xprocbook.com/

	This XProc pipeline in turn calls several XSLT stylesheets to do various tasks and routing XML documents in progress.

	The XSLT stylesheets, as well as the css-templates, have been tailored to fit our workflow, but they can be further tweaked and customized by the user to get a desired output.

	This pipeline is called from the jats2epub shellscript, but can also be run directly from the commandline with calabash:
		calabash -i source=path/to/article.xml path/to/jats2epub.xpl
	
	Using the shellscript/batch file, jats2epub, is the recommended way of running this pipeline because some tasks have to be done on the OS level. 
	
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

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/" xmlns:mml="http://www.w3.org/1998/Math/MathML"
	name="jats2epub" version="1.0">

	<p:input port="source"/>
	<p:input port="transform" kind="parameter"/>
	<!-- work_dir - where the files will be saved. defaults to latest-run folder in folder where jats2epub is located -->
	<p:option name="work_dir" select="'latest-run'"/>

	<!-- EH 2013-11-25: <p:output> displays all files that were saved to disk in <c:result> elements -->
	<p:output port="result" sequence="true">
		<p:pipe step="step-00-original-xml" port="result"/>
		<p:pipe step="step-10-xml-article-APAcit-preprocessed" port="result"/>
		<p:pipe step="step-15-xml-book-chapter-bugfixed" port="result"/>
		<p:pipe step="step-20-xml-article-bugfix-book-chapter-mixed-citation" port="result"/>
		<p:pipe step="step-30-xml-article-bugfix-graphic-missing-id" port="result"/>
		<p:pipe step="step-40-xhtml-article-display" port="result"/>
		<!-- html-file used in the epub -->
		<p:pipe step="epub-index-html" port="result"/>
		<p:pipe step="step-50-xhtml-namespace-fixed-epub-version" port="result"/>
		<!-- html-file for upload in open journal systems -->
		<p:pipe step="article-webversion" port="result"/>
		<p:pipe step="step-60-webversion" port="result"/>
		<p:pipe step="content-opf" port="result"/>
		<p:pipe step="step-70-content-opf" port="result"/>
		<p:pipe step="toc-ncx" port="result"/>
		<p:pipe step="step-80-toc-ncx" port="result"/>
	</p:output>

	<!-- EH 2013-11-25: Stores the unchanged xml-->
	<p:store name="step-00-original-xml">
		<p:with-option name="href" select="concat($work_dir, '00-original.xml')"/>
	</p:store>

	<p:identity name="document-source">
		<p:input port="source">
			<p:pipe port="source" step="jats2epub"/>
		</p:input>
	</p:identity>

	<!-- until we transit to html5 and epub3, rely on alternative representation of equations. -->
	<p:delete name="remove-mml" match="//mml:math"/>

	<p:xslt name="fix_trans_source_issues" version="2.0">
		<p:input port="source">
			<p:pipe port="result" step="remove-mml"></p:pipe>
		</p:input>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					xmlns:xs="http://www.w3.org/2001/XMLSchema"
					exclude-result-prefixes="xs"
					version="2.0">
					<xsl:output method="xml" indent="yes"></xsl:output>
					
					<xsl:template match="element-citation[@publication-type='book-chapter']//trans-source"><trans-source><xsl:text> [</xsl:text><xsl:value-of select="."/><xsl:text>]</xsl:text></trans-source></xsl:template>
					
					<xsl:template match="@*|node()">
						<xsl:copy>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:input port="parameters">
			<p:empty></p:empty>
		</p:input>
	</p:xslt>

	<p:xslt name="format-APA-citations" version="2.0">
		<!-- EH 24.11.2013: Citations are APA-formatted. -->
		<p:input port="source">
			<p:pipe port="result" step="fix_trans_source_issues"/>
		</p:input>
		<p:input port="stylesheet">
			<!-- hioa-APAcit.xsl imports jats-APAcit.xsl -->
			<p:document href="hioa-xslt/hioa-citations-prep-APAcit.xsl"/>
		</p:input>
	</p:xslt>

	<!-- Stores the APAcit formatted xml-document -->
	<p:store name="step-10-xml-article-APAcit-preprocessed">
		<p:with-option name="href" select="concat($work_dir, '10-xml-article-APAcit-preprocessed.xml')"
		/>
	</p:store>

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
			<p:document href="hioa-xslt/hioa-mixed-citations-bugfix.xsl"/>
		</p:input>
	</p:xslt>

	<p:store name="step-15-xml-book-chapter-bugfixed">
		<p:with-option name="href"
			select="concat($work_dir, '15-xml-article-APAcit-preprocessed-book-chapter-refs-bugfixed.xml')"
		/>
	</p:store>

	<p:identity name="fixed-book-chapter-references">
		<p:input port="source">
			<p:pipe step="fix-element-citation-to-mixed-citation-bug" port="result"/>
		</p:input>
	</p:identity>

	<!-- EH 2014-04-14: Applying regex to fix some punctuation errors in <mixed-citation> elements where there are uri's at the end. -->

	<!-- EH 2014-04-14: Delete only the last text nodes containing "." followed only by any number of whitespace in <mixed-citation> elements following directly after <uri> -->
	<p:delete
		match="//mixed-citation/text()[position() = last()][preceding-sibling::uri][matches(., '^\.\s*$')]"/>
	<!-- EH 2014-04-14: Replace the ", " with ". " _in_the_end_ of the text-node immediately followed by <uri>...</uri> in <mixed-citation> elements -->
	<p:string-replace
		match="//mixed-citation/text()[following-sibling::*[1][self::uri]][matches(., ',\s$')]"
		replace="replace(., ',\s$', '. ')"/>

	<!--
    EH 2014.04.23: We still have an issue with references with more than 7 authors. 
    According to the apa style APA Formatting and Style guide, there should be no more than 7 authors listed.
    After the sixth author's name, an ellipsis should be used, followed by the final author's name.
     -->

	<p:identity name="fixed-mixed-citation-elements"/>

	<!-- Store the APAcit formatted mixed-citation-bugfixed xml-document -->
	<p:store name="step-20-xml-article-bugfix-book-chapter-mixed-citation">
		<p:with-option name="href"
			select="concat($work_dir, '20-xml-article-bugfix-book-chapter-mixed-citation.xml')"/>
	</p:store>

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
					<xsl:template match="@*|node()">
						<xsl:copy>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
	</p:xslt>

	<!-- Stores xml where potential missing id is fixed on graphic elements ) -->
	<p:store name="step-30-xml-article-bugfix-graphic-missing-id">
		<p:with-option name="href"
			select="concat($work_dir, '30-xml-article-bugfix-graphic-missing-id.xml')"/>
	</p:store>

	<p:xslt name="display-xhtml" version="2.0">
		<p:with-param name="current-date"
			select="concat('This display was generated: ' , current-date())"/>
		<p:input port="source">
			<p:pipe step="fix-missing-id-on-graphics" port="result"/>
		</p:input>
		<p:input port="stylesheet">
			<!-- hioa-xhtml.xsl imports jats-html.xsl -->
			<p:document href="hioa-xslt/hioa-xhtml.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe step="jats2epub" port="transform"/>
		</p:input>
	</p:xslt>
	

	<!-- Stores the xhtml display document for use in ePub ( at this stage we have problems with elements that have no namespace - xmlns="" ) -->
	<p:store omit-xml-declaration="true" indent="true" name="step-40-xhtml-article-display">
		<p:with-option name="href" select="concat($work_dir, '40-xhtml-article-display.html')"/>
	</p:store>

	<!-- Casts all elements to xhtml namespace. This remedies the problem where some elements get no namespace (xmlns="").-->
	<p:xslt name="cast-to-xhtml" version="1.0">
		<p:input port="source">
			<p:pipe step="display-xhtml" port="result"/>
		</p:input>
		<p:input port="stylesheet">
			<!-- hioa-xhtml-namespace-fix.xsl imports the default xhtml-ns.xsl -->
			<p:document href="hioa-xslt/hioa-xhtml-namespace-fix.xsl"/>
		</p:input>
	</p:xslt>

	<p:identity name="xhtml-ready-for-epub"/>

	<!-- EH 2013.11.25: Stores the xhtml-casted display document for use in ePub in the ePub-folder-structure-->
	<!-- EH 2013.11.25: Adding the correct doctype required for the ePub format-->
	<p:store omit-xml-declaration="true" indent="true" encoding="utf-8"
		doctype-public="-//W3C//DTD XHTML 1.1//EN"
		doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" name="epub-index-html">
		<p:with-option name="href" select="concat($work_dir, 'epub/EPUB/index.html')"/>
	</p:store>

	<!-- EH 2014-03-22: Storing a copy for inspeciton -->
	<p:store omit-xml-declaration="true" indent="true" encoding="utf-8"
		doctype-public="-//W3C//DTD XHTML 1.1//EN"
		doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
		name="step-50-xhtml-namespace-fixed-epub-version">
		<p:with-option name="href"
			select="concat($work_dir, '50-xhtml-namespace-fixed-epub-version.html')"/>
		<p:input port="source">
			<p:pipe step="xhtml-ready-for-epub" port="result"/>
		</p:input>
	</p:store>

	<!-- EH 2014-03-14: For the web-version we don't want the xml processing instruction at the beginning -->
	<p:xslt name="cast-to-xhtml-and-remove-xml-processing-instruction" version="1.0">
		<p:input port="source">
			<p:pipe step="display-xhtml" port="result"/>
		</p:input>
		<p:input port="stylesheet">
			<!-- this xslt stylesheet removes xml processing instruction and imports assets/jats-xhtml/post/xhtml-ns.xsl -->
			<p:document href="hioa-xslt/hioa-fix-ns-and-remove-xml-processing-instruction.xsl"/>
		</p:input>
	</p:xslt>

	<!-- Removing xhtml namespace -->
	<p:namespace-rename from="http://www.w3.org/1999/xhtml" to="" name="namespace-removed">
		<p:input port="source">
			<p:pipe step="cast-to-xhtml-and-remove-xml-processing-instruction" port="result"/>
		</p:input>
	</p:namespace-rename>

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
							</div>
							<!-- pp-ojs-article -->
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
	<p:replace match="//p[@class='license']">
		<p:input port="replacement">
			<p:inline>
				<p class="license"><a target="_top" rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a target="_top" rel="license" href="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>, which permits unrestricted use, distribution, and reproduction in any medium, provided the original work is properly cited.</p>
			</p:inline>
		</p:input>
	</p:replace>

	<!-- add target attribute to all external links -->
	<p:add-attribute attribute-name="target" attribute-value="_top" match="//a[@href][matches(@href, 'https?://')]"/>

	<p:identity name="webversion-for-ojs-upload"/>
	
	<!-- PREPARE WEBVERSION for OJS GALLEY UPLOAD -->
	<p:xslt version="2.0">
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="source"/>
		<p:input port="stylesheet"><p:document href="hioa-xslt/create-html5-galley.xsl"/></p:input>
	</p:xslt>
	<!--<p:xslt version="2.0">
		<p:input port="source"/>
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/" xmlns:mml="http://www.w3.org/1998/Math/MathML">
					<xsl:output exclude-result-prefixes="ncx mml"/>
					
					
					
					
					
					<xsl:template match="@*|node()">
						<xsl:copy copy-namespaces="no">
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
	</p:xslt>
	
	
	<p:insert match="html/head" position="last-child">
		<p:input port="source"/>
		<p:input port="insertion">
			<p:inline>
				<link rel="stylesheet" href="/styles/galley/pp-xhtml5-galley.css" />
			</p:inline>
		</p:input>
	</p:insert>-->

	<!-- remove namespaces that are not needed to be defined in HTML5 -->
	<p:namespace-rename apply-to="all" from="http://www.daisy.org/z3986/2005/ncx/" to=""/>
	<p:namespace-rename apply-to="all" from="http://www.w3.org/1998/Math/MathML" to=""/>
	<p:namespace-rename apply-to="all" from="http://www.w3.org/1999/xhtml" to=""/>

	<!-- Saves a version for web display in OJS with HTML5 doctype -->
	<p:store omit-xml-declaration="true" undeclare-prefixes="true" indent="true" encoding="utf-8" method="html" version="5.0"
 name="article-webversion">
		<p:with-option name="href" select="concat($work_dir, 'article-webversion.html')"/>
	</p:store>

	<!-- 
    EH 2014-03-27. The html fulltext version cannot reference css, and images must 
    be relative in the same folder as the html-file because of OJS
    compatibility reasons. I still want to inspect the html fulltext copy and view
    it in a way that represents the way it is displayed in the OJS context. Therefore
    I change the reference to the css and images used in the article so that 
    the fulltext html copy can be viewed in a browser in output_working.  -->

	<p:identity>
		<p:input port="source">
			<p:pipe step="wrap-body-contents-in-div" port="result"/>
		</p:input>
	</p:identity>

	<!-- EH 2014-03-27: changing the css stylesheet reference. -->
	<p:string-replace match="//link[contains(@href,'css/hioa-epub.css')]/@href"
		replace="'../assets/web-template/css/pp-just-article.css'"/>

	<!--EH 2014-03-27: changing the image references to the html fulltext copy to 
    facilitate easier troubleshooting -->

	<!-- EH 2014-03-27: changing the img src references. -->
	<p:string-replace match="*[exists(//img/@src)]/@src" replace="concat('epub/EPUB/', .)"/>

	<p:identity name="webversion-for-ojs-upload-copy-with-css-and-image-ref"/>

	<!-- EH 2014-03-22: Storing the html fulltext copy for inspeciton -->
	<p:store omit-xml-declaration="true" indent="true" encoding="utf-8" method="html" version="4.0"
		doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
		doctype-system="http://www.w3.org/TR/html4/loose.dtd" name="step-60-webversion">
		<p:with-option name="href" select="concat($work_dir, '60-webversion.html')"/>
	</p:store>

	<!-- EH 2013-12-02: Generate content.opf, a required file in an epub publication -->
	<p:xslt name="generate-content-opf" version="1.0">
		<p:input port="source">
			<p:pipe step="fix-missing-id-on-graphics" port="result"/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="hioa-xslt/epub-content.opf.xsl"/>
		</p:input>
	</p:xslt>

	<!-- EH 2014-03-22: storing content.opf in epub structure -->
	<p:store indent="true" name="content-opf">
		<p:with-option name="href" select="concat($work_dir, 'epub/EPUB/content.opf')"/>
	</p:store>

	<!-- EH 2014-03-22: storing a copy for inspection -->
	<p:store indent="true" name="step-70-content-opf">
		<p:with-option name="href" select="concat($work_dir, '70-content.opf')"/>
		<p:input port="source">
			<p:pipe step="generate-content-opf" port="result"/>
		</p:input>
	</p:store>

	<p:xslt name="generate-navmap-with-toc" version="2.0">
		<p:input port="source">
			<p:pipe port="result" step="xhtml-ready-for-epub"/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="hioa-xslt/generate-navmap-with-toc.xsl"/>
		</p:input>
	</p:xslt>

	<!-- EH 2013-12-02: Generate toc.ncx, a required file in an epub publication -->
	<p:xslt name="generate-toc-ncx" version="1.0">
		<p:input port="source">
			<p:pipe step="format-APA-citations" port="result"/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="hioa-xslt/epub-toc.ncx.xsl"/>
		</p:input>
	</p:xslt>

	<!-- Replace  navMap with a new navMap where all headings are represented -->
	<p:replace name="replace-navMap" match="/ncx:ncx/ncx:navMap">
		<p:input port="source">
			<p:pipe port="result" step="generate-toc-ncx"/>
		</p:input>
		<p:input port="replacement">
			<p:pipe port="result" step="generate-navmap-with-toc"/>
		</p:input>
	</p:replace>

	<p:identity name="toc-ncx-ready"/>

	<!-- EH 2014-03-22: storing content.opf in epub structure -->
	<p:store indent="true" name="toc-ncx">
		<p:with-option name="href" select="concat($work_dir, 'epub/EPUB/toc.ncx')"/>
	</p:store>

	<!-- EH 2014-03-22: storing a copy for inspection -->
	<p:store indent="true" name="step-80-toc-ncx">
		<p:with-option name="href" select="concat($work_dir, '80-toc.ncx')"/>
		<p:input port="source">
			<p:pipe step="toc-ncx-ready" port="result"/>
		</p:input>
	</p:store>

</p:declare-step>