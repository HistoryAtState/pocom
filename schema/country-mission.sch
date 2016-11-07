<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <pattern>
        <rule context="country-mission/territory-id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does
                not match filename “<value-of select="$basename"/>”</assert>
            <assert test="matches(., '^[a-z-]+$')">The id 
                “<value-of select="."/>” must contain only lower case letters and hyphens</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="chief/id">
            <assert test="matches(., '^\w{2}-\d{4}-\w{1,4}-\d{2}$')">The id 
                “<value-of select="."/>” should take the form xx-dddd-xxxx-dd, where x is a lower case letter and d is a digit</assert>
            <let name="territory-id" value="root(.)/country-mission/territory-id"/>
            <let name="current-territory-iso" value="doc(concat('../../gsh/data/countries-old/', $territory-id, '.xml'))/country/iso2"/>
            <assert test="tokenize(., '-')[1] = $current-territory-iso">The first portion of the id should be the 2-letter ISO country code: <value-of select="$current-territory-iso"/></assert>
            <assert test="not(../date[. ne '']) or tokenize(., '-')[2] = substring(subsequence(..//date[. ne ''], 1, 1), 1, 4)">The second portion of the id should be the year portion of the first date in the record; or if no date, the year closest to the beginning of events described</assert>
            <assert test="tokenize(., '-')[3] = substring(tokenize(./following-sibling::person-id, '-')[1], 1, 4)">The third portion of the id should be the first four letters of the surname portion of a person's ID, e.g., “<value-of select="substring(tokenize(./following-sibling::person-id, '-')[1], 1, 4)"/>”</assert>
            <assert test="string-length(tokenize(., '-')[4]) = 2">The fourth portion of the id should be a two digit increment, starting 01 unless there's already a previous ID matching 01</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="chief//date[. ne ''][parent::*/preceding-sibling::*[1][date ne '']]">
            <assert test=". ge ./parent::*/preceding-sibling::*[date ne ''][1]/date">Date ordering problem. expected this date to come after the preceding date.</assert>
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
        <rule context="contemporary-territory-id">
            <!-- NOTE: THIS PATH TO GSH ASSUMES THAT GSH APP IS IN THE HSG-PROJECT REPOS DIRECTORY -->
            <assert test="doc-available(concat('../../gsh/data/territories/', ., '.xml'))">The contemporary-territory-id “<value-of select="."/>” was not found in the gsh territory collection.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="date">
            <assert test="(. = '') or matches(., '^\d{4}$') or matches(., '^\d{4}-\d{2}$') or . castable as xs:date">Date should be yyyy-mm-dd, yyyy-mm, or empty</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="last-modified-date">
            <assert test="xs:date(.) ge xs:date(./preceding-sibling::created-date)">Last
                updated date should come after the created date</assert>
        </rule>
    </pattern>
</schema>
