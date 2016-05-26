<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
  xmlns:tr="http://transpect.io"
  xmlns:sm="http://transpect.io/stylemapper" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:adhcss="http://transpect.io/adhcss"
  xmlns:docx2hub="http://transpect.io/namespace/docx2hub" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:variable name="hub-doc" select="collection()[2]" as="document-node()"/>
  <xsl:variable name="source-dir-uri" as="xs:string"
    select="$hub-doc/dbk:hub/dbk:info/dbk:keywordset[@role='hub']/dbk:keyword[@role='source-dir-uri']"/>

  <xsl:key name="hub-element-by-srcpath" match="*[@srcpath]" use="concat($source-dir-uri, @srcpath)"/>
  <xsl:key name="marked-element-by-srcpath" match="*[@sm:action = 'delete'][@srcpath]" use="concat($source-dir-uri, @srcpath)"/>
  
  <xsl:function name="tr:get-new-spaces">
    <xsl:param name="corresponding-hub-element" as="element()?"/>
    <xsl:variable name="original-spaces" as="attribute()?">
      <xsl:sequence select="$corresponding-hub-element/@css:*[matches(local-name(), 'orig-margin')]"/>
    </xsl:variable>
            <xsl:sequence
              select="
                for $x in $original-spaces
                return
                 $corresponding-hub-element/@*[local-name() = replace($x/local-name(), 'orig-', '')]"
            />
  </xsl:function>

  <xsl:template match="*|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- IDML-->
  <xsl:template match="ParagraphStyleRange[key('hub-element-by-srcpath', @srcpath, $hub-doc)]">
    <xsl:copy>
      <xsl:apply-templates select="@*">
        </xsl:apply-templates>
      <xsl:attribute name="AppliedParagraphStyle" select="concat('ParagraphStyle/',key('hub-element-by-srcpath', @srcpath, $hub-doc)/@role)"></xsl:attribute>
      <xsl:apply-templates select="node()">
        <xsl:with-param name="corresponding-hub-element" as="element(*)?"
          select="key('hub-element-by-srcpath', ./@srcpath, $hub-doc)" tunnel="yes"/>
      </xsl:apply-templates>    
    </xsl:copy>
  </xsl:template>

  <xsl:template match="CharacterStyleRange[key('hub-element-by-srcpath', @srcpath, $hub-doc)]" priority="2">
    <xsl:param name="corresponding-hub-element" as="element()?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*">
        <xsl:with-param name="corresponding-hub-element" as="element(*)?"
          select="key('hub-element-by-srcpath', ./@srcpath, $hub-doc)" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:attribute name="AppliedCharacterStyle" select="concat('CharacterStyle/',key('hub-element-by-srcpath', @srcpath, $hub-doc)/@role)"></xsl:attribute>
      <xsl:apply-templates select="node()">
        <xsl:with-param name="corresponding-hub-element" as="element(*)?"
          select="key('hub-element-by-srcpath', ./@srcpath, $hub-doc)" tunnel="yes"/>
      </xsl:apply-templates>    
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="CharacterStyleRange">
    <xsl:param name="corresponding-hub-element" as="element(*)?" tunnel="yes"/>
        <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="corresponding-hub-element" as="element(*)?" select="$corresponding-hub-element"></xsl:with-param>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="CharacterStyleRange/@*[not(local-name() = ('AppliedCharacterStyle', 'srcpath'))]" priority="2">
    <xsl:param name="corresponding-hub-element" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="prop" as="xs:string">
      <xsl:apply-templates select="." mode="Attr2css"/>
    </xsl:variable>
    <xsl:if test="not(tokenize($corresponding-hub-element/@sm:remove-adhoc, '\s+') = ($prop, '#all'))">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@Underline" mode="Attr2css">
    <xsl:sequence select="'text-decoration-style:underlined'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@FillColor" mode="Attr2css">
    <xsl:sequence select="'color'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@StrikeThru" mode="Attr2css">
    <xsl:sequence select="'text-decoration-style:line-trhough]'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@PointSize" mode="Attr2css">
    <xsl:sequence select="'font-size'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RightIndent" mode="Attr2css">
    <xsl:sequence select="'margin-right'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@LeftIndent" mode="Attr2css">
    <xsl:sequence select="'margin-left'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@LeftAlign" mode="Attr2css">
    <xsl:sequence select="'text-align:left'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RightAlign" mode="Attr2css">
    <xsl:sequence select="'text-align:right'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@CenterAlign" mode="Attr2css">
    <xsl:sequence select="'text-align:center'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@LeftJustified" mode="Attr2css">
    <xsl:sequence select="'text-align-last:left'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RightJustified" mode="Attr2css">
    <xsl:sequence select="'text-align-last:right'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@CenterJustified" mode="Attr2css">
    <xsl:sequence select="'text-align-last:center'"></xsl:sequence>
  </xsl:template>

  <xsl:template match="@FullyJustified" mode="Attr2css">
    <xsl:sequence select="'text-align-last:justify'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@FontStyle" mode="Attr2css">
    <xsl:sequence select="'font-style font-weight'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleBelowLineWeight" mode="Attr2css">
    <xsl:sequence select="'border-bottom-width'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleBelowTint" mode="Attr2css">
    <xsl:sequence select="'border-bottom-tint'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleBelowOffset" mode="Attr2css">
    <xsl:sequence select="'padding-bottom'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleBelowTint" mode="Attr2css">
    <xsl:sequence select="'border-bottom-tint'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleAboveLineWeight" mode="Attr2css">
    <xsl:sequence select="'border-top-width'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleAboveTint" mode="Attr2css">
    <xsl:sequence select="'border-top-tint'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@RuleAboveOffset" mode="Attr2css">
    <xsl:sequence select="'padding-top'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@TopRightCornerRadius" mode="Attr2css">
    <xsl:sequence select="'border-top-right-radius'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@BottomLeftCornerRadius" mode="Attr2css">
    <xsl:sequence select="'border-bottom-left-radius'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@BottomRightCornerRadius" mode="Attr2css">
    <xsl:sequence select="'border-bottom-right-radius'"></xsl:sequence>
  </xsl:template>  

  <xsl:template match="@RightEdgeStrokeWeight" mode="Attr2css">
    <xsl:sequence select="'border-right-width'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@StrokeColor" mode="Attr2css">
    <xsl:sequence select="'border-color'"></xsl:sequence>
  </xsl:template>

  <xsl:template match="@StrokeWeight" mode="Attr2css">
    <xsl:sequence select="'border-width'"></xsl:sequence>
  </xsl:template>
 
  <xsl:template match="@VerticalJustification[.= 'TopAlign']" mode="Attr2css">
    <xsl:sequence select="'vertical-align:top'"></xsl:sequence>
  </xsl:template> 
  
  <xsl:template match="@VerticalJustification[.= 'CenterAlign']" mode="Attr2css">
    <xsl:sequence select="'vertical-align:middle'"></xsl:sequence>
  </xsl:template> 
  
  <xsl:template match="@VerticalJustification[.= 'BottomAlign']" mode="Attr2css">
    <xsl:sequence select="'vertical-align:bottom'"></xsl:sequence>
  </xsl:template> 

  <xsl:template match="@Capitalization[.= 'SmallCaps']" mode="Attr2css">
    <xsl:sequence select="'font-variant:small-caps'"></xsl:sequence>
  </xsl:template>
  
  <xsl:template match="@Capitalization[.= ('AllCaps', 'CapToSmallCap')]" mode="Attr2css">
    <xsl:sequence select="'text-transform:uppercase'"></xsl:sequence>
  </xsl:template>
  
  <!--    
     <prop name="RightIndent" type="length" target-name="css:margin-right" />
    <prop name="RightInset" type="length" target-name="css:padding-right" />
    <prop name="ShadowColor" type="color" target-name="shadow-color" />
    <prop name="SpaceAfter" type="length" target-name="css:margin-bottom" />
    <prop name="SpaceBefore" type="length" target-name="css:margin-top" />
    <prop name="LeftIndent" type="length" target-name="css:margin-left" />
    <prop name="LeftInset" type="length" target-name="css:padding-left" />
    <prop name="AppliedFont" type="linear" target-name="css:font-family"/>
    <prop name="UnderlineColor" type="color" target-name="css:text-decoration-color"/>
    <prop name="UnderlineOffset" type="length" target-name="css:text-decoration-offset"/>
    <prop name="UnderlineTint" implement="implicitly with UnderlineColor" />
    <prop name="UnderlineType" implement="use text-decoration-style must look at Stroke/..." />
    <prop name="UnderlineWeight" type="length" target-name="css:text-decoration-width" />
  -->
  <!-- DOCX  -->
  
  <xsl:template match="w:p[key('hub-element-by-srcpath', @srcpath, $hub-doc)]" priority="2">
    <xsl:variable name="corresponding-hub-element" select="key('hub-element-by-srcpath', @srcpath, $hub-doc)" as="element()?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <w:pPr>
        <w:pStyle w:val="{key('hub-element-by-srcpath', @srcpath, $hub-doc)/@role}"/>
        <xsl:apply-templates select="w:pPr/* except (w:pPr/w:pStyle, w:pPr/w:spacing)">
          <xsl:with-param name="corresponding-hub-element" as="element(*)?"
            select="$corresponding-hub-element" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:choose>
        <xsl:when test="not(exists(w:pPr/w:spacing)) and (some $x in $corresponding-hub-element/@css:* satisfies matches($x/local-name(), 'orig-margin')) and not(tokenize($corresponding-hub-element/@sm:remove-adhoc, '\s+') = ('#all'))">
          <xsl:call-template name="generate-spacing-element">
            <xsl:with-param name="corresponding-hub-element" select="$corresponding-hub-element" as="element()?"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(w:pPr/w:spacing) and (some $x in $corresponding-hub-element/@css:* satisfies matches($x/local-name(), 'orig-margin')) and not(tokenize($corresponding-hub-element/@sm:remove-adhoc, '\s+') = ('#all'))">
         <xsl:message select="'PARA HAS SPACING ATTRRRR111', $corresponding-hub-element"></xsl:message>
          <xsl:apply-templates select="w:pPr/w:spacing" mode="space-comp">
           <xsl:with-param name="corresponding-hub-element" select="$corresponding-hub-element"/>
         </xsl:apply-templates>
        </xsl:when>
        </xsl:choose>
      </w:pPr>
      <xsl:apply-templates select="* except w:pPr"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:pPr/w:spacing" mode="space-comp">
    <xsl:param name="corresponding-hub-element" as="element()?"/>
    <xsl:message select="'PARA HAS SPACING ATTRRRR222', $corresponding-hub-element"></xsl:message>
    <xsl:copy>
    <!-- to apply other templates @* like  @w:line etc is maybe not a good move for a correct computed space compensation -->
          <xsl:apply-templates select="@*"/>
           <xsl:call-template name="generate-spacing-attributes">
             <xsl:with-param name="corresponding-hub-element" select="$corresponding-hub-element"/>
           </xsl:call-template>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:r[key('hub-element-by-srcpath', @srcpath, $hub-doc)[@layout-type = 'inline']]" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*"></xsl:apply-templates>
      <w:rPr>
        <w:rStyle w:val="{key('hub-element-by-srcpath', @srcpath, $hub-doc)/@role}"></w:rStyle>
