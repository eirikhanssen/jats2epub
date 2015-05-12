<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
    exclude-result-prefixes="xs xhtml ncx"
    version="2.0">
    <xsl:param name="article-xhtml" select="'index.html'"/>
    <xsl:output method="text" indent="yes"/>
    
    <xsl:variable name="headers" as="element()+">
        <xsl:sequence select="(//(xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6))[not(@class='author')]"/>
    </xsl:variable>
    
    <xsl:variable name="header-tree">
        <header>
            <xsl:for-each select="$headers">
                <xsl:element name="{local-name()}">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="pos" select="position()"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
        </header>
    </xsl:variable>
    
    <xsl:template match="/">
        <navMap xmlns="http://www.daisy.org/z3986/2005/ncx/">
            <xsl:apply-templates select="$header-tree/header/h1"/>
        </navMap>
    </xsl:template>
    
    <xsl:template match="h1">
        <xsl:variable name="this" select="."/>
        <ncx:navPoint id="{generate-id()}" playOrder="{@pos}">
            <ncx:navLabel>
                <ncx:text><xsl:value-of select="."/></ncx:text>
            </ncx:navLabel>
            <ncx:content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></ncx:content>
            <xsl:apply-templates select="following-sibling::h2[preceding-sibling::h1 is $this]"/>
        </ncx:navPoint>
    </xsl:template>
    <xsl:template match="h2">
        <xsl:param name="parent-position" select="0"/>
        <xsl:variable name="this" select="."/>
        <ncx:navPoint id="{generate-id()}" playOrder="{@pos}">
            <ncx:navLabel>
                <ncx:text><xsl:value-of select="."/></ncx:text>
            </ncx:navLabel>
            <ncx:content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></ncx:content>
            <xsl:apply-templates select="following-sibling::h3[preceding-sibling::h2 is $this]"/>
        </ncx:navPoint>
    </xsl:template>
    <xsl:template match="h3">
        <xsl:param name="parent-position" select="0"/>
        <xsl:variable name="this" select="."/>
        <ncx:navPoint id="{generate-id()}" playOrder="{@pos}">
            <ncx:navLabel>
                <ncx:text><xsl:value-of select="."/></ncx:text>
            </ncx:navLabel>
            <ncx:content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></ncx:content>
            <xsl:apply-templates select="following-sibling::h4[preceding-sibling::h3 is $this]"/>
        </ncx:navPoint>
    </xsl:template>
    <xsl:template match="h4">
        <xsl:param name="parent-position" select="0"/>
        <xsl:variable name="this" select="."/>
        <ncx:navPoint id="{generate-id()}" playOrder="{@pos}">
            <ncx:navLabel>
                <ncx:text><xsl:value-of select="."/></ncx:text>
            </ncx:navLabel>
            <ncx:content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></ncx:content>
            <xsl:apply-templates select="following-sibling::h5[preceding-sibling::h4 is $this]"/>
        </ncx:navPoint>
    </xsl:template>
    <xsl:template match="h5">
        <xsl:param name="parent-position" select="0"/>
        <xsl:variable name="this" select="."/>
        <ncx:navPoint id="{generate-id()}" playOrder="{@pos}">
            <ncx:navLabel>
                <ncx:text><xsl:value-of select="."/></ncx:text>
            </ncx:navLabel>
            <ncx:content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></ncx:content>
            <xsl:apply-templates select="following-sibling::h6[preceding-sibling::h5 is $this]"/>
        </ncx:navPoint>
    </xsl:template>
    <xsl:template match="h6">
        <xsl:param name="parent-position" select="0"/>
        <xsl:variable name="this" select="."/>
        <ncx:navPoint id="{generate-id()}" playOrder="{@pos}">
            <ncx:navLabel>
                <ncx:text><xsl:value-of select="."/></ncx:text>
            </ncx:navLabel>
            <ncx:content><xsl:attribute name="src" select="concat($article-xhtml, '#' , @id)"/></ncx:content>
        </ncx:navPoint>
    </xsl:template>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>