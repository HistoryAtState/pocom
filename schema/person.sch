<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt3">
    <pattern id="id">
        <rule id="id-checks" context="id">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <let name="parent-dir" value="replace(base-uri(.), '^.*/(.*?)/.*?$', '$1')"/>
            <let name="original-id" value="./string()"/>
            <let name="generated-id" value="lower-case(replace(replace(string-join(./following-sibling::persName/(surname, forename, genName), ' '), '[\(\)\.’]', ''), '\s+', '-'))"/>
            <assert test="$basename = concat(., '.xml')">The id “<value-of select="."/>” does
                not match filename “<value-of select="$basename"/>”</assert>
            <assert test="$parent-dir = substring(., 1, 1)">The file should be stored in the “<value-of select="substring(., 1, 1)"/>” directory, not in the “<value-of select="$parent-dir"/>” directory</assert>
            <assert id="expected-format" test="matches(., '^[a-z-]+(\d+)?$')">The id 
                “<value-of select="."/>” must contain only lower case letters and hyphens, and can optionally end with a number</assert>
            <assert id="expected-value" test=". eq $generated-id" sqf:fix="update-id">Based on the name elements, the ID “<value-of select="."/>” should be “<value-of select="$generated-id"/>”.</assert>
            <sqf:fix id="update-id">
                <sqf:description>
                    <sqf:title>Update ID from name</sqf:title>
                </sqf:description>
                <sqf:add use-when="not(following-sibling::old-ids)" match="." position="after" target="old-ids" node-type="element">
                    <old-id xmlns="">
                        <sch:value-of select="$original-id"/>
                    </old-id>
                </sqf:add>
                <sqf:add use-when="following-sibling::old-ids" match="following-sibling::old-ids" position="last-child">
                    <old-id xmlns="">
                        <sch:value-of select="$original-id"/>
                    </old-id>
                </sqf:add>
                <sqf:replace match="text()" select="$generated-id"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern>
        <rule context="surname | forename">
            <let name="word-regex" value="'[-\s’;\(\)]+'"/>
            <let name="words-to-ignore" value="'de', 'van', 'von', 'D', 'O', 'St.'"/>
            <let name="name-regex" value="'^((de|De|di|Di|Du|Fitz|La|Le|Mac|Mc)?\p{Lu}\p{Ll}+)$|^(\p{Lu}\.)+$'"/>
            <let name="words" value="tokenize(., $word-regex)[. ne ''][not(. = $words-to-ignore)]"/>
            <assert test="every $word in $words satisfies matches($word, $name-regex)">Unexpected capitalization or punctuation found in name: <value-of select="string-join($words[not(matches(., $name-regex))], '; ')"/>.</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="death[. castable as xs:double]">
            <assert test=". gt '1600' and xs:double(.) le year-from-date(current-date())">Death element must be a 4-digit year in the form yyyy, and can't be in the future (unless you know something that I don't know).</assert>
            <assert test="if (preceding-sibling::birth castable as xs:double) then xs:double(.) gt xs:double(preceding-sibling::birth) else true()">Wrong birth/death years. (The dates show born in <value-of select="preceding-sibling::birth"/>, died in <value-of select="."/>.)</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="death[. = '']">
            <assert role="warn" test="if (preceding-sibling::birth castable as xs:double) then year-from-date(current-date()) - xs:double(preceding-sibling::birth) le 100 else true()">Call Willard Scott! Born in <value-of select="preceding-sibling::birth"/>, <value-of select="year-from-date(current-date()) - xs:double(preceding-sibling::birth) + 1"/> years ago!</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="last-modified-date">
            <assert test="xs:date(.) ge xs:date(./preceding-sibling::created-date)">Last
                updated date should come after the created date</assert>
        </rule>
    </pattern>
</schema>