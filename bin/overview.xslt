<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright (c) 2013-2014, Marcus Rohrmoser mobile Software
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted
  provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions
     and the following disclaimer.

  2. The software must not be used for military or intelligence or related purposes nor
     anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  get RDF about Tatort episodes index with episode numbering added.


  $ xsltproc -html daserste.de.index.xslt http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/sendung/index.html

  http://www.w3.org/TR/xslt
  http://www.w3.org/TR/xpath/#function-substring
-->
<xsl:stylesheet
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:taep="http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/sendung/#"
    xmlns:tako="http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/ermittler/#"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="date str"
    exclude-result-prefixes="xsl date str"
    version="1.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <rdf:RDF xml:base="http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/sendung/">
      <!-- missing: 267 http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/sendung/2008/die-pruefung-100.html -->
			<dctype:MovingImage rdf:about="#episode-{267}">
				<dcterms:title xml:lang="de">Die Prüfung</dcterms:title>
				<dcterms:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2005-07-03</dcterms:issued>
				<dcterms:alternative rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">267</dcterms:alternative>
				<dcterms:identifier>2008/die-pruefung-100</dcterms:identifier>
				<dcterms:source rdf:resource="2008/die-pruefung-100.html"/>
			</dctype:MovingImage>
      <xsl:for-each select=".//select[@id='filterBoxDate']//option[position() &gt; 1]">
        <!-- skip first entry -->
        <xsl:variable name="epi_wrong" select="last() - position() + 1"/>
        <xsl:variable name="epi_right">
          <xsl:choose>
            <xsl:when test="$epi_wrong &lt;= 266"><xsl:value-of select="$epi_wrong"/></xsl:when>
            <!-- missing: 267 http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/sendung/2008/die-pruefung-100.html -->
            <xsl:otherwise><xsl:value-of select="$epi_wrong + 1"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="episode" select="format-number($epi_right, '0000')"/>
        <xsl:variable name="title" select="normalize-space(substring-after(.,':'))"/>
        <xsl:variable name="date_de" select="str:split(normalize-space(substring-before(.,':')),'.')"/>
        <xsl:variable name="issued">
          <xsl:value-of select="$date_de[3]"/>-<xsl:value-of select="$date_de[2]"/>-<xsl:value-of select="$date_de[1]"/>
        </xsl:variable>

        <dctype:MovingImage rdf:about="#episode-{$episode}">
          <dcterms:title xml:lang="de"><xsl:value-of select="$title"/></dcterms:title>
          <dcterms:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="$issued"/></dcterms:issued>
          <dcterms:alternative rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="format-number($episode, '0')"/></dcterms:alternative>
          <dcterms:identifier><xsl:value-of select="@value"/></dcterms:identifier>
          <dcterms:source rdf:resource="{@value}.html"/>
        </dctype:MovingImage>
      </xsl:for-each>

      <xsl:for-each select=".//select[@id='filterBoxGroup']//option[position() &gt; 1]">
        <dctype:Text rdf:about="../ermittler/{@value}.html">
          <xsl:variable name="s0">
            <xsl:choose>
              <xsl:when test="substring-before(.,'(') != ''">
                <xsl:value-of select="substring-before(.,'(')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:for-each select="str:split(str:replace(str:replace(str:replace($s0, ' und ', ','), ' sowie ', ','), ' mit ', ','),',')">
            <dc:subject><xsl:value-of select="normalize-space(.)"/></dc:subject>
          </xsl:for-each>
          <dcterms:identifier><xsl:value-of select="@value"/></dcterms:identifier>
          <dcterms:title xml:lang="de"><xsl:value-of select="."/></dcterms:title>
          <dcterms:references rdf:resource="../ermittler/{@value}~_show-overviewBroadcasts.html"/>
        </dctype:Text>
      </xsl:for-each>

    </rdf:RDF>
  </xsl:template>
</xsl:stylesheet>