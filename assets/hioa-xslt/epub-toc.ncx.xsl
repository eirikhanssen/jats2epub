<?xml version="1.0" encoding="UTF-8"?>
<!--
	Overview:
	
	This stylesheet generates toc.ncx, a required file in the ePub format.
	It copies over relevant data from a journal article tagged using NISO jats xml.
	
	Author: Trude Eikebrokk, Oslo and Akershus University College of Applied Sciences
	
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
	
	Contact: trude dot eikebrokk at hioa dot no, tor-arne dot dahl at hioa dot no, eirik dot hanssen at hioa dot no
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:param name="article-xhtml" select="'index.html'"/>

  <xsl:template match="/">
	<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
	  <head>
	    <meta name="dtb:uid"> 
	    <xsl:attribute name="content"><xsl:text>DOI:</xsl:text><xsl:value-of select="article/front/article-meta/article-id[@pub-id-type='doi']" /></xsl:attribute>
	    </meta>
	    <meta name="dtb:depth" content="1"/>
	    <meta name="dtb:totalPageCount" content="0"/>
	    <meta name="dtb:maxPageNumber" content="0"/>
	  </head>
	  <xsl:for-each select="article/front">
	  <docTitle>
	    <text>
	     <xsl:value-of select="article-meta/title-group/article-title"></xsl:value-of>
	     </text>
	  </docTitle>
	  </xsl:for-each>
	  <navMap>
	    <navPoint id="article" playOrder="1">
	      <navLabel>
	        <text>Article</text>
	      </navLabel>
	      <!-- Article source from parameter, using default value if none supplied to the stylesheet -->
	      <content><xsl:attribute name="src" select="$article-xhtml"/></content>
	    </navPoint>
	   </navMap>
	</ncx>
  </xsl:template>
</xsl:stylesheet>
