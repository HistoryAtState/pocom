<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt2">
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
        <rule context="chief[.//date[. ne '']][preceding-sibling::chief[1]//date[. ne '']]" role="warn">
            <let name="current-position-start-date" value="(started/date, arrived/date, appointed/date)[. ne ''][1]"/>
            <let name="previous-position-end-date" value="(preceding-sibling::chief[1]//date[. ne ''])[last()]"/>
            <assert test="$current-position-start-date ge $previous-position-end-date">Possible position ordering problem: This position started on <value-of select="if ($current-position-start-date castable as xs:date) then format-date($current-position-start-date, '[MNn] [D], [Y0001]') else $current-position-start-date"/>, but the previous position didn't end until afterward, <value-of select="if ($previous-position-end-date castable as xs:date) then format-date($previous-position-end-date, '[MNn] [D], [Y0001]') else $previous-position-end-date"/>.</assert>
        </rule>
    </pattern>
    <pattern>
        <title>Report possible missing termination dates</title>
        <rule context="ended[date = ''][not(date/@certainty='high')][ancestor::chiefs]">
            <let name="start-date" value="(./preceding-sibling::started/date, ./preceding-sibling::appointed/date)[. ne ''][1]"/>
            <assert test="if (substring($start-date, 1, 4) castable as xs:gYear) then (year-from-date(current-date()) - substring($start-date, 1, 4) cast as xs:integer lt 6) else true()">Missing termination date? More than 5 years has passed since appointment or presentation of credentials (<value-of select="substring($start-date, 1, 4)"/>).</assert>
        </rule>
    </pattern>
    <pattern>
        <title>Report large gaps between appointment and presentation of credentials</title>
        <rule context="started[not(date/@certainty='high')]">
            <let name="started-date" value="./date[. ne '']"/>
            <let name="appointed-date" value="./preceding-sibling::appointed/date[. ne '']"/>
            <assert test="if ($appointed-date castable as xs:date and $started-date castable as xs:date) then (xs:date($started-date) - xs:date($appointed-date) le xs:dayTimeDuration('P365D')) else true()">Typo? More than 1 year (<value-of select="format-number(days-from-duration(xs:date($started-date) - xs:date($appointed-date)), '#,###')"/> days) between appointment (<value-of select="$appointed-date"/>) &amp; presentation of credentials (<value-of select="$started-date"/>).</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="last-modified-date">
            <assert test="xs:date(.) ge xs:date(./preceding-sibling::created-date)">Last
                updated date should come after the created date</assert>
        </rule>
    </pattern>
</schema>