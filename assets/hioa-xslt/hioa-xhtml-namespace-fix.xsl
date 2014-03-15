<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
	Overview:
	
	This stylesheet imports xhtml-ns.xsl, a stylesheet developed by 
	Wendell Piez for NLM. The purpose of the stylesheet is to cast any xml input 
	into the xhtml namespace. Just a few local changes here to override the 
	defaults in xhtml-ns.xsl.
	
	Author (this stylesheet): 
	Eirik Hanssen, Oslo and Akershus University College of Applied Sciences

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
	
	Contact: eirik hanssen at hioa dot no, trude dot eikebrokk at hioa dot no, tor-arne dot dahl at hioa dot no
-->


<xsl:import href="../jats-xslt/post/xhtml-ns.xsl"/>

  <!-- EH 2013-11-25: Changed indent to "yes". And commmented out this rule later.. -->
<!--  <xsl:output method="xml" indent="yes" encoding="UTF-8"/> -->
    
  <!-- EH 2013-11-25: Removed mml processing instruction -->
<!--  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
-->
</xsl:stylesheet>
