<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <pattern>
        <rule context="org-mission/id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does
                not match filename “<value-of select="$basename"/>”</assert>
            <assert test="matches(., '^[a-z-]+$')">The id 
                “<value-of select="."/>” must contain only lower case letters and hyphens</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="chief//date[. ne ''][parent::*/preceding-sibling::*[1][date ne '']]">
            <assert test=". ge ./parent::*/preceding-sibling::*[date ne ''][1]/date">Date ordering problem. expected this date to come after the preceding date.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="date">
            <assert test="(. = '') or matches(., '^\d{4}$') or matches(., '^\d{4}-\d{2}$') or . castable as xs:date">Date should be yyyy-mm-dd, yyyy-mm, or empty</assert>
        </rule>
    </pattern>
    <pattern>
        <title>Report possible missing termination dates</title>
        <rule context="ended[date = '']">
            <let name="start-date" value="(./preceding-sibling::started/date, ./preceding-sibling::appointed/date)[. ne ''][1]"/>
            <assert test="if (substring($start-date, 1, 4) castable as xs:gYear) then (year-from-date(current-date()) - substring($start-date, 1, 4) cast as xs:integer lt 6) else true()">Missing termination date? More than 5 years has passed since appointment or presentation of credentials (<value-of select="substring($start-date, 1, 4)"/>).</assert>
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
