<?xml version="1.0"?>
<!--
	copy.xslt http://stackoverflow.com/a/5877772
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:movie="http://data.linkedmdb.org/resource/movie/" version="1.0">
  <!--  -->
  <xsl:template match="movie:*"/>
  <!-- Identity template, provides default behavior that copies all content into the output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
