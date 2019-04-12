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

declare function pc:person($person-id) {
    collection($pc:PEOPLE-COL)/person[id = $person-id]
};

declare function pc:name-last-first($person-id) {
    pc:person($person-id)/persName ! string-join((./surname, ./forename, ./genName), ", ")
};

declare function pc:title-label($role-title-id) {
    let $role := collection($pc:DATA-COL)//id[. = $role-title-id]/..
    return
        $role/names/singular/string()
};

declare function pc:current-age($person-id) {
    let $person := pc:person($person-id)
    return 
        (: person is dead :)
        if ($person/birth ne "" and $person/death ne "") then
            "(passed away)"
        else if ($person/birth ne "" and $person/death eq "") then
            (current-date() => year-from-date() => xs:integer()) - ($person/birth cast as xs:integer)
        (: no info available :)
        else
            "(birth year unknown)"
};

declare function pc:age-group($person-id) {
    let $current-age := pc:current-age($person-id)
    return
        if ($current-age instance of xs:integer) then
            ((($current-age div 10) => floor()) * 10) ! (. || "-" || . + 9)
        else
            $current-age
};

(:
<facet dimension="chief-roles" expression="pc:chief-roles(id)"/>
<facet dimension="countries-as-chief" expression="pc:countries-as-chief(id)"/>
<facet dimension="principal-roles" expression="pc:principal-roles(id)"/>
:)

declare function pc:chief-roles($person-id) {
    collection($pc:MISSIONS-COUNTRIES-COL)//person-id[. eq $person-id]/../role-title-id
};

declare function pc:countries-as-chief($person-id) {
    collection($pc:MISSIONS-COUNTRIES-COL)//person-id[. eq $person-id]/ancestor::country-mission/territory-id
};

declare function pc:principal-roles($person-id) {
    collection($pc:POSITIONS-PRINCIPALS-COL)//person-id[. eq $person-id]/ancestor::principal-position/id
};