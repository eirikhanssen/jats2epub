<?xml version="1.0" encoding="UTF-8"?>
<!--
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
	
	Contact: tor-arne dot dahl at hioa dot no, trude dot eikebrokk at hioa dot no, eirik dot hanssen at hioa dot no
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:nlm="http://www.ncbi.nlm.gov/xslt/util">
	<xsl:import href="../jats-xslt/citations-prep/jats-APAcit.xsl"/>
 
<!-- handled with the preceding-sibling edition -->
  <xsl:template match="volume" mode="article-item">
    <xsl:document>
      <!-- TAD 2012-08-03: volume i kursiv for tidsskriftartikler -->
      <italic>
        <xsl:apply-templates select="." mode="format"/>
      </italic>
      <xsl:for-each select="../(issue|supplement)[1]">
        <!-- pick up the issue and/or supplement if there is no volume -->
        <xsl:call-template name="issue"/>
      </xsl:for-each>
    </xsl:document>
  </xsl:template>  
  
  <!-- TAD 2012-08-15: Added volume, which should be in italic. This template is used for mixed-citation elements -->
  <xsl:template mode="format" match="source | volume">
    <italic>
      <xsl:apply-templates mode="format"/>
    </italic>
  </xsl:template>

</xsl:stylesheet>
