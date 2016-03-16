<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:orig="http://www.le-tex.de/namespace"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:adhcss="http://transpect.io/adhcss"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:sm="http://transpect.io/stylemapper"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  <xsl:template match="*|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[preceding-sibling::para[1][not(./node()) and not(./text())]]">
    <xsl:variable name="pre-sib" select="preceding-sibling::para[1]" as="element(para)?"/>
    <xsl:copy>
      <xsl:attribute name="orig:margin-top" select="@css:margin-top"/>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="pre" select="$pre-sib" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="css:length-to-double" as="xs:double">
    <xsl:param name="length" as="xs:string?"/>
    <xsl:sequence select="(
                            for $m in $length 
                              return number(replace($m, '[^\d.]', '')),
                            0
                          )[1]"/>
  </xsl:function>
  
  <xsl:template match="@css:margin-top">
    <xsl:param name="pre" as="element(para)?" tunnel="yes"/>
    <xsl:variable name="line-height" select=" css:length-to-double($pre/@css:line-height)*css:length-to-double($pre/@css:font-size)"></xsl:variable>
      <xsl:attribute name="{name()}" select="concat(
                                               string(
                                                 sum((css:length-to-double(.),
                                                      css:length-to-double($pre/@css:margin-bottom),
                                                      css:length-to-double($pre/@css:margin-top),
                                                       css:length-to-double($pre/@css:font-size),
                                                      $line-height
                                                    ))
                                               ),
                                               'pt'
                                             )"/>    
  </xsl:template>
</xsl:stylesheet>