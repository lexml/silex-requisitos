<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
  
    
        <xsl:output method="text" encoding="UTF-8" media-type="text/plain"  />
        <xsl:key name="ks" match="entrada" use="@id"/>
        <xsl:key name="ke" match="especificoDe" use="@refid"/>
        <xsl:template match="/glossario">
            <xsl:result-document href="glossario.tex">
                <xsl:for-each select="entrada[not(@abstrato='sim')]">
                    <xsl:sort select="singular" lang="pt"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:result-document>
            <xsl:result-document href="hierarquia.tex">
                <xsl:for-each select="entrada[not(especificoDe) and not(@abstrato='sim')]">
                    <xsl:sort select="singular" lang="pt"/>
                    <xsl:apply-templates select="." mode="hierarquia"/>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:template>
    
        <xsl:template match="entrada" mode="hierarquia">
            <xsl:choose>
                <xsl:when test="ver"><xsl:value-of select="normalize-space(singular)"/><xsl:text> \\ &#x0a;</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>\Gls{</xsl:text><xsl:value-of select="@id"/><xsl:text>} \\ &#x0a;</xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:if test="ver"><xsl:text> \hspace*{1.0cm}\glosshsep \textit{Ver:} \Gls{</xsl:text><xsl:value-of select="ver/@refid"/><xsl:text>} \\ &#x0a;</xsl:text></xsl:if>
            <xsl:call-template name="filhos"><xsl:with-param name="nivel">1</xsl:with-param></xsl:call-template>
        </xsl:template>
    
        <xsl:template name="filhos">
            <xsl:param name="nivel" />
            <xsl:for-each select="key('ke',@id)/..">
                <xsl:text> \hspace*{</xsl:text><xsl:value-of select="$nivel"></xsl:value-of><xsl:text>.0cm}</xsl:text><xsl:choose>
                    <xsl:when test="@classificacao='sim'"><xsl:text>\glosshsepclass </xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>\glosshsep </xsl:text></xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="@abstrato='sim'">
                        <xsl:value-of select="singular"/> <xsl:text> \\ &#x0a;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('\Gls{',@id,'} \\ &#x0a;')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="filhos"><xsl:with-param name="nivel"><xsl:value-of select="number($nivel)+1"/></xsl:with-param></xsl:call-template>
            </xsl:for-each>
        </xsl:template>
    
        <xsl:template match="entrada">
            <xsl:text>\newglossaryentry{</xsl:text><xsl:value-of select="@id"/><xsl:text>}{&#x0a;</xsl:text>
               <xsl:if test="singular"><xsl:text>       name={</xsl:text><xsl:value-of select="normalize-space(singular)"/><xsl:text>},&#x0a;</xsl:text></xsl:if>

				<!-- 
               <xsl:if test="ver"><xsl:text>       see=[ver:]{</xsl:text><xsl:value-of select="ver/@refid"/><xsl:text>},&#x0a;</xsl:text></xsl:if>
				 -->
				 
               <xsl:if test="definicao">
                   <xsl:text>       description={</xsl:text><xsl:value-of select="normalize-space(definicao)"/>
                   <xsl:if test="ver"><xsl:text> \textit{Ver:} \Gls{</xsl:text><xsl:value-of select="ver/@refid"/><xsl:text>}.</xsl:text></xsl:if>
                   <xsl:if test="acronimo"><xsl:text>&#x0a;\newline \textit{Acrônimo(s):} </xsl:text><xsl:value-of select="acronimo"/><xsl:text>.</xsl:text></xsl:if>
                   <xsl:if test="especificoDe"><xsl:text>&#x0a;\newline \textit{Específico de:} \Gls{</xsl:text><xsl:for-each select="key('ks',especificoDe/@refid)/@id"><xsl:value-of select="."/><xsl:text>}.</xsl:text></xsl:for-each></xsl:if>
                   <xsl:if test="key('ke',@id)"><xsl:text>&#x0a;\newline \textit{Geral de:} </xsl:text><xsl:for-each select="key('ke',@id)/../@id"><xsl:value-of select="concat('\Gls{',.,'}')"/><xsl:if test="not(position()=last())"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>.</xsl:text></xsl:if>
                   <xsl:if test="nota"><xsl:text>&#x0a;\newline \textit{Nota:} </xsl:text><xsl:value-of select="nota"/></xsl:if>
                   <xsl:if test="refLeg"><xsl:text>&#x0a;\newline \textit{Referência Legislativa:} </xsl:text><xsl:value-of select="refLeg"/><xsl:text>.</xsl:text></xsl:if>
                   <xsl:variable name="vt">
                       <xsl:copy-of select="id(verTambem/@refids)"/>
                       <xsl:copy-of select="idref(@id)[name()='refids']/../.."/>
                   </xsl:variable>
                   <!--<xsl:value-of select="$vt"></xsl:value-of>-->
                 <!--<xsl:message><xsl:value-of select="concat(./@id,'@', count($vt),'%',$vt,   count(distinct-values($vt)),'x')"/></xsl:message>-->
                   <xsl:if test="verTambem"><xsl:text>&#x0a;\newline \textit{Ver também:} </xsl:text><xsl:for-each select="distinct-values($vt/entrada/@id)"><xsl:sort select="." lang="pt"></xsl:sort><xsl:text>\Gls</xsl:text>{<xsl:value-of select="."/><xsl:text>}</xsl:text><xsl:if test="not(position()=last())"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>.</xsl:text></xsl:if>
                   <xsl:text>},&#x0a;</xsl:text>
               </xsl:if>
 			<!--                 
            <xsl:if test="verTambem"><xsl:text>       see=[ver também:]{</xsl:text><xsl:for-each select="tokenize(verTambem/@refids,' ')"><xsl:value-of select="."/><xsl:if test="not(position()=last())"><xsl:text>,</xsl:text></xsl:if></xsl:for-each><xsl:text>},&#x0a;</xsl:text></xsl:if>
              -->
            <xsl:text>      }&#x0a;</xsl:text>
             
        </xsl:template>
                
    
</xsl:stylesheet>