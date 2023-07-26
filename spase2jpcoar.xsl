<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:spase="http://www.spase-group.org/data/schema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:orcid="http://www.orcid.org/ns/orcid"
    xmlns:jpcoar="https://github.com/JPCOAR/schema/blob/master/1.0/"
    xmlns:datacite="https://schema.datacite.org/meta/kernel-4/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<xsl:template match="/spase:Spase">

    <jpcoar:jpcoar
        xmlns:jpcoar="https://github.com/JPCOAR/schema/blob/master/1.0/" 
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:datacite="https://schema.datacite.org/meta/kernel-4/"
        xmlns:oaire="http://namespace.openaire.eu/schema/oaire/"
        xmlns:dcndl="http://ndl.go.jp/dcndl/terms/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="https://github.com/JPCOAR/schema/blob/master/1.0/ jpcoar_scm.xsd">
        <!-- 7. 研究データ（オープンアクセス、JaLC DOI登録あり） / Research Data (Open Access, JaLC DOI registered) -->

        <!-- title / alternative -->
        <dc:title xml:lang="en">
            <xsl:value-of select="//spase:ResourceHeader/spase:ResourceName"/>
        </dc:title>

        <xsl:if test="//spase:ResourceHeader/spase:AlternateName">
            <dcterms:alternative xml:lang="en">
                <xsl:value-of select="//spase:ResourceHeader/spase:AlternateName"/>
            </dcterms:alternative>
        </xsl:if>

        <!-- creator / contributor -->
        <xsl:apply-templates select="//spase:ResourceHeader/spase:Contact"/>

        <!-- accessRights -->
        <xsl:apply-templates select="//spase:AccessInformation/spase:AccessRights"/>

        <!-- rights -->
        <xsl:apply-templates select="//spase:ResourceHeader/spase:Acknowledgement"/>

        <!-- subject -->
        <xsl:apply-templates select="//spase:Keyword"/>

        <!-- description -->
        <xsl:apply-templates select="//spase:ResourceHeader/spase:Description"/>

        <!-- publisher -->
        <dc:publisher xml:lang="ja">名古屋大学</dc:publisher>
        <dc:publisher xml:lang="en">Nagoya University</dc:publisher>

        <!-- date -->
        <xsl:apply-templates select="//spase:ResourceHeader/spase:ReleaseDate"/>

        <!-- language -->
        <dc:language>eng</dc:language>

        <!-- type/resource -->
        <dc:type rdf:resource="http://purl.org/coar/resource_type/c_ddb1">dataset</dc:type>

        <!-- version -->
        <xsl:apply-templates select="//spase:ProviderVersion"/>

        <!-- relation -->
        <xsl:apply-templates select="//spase:ResourceHeader/spase:DOI"/>

        <!-- url -->
        <xsl:apply-templates select="//spase:AccessInformation/spase:AccessURL/spase:URL"/>

        <!-- temporal -->
        <xsl:apply-templates select="//spase:TemporalDescription/spase:TimeSpan"/>

        <!-- geolocation -->
        <xsl:apply-templates select="//spase:InstrumentID"/>

        <!-- fundingReference -->
        <xsl:apply-templates select="//spase:ResourceHeader/Funding"/>

    </jpcoar:jpcoar>

</xsl:template>

