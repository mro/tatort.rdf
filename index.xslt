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


  $ xsltproc -html daserste.de.index.xslt http://www.daserste.de/unterhaltung/krimi/tatort/sendung/index.html

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
    xmlns:taep="http://www.daserste.de/unterhaltung/krimi/tatort/sendung/#"
    xmlns:tako="http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/#"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="date str"
    exclude-result-prefixes="xsl date str"
    version="1.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <rdf:RDF xml:base="http://www.daserste.de/unterhaltung/krimi/tatort/sendung/">
      <xsl:for-each select=".//select[@id='filterBoxDate']//option[position() &gt; 1]">
        <!-- skip first entry -->
        <xsl:variable name="episode" select="format-number(last() - position() + 1, '0000')"/>
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
<!--
      <xsl:for-each select=".//select[@id='filterBoxGroup']//option[position() &gt; 1]">
        <dctype:Text rdf:about="../kommissare/{@value}.html">
        	<xsl:comment>
        		Todo: split title into kommissar names.
        	</xsl:comment>
          <dcterms:identifier><xsl:value-of select="@value"/></dcterms:identifier>
          <dcterms:title xml:lang="de"><xsl:value-of select="."/></dcterms:title>
          <dcterms:references rdf:resource="../kommissare/{@value}~_show-overviewBroadcasts.html"/>
        </dctype:Text>
      </xsl:for-each>
-->
    </rdf:RDF>
  </xsl:template>
</xsl:stylesheet>