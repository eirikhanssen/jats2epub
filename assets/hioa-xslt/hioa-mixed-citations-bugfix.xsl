<?xml version="1.0" encoding="UTF-8"?>
<!--
	Overview:
	
	This XSLT stylesheet is just a quick fix to a problem resulting from what
	we think is a bug with the original jats-APAcit.xsl. When using the <element-citation>
	markup style in the reflist and a reference of the type publication-type="book-chapter",
	the jats-APAcit.xsl transformation incorrectly doesn't wrap the contents of the resulting <ref> 
	element in a <mixed-citation> element. This in turn causes the source of a reference not to be
	italicized in the reference list.

	The problem should be avoided in the first place by fixing the jats-APAcit.xsl
	or using best practice (vertical customization) to override some rules in the 
	xslt stylesheet importing jats-APAcit.xsl

	But since we're using an xproc pipeline, it is easy to insert a fix in the document flow.

	I added publication-type and publication-format attributes with 
	hardcoded values. This is not optimal, and we're sure there is a better 
	way to get the correct attributes, but we only observed this error
	when publication-type="book-chapter" was used. 

	This is just a temporary fix until we find a better way 

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
	
	Contact: eirik hanssen at hioa dot no, tor-arne dot dahl at hioa dot no, trude dot eikebrokk at hioa dot no
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

<!-- 
	Special treatment of //ref elements, make sure the contents are wrapped in a 
	<mixed-citation> element 
-->
  <xsl:template match="//ref">
    <xsl:element name="{local-name()}" namespace="{namespace-uri(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <!-- Test if <ref> element conatins <mixed-citation> element -->
        <xsl:when test="boolean(./mixed-citation)">
          <!-- Found <mixed-citation>, make no changes -->
          <xsl:apply-templates/>
        </xsl:when>
        <!-- Otherwise, wrap the contents of <ref> in a <mixed-citation> element-->
        <xsl:otherwise>
          <mixed-citation publication-type="book-chapter" publication-format="print">
            <xsl:apply-templates/>
          </mixed-citation>
        </xsl:otherwise>
      </xsl:choose>
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