<xsl:template match="//spase:ResourceHeader/spase:Contact">
    <xsl:variable name="person_id" select="spase:PersonID"/>
    <!-- If Person information is available in //Person, use it. Othewrise, load external XML. -->
    <xsl:variable name="path">
        <xsl:choose>
            <xsl:when test="//spase:Person[spase:ResourceID[text()=$person_id]]"></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(substring-after($person_id, 'spase://IUGONET/'), '.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="person" select="document($path)//spase:Person[spase:ResourceID[text()=$person_id]]"/>

    <!-- Write creator and contributor -->
    <jpcoar:creator>
        <!-- jpcoar:nameIdentifier nameIdentifierScheme="xxx" nameIdentifierURI="xxx">
            <xsl:value-of select="$person_id"/>
        </jpcoar:nameIdentifier -->
        <jpcoar:creatorName xml:lang="en">
            <xsl:value-of select="$person/spase:PersonName"/>
        </jpcoar:creatorName>
        <jpcoar:affiliation>
            <jpcoar:affiliationName xml:lang="en">
                <xsl:value-of select="$person/spase:OrganizationName"/>
            </jpcoar:affiliationName>
        </jpcoar:affiliation>
    </jpcoar:creator>

    <xsl:variable name="role">
        <xsl:choose>
            <xsl:when test="spase:Role='MetadataContact'">
                <xsl:text>ContactPerson</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>ProjectMember</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <jpcoar:contributor>
        <xsl:attribute name="contributorType">
            <xsl:value-of select="$role"/>
        </xsl:attribute>
        <!--jpcoar:nameIdentifier nameIdentifierScheme="xxx" nameIdentifierURI="xxx">
            <xsl:value-of select="$person_id"/>
        </jpcoar:nameIdentifier -->
        <jpcoar:contributorName xml:lang="en">
            <xsl:value-of select="$person/spase:PersonName"/>
        </jpcoar:contributorName>
        <jpcoar:affiliation>
            <jpcoar:affiliationName xml:lang="en">
                <xsl:value-of select="$person/spase:OrganizationName"/>
            </jpcoar:affiliationName>
        </jpcoar:affiliation>
    </jpcoar:contributor>
</xsl:template>

<xsl:template match="//spase:AccessInformation/spase:AccessRights">
    <xsl:choose>
        <xsl:when test="text()='Open'">
            <dcterms:accessRights rdf:resource="http://purl.org/coar/access_right/c_abf2">
                <xsl:text>open access</xsl:text>
            </dcterms:accessRights>
        </xsl:when>
        <xsl:otherwise>
            <dcterms:accessRights rdf:resource="http://purl.org/coar/access_right/c_16ec">
                <xsl:text>restricted access</xsl:text>
            </dcterms:accessRights>
        </xsl:otherwise>
        <!--
            embargoed access -> rdf:resource="http://purl.org/coar/access_right/c_f1cf"
            metadata only access -> rdf:resource="http://purl.org/coar/access_right/c_14cb"
        -->
    </xsl:choose>
</xsl:template>

<xsl:template match="//spase:ResourceHeader/spase:Acknowledgement">
    <dc:rights xml:lang="en">
        <xsl:value-of select="text()"/>
    </dc:rights>
</xsl:template>

<xsl:template match="//spase:Keyword">
    <jpcoar:subject xml:lang="en" subjectScheme="Other">
        <xsl:value-of select="text()"/>
    </jpcoar:subject>
</xsl:template>

<xsl:template match="//spase:ResourceHeader/spase:Description">
    <datacite:description xml:lang="en" descriptionType="Abstract">
        <xsl:value-of select="text()"/>
    </datacite:description>
</xsl:template>

<xsl:template match="//spase:ResourceHeader/spase:ReleaseDate">
    <xsl:if test="string-length(text() >= 10)">
        <datacite:date dateType="Issued">
            <xsl:value-of select="substring(text(), 1, 10)"/>
        </datacite:date>
    </xsl:if>
</xsl:template>

<xsl:template match="//spase:ProviderVersion">
    <datacite:version>
        <xsl:value-of select="text()"/>
    </datacite:version>
</xsl:template>

<xsl:template match="//spase:ResourceHeader/spase:DOI">
    <jpcoar:relation relationType="isIdenticalTo">
        <jpcoar:relatedIdentifier identifierType="DOI">
            <xsl:value-of select="text()"/>
        </jpcoar:relatedIdentifier>
    </jpcoar:relation>
</xsl:template>

<xsl:template match="//spase:AccessInformation/spase:AccessURL/spase:URL">
    <jpcoar:relation relationType="isIdenticalTo">
        <jpcoar:relatedIdentifier identifierType="URI">
            <xsl:value-of select="text()"/>
        </jpcoar:relatedIdentifier>
    </jpcoar:relation>
</xsl:template>

<xsl:template match="//spase:TemporalDescription/spase:TimeSpan">
    <dcterms:temporal xml:lang="en">StartDate:<xsl:value-of select="spase:StartDate"/>, StopDate:<xsl:value-of select="spase:StopDate"/>, RelativeStopDate:<xsl:value-of select="spase:RelativeStopDate"/>
    </dcterms:temporal>
</xsl:template>

<xsl:template match="//spase:InstrumentID">
    <xsl:variable name="instrument_id" select="text()"/> <!-- spase://IUGONET/Instrument/ISEE/Induction/ATH/induction -->
    <!-- If Instrument information is available in //Instrument, use it. Otherwise, load external XML. -->
    <xsl:variable name="instrument_path">
        <xsl:choose>
            <xsl:when test="//spase:Instrument[spase:ResourceID[text()=$instrument_id]]"></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(substring-after($instrument_id, 'spase://IUGONET/'), '.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="instrument" select="document($instrument_path)//spase:Instrument[spase:ResourceID[text()=$instrument_id]]"/>
    <xsl:variable name="observatory_id" select="$instrument/spase:ObservatoryID"/> <!-- spase://IUGONET/Observatory/ISEE/Induction/ATH -->
    <!-- if Observatory information is available in //Observatory, use it. Otherwise, load external XML. -->
    <xsl:variable name="observatory_path">
        <xsl:choose>
            <xsl:when test="//spase:Observatory[spase:ResourceID[text()=$observatory_id]]"></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(substring-after($observatory_id, 'spase://IUGONET/'), '.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="observatory" select="document($observatory_path)//spase:Observatory[spase:ResourceID[text()=$observatory_id]]"/>
    <datacite:geoLocation>
        <datacite:geoLocationPoint>
            <datacite:pointLatitude>
                <xsl:value-of select="$observatory/spase:Location/spase:Latitude"/>
            </datacite:pointLatitude>
            <datacite:pointLongitude>
                <xsl:value-of select="$observatory/spase:Location/spase:Longitude"/>
            </datacite:pointLongitude>
        </datacite:geoLocationPoint>
    </datacite:geoLocation>
</xsl:template>

<xsl:template match="//spase:ResourceHeader/spase:Funding">
    <jpcoar:fundingReference>
        <jpcoar:funderName xml:lang="en">
            <xsl:value-of select="spase:Agency"/>
        </jpcoar:funderName>
        <jpcoar:awardTitle xml:lang="en">
            <xsl:value-of select="spase:Project"/>
        </jpcoar:awardTitle>
        <xsl:if test="spase:AwardNumber">
            <datacite:awardNumber>
                <xsl:value-of select="spase:AwardNumber"/>
            </datacite:awardNumber>
        </xsl:if>
    </jpcoar:fundingReference>
</xsl:template>

</xsl:stylesheet>