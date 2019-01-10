<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:eh="http://eirikhanssen.no/ns"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs xhtml ncx mml eh saxon">
    
    <xsl:strip-space elements="*"/>
    
    <xsl:output 
        method="xhtml"
        indent="yes"
        omit-xml-declaration="yes"
        undeclare-prefixes="no" xml:space="default"/>
    
    <xsl:function name="eh:date_char2num" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
        <xsl:variable name="dateparts_seq" select="tokenize($input, ' ')"/>
        <xsl:variable name="month" select="$dateparts_seq[2]"/>
        <xsl:variable name="dd" select="     if(xs:integer($dateparts_seq[1]) &lt; 10) then concat('0', xs:string(xs:integer($dateparts_seq[1])))
                                        else xs:string(xs:integer($dateparts_seq[1]))"/>
        <xsl:variable name="yyyy" select="$dateparts_seq[3]"/>
        <xsl:variable name="mm" select="     if ($month = 'January')   then '01'
                                        else if ($month = 'February')  then '02'
                                        else if ($month = 'March')     then '03'
                                        else if ($month = 'April')     then '04'
                                        else if ($month = 'May')       then '05'
                                        else if ($month = 'June')      then '06'
                                        else if ($month = 'July')      then '07'
                                        else if ($month = 'August')    then '08'
                                        else if ($month = 'September') then '09'
                                        else if ($month = 'October')   then '10'
                                        else if ($month = 'November')  then '11'
                                        else if ($month = 'December')  then '12'
                                        else '00'"/>
        <xsl:value-of select="concat($yyyy , '-' , $mm , '-' , $dd)"/>
    </xsl:function>
    
    <xsl:variable name="author">
        <xsl:variable name="authorstring" select="//xhtml:h2[@class='author']/text()"/>
        <ul class="authors">
            <xsl:for-each select="tokenize($authorstring, '(\s*,\s*|\s*&amp;\s*|\s*and\s*)')">
                <li itemprop="author"><xsl:value-of select="."/></li>
            </xsl:for-each>
        </ul>
    </xsl:variable>
    
    <xsl:variable name="keywords">
        <xsl:variable name="keywordstring" select="//xhtml:div[@class='abstract']/xhtml:p[last()]/text()"/>
        <xsl:variable name="keyword_seq" select="tokenize($keywordstring, '(Keywords:\s*|\s*;\s*)')"/>
        <p class="keywords" itemprop="keywords">
            <xsl:for-each select="$keyword_seq">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
            </xsl:for-each>
                <li itemprop="author"><xsl:value-of select="."/></li>
        </p>
    </xsl:variable>
    
    <xsl:variable name="historymeta">
        <xsl:variable name="history_seq" select="//xhtml:div[@class='history']"/>
        <p class="historymeta">
            <xsl:for-each select="$history_seq/xhtml:p">
                <xsl:variable name="timestring" select="replace(text(), '^\s*(.+?)\s*$', '$1')"/>
                <span><xsl:value-of select="xhtml:span"/></span><time datetime="{eh:date_char2num($timestring)}">
                    <xsl:if test="matches(xhtml:span[1]/text(), '^Published:')"><xsl:attribute name="itemprop" select="'datePublished'"></xsl:attribute></xsl:if><xsl:value-of select="$timestring"/></time>
            </xsl:for-each>
        </p>
    </xsl:variable>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:h2[@class='author']"/>
    <xsl:template match="xhtml:p[@class='logo']"/>
    
    <xsl:template match="xhtml:h1[1]">
        <h1 itemprop="headline" class="article-title"><xsl:apply-templates select="@*|node()"/></h1><xsl:text>
</xsl:text><xsl:sequence select="$author"></xsl:sequence>
    </xsl:template>
   
    <xsl:template match="xhtml:div[@class='blockquote']">
        <blockquote><xsl:apply-templates select="@*|node()"/></blockquote>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@class='section']">
        <section><xsl:apply-templates select="node()"/></section>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@class='footer']">
        <footer class="article-footer">
            <xsl:apply-templates select="node()"/>
        </footer>
    </xsl:template>

    <xsl:template match="div[@class='abstract']">
        <section>
            <xsl:apply-templates select="@*"/>
            <h2>Abstract</h2>
            <xsl:apply-templates select="node()"/>
        </section><xsl:comment>.abstract END</xsl:comment>
    </xsl:template>

<!-- Delete the <strong>Abstract:</strong>  -->
<xsl:template match="xhtml:div[@class='abstract']//xhtml:strong">

	<xsl:variable name="strong" select="."></xsl:variable>
	<xsl:choose>
		<xsl:when test="matches($strong, '^Abstract:$')"/>
		<xsl:otherwise>
      		<xsl:copy>
      			<xsl:apply-templates/>
      		</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

    <xsl:template match="@class[.='main-title']"/>
    <xsl:template match="xhtml:p/@id"/>
    
    <xsl:template match="xhtml:div[@id='pp-ojs-article']">
        <article itemscope="itemscope" itemtype="http://schema.org/ScholarlyArticle">
            <xsl:apply-templates/>    
        </article>
        
    </xsl:template>
    
    <xsl:template match="xhtml:div[@id='article1-front']">
        <div class="front">
            <xsl:apply-templates/>
        </div><xsl:comment>.front END</xsl:comment>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@id='article1-body']">
        <div itemprop="articleBody" class="body">
            <xsl:apply-templates/>
        </div><xsl:comment>.body END</xsl:comment>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@id='article1-back']">
        <div class="back">
            <xsl:apply-templates/>
        </div><xsl:comment>.back END</xsl:comment>
    </xsl:template>
    
    <xsl:template match="xhtml:p[@class='license']/xhtml:a">
        <a>
        <xsl:apply-templates select="@*"/>
        <xsl:attribute name="itemprop" select="'license'"/>
        <xsl:apply-templates select="node()"/>
        </a>
    </xsl:template>
    
    <xsl:template match="xhtml:p[not(node())]"/>
    
    <xsl:template match="xhtml:i/xhtml:i">
            <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <xsl:template match="xhtml:div[@class='history']">
        <xsl:sequence select="$historymeta"/>
    </xsl:template>
    
</xsl:stylesheet>