<!--          <xsl:message select="'HUB FROM w:r', ./ancestor::*[@srcpath][1]/@srcpath"></xsl:message>-->
        <xsl:apply-templates select="w:rPr/* except w:rStyle">
          <xsl:with-param name="corresponding-hub-element" as="element(*)?"
            select="key('hub-element-by-srcpath', @srcpath, $hub-doc)" tunnel="yes"/>
          </xsl:apply-templates>
      </w:rPr>
      <xsl:apply-templates select="* except w:rPr"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[key('marked-element-by-srcpath', @srcpath, $hub-doc)]" priority="3"/>
  
  <xsl:template match="w:p[@srcpath]//w:rPr">
<!--    <xsl:message select="'HUB FROM w:p//w:rPr', ./ancestor::w:p[@srcpath][1]/@srcpath"></xsl:message>-->
    <xsl:copy>
      <xsl:apply-templates select="@*, node()">
        <xsl:with-param name="corresponding-hub-element" as="element(*)?"
          select="key('hub-element-by-srcpath', ./ancestor::w:p[@srcpath][1]/@srcpath, $hub-doc)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="w:b" mode="w2css" as="xs:string">
    <xsl:sequence select="'font-weight'"/>
  </xsl:template>

  <xsl:template match="w:spacing/@w:after" mode="w2css" as="xs:string">
    <xsl:sequence select="'margin-bottom'"/>
  </xsl:template>

  <xsl:template match="w:spacing/@w:before" mode="w2css" as="xs:string">
    <xsl:sequence select="'margin-top'"/>
  </xsl:template>

  <xsl:template match="w:ind/@w:left" mode="w2css" as="xs:string">
    <xsl:sequence select="'margin-left'"/>
  </xsl:template>

  <xsl:template match="w:ind/@w:right" mode="w2css" as="xs:string">
    <xsl:sequence select="'margin-right'"/>
  </xsl:template>

  <xsl:template match="w:ind/@w:firstLine|w:ind/@hanging" mode="w2css" as="xs:string">
    <xsl:sequence select="'indent'"/>
  </xsl:template>

  <xsl:template match="w:spacing/@w:line" mode="w2css" as="xs:string">
    <xsl:sequence select="'line-height'"/>
  </xsl:template>

  <xsl:template match="w:jc" mode="w2css" as="xs:string">
    <xsl:sequence select="'text-align'"/>
  </xsl:template>

  <xsl:template match="w:vAlign|w:textAlignment" mode="w2css" as="xs:string">
    <xsl:sequence select="'vertical-align'"/>
  </xsl:template>

  <xsl:template match="w:sz|w:szCs" mode="w2css" as="xs:string">
    <xsl:sequence select="'font-size'"/>
  </xsl:template>

  <xsl:template match="w:u" mode="w2css" as="xs:string">
    <xsl:sequence select="'text-decoration-line'"/>
  </xsl:template>

  <xsl:template match="w:u/@w:val" mode="w2css" as="xs:string">
    <xsl:sequence select="'text-decoration-style'"/>
  </xsl:template>

  <xsl:template match="w:u/@w:color" mode="w2css" as="xs:string">
    <xsl:sequence select="'text-decoration-color'"/>
  </xsl:template>

  <xsl:template match="w:i" mode="w2css">
    <xsl:sequence select="'font-style'"/>
  </xsl:template>

  <xsl:template match="w:rFonts" mode="w2css">
    <xsl:sequence select="'font-family'"/>
  </xsl:template>

  <xsl:template match="w:numPr" mode="w2css">
    <xsl:sequence select="'numbering'"/>
  </xsl:template>

  <xsl:template match="w:color" mode="w2css">
    <xsl:sequence select="'color'"/>
  </xsl:template>

  <xsl:template match="w:shd" mode="w2css">
    <xsl:sequence select="'background-color'"/>
  </xsl:template>
