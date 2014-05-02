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


  get RDF about a single Tatort episode from original broadcast page.


  $ url=... ; xsltproc -stringparam episode 0002 -html episode.xslt "$url"

  http://www.w3.org/TR/xslt
  http://www.w3.org/TR/xpath/#function-substring
-->
<xsl:stylesheet
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns:movie="http://data.linkedmdb.org/resource/movie/"
    xmlns:imdb_name="http://www.imdb.com/name/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:movieontology="http://www.movieontology.org/2009/10/01/movieontology.owl#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:taep="http://www.daserste.de/unterhaltung/krimi/tatort/sendung/#"
    xmlns:tako="http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/#"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:dyn="http://exslt.org/dynamic"
    extension-element-prefixes="date dyn"
    exclude-result-prefixes="xsl date dyn"
    version="1.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <rdf:RDF>
      <xsl:variable name="image_nodes_expression">substring-before(substring-after(., "'m':{'src':'"), "'")</xsl:variable>
      <xsl:variable name="image_nodes" select="dyn:map(.//div[contains(@class,'mediaA')]//img/@data-ctrl-attributeswap, $image_nodes_expression) | /html/head/meta[@name='twitter:image:src' or @property='og:image']/@content[normalize-space(.) != '']"/>

      <xsl:variable name="lang">de</xsl:variable>
      <!-- alternate url (with strange year) -->
      <rdf:Description rdf:about="{/html/head/meta[@property='og:url']/@content}">
        <owl:sameAs rdf:resource="{$base_url}"/>
      </rdf:Description>

      <xsl:for-each select="$image_nodes">
        <!-- all candidates -->
        <dctype:StillImage rdf:about="{.}">
          <dcterms:isReferencedBy rdf:resource="{$base_url}"/>
        </dctype:StillImage>
      </xsl:for-each>

      <dctype:Text rdf:about="{$base_url}">
        <xsl:for-each select=".//div[@id='content']//div[@class='box' and h1]">
          <!-- Legal -->
          <dc:rights><xsl:value-of select="/html/head/meta[@name='DC.Copyright']/@content"/></dc:rights>
          <dc:publisher><xsl:value-of select="/html/head/meta[@name='DC.Publisher']/@content"/></dc:publisher>
          <dcterms:rightsHolder><xsl:value-of select="/html/head/meta[@name='DC.Author']/@content"/></dcterms:rightsHolder>
          <!-- Basics -->
          <dcterms:title xml:lang="{$lang}"><xsl:value-of select="h1"/></dcterms:title>
          <dcterms:abstract xml:lang="{$lang}"><xsl:value-of select="/html/head/meta[@name='DC.Description']/@content"/></dcterms:abstract>
          <xsl:for-each select="$image_nodes[1]">
            <!-- only first -->
            <dcterms:references rdf:resource="{.}"/>
          </xsl:for-each>
          <dcterms:description xml:lang="{$lang}">
            <xsl:for-each select="h1/following-sibling::p">
              <xsl:apply-templates select="text()|br"/><xsl:text>

</xsl:text>
            </xsl:for-each>
          </dcterms:description>

          <!-- Broadcast Date(s) -->
          <xsl:for-each select="//*[contains(@class,'sectionC')]//*[contains(@class,'boxCon')]//*[contains(@class,'teasertext') or contains(@class,'text')]">
            <xsl:variable name="p00" select="substring-after(normalize-space(translate(.,'|',' ')),' ')"/>
            <xsl:variable name="d00" select="substring-before($p00,' ')"/>
            <xsl:variable name="day" select="substring-before($d00,'.')"/>
            <xsl:variable name="mon_year" select="substring-after($d00,'.')"/>
            <xsl:variable name="mon" select="substring-before($mon_year,'.')"/>
            <xsl:variable name="year" select="substring-after($mon_year,'.')"/>
            <xsl:variable name="p01" select="substring-after($p00,' ')"/>
            <xsl:variable name="time" select="substring-before($p01,' ')"/>
            <xsl:variable name="century">
              <xsl:choose>
                <xsl:when test="$year &lt; 70">20</xsl:when>
                <xsl:otherwise>19</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="date_time"><!--
              --><xsl:value-of select="$century"/><xsl:value-of select="$year"/>-<xsl:value-of select="$mon"/>-<xsl:value-of select="$day"/>T<xsl:value-of select="$time"/>:00<!--
            --></xsl:variable>
            <dcterms:date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
              <xsl:value-of select="$date_time"/>
            </dcterms:date>
          </xsl:for-each>
          <!-- xsl:for-each select="//*[contains(@class,'teasertext') | (contains(../@class,'text'))]">
          </xsl:for-each -->

          <!-- Cast -->
          <xsl:for-each select=".//table[1]//tr[td]">
            <movie:performance>
              <movie:performance>
                <movie:character>
                  <movie:character>
                    <foaf:name><xsl:value-of select="td[1]"/></foaf:name>
                    <!-- foaf:page rdf:resource="http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/#kressin"/ -->
                  </movie:character>
                </movie:character>
                <movie:actor>
                  <foaf:Person>
                    <foaf:name><xsl:value-of select="td[2]"/></foaf:name>
                  </foaf:Person>
                </movie:actor>
              </movie:performance>
            </movie:performance>
          </xsl:for-each>

          <!-- Crew -->
          <movie:production_company><xsl:value-of select="//*[contains(@class,'teaser')]//*[contains(@class,'headline')]"/></movie:production_company>
          <xsl:for-each select=".//table[2]//tr[td]">
            <xsl:choose>
              <xsl:when test="td[1] = 'Regie:'">
                <movie:director>
                  <foaf:Person>
                    <foaf:name><xsl:value-of select="td[2]"/></foaf:name>
                  </foaf:Person>
                </movie:director>
              </xsl:when>
              <xsl:when test="td[1] = 'Buch:'">
                <movie:story_contributor>
                  <foaf:Person>
                    <foaf:name><xsl:value-of select="td[2]"/></foaf:name>
                  </foaf:Person>
                </movie:story_contributor>
              </xsl:when>
              <xsl:when test="td[1] = 'Kamera:'">
                <movie:cinematographer>
                  <foaf:Person>
                    <foaf:name><xsl:value-of select="td[2]"/></foaf:name>
                  </foaf:Person>
                </movie:cinematographer>
              </xsl:when>
              <xsl:when test="td[1] = 'Musik:'">
                <movie:music_contributor>
                  <foaf:Person>
                    <foaf:name><xsl:value-of select="td[2]"/></foaf:name>
                  </foaf:Person>
                </movie:music_contributor>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message><xsl:value-of select="td[1]"/></xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>

        </xsl:for-each>
      </dctype:Text>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="br">
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>
