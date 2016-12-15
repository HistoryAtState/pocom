<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt2">
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