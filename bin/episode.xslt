<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright (c) 2013-2015, Marcus Rohrmoser mobile Software
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
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
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
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="date dyn str"
    exclude-result-prefixes="xsl date dyn str"
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
          <dc:rights><xsl:value-of select="/html/head/meta[@name='copyright']/@content"/></dc:rights>
          <dc:publisher><xsl:value-of select="/html/head/meta[@name='publisher']/@content"/></dc:publisher>
          <dcterms:rightsHolder><xsl:value-of select="/html/head/meta[@name='owner']/@content"/></dcterms:rightsHolder>
          <!-- Basics -->
          <dcterms:title xml:lang="{$lang}"><xsl:value-of select="h1"/></dcterms:title>
          <dcterms:abstract xml:lang="{$lang}"><xsl:value-of select="/html/head/meta[@property='og:description']/@content"/></dcterms:abstract>
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
                    <foaf:name><xsl:value-of select="normalize-space(td[1])"/></foaf:name>
                    <!-- foaf:page rdf:resource="http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/#kressin"/ -->
                  </movie:character>
                </movie:character>
                <movie:actor>
                  <foaf:Person>
                    <foaf:name><xsl:value-of select="normalize-space(td[2])"/></foaf:name>
                  </foaf:Person>
                </movie:actor>
              </movie:performance>
            </movie:performance>
          </xsl:for-each>

          <!-- Crew -->
          <movie:production_company>
            <xsl:variable name="prod_comp" select="//div[contains(@class,'box') and h3[contains(@class,'ressort') and text() = 'Produktion']]//h4[contains(@class,'headline')]"/>
            <xsl:if test="$prod_comp">
              <foaf:Organization>
                <foaf:name>
                  <xsl:value-of select="normalize-space(str:replace(str:replace($prod_comp, 'Dieser Film wurde vom', ''), 'produziert.', ''))"/>
                </foaf:name>
              </foaf:Organization>
            </xsl:if>
          </movie:production_company>
          <xsl:for-each select=".//table[2]//tr[td]">
            <xsl:variable name="crew_task" select="normalize-space(translate(td[1], ':', ' '))"/>
            <xsl:variable name="crew_member" select="normalize-space(td[2])"/>
            <xsl:variable name="elm_qnames">
              <xsl:choose>
                <xsl:when test="$crew_task = 'Puppenspiel, Bühne, Figuren'"></xsl:when>
                <xsl:when test="$crew_task = 'Regie'">director</xsl:when>
                <xsl:when test="$crew_task = 'Regie und Drehbuch'">director,story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Regie und Buch'">director,story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Buch und Regie'">director,story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Regie und Musik'">director,music_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Kamera und Musik'">cinematographer,music_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Regie und Kamera'">director,cinematographer</xsl:when>
                <xsl:when test="$crew_task = 'Ausstattung J'">film_set_designer</xsl:when>
                <xsl:when test="$crew_task = 'Ausstattung'">film_set_designer</xsl:when>
                <xsl:when test="$crew_task = 'Szenenbild'">film_set_designer</xsl:when>
                <xsl:when test="$crew_task = 'Schnitt'">editor</xsl:when>
                <xsl:when test="$crew_task = 'Autor'">story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Drehbuch'">story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Drehbuchbearbeitung'">story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Idee'">story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Buch'">story_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Kamera'">cinematographer</xsl:when>
                <xsl:when test="$crew_task = 'Musik'">music_contributor</xsl:when>
                <xsl:when test="$crew_task = 'Produktionsleitung'">producer</xsl:when>
                <xsl:when test="$crew_task = 'Kostüme'">film_costume_designer</xsl:when>
                <xsl:otherwise><xsl:message>Unknown Crew: <xsl:value-of select="td[1]"/> in <xsl:value-of select="$base_url"/></xsl:message></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="str:split($elm_qnames,',')">
              <xsl:variable name="elm_qname" select="."/>
              <xsl:if test="string-length($elm_qname) &gt; 0">
                <xsl:for-each select="str:split(str:replace(str:replace(str:replace(str:replace(translate($crew_member, '/', ','), ' und ', ','), ' u. ', ','), ' sowie ', ','), ' mit ', ','), ',')">
                  <xsl:element name="movie:{$elm_qname}">
                    <!-- rdfs:label><xsl:value-of select="$crew_task"/></rdfs:label -->
                    <foaf:Person><foaf:name><xsl:value-of select="normalize-space(.)"/></foaf:name></foaf:Person>
                  </xsl:element>
                </xsl:for-each>
              </xsl:if>
              </xsl:for-each>
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
