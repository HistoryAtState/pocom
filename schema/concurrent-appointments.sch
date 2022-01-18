<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt2">
    <!-- See documentation on Saxon-specific collection syntax used below: http://www.saxonica.com/documentation/index.html#!sourcedocs/collections --> 
    <let name="chief-ids" value="(collection('../missions-orgs?select=*.xml')//chief/id, collection('../missions-countries?select=*.xml')//chief/id)"/>
    <pattern>
        <rule context="id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does
                not match filename “<value-of select="$basename"/>”</assert>
            <assert test="matches(., '^[\da-z-]+$')">The id 
                “<value-of select="."/>” must contain only lower case letters, numbers, and hyphens</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="person-id">
            <assert test="matches(., '^[a-z-]+\d?$')">The person-id “<value-of select="."/>” should only contain lower-case letters and hyphens, with an optional digit as the last character</assert>
            <assert test="doc-available(concat('../people/', substring(., 1, 1), '/', ., '.xml'))">The person-id “<value-of select="."/>” was not found in the people collection.</assert>
            <!--<assert test="doc(concat('http://localhost:8080/services/check-person-id?person-id=', .))/result/is-valid = 'true'">The person-id “<value-of select="."/>” was not found in the database.</assert>-->
        </rule>
    </pattern>
    <pattern>
        <rule context="locale-id">
            <!-- NOTE: THIS PATH TO GSH ASSUMES THAT GSH APP IS IN THE HSG-PROJECT REPOS DIRECTORY -->
            <assert test=". = root(.)/country-mission/territory-id or doc-available(concat('../../gsh/data/locales/', ., '.xml'))">The locale-id “<value-of select="."/>” was not found in the gsh locales collection.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="contemporary-territory-id">
            <!-- NOTE: THIS PATH TO GSH ASSUMES THAT GSH APP IS IN THE HSG-PROJECT REPOS DIRECTORY -->
            <assert test="doc-available(concat('../../gsh/data/territories/', ., '.xml'))">The contemporary-territory-id “<value-of select="."/>” was not found in the gsh territory collection.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="chief-id">
            <assert test=". = $chief-ids">The chief-id “<value-of select="."/>” was not found in the missions-countries or missions-orgs collection as a chief/id.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="created-date | last-modified-date">
            <assert test=". castable as xs:date">Should be a valid date, yyyy-mm-dd</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="last-modified-date">
            <assert test="xs:date(.) ge xs:date(./preceding-sibling::created-date)">Last
                updated date should come after the created date</assert>
        </rule>
    </pattern>
</schema>