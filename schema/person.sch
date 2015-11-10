<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <let name="state-ids" value="doc('../code-tables/us-state-codes.xml')//value[. ne '']"/>
    <pattern>
        <rule context="/">
            <assert test="exists(person)">The document's root element must be person</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="person">
            <assert test="exists(id)">Missing id element</assert>
            <assert test="count(id) le 1">Only one id element allowed</assert>
            <assert test="exists(persName)">Missing persName element</assert>
            <assert test="count(persName) le 1">Only one persName element allowed</assert>
            <assert test="exists(birth)">Missing birth element</assert>
            <assert test="count(birth) le 1">Only one birth element allowed</assert>
            <assert test="exists(death)">Missing death element</assert>
            <assert test="count(death) le 1">Only one death element allowed</assert>
            <assert test="exists(career-type)">Missing career-type element</assert>
            <assert test="count(career-type) le 1">Only one career-type element allowed</assert>
            <assert test="exists(residence)">Missing residence element</assert>
            <assert test="count(residence) le 1">Only one residence element allowed</assert>
            <assert test="exists(created-by)">Missing created-by element</assert>
            <assert test="count(created-by) le 1">Only one created-by element allowed</assert>
            <assert test="exists(created-date)">Missing created-date element</assert>
            <assert test="count(created-date) le 1">Only one created-date element allowed</assert>
            <assert test="exists(last-modified-by)">Missing last-modified-by element</assert>
            <assert test="count(last-modified-by) le 1">Only one last-modified-by element
                allowed</assert>
            <assert test="exists(last-modified-date)">Missing last-modified-date element</assert>
            <assert test="count(last-modified-date) le 1">Only one last-modified-date element
                allowed</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <let name="parent-dir" value="replace(base-uri(.), '^.*/(.*?)/.*?$', '$1')"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does
                not match filename “<value-of select="$basename"/>”</assert>
            <assert test="$parent-dir = substring(., 1, 1)">The file should be stored in the “<value-of select="substring(., 1, 1)"/>” directory, not in the “<value-of select="$parent-dir"/>” directory</assert>
            <assert test="matches(., '^[a-z-]+(\d+)?$')">The id 
                “<value-of select="."/>” must contain only lower case letters and hyphens, and can optionally end with a number</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="persName">
            <assert test="exists(surname)">Missing surname element</assert>
            <assert test="count(surname) le 1">Only one surname element allowed</assert>
            <assert test="exists(forename)">Missing forename element</assert>
            <assert test="count(forename) le 1">Only one forename element allowed</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="birth">
            <assert test=". ne ''">Empty birth element</assert>
            <assert test=". eq '' or matches(., '\d{4}')">Birth element must be a year in the form yyyy</assert>
            <assert test="not(@type) or @type eq 'unknown'">Invalid @type value: ‘<value-of select="@type"/>’. Valid values: unknown.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="death[@type]">
            <assert test="@type = ('unknown', 'still-living')">Invalid @type value: ‘<value-of select="@type"/>’. Valid values: unknown, still-living.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="death[. castable as xs:double]">
            <assert test=". gt '1600' and xs:double(.) le year-from-date(current-date())">Death element must be a 4-digit year in the form yyyy, and can't be in the future (unless you know something that I don't know).</assert>
            <assert test="if (preceding-sibling::birth castable as xs:double) then xs:double(.) gt xs:double(preceding-sibling::birth) else true()">Wrong birth/death years. (The dates show born in <value-of select="preceding-sibling::birth"/>, died in <value-of select="."/>.)</assert>
            <assert test="if (preceding-sibling::birth castable as xs:double and xs:double(.) gt xs:double(preceding-sibling::birth) and not(./@certainty = 'high')) then xs:double(.) - xs:double(preceding-sibling::birth) ge 25 else true()">Really? This person lived to only <value-of select="xs:double(.) - xs:double(preceding-sibling::birth)"/> years old? (The dates show born in <value-of select="preceding-sibling::birth"/>, died in <value-of select="."/>.)</assert>
            <assert test="if (preceding-sibling::birth castable as xs:double and not(./@certainty = 'high')) then xs:double(.) - xs:double(preceding-sibling::birth) le 100 else true()">Really? This person lived to <value-of select="xs:double(.) - xs:double(preceding-sibling::birth)"/> years old? (The dates show born in <value-of select="preceding-sibling::birth"/>, died in <value-of select="."/>.)</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="death[. = '']">
            <assert test="if (preceding-sibling::birth castable as xs:double) then year-from-date(current-date()) - xs:double(preceding-sibling::birth) le 100 else true()">Call Willard Scott! Born in <value-of select="preceding-sibling::birth"/>, <value-of select="year-from-date(current-date()) - xs:double(preceding-sibling::birth) + 1"/> years ago!</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="career-type">
            <assert test=". ne ''">Empty career-type element</assert>
            <assert test=". eq '' or . = ('fso', 'appointee', 'both')">Invalid career-type: ‘<value-of select="."/>’. Valid values: fso, appointee, both.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="residence">
            <assert test="exists(state-id)">Missing state-id element</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="state-id">
            <!--<assert test="string-length(.) = 2 and matches(., '^[a-z]+$')">The state-id “<value-of select="."/>” is invalid. Must be 2 letters and
                lower case</assert>-->
            <assert test=". ne ''">Empty state-id element</assert>
            <assert test=". eq '' or . = $state-ids">Invalid state-id “<value-of select="."/>”; it was not found in the database.</assert>
            <!--<assert
                test="doc(concat('http://localhost:8080/services/check-state-id?state-id=', .))/result/is-valid = 'true'"
                >The state-id “<value-of select="."/>” was not found in the database.</assert>-->
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
    <pattern>
        <rule context="@*">
            <assert test="(./parent::birth or ./parent::death) and name() = ('type', 'certainty')">Unexpected attribute @<value-of select="name(.)"/>='<value-of select="./string()"/>'. (No attributes allowed other than @type and @certainty on birth/death.)</assert>
        </rule>
    </pattern>
</schema>
