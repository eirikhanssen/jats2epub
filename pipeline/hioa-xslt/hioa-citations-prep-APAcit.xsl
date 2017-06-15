<?xml version="1.0" encoding="UTF-8"?>
<!--
	Overview:
	
	This xslt stylesheet imports jats-APAcit.xsl from the JATS tools package
	and adds some overrides.
	
	Author: Tor Arne Dahl, Oslo and Akershus University College of Applied Sciences
	
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
      <!-- TAD 2012-08-03: volume in italics for journal articles -->
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
	
	<!-- ============================================================= -->
	<!-- For publication type 'book-chapter'                           -->
	<!-- ============================================================= -->
	
	<xsl:template name="book-chapter-citation-content"
		match="element-citation[@publication-type='book-chapter']">
		<xsl:variable name="all-names"
			select="(person-group|name|collab|anonymous|etal|string-name) /
			(. | nlm:fetch-comment(.))"/>
		<!-- $all-authors are all the elements that might be authors -->
		<xsl:variable name="placed-names"
			select="$all-names[not(preceding-sibling::* intersect
			(current()/* except $all-names))]"/>
		<!-- placed authors are all person-groups and all the
         elements that might be authors, except when they are 
         preceded by elements that can't be authors -->
		<xsl:variable name="date"
			select="date[1] |
			(year[1]|month[1]|day[1]|season[1])[not(exists(date))] |
			date-in-citation[1][not(exists(date|year|month|day|season))]"/>
		<!-- the date is either the first date element, or the first
         year, month, day elements when there is no date element -->
		<xsl:variable name="titles"
			select="(chapter-title | article-title | trans-title) /
			(. | nlm:fetch-comment(.))"/>
		<xsl:variable name="placed-title"
			select="$titles[1][not($placed-names)]"/>
		<xsl:variable name="book-info"
			select="(source | edition |
			edition/following-sibling::*[1]/self::sup |
			volume | fpage | lpage | page-range) /
			(. | nlm:fetch-comment(.))"/>
		<xsl:variable name="publisher"
			select="(publisher-loc | publisher-name) /
			(. | nlm:fetch-comment(.))"/>
		<xsl:call-template name="format-names">
			<xsl:with-param name="names"
				select="$placed-names except comment"/>
		</xsl:call-template>
		<xsl:if test="not(exists($placed-names))">
			<!-- if we have no authors to place, we'll have a placed
           title -->
			<xsl:apply-templates mode="article-title"
				select="$placed-title"/>
		</xsl:if>
		<xsl:call-template name="format-date">
			<xsl:with-param name="date" select="$date"/>
		</xsl:call-template>
		<!-- following the date, we process titles -->
		<xsl:apply-templates mode="article-title"
			select="$titles except ($placed-title | comment)"/>
		<!-- next we do the book info, which includes source,
         edition (w/ sup if it has any), volume, publisher-name,
         publisher-loc, and any comments directly following 
         these, plus any authors not included among
         $placed-authors. -->
		<xsl:call-template name="format-in-book">
			<xsl:with-param name="book-info" select="$book-info"/>
			<xsl:with-param name="book-names"
				select="$all-names except $placed-names"/>
		</xsl:call-template>
		<xsl:call-template name="format-publisher">
			<xsl:with-param name="publisher" select="$publisher"/>
		</xsl:call-template>
		<!-- if there's anything left we drop it in -->
		<xsl:call-template name="comma-sequence-sentence">
			<xsl:with-param name="phrases" as="node()*">
				<xsl:apply-templates mode="book-chapter-item"
					select="* except ($all-names | $date |
					$titles | $book-info | $publisher)"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
