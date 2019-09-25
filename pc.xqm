xquery version "3.1";

module namespace pc = "http://history.state.gov/ns/xquery/pocom";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare variable $pc:DATA-COL := '/db/apps/pocom';
declare variable $pc:DATA := collection($pc:DATA-COL);
declare variable $pc:CODE-TABLES-COL := $pc:DATA-COL || '/code-tables';
declare variable $pc:CONCURRENT-APPOINTMENTS-COL := $pc:DATA-COL || '/concurrent-appointments';
declare variable $pc:MISSIONS-COUNTRIES-COL := $pc:DATA-COL || '/missions-countries';
declare variable $pc:MISSIONS-ORGS-COL := $pc:DATA-COL || '/missions-orgs';
declare variable $pc:PEOPLE-COL := $pc:DATA-COL || '/people';
declare variable $pc:POSITIONS-PRINCIPALS-COL := $pc:DATA-COL || '/positions-principals';
declare variable $pc:ROLES-COUNTRY-CHIEFS-COL := $pc:DATA-COL || '/roles-country-chiefs';
declare variable $pc:OLD-COUNTRIES-COL := '/db/apps/gsh/data/countries-old';

declare function pc:person($person-id as xs:string) as element(person) {
    collection($pc:PEOPLE-COL)/person[id eq $person-id]
};

declare function pc:person-to-name-last-first($person as element(person)) as xs:string {
    $person/persName ! string-join((./surname, ./forename, ./genName), ", ")
};

declare function pc:person-id-to-name-last-first($person-id as xs:string) as xs:string {
    pc:person($person-id) => pc:person-to-name-last-first()
};

declare function pc:alive-status($birth-year as xs:string, $death-year as xs:string) as xs:string {
    if ($birth-year ne "" and $death-year eq "") then 
        "Alive"
    else if ($birth-year ne "" and $death-year ne "") then 
        "Passed away"
    else if ($birth-year eq "" and $death-year ne "") then 
        "Passed away (Birth year unknown)"
    else (: if ($birth-year eq "" and $death-year eq "") then :)
        "Unknown (No birth or death information)"
};

declare function pc:age-group($birth-year as xs:string, $death-year as xs:string) as xs:string? {
    (: only determine age group if birth year is known, we have no record of death, and person is thus presumed alive :)
    if ($birth-year ne "" and $death-year eq "") then 
        let $current-age := pc:current-age($birth-year cast as xs:integer)
        return
            ((($current-age div 10) => floor()) * 10) ! (. || "–" || . + 9)
    else
        ()
};

declare function pc:current-age($birth-year as xs:integer) as xs:integer {
    current-date() => year-from-date() => xs:integer()
    - 
    $birth-year
};

declare function pc:title-label($role-title-id as xs:string) as xs:string {
    let $role := collection($pc:DATA-COL)//id[. eq $role-title-id]/..
    let $label := $role/names/singular/string()
    return
        if (exists($label)) then 
            $label
        else
            "(unknown)"
};

(:
<facet dimension="countries-as-chief" expression="pc:countries-as-chief(id)"/>
<facet dimension="country-chief-roles" expression="pc:country-chief-roles(id)"/>
<facet dimension="org-chief-roles" expression="pc:org-chief-roles(id)"/>
<facet dimension="principal-roles" expression="pc:principal-roles(id)"/>
:)

declare function pc:countries-as-chief($person-id as xs:string) {
    for $chief in collection($pc:MISSIONS-COUNTRIES-COL)//person-id[. eq $person-id]/parent::chief
    let $current-territory-id := $chief/ancestor::country-mission/territory-id
    let $contemporary-territory-id := $chief/contemporary-territory-id
    return
        (
            gsh:territory-id-to-short-name($contemporary-territory-id)/string(), 
            (: fall back on original country ID in case it's different than GSH's country ID :) 
            collection($pc:OLD-COUNTRIES-COL)/country[id eq $contemporary-territory-id]/label/string()
        )[1] 
};

declare function pc:country-chief-roles($person-id as xs:string) {
    let $chief-roles := collection($pc:MISSIONS-COUNTRIES-COL)//person-id[. eq $person-id]/parent::chief
    let $role-title-ids := $chief-roles/role-title-id
    let $roleinfo := collection($pc:DATA-COL)//*[id eq $role-title-ids]
    return
        $roleinfo/names/singular/string()
};

declare function pc:org-chief-roles($person-id as xs:string) {
    let $chief-roles := collection($pc:MISSIONS-ORGS-COL)//person-id[. eq $person-id]/parent::chief
    let $role-title-ids := $chief-roles/role-title-id
    let $roleinfo := collection($pc:DATA-COL)//*[id eq $role-title-ids]
    return
        $roleinfo/names/singular/string()
};

declare function pc:principal-roles($person-id as xs:string) {
    let $principal-roles := collection($pc:POSITIONS-PRINCIPALS-COL)//person-id[. eq $person-id]/parent::principal
    let $role-title-ids := $principal-roles/ancestor::principal-position/id
    let $roleinfo := collection($pc:DATA-COL)//*[id eq $role-title-ids]
    return
        $roleinfo/names/singular/string()
};

declare function pc:role-types($person-id as xs:string) {
    let $principal-officer := collection($pc:POSITIONS-PRINCIPALS-COL)//person-id[. eq $person-id]
    let $country-chief := collection($pc:MISSIONS-COUNTRIES-COL)//person-id[. eq $person-id]
    let $org-chief := collection($pc:MISSIONS-ORGS-COL)//person-id[. eq $person-id]
    let $person := collection($pc:PEOPLE-COL)//person[id eq $person-id]
    return
        (
            if (exists($principal-officer)) then "Principal Officer" else (),
            if (exists($country-chief)) then "Chief of Mission (Country)" else (),
            if (exists($org-chief)) then "Chief of Mission (Int’l Org.)" else (),
            if (exists($person) and (not($principal-officer) and not($country-chief) and not($org-chief))) then "No roles" else ()
        )
};

declare function pc:career-type($career-type as xs:string) {
    if ($career-type = 'pre-1915') then 
        "Pre-1915"
    else
        let $label := doc($pc:CODE-TABLES-COL || "/career-appointee-codes.xml")//item[value eq $career-type]/label/string()
        return
            if (exists($label)) then 
                $label
            else
                "(unknown)"
};

declare function pc:state-id-to-label($state-id as xs:string) {
    let $label := doc($pc:CODE-TABLES-COL || "/us-state-codes.xml")//item[value eq $state-id]/label/string()
    return
        if (exists($label)) then
            $label
        else
            "(unknown)"
};
