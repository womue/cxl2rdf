<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:functx="http://www.functx.com">
<xsl:output method="xml" indent="yes"/>

  <!-- see http://www.xsltfunctions.com/xsl/functx_words-to-camel-case.html -->
  <xsl:function name="functx:capitalize-first" as="xs:string?">
    <xsl:param name="arg" as="xs:string?"/>

    <xsl:sequence select="
     concat(upper-case(substring($arg,1,1)),
               substring($arg,2))
   "/>

  </xsl:function>

<xsl:function name="functx:words-to-camel-case" as="xs:string">
  <xsl:param name="arg" as="xs:string?"/>

  <xsl:sequence select="
     string-join((tokenize($arg,'\s+')[1],
       for $word in tokenize($arg,'\s+')[position() > 1]
       return functx:capitalize-first($word))
      ,'')
 "/>

</xsl:function>
<xsl:template match="/">
  <rdf:RDF
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
      xmlns:owl="http://www.w3.org/2002/07/owl#"
      xmlns:dc="http://purl.org/dc/elements/1.1/">

  <!-- eSIT4SIP Header -->
  <xsl:message>before ontology ...</xsl:message>
  <owl:Ontology rdf:about="http://www.esit4sip.eu/learning">
        <dc:title>eSIT4SIP Learning Ontology</dc:title>
        <dc:description>Ontology for tagging learning scenarios and patterns</dc:description>
  </owl:Ontology>

  <xsl:for-each select="/*[local-name() = 'cmap']/*[local-name() = 'map']/*[local-name() = 'concept-list']/*[local-name() = 'concept']">
    <xsl:variable name="current-concept" select="."/>
    <xsl:variable name="current-id" select="$current-concept/@id"/>
      <!-- check whether this concept is class or property -->
      <!-- find linking phrase -->
      <xsl:message>concept: <xsl:value-of select="$current-concept/@label"/>  id: <xsl:value-of select="$current-id"/></xsl:message>
      <xsl:for-each select="/*[local-name() = 'cmap']/*[local-name() = 'map']/*[local-name() = 'connection-list']/*[local-name() = 'connection' and @from-id = $current-id]">
        <xsl:variable name="linking-phrase-id" select="@to-id"/>
          <!-- extract corresponding linking phrase -->
          <xsl:variable name="linking-phrase" select="/*[local-name() = 'cmap']/*[local-name() = 'map']/*[local-name() = 'linking-phrase-list']/*[local-name() = 'linking-phrase' and @id = $linking-phrase-id]"/>
          <xsl:message>  to: <xsl:value-of select="@to-id"/>  phrase: <xsl:value-of select="$linking-phrase/@label"/></xsl:message>
          <!-- extract connection to linked concept -->
          <xsl:variable name="connection-to-linked-concept" select="/*[local-name() = 'cmap']/*[local-name() = 'map']/*[local-name() = 'connection-list']/*[local-name() = 'connection' and @from-id = $linking-phrase-id]"/>
          <xsl:message> connection to linked concept: <xsl:value-of select="$connection-to-linked-concept/@id"/></xsl:message>
          <!-- extract corresponding linked concept -->
          <xsl:variable name="linked-concept" select="/*[local-name() = 'cmap']/*[local-name() = 'map']/*[local-name() = 'concept-list']/*[local-name() = 'concept' and @id = $connection-to-linked-concept/@to-id]"/>
          <xsl:message> linked concept: <xsl:value-of select="$linked-concept/@id"/>  label: <xsl:value-of select="$linked-concept/@label"/></xsl:message>
          <xsl:choose>
            <xsl:when test="$linking-phrase/@label = 'is a' or $linking-phrase/@label = 'is-a'">
              <owl:Class rdf:ID='{functx:words-to-camel-case($current-concept/@label)}'>
              <!-- <owl:Class rdf:ID="functx:words-to-camel-case($current-concept/@label)"> -->
                <rdfs:subClassOf rdf:resource='#{functx:words-to-camel-case($linked-concept/@label)}'/>
                <!-- <rdfs:subClassOf rdf:resource="#functx:words-to-camel-case($linked-concept/@label)"/> -->
                <rdfs:label xml:lang="en"><xsl:value-of select="$current-concept/@label"/></rdfs:label>
                <rdfs:comment><xsl:value-of select="$current-concept/@long-comment"/></rdfs:comment>
              </owl:Class>
            </xsl:when>
            <xsl:when test="$linking-phrase/@label = 'is a form of' or $linking-phrase/@label = 'is a Form of'">
              <xsl:message>WARNING: 'is a form of' connection for concept <xsl:value-of select="$current-concept/@label"/> currently not supported</xsl:message>
            </xsl:when>
            <xsl:when test="$linking-phrase/@label = 'synonym' or $linking-phrase/@label = 'Synonym'">
              <xsl:message>WARNING: 'synonym' connection for concept <xsl:value-of select="$current-concept/@label"/> currently not supported</xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>WARNING: unknown connection '<xsl:value-of select="$linking-phrase/@label"/>' for concept <xsl:value-of select="$current-concept/@label"/></xsl:message>
            </xsl:otherwise>
          </xsl:choose>

      </xsl:for-each>
    </xsl:for-each>
  </rdf:RDF>
</xsl:template>
</xsl:stylesheet>
