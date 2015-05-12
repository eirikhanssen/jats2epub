<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs xhtml"
    version="2.0">
    <xsl:param name="article-xhtml" select="'index.html'"/>
    <xsl:output method="text" indent="yes"/>
    
    <xsl:variable name="headers" select="(//(xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6))[not(@class='author')]"/>
    
    <xsl:template match="/">
        <navMap xmlns="http://www.daisy.org/z3986/2005/ncx/">
            <xsl:for-each select="$headers">
                <navPoint id="{generate-id()}" playOrder="{position()}">
                    <navLabel>
                        <text><xsl:value-of select="."/></text>
                    </navLabel>
                    <!-- Article source from parameter, using default value if none supplied to the stylesheet -->
                    <content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></content>
                </navPoint>
            </xsl:for-each>
        </navMap>
    </xsl:template>
</xsl:stylesheet>