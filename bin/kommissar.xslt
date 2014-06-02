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


  Get all kommissar <-> episode relations.


  $ xsltproc -stringparam base_url http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/ermittler/eisner-100~_show-overviewBroadcasts.html -html -output kommissar/eisner-100.rdf kommissar.xslt http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/ermittler/eisner-100~_show-overviewBroadcasts.html

  http://www.w3.org/TR/xslt
  http://www.w3.org/TR/xpath/#function-substring
-->
<xsl:stylesheet
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns:movieontology="http://www.movieontology.org/2009/10/01/movieontology.owl#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:taep="http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/sendung/#"
    xmlns:tako="http://www.daserste.de/unterhaltung/krimi/polizeiruf-110/ermittler/#"
    xmlns:date="http://exslt.org/dates-and-times"
    extension-element-prefixes="date"
    exclude-result-prefixes="xsl date"
    version="1.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <rdf:RDF>
      <xsl:for-each select="//*[contains(@class,'list')]//a/@href">
        <rdf:Description rdf:about="http://www.daserste.de{.}">
          <dcterms:isPartOf rdf:resource="{$base_url}"/>
        </rdf:Description>
        <rdf:Description rdf:about="{$base_url}">
          <dcterms:hasPart rdf:resource="http://www.daserste.de{.}"/>
        </rdf:Description>
      </xsl:for-each>
    </rdf:RDF>
  </xsl:template>

</xsl:stylesheet>
