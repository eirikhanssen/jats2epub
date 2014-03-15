<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:mml="http://www.w3.org/1998/Math/MathML" 
	xmlns:oasis="http://docs.oasis-open.org/ns/oasis-exchange/table" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns="http://www.w3.org/1999/xhtml" 
	version="1.0" 
	exclude-result-prefixes="xlink mml">
<!--
	Overview:
	
	This stylesheet imports jats-html.xsl from the JATS tools package, developed
	by Wendel Piez for National Library of Medicine. jats-html.xsl transforms a 
	jats tagged xml article to a html preview.
	
	This stylesheet override many rules to suit our needs to produce a valid xhtml 1.1 document
	that is required by the EPUB 2.0.1 standards. This is because the resulting xhtml document
	is to be used as part of an epub package.
	
	Authors: 
	Tor Arne Dahl, Oslo and University College of Applied Sciences
	Trude Eikebrokk, Oslo and University College of Applied Sciences
	Eirik Hanssen, Oslo and University College of Applied Sciences
	
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
	along with jats2epub.  If not, see http://www.gnu.org/licenses/gpl.html
	
	Contact: tor-arne dot dahl at hioa dot no, trude dot eikebrokk at hioa dot no, eirik hanssen at hioa dot no
-->

<!-- TAD and TE, 2012-03-30: Default namespace added to avoid empty namespace attributes in the result xhtml document -->
<!-- TAD 2012-08-09: Added  xmlns:xsi to make sure this is not added to the opening tag in tables -->
<!-- TAD 2012-08-09: Tried to add oasis-namespace, but it didn't work (trying to get rid of empty namespace-attributes in the resulting xhtml document) -->
<!-- 
	EH 2014-03-15: In the end, we still haven't found the exact cause of the problem of why the empty namespace nodes occur on 
	elements in the resulting xhtml document.
	
	Even if we haven't discovered the reason why, what happens is that during transformation the xslt processor thinks
	some nodes don't have namespaces. Since this is illegal, the xslt processor adds empty namespace nodes (xmlns="")
	to several elements in the resulting xhtml document during what is a called namespace fixup process.
	
	Empty namespace nodes on xhtml elements means that the xhtml-file (and also the epub-document) will not validate.
	
	However, we did solve this problem downstream in the XProc pipeline by adding another xslt transformation that 
	casts the whole document into the xhtml namespace, that way, no element have no namespace.