<!-- expandable collection of style properties that could be removed via @remove-adhoc-->
  <xsl:template
    match="
      w:u/@w:color
      | w:u
      | w:u/@w:val
      | w:i
      | w:rFonts
      | w:numPr
      | w:color
      | w:shd
      | w:sz
      | w:jc
      | w:szCs
      | w:vAlign
      | w:textAlignment
      | w:spacing/@w:line
      | w:ind/@w:firstLine
      | w:ind/@hanging
      | w:ind/@w:left
      | w:ind/@w:right
      | w:spacing/@w:before
      | w:spacing/@w:after
      | w:b
      ">
    <xsl:param name="corresponding-hub-element" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="prop" as="xs:string?">
      <xsl:apply-templates select="." mode="w2css"/>
    </xsl:variable>
    <xsl:if test="not(tokenize($corresponding-hub-element/@sm:remove-adhoc, '\s+') = ($prop, '#all'))">
      <xsl:choose>
        <xsl:when test="matches($prop, 'margin-bottom|margin-top')">
          <xsl:apply-templates select="." mode="space-comp">
            <xsl:with-param name="corresponding-hub-element" select="$corresponding-hub-element"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-match/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="generate-spacing-element">
    <xsl:param name="corresponding-hub-element" as="element()?"/>
    <xsl:variable name="new-spaces" select="tr:get-new-spaces($corresponding-hub-element)"/>
    <xsl:message select="'NEWWWWWWWWWWWWWWWW SPAACES', $new-spaces,  $corresponding-hub-element/@srcpath"></xsl:message>
    <xsl:element name="w:spacing">
      <xsl:for-each select="$new-spaces">
        <xsl:choose>
          <xsl:when
            test="not(tokenize($corresponding-hub-element/@sm:remove-adhoc, '\s+') = ('margin-bottom', '#all')) and current()/local-name() = 'margin-bottom'">
            <xsl:attribute name="w:after" select="number(replace(current(), 'pt', '')) * 20"/>
          </xsl:when>
          <xsl:when
            test="not(tokenize($corresponding-hub-element/@sm:remove-adhoc, '\s+') = ('margin-top', '#all')) and current()/local-name() = 'margin-top'">
            <xsl:attribute name="w:before" select="number(replace(current(), 'pt', '')) * 20"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="generate-spacing-attributes">
    <xsl:param name="corresponding-hub-element" as="element()"/>
    <xsl:variable name="new-spaces" select="tr:get-new-spaces($corresponding-hub-element)"/>
    <xsl:for-each select="$new-spaces">
      <xsl:choose>
        <xsl:when test="current()/local-name() = 'margin-bottom'">
          <xsl:attribute name="w:after" select="number(replace(current(), 'pt', '')) * 20"/>
        </xsl:when>
        <xsl:when test="current()/local-name() = 'margin-after'">
          <xsl:attribute name="w:before" select="number(replace(current(), 'pt', '')) * 20"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="w:spacing/@w:after | w:spacing/@w:before" mode="space-comp">
    <xsl:param name="corresponding-hub-element" as="element()?"/>
    <xsl:variable name="new-space" select="if (./local-name() = 'after') then $corresponding-hub-element/@css:margin-bottom else $corresponding-hub-element/@css:margin-top" as="attribute()?"/>
    <xsl:message select="'SPACE_COMP##################################################', ., $new-space, $corresponding-hub-element/@srcpath"/>
     <xsl:message select="'PARA HAS SPACING ATTRRRR333', $corresponding-hub-element"></xsl:message>
    <xsl:copy>
      <xsl:value-of select="number(replace($new-space, 'pt', '')) * 20"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>