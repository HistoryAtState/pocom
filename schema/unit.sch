<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt2">
    <pattern>
        <rule context="id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does not
                match filename “<value-of select="$basename"/>”</assert>
            <assert test="matches(., '^[a-z-]+\d*$')">The id “<value-of select="."/>” may contain
                only lower case letters, hyphens, and a trailing number</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="date[. ne ''][parent::*/preceding-sibling::*[1][date ne '']]">
            <assert test=". ge ./parent::*/preceding-sibling::*[date ne ''][1]/date">Date ordering
                problem. expected this date to come after the preceding date.</assert>
            <assert test="(. = '') or matches(., '^\d{4}$') or matches(., '^\d{4}-\d{2}$') or . castable as xs:date">Date should be yyyy-mm-dd, yyyy-mm, or empty</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="child-of[. ne ''] | predecessor | successor">
            <assert test="doc-available(concat('../units/current-units/', ., '.xml')) or doc-available(concat('../units/discontinued-units/', ., '.xml')) or doc-available(concat('../units/predecessor-units/', ., '.xml'))">No matching office ID found for "<value-of select="."/>" in units
                folder</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="created-by | last-modified-by">
            <assert test="not(. = '') and not(matches(., '[A-Z]'))">Cannot be left empty; please enter your last name and initials, all lower-case (e.g., jeffersontj)</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="created-date | last-modified-date">
            <assert test=". castable as xs:date">Should be a valid date, yyyy-mm-dd</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="last-modified-date">
            <assert test="xs:date(.) ge xs:date(./preceding-sibling::created-date)">Last updated
                date should come after the created date</assert>
        </rule>
    </pattern>
</schema>