-->
	
  <xsl:import href="../jats-xslt/main/jats-html.xsl"/>
  <!-- TAD og TE 2012-03-30: EPUB vil ha XHTML 1.1 -->
  <xsl:output indent="yes" method="xml" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" encoding="UTF-8"/>
  <!-- EH 2013.06.14: adding output method to produce html-output -->
  <!--<xsl:output method="html" indent="yes"/>-->
  <!-- 2011-01-22, TAD: Custom CSS stylesheet that imports the provided JATS-CSS -->
  <!-- EH 2013-06-14: commenting out this rule to change stylesheet -->
  <!--<xsl:param name="css">css/professions_and_professionalism-web.css</xsl:param> -->
  <!-- EH 2013-06-14: changing the included css stylesheets -->
  <xsl:param name="css">css/hioa-epub.css</xsl:param>
  <!-- ============================================================= -->
  <!--  ROOT TEMPLATE - HANDLES HTML FRAMEWORK                       -->
  <!-- ============================================================= -->
  <xsl:template match="/">
    <!-- TAD & TE, 2012-03-30: The html root element must have a namespace attribute in XHTML -->
    <html xmlns="http://www.w3.org/1999/xhtml">
      <!-- HTML header -->
      <xsl:call-template name="make-html-header"/>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  <xsl:template name="make-html-header">
    <head>
      <title>
        <xsl:variable name="authors">
          <xsl:call-template name="author-string"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($authors)"/>
        <xsl:if test="normalize-space($authors)">: </xsl:if>
        <xsl:value-of select="/article/front/article-meta/title-group/article-title[1]"/>
      </title>
      <!-- TAD & TE: 2012-03-30: Extra encoding header, recommended by W3C -->
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <link rel="stylesheet" type="text/css" href="{$css}"/>
      <!-- XXX check: any other header stuff? XXX -->
    </head>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  TOP LEVEL                                                    -->
  <!-- ============================================================= -->
  <xsl:template match="front | front-stub">
    <!-- TAD 2012-08-10: No tables. We only need ISSN, volumw, issue, publication year, page number and DOI from the metadata elements -->
    <div class="metadata-group">
      <p>
        <xsl:text>ISSN: </xsl:text>
        <xsl:value-of select="journal-meta/issn"/>
      </p>
      <p>
        <xsl:text>Volume </xsl:text>
        <xsl:value-of select="article-meta/volume"/>
        <xsl:text>, No </xsl:text>
        <xsl:value-of select="article-meta/issue"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="article-meta/pub-date[@pub-type='pub']/year"/>
        <xsl:text>), pp. </xsl:text>
        <xsl:value-of select="article-meta/fpage"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="article-meta/lpage"/>
      </p>
      <p>Doi: <a href="http://dx.doi.org/{article-meta/article-id[@pub-id-type='doi']}"><xsl:value-of select="article-meta/article-id[@pub-id-type='doi']"/></a>
      </p>
    </div>
    <!-- TAD 2012-08-10: Logo -->
    <p class="logo">
      <img src="images/pp-logo_trans.png" alt="Professions &amp; Professionalism"/>
    </p>
    <h2 class="author">
      <xsl:for-each select="article-meta/contrib-group/contrib[@contrib-type='author']">
        <xsl:choose>
          <xsl:when test="position() != 1 and position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="position() != 1 and position()= last()">
            <xsl:text> and </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="name/given-names"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="name/surname"/>
      </xsl:for-each>
    </h2>
    <!-- TAD 2012-08-15: Use provided templates for article-title -->
    <xsl:apply-templates select="article-meta/title-group/article-title" mode="metadata"/>
    <div class="abstract">
      <p>
        <strong>Abstract:</strong>
        <xsl:text> </xsl:text>
        <xsl:value-of select="article-meta/abstract"/>
      </p>
      <p>
        <strong>Keywords:</strong>
        <xsl:text> </xsl:text>
        <xsl:for-each select="article-meta/kwd-group[@kwd-group-type='author-generated']/kwd">
          <xsl:value-of select="."/>
          <xsl:if test="position()!= last()">
            <xsl:text>; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </p>
    </div>
    <!-- end of big front-matter pull -->
  </xsl:template>
  <xsl:template mode="metadata" match="contrib-group">
    <!-- 2012-08-10, TAD: No tables. We only need ISSN, volume, issue, publication year, page number and DOI from the metadata elements -->
    <div class="metadata-group">
      <p>
        <xsl:text>ISSN: </xsl:text>
        <!-- EH 2013.06.12: Fixed XPath to find issn-->
        <xsl:value-of select="../../journal-meta/issn"/>
      </p>
      <p>
        <xsl:text>Volume: </xsl:text>
        <!-- EH 2013.06.12: Fixed XPath to find volume-->
        <xsl:value-of select="../volume"/>
        <xsl:text>, No </xsl:text>
        <!-- EH 2013.06.12: Fixed XPath to find issue-->
        <xsl:value-of select="../issue"/>
        <xsl:text> (</xsl:text>
        <!-- EH 2013.06.12: Fixed XPath to find year-->
        <xsl:value-of select="../pub-date[@pub-type='pub']/year"/>
        <xsl:text>), pp. </xsl:text>
        <!-- EH 2013.06.12: Fixed XPath to find fpage-->
        <xsl:value-of select="../fpage"/>
        <xsl:text>-</xsl:text>
        <!-- EH 2013.06.12: Fixed XPath to find lpage-->
        <xsl:value-of select="../lpage"/>
      </p>
      <p>
        Doi: <a href="http://dx.doi.org/{article-meta/article-id[@pub-id-type='doi']}"><xsl:value-of select="../article-id[@pub-id-type='doi']"/></a>
      </p>
    </div>
    <h2 class="author">
      <xsl:for-each select="article-meta/contrib-group/contrib[@contrib-type='author']">
        <xsl:choose>
          <xsl:when test="position() != 1 and position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="position() != 1 and position()= last()">
            <xsl:text> and </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="name/given-names"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="name/surname"/>
      </xsl:for-each>
    </h2>
    <!-- TAD 2012-08-15: Use provided templates for article-title -->
    <xsl:apply-templates select="article-meta/title-group/article-title" mode="metadata"/>
    <div class="abstract">
      <p>
        <strong>Abstract:</strong>
        <xsl:text> </xsl:text>
        <xsl:value-of select="article-meta/abstract"/>
      </p>
      <p>
        <strong>Keywords:</strong>
        <xsl:text> </xsl:text>
        <xsl:for-each select="article-meta/kwd-group[@kwd-group-type='author-generated']/kwd">
          <xsl:value-of select="."/>
          <xsl:if test="position()!= last()">
            <xsl:text>; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </p>
    </div>
    <!-- end of big front-matter pull -->
  </xsl:template>
  <xsl:template name="footer-metadata">
    <!-- handles: article-categories, kwd-group, counts, supplementary-material, custom-meta-group
         Plus also generates a sheet of processing warnings -->
    <xsl:for-each select="front/article-meta | front-stub">
      <div class="metadata-group">
        <!-- TAD 2012-08-13: New content for the footer area -->
        <div class="history">
          <!-- TAD 2012-08-13: Use the provided template for handling article history -->
          <xsl:apply-templates select="history/date" mode="metadata"/>
        </div>
        <!-- Affiliations -->
        <div class="address">
          <xsl:for-each select="contrib-group/contrib[@contrib-type='author']">
            <p>
              <em>
                <xsl:value-of select="name/given-names"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="name/surname"/>
              </em>
              <xsl:text>, </xsl:text>
              <xsl:variable name="aff-id" select="xref/@rid"/>
              <xsl:value-of select="../../aff[@id = $aff-id]"/>
            </p>
          </xsl:for-each>
          <!-- Contact -->
          <xsl:for-each select="contrib-group/contrib[@contrib-type='author']">
            <xsl:if test="address">
              <!-- This author has a contact address -->
              <p>
                <strong>Contact:</strong>
                <xsl:text> </xsl:text>
                <xsl:value-of select="name/given-names"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="name/surname"/>
                <xsl:text>, </xsl:text>
                <xsl:if test="address/institution">
                  <xsl:value-of select="address/institution"/>
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:for-each select="address/addr-line">
                  <xsl:value-of select="."/>
                  <xsl:text>, </xsl:text>
                  <xsl:if test="address/country">
                    <xsl:value-of select="address/country"/>
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                </xsl:for-each>
                <xsl:if test="address/email">
                  <a href="mailto:{address/email}">
                    <xsl:value-of select="address/email"/>
                  </a>
                </xsl:if>
              </p>
            </xsl:if>
          </xsl:for-each>
        </div>
        <p class="license">
          <img src="images/cc-license.png" alt="Attribution 3.0 Unported (CC BY 3.0)"/>
          <xsl:value-of select="permissions/license/license-p"/>
        </p>
      </div>
    </xsl:for-each>
    <!-- EH 2013.06.21: Removed process warnings output that were commented out by TAD/TE -->
  </xsl:template>
  <!-- ============================================================= -->
  <!--  METADATA PROCESSING                                          -->
  <!-- ============================================================= -->
  <xsl:template match="history/date" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <!-- TAD & TE 2012-08-14: No "Date" in HiOA journals -->
        <!-- xsl:text>Date</xsl:text -->
        <xsl:for-each select="@date-type">
          <xsl:choose>
            <!-- TAD & TE 2012-08-14: Capital letter -->
            <xsl:when test=".='accepted'">Accepted</xsl:when>
            <xsl:when test=".='received'">Received</xsl:when>
            <xsl:when test=".='rev-request'">Revision requested</xsl:when>
            <xsl:when test=".='rev-recd'">Revision received</xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:call-template name="format-date"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  REGULAR (DEFAULT) MODE                                       -->
  <!-- ============================================================= -->
  
	<!--
		EH 2014-03-15: Here we change the way references will be marked up in the
		resulting xhtml. They will be marked up as an unordered list, instead of divs. 
	-->
  <xsl:template match="ref-list" name="ref-list">
    <!-- EH 2013.06.21: The title "References" should be inserted by some other mechanism using generated title, see template match="back/ref-list" -->
    <!-- Since this doesn't happen, until I can find the cause of this error, I am hard-coding it in -->
     <h2 class="main-title">References</h2> 
        <ul class="section references">
      <!-- EH 2013.06.21: Anchor and label not needed here, removed. -->
      <xsl:apply-templates select="*[not(self::ref | self::ref-list)]"/>
      <xsl:if test="ref">
        <!-- TAD 2012-08-10: No table for the references. Make a div section instead -->
        <xsl:apply-templates select="ref"/>
      </xsl:if>
      <xsl:apply-templates select="ref-list"/>
    </ul>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  Figures, lists and block-level objectS                       -->
  <!-- ============================================================= -->

  <xsl:template match="ref">
    <!-- EH 2013.06.21: this reference goes in an li element -->
    <li>
    <!-- EH 2013.06.21: named-anchor here is needed for links to work between text and reference list -->
    <xsl:call-template name="named-anchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
    <xsl:template match="ref/*" priority="0">
    <!-- should match mixed-citation, element-citation, nlm-citation.

         note and label should be matched below. -->
    <!-- TAD 2012-08-10: Part of a paragraph of class citation already -->
    <!-- p class="citation" -->
    <!-- EH 2013.06.21: removed named anchor -->
    <!--<xsl:call-template name="named-anchor"/>-->
    <xsl:apply-templates/>
    <!-- /p -->
  </xsl:template>

  <xsl:template match="ref/note" priority="2">
    <xsl:param name="label" select="''"/>
    <xsl:if test="normalize-space($label) and not(preceding-sibling::*[not(self::label)])">
      <p class="label">
        <xsl:copy-of select="$label"/>
      </p>
    </xsl:if>
    <div class="note">
      <!-- EH 2013.06.21: removed named anchor -->
      <!--<xsl:call-template name="named-anchor"/>-->
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- ============================================================= -->
  <!--  TABLES                                                       -->
  <!-- ============================================================= -->
  <!--  Tables are already in XHTML, and can simply be copied through -->
  <xsl:template match="table | thead | tbody | tfoot | col | colgroup | tr | th | td">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="table-copy"/>
      <!-- TAD 2012-08-09: Ankrene trengs ikke, og plasserer seg dessuten på ulovlige steder i tabellen -->
      <!-- xsl:call-template name="named-anchor"/ -->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="array/tbody">
    <table>
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="table-copy"/>
        <!-- EH 2013.06.21: removed named anchor -->
        <!--<xsl:call-template name="named-anchor"/>-->
        <xsl:apply-templates/>
      </xsl:copy>
    </table>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  INLINE MISCELLANEOUS                                         -->
  <!-- ============================================================= -->
  <xsl:template match="ext-link | uri | inline-supplementary-material">
    <!-- TE og TAD 2012-08-02: target-attributtet er ikke tillatt i XHTML Strict -->
    <!-- a target="xrefwindow" -->
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="."/>
      </xsl:attribute>
      <!-- if an @href is present, it overrides the href

           just attached -->
      <xsl:call-template name="assign-href"/>
      <xsl:call-template name="assign-id"/>
      <xsl:apply-templates/>
      <xsl:if test="not(normalize-space())">
        <xsl:value-of select="@xlink:href"/>
      </xsl:if>
    </a>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  BACK MATTER                                                  -->
  <!-- ============================================================= -->
  <xsl:template name="backmatter-section">
    <xsl:param name="generated-title"/>
    <xsl:param name="contents">
      <xsl:apply-templates/>
    </xsl:param>
    <div class="back-section">
      <!-- TE og TAD, 2012-09-02: Kommenterer ut for å unngå dubletter av unike ID-er -->
      <!-- xsl:call-template name="named-anchor"/ -->
      <xsl:if test="not(title) and $generated-title">
        <xsl:choose>
          <!-- The level of title depends on whether the back matter itself has a title -->
          <xsl:when test="ancestor::back/title">
            <xsl:call-template name="section-title">
              <xsl:with-param name="contents" select="$generated-title"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="main-title">
              <xsl:with-param name="contents" select="$generated-title"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select="$contents"/>
    </div>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  MODE 'label-text' -->
  <!-- Generates label text for elements and their cross-references -->
  <!-- ============================================================= -->
  <xsl:template match="fn" mode="label-text">
    <xsl:param name="warning" select="true()"/>
    <!-- pass $warning in as false() if a warning string is not wanted

         (for example, if generating autonumbered labels) -->
    <xsl:variable name="auto-number-fn" select="not(ancestor::article//fn[not(ancestor::front|ancestor::table-wrap)]/label |                    ancestor::article//fn[not(ancestor::front|ancestor::table-wrap)]/@symbol)"/>
    <xsl:call-template name="make-label-text">
      <xsl:with-param name="auto" select="$auto-number-fn"/>
      <xsl:with-param name="warning" select="$warning"/>
      <xsl:with-param name="auto-text">
        <xsl:text>[</xsl:text>
        <!-- TAD 2012-08-13: The numbering should start from scratch, keeping table footnotes etc. separate. Changed value of attribute "from" from article to article/back. This means: Just count the footnotes in the back section of the article -->
       <!-- EH 2014-01-28: added table, to start counting from table element for footnotes within a table Changed format to roman numbers (added format"I") -->
        <xsl:number level="any" count="fn[not(ancestor::front)]" from="article/back | sub-article | response | table" format="i"/>
        <xsl:text>]</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  UTILITY TEMPLATES                                           -->
  <!-- ============================================================= -->
  <xsl:template name="named-anchor">
    <!-- generates an HTML named anchor, using the source ID when found, otherwise a unique ID -->
    <xsl:variable name="id">
      <xsl:value-of select="@id"/>
      <xsl:if test="not(normalize-space(@id))">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:if>
    </xsl:variable>
    <!-- TAD og TE, 2012-03-30: XHTML vil ha id i stedet for name -->
    <a id="{$id}">
      <xsl:comment> named anchor </xsl:comment>
    </a>
  </xsl:template>
  <!-- ============================================================= -->
  <!--  Process warnings                                             -->
  <!-- ============================================================= -->
  <!-- Generates a list of warnings to be reported due to processing anomalies. -->
  <xsl:template name="process-warnings">
    <!-- returns an RTF containing all the warnings -->
    <xsl:variable name="xref-warnings">
      <xsl:for-each select="//xref[not(normalize-space())]">
        <xsl:variable name="target-label">
          <xsl:apply-templates select="key('element-by-id',@rid)" mode="label-text">
            <xsl:with-param name="warning" select="false()"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="not(normalize-space($target-label)) and @ref-type!='aff'           or not(normalize-space($target-label)) and @ref-type='aff'            and count(/article/front/article-meta//aff) &gt; 1">
          <!-- if we failed to get a label with no warning, and

               this is the first cross-reference to this target

               we ask again to get the warning -->
          <li>
            <xsl:apply-templates select="key('element-by-id',@rid)" mode="label-text">
              <xsl:with-param name="warning" select="true()"/>
            </xsl:apply-templates>
          </li>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!-- TAD 2012-08-13: xref warnings not relevant in the HiOA context -->
    <!-- xsl:if test="normalize-space($xref-warnings)">
      <h4>Elements are cross-referenced without labels.</h4>
      <p>Either the element should be provided a label, or their cross-reference(s) should

        have literal text content.</p>
      <ul>
        <xsl:copy-of select="$xref-warnings"/>
      </ul>
    </xsl:if -->
  </xsl:template>
  <!-- 2011-01-22, TAD: Turns off xref warnings (important for missing labels for author aff's. See this article: <http://www.ncbi.nlm.nih.gov/books/NBK47104/>  -->
  <xsl:template name="make-label-text">
    <xsl:param name="auto" select="false()"/>
    <xsl:param name="warning" select="false()"/>
    <xsl:param name="auto-text"/>
    <xsl:choose>
      <xsl:when test="$auto">
        <span class="generated">
          <xsl:copy-of select="$auto-text"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <!-- Do nothing, especially no empty [] -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
