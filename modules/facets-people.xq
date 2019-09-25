xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace pc="http://history.state.gov/ns/xquery/pocom" at "../pc.xqm";

declare option output:method "html";
declare option output:media-type "text/html";

declare function local:wrap-html($title, $body, $q, $sort) {
    <html lang="en">
        <head>
            <!-- Required meta tags -->
            <meta charset="utf-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
            
            <!-- Bootstrap CSS -->
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"/>
            <style type="text/css">
                body {{ font-family: HelveticaNeue, Helvetica, Arial, sans; }}
                .missing-target {{ text-decoration-line: underline; text-decoration-style: dashed; }}
                .highlight {{ background-color: yellow }}
                .form-check {{ justify-content: left !important }}
                dt {{
                    float: left;
                    clear: left;
                    width: 10em;
                    text-align: right;
                }}
                dt::after {{
                    content: ":";
                }}
                dd {{
                    margin: 0 0 0 11em;
                    padding: 0 0 0.5em 0;
                }}
            </style>
            <style type="text/css" media="print">
                a, a:visited {{ text-decoration: underline; color: #428bca; }}
                a[href]:after {{ content: ""; }}
            </style>
            <title>{$title}</title>
        </head>
        <body>
            <div class="container-fluid">
                <div class="row">
                    <div class="col">
                        <h3><a href="/exist/apps/pocom/modules/facets-people.xq">POCOM People</a></h3>
                    </div>
                </div>
                <form action="?" method="get">
                    <div class="row">
                        <div class="col">
                            <div class="form-group form-inline">
                                <label for="q" class="control-label mb-2 mr-2">Search POCOM People</label>
                                <input type="text" name="q" id="q" class="form-control mb-2 mr-2" value="{$q}"/>
                                <!--
                                <label for="sort-country" class="control-label mb-2 mr-2">Sort by country</label>
                                <input type="radio" name="sort" id="sort-country" class="form-control mb-2 mr-2" value="country"/>{if ($sort eq "country" or $sort eq "") then attribute checked { "checked" } else ()}
                                <label for="sort-date" class="control-label mb-2 mr-2">by date</label>
                                <input type="radio" name="sort" id="sort-date" class="form-control mb-2 mr-2" value="date"/>{if ($sort eq "date") then attribute checked { "checked" } else ()}
                                -->
                                <button type="submit" class="btn btn-primary mb-2 mr-2">Submit</button>
                                { if (request:get-query-string() ne "") then <a class="btn btn-secondary mb-2 mr-2" href="{request:get-url()}">Reset</a> else () }
                            </div>
                        </div>
                    </div>
                    {$body}
                </form>
            </div>
            
            <!-- jQuery first, then Popper.js, then Bootstrap JS -->
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
        </body>
    </html>
};

declare function local:results-to-list($q, $facet-query, $query-hits, $facet-results as array(*)?, $facet-prefs as map(*)+, $start, $per-page, $sort) {
    <div class="row">
        <div class="col col-3">
            <h3>Facets</h3>
            {
            if (array:size($facet-results) gt 1) then
                array:for-each(
                    $facet-results, 
                    function($result) {
                        let $facet-name := map:keys($result)
                        let $facet := $facet-prefs[?name eq $facet-name]
                        let $is-hierarchical := $facet?hierarchical 
                        let $is-hierarchical-request := $is-hierarchical and exists($facet?request)
                        return
                            <fieldset class="form-group" id="{$facet-name}">
                                <h4>{if (empty($result?*?*)) then attribute style { "color: gray" } else (), $facet?label, " ", if (($facet?max ne -1 and $facet?max lt 10) or empty($result?*?*)) then () else <small>{
                                let $max := if ($facet?max eq 10) then -1 else 10 
                                return
                                    <a href="{request:get-url() || (if (request:get-query-string() ne "") then ("?" || replace(request:get-query-string(), "&amp;?" || $facet-name || "-max=-?\d+", "") || "&amp;") else "?") || $facet-name || "-max=" || $max}#{$facet-name}">{if ($max eq -1) then "Show all choices" else "Limit to top 10"}</a>
                                , if ($facet?hierarchical) then " [hierarchical]" else ()}</small>}</h4>
                                {
                                    if ($is-hierarchical) then
                                        for $request at $n in $facet?request
                                        let $id := $facet-name || "-hierarchical-" || $n
                                        return
                                            <div class="form-check">
                                                {
                                                    if ($is-hierarchical-request) then 
                                                        attribute style { "padding-left: " || $n - 1 || "em" } 
                                                    else 
                                                        ()
                                                }
                                                <input class="form-check-input" type="checkbox" checked="checked" id="{$id}" name="{$facet-name}" value="{$request}"/>
                                                <label class="form-check-label" for="{$id}">{$request}</label>
                                            </div>
                                    else
                                        (),
                                    <div>{
                                        if ($is-hierarchical-request) then 
                                            attribute style { "padding-left: " || count($facet?request) || "em" } 
                                        else 
                                            (),
                                        for $value at $n in $result?*?*
                                        let $name := map:keys($value)
                                        let $id := $facet-name || "-" || $n
                                        let $count := format-number($value?*, "#,###.##")
                                        let $is-checked := if ($is-hierarchical-request) then () else $facet-query?facets($facet-name) = $name
                                        return
                                            <div class="form-check">
                                                <input class="form-check-input" type="{if ($is-hierarchical) then "radio" else "checkbox"}" id="{$id}" name="{$facet-name}" value="{$name}"/>
                                                {if ($is-checked) then attribute checked { "checked" } else () }
                                                <label class="form-check-label" for="{$id}">{$name} ({$count})</label>
                                            </div>
                                    }</div>
                                }
                            </fieldset>
                    }
                )
            else
                ()
            }
            <button type="submit" class="btn btn-secondary">Apply Filters</button>
        </div>
        <div class="col col-9">
            <h2>Results</h2>
            <p>{$start}–{min((count($query-hits), $start + $per-page - 1))} of { 
                if ($q or map:size($facet-query?facets) ge 1) then 
                    format-number(count($query-hits), "#,###.##") || " hits for officials with "
                else 
                    "all " || format-number(count($query-hits), "#,###.##") || " officials",
                string-join(
                    (
                        if ($q) then "keyword “" || $q || "”" else (),
                        map:for-each($facet-query?facets, function($key, $values) { 
                            let $facet := $facet-prefs[?name eq $key]
                            let $facet-label := $facet?label
                            return
                                lower-case($facet-label) || " of " || 
                                    (
                                        if ($facet?hierarchical) then
                                            ( "“" || string-join($values, " › ") || "”" )
                                        else
                                            string-join($values ! ("“" || . || "”"), ", ")
                                    )
                           }
                       )
                    ),
                    "; "
                )[. ne ""]
            }.</p>
            {
            let $nav := <nav aria-label="Page navigation">
                <ul class="pagination">{
                    if ($start gt $per-page) then 
                        <li class="page-item"><a class="page-link" href="{request:get-url() || (if (request:get-query-string() ne "") then ("?" || replace(request:get-query-string(), "&amp;?start=\d+", "") || "&amp;") else "?") || "start=" || $start - $per-page}">Previous</a></li>
                    else
                        (),
                    if (count($query-hits) gt $start + $per-page) then 
                        (
                            <li class="page-item"><a class="page-link" href="{request:get-url() || (if (request:get-query-string() ne "") then ("?" || replace(request:get-query-string(), "&amp;?start=\d+", "") || "&amp;") else "?") || "start=" || $start + $per-page}">Next</a></li>,
                            <li class="page-item"><a class="page-link" href="{request:get-url() || (if (request:get-query-string() ne "") then ("?" || replace(request:get-query-string(), "&amp;?start=\d+", "") || "&amp;") else "?") || "per-page=" || count($query-hits)}">All</a></li>
                        )
                    else 
                        (),
                    <li class="page-item"><a class="page-link" href="{request:get-url() || (if (request:get-query-string() ne "") then ("?" || replace(request:get-query-string(), "&amp;?start=\d+", "") || "&amp;") else "?") || "tsv=true"}">Download TSV</a></li>
                }</ul>
            </nav>
            return 
                if ($nav//li) then 
                    $nav
                else
                    ()
            }
            <table class="table">
                <thead>
                    <tr>
                        <th>No.</th>
                        <th>Name</th>
                        <th>State of Residence</th>
                        <th>Career Type</th>
                        <th>Roles</th>
                    </tr>
                </thead>
                {
                    let $ordered-hits := 
                        for $hit in $query-hits
                        order by ft:field($hit, "name")
                        return $hit
                    let $hits-to-show := $ordered-hits => subsequence($start, $per-page)
                    for $hit at $n in $hits-to-show
                    let $name := ft:field($hit, "name")
                    return
                        <tr>
                            <td>{$start + $n - 1}</td>
                            <td><a href="https://history.state.gov/departmenthistory/people/{$hit/id}">{$name}</a> ({if ($hit/birth eq "") then "?" else $hit/birth || "–" || $hit/death})</td>
                            <td>{string-join(($hit//state-id ! upper-case(.)), ", ")}</td>
                            <td>{pc:career-type($hit/career-type)}</td>
                            <td><ul>{local:format-roles($hit)}</ul></td>
                        </tr>
                }
            </table>
        </div>
    </div>
};

declare function local:format-date($date as xs:string) {
    if ($date eq "") then ()
    else if (matches($date, "^\d{4}$")) then $date
    else if (matches($date, "^\d{4}-\d{2}$")) then format-date(xs:date($date || "-01"), "[MNn,*-3] [Y]")
    else format-date(xs:date($date), "[MNn,*-3] [D], [Y]")
};

(:~
 : A function for constructing a TSV (tab-separated value) file
 : 
 : @param A sequence of column headings
 : @param A sequence of arrays, each containing a row 
 :)
declare function local:tsv($column-headings as xs:string*, $rows as array(*)*) as xs:string {
    let $cell-separator := '&#09;' (: tab :)
    let $row-separator := '&#10;' (: newline :)
    let $heading-row := string-join($column-headings, $cell-separator)
    let $body-rows := 
        for $row in $rows
        return
            string-join($row?*, $cell-separator)
    let $all-rows := ($heading-row, $body-rows)
    let $tsv := string-join($all-rows, $row-separator)
    return 
        $tsv
};

declare function local:format-roles($person) {
    let $person-id := $person/id
    let $concurrent-appointments := collection($pc:CONCURRENT-APPOINTMENTS-COL)/concurrent-appointments[person-id = $person-id]
    let $roles := collection($pc:DATA-COL)//person-id[. = $person-id][not(parent::concurrent-appointments)]/..
    let $concurrent-groups :=
        for $group in $concurrent-appointments
        let $concurrent-roles := $roles[id = $group/chief-id]
        return
            <group>
                {
                    local:sort-roles($concurrent-roles) ! 
                        (: preserve all info needed to reconstruct position description with dept:format-role() :) 
                        element { root(.)/*/name() } 
                            {
                                (: country chief :) ./preceding::territory-id | (: int'l org chief :) root(.)/*/id,
                                element { ./name() } 
                                    {
                                        ./*, 
                                        <note/>
                                    }
                            }
                }
            </group>
    let $non-concurrent := local:sort-roles($roles[not(id = $concurrent-appointments/chief-id)])
    let $full-listing := local:sort-roles(($concurrent-groups, $non-concurrent))
    for $item in $full-listing
    return
        if ($item/self::group) then
            let $sorted-roles :=
                for $role in $item/*
                (: delicately construct a new root node containing all of the info needed to reconstruct position description with dept:format-role() :)
                let $role-node := element {$role/name()} {$role/*}
                return
                    local:format-role($person, $role-node/*[2])
            return
                <li>
                    <em>Concurrent Appointments</em>
                    <ol style="list-style-type: lower-alpha">{$sorted-roles ! <li>{.}</li>}</ol>
                </li>
        else
            <li>{local:format-role($person, $item)}</li>
};

declare function local:format-role($person, $role) {
    let $role-title-id := $role/role-title-id
    let $roleinfo := collection("/db/apps/pocom")/*[id = $role-title-id]
    let $roletitle := $roleinfo/names/singular/text()
    let $rolesubtype := $roleinfo/category
    let $roleclass := root($role)/*/name()
    let $current-territory-id := root($role)/*/territory-id
    let $current-org-mission-id := root($role)/*/id
    let $contemporary-territory-id := $role/contemporary-territory-id
    let $whereserved := 
        if ($contemporary-territory-id) then 
            (
                gsh:territory-id-to-short-name($contemporary-territory-id)/string(), 
                (: fall back on original country ID in case it's different than GSH's country ID :) 
                collection("/db/apps/gsh/data/countries-old")/country[id = $contemporary-territory-id]/label
            )[. ne ""][1] 
        else 
            ()
    let $appointed := $role/appointed
    let $started := $role/started
    let $ended := $role/ended
    let $startdate :=
        (
            $started/date,
            $appointed/date
        )[. ne ""][1]
    let $dates := substring($startdate, 1, 4) || "–" || substring($ended/date, 1, 4)
    let $role-id := $role/id
    order by $startdate
    return
        (
            $dates 
            || ": " 
            || 
            (
                if ($roleclass eq 'country-mission') then
                    $roletitle || " (" || $whereserved || ")"
                else if ($roleclass eq 'org-mission') then
                    $roletitle || (: handle cda-ad-interm chiefs to int'l orgs :) (if ($role-title-id = 'charge-daffaires-ad-interim') then concat(" (", root($role)/org-mission/names/singular, ")") else ())
                else (: if ($roleclasss eq 'principal-position') then :)
                    $roletitle
            )
        )
};

declare function local:sort-roles($roles) {
    (: why, oh why, does sorting not work without the namespace wildcard?! :)
    for $role in $roles
    let $sort-date := $role//date[. ne ''] => head()
    order by $sort-date
    return
        $role
};

let $q := request:get-parameter("q", ())[. ne ""]
let $start := request:get-parameter("start", 1) cast as xs:integer
let $per-page := request:get-parameter("per-page", 25) cast as xs:integer
let $sort := request:get-parameter("sort", "name")
let $default-facets-max := request:get-parameter("facets-max", 10) cast as xs:integer
let $tsv := request:get-parameter("tsv", "false")[1] cast as xs:boolean

let $alive := request:get-parameter("alive", ())[. ne ""]
let $age-groups := request:get-parameter("age-group", ())[. ne ""]
let $career-types := request:get-parameter("career-type", ())[. ne ""]
let $role-types := request:get-parameter("role-types", ())[. ne ""]
let $principal-roles := request:get-parameter("principal-roles", ())[. ne ""]
let $countries-as-chief := request:get-parameter("countries-as-chief", ())[. ne ""]
let $country-chief-roles := request:get-parameter("country-chief-roles", ())[. ne ""]
let $org-chief-roles := request:get-parameter("org-chief-roles", ())[. ne ""]
let $states-of-residence := request:get-parameter("state-of-residence", ())[. ne ""]

let $alive-max := 4
let $age-groups-max := request:get-parameter("age-group-max", $default-facets-max) cast as xs:integer
let $career-types-max := 4
let $role-types-max := 4
let $principal-roles-max := request:get-parameter("principal-roles-max", $default-facets-max) cast as xs:integer
let $countries-as-chief-max := request:get-parameter("countries-as-chief-max", $default-facets-max) cast as xs:integer
let $country-chief-roles-max := request:get-parameter("country-chief-roles-max", $default-facets-max) cast as xs:integer
let $org-chief-roles-max := request:get-parameter("org-chief-roles-max", $default-facets-max) cast as xs:integer
let $states-of-residence-max := request:get-parameter("state-of-residence-max", $default-facets-max) cast as xs:integer

let $facet-query :=
    map { 
        "facets":
            map:merge((
                if (exists($alive)) then map:entry("alive", $alive) else (),
                if (exists($age-groups)) then map:entry("age-group", $age-groups) else (),
                if (exists($career-types)) then map:entry("career-type", $career-types) else (),
                if (exists($role-types)) then map:entry("role-types", $role-types) else (),
                if (exists($principal-roles)) then map:entry("principal-roles", $principal-roles) else (),
                if (exists($countries-as-chief)) then map:entry("countries-as-chief", $countries-as-chief) else (),
                if (exists($country-chief-roles)) then map:entry("country-chief-roles", $country-chief-roles) else (),
                if (exists($org-chief-roles)) then map:entry("org-chief-roles", $org-chief-roles) else (),
                if (exists($states-of-residence)) then map:entry("state-of-residence", $states-of-residence) else ()
            )),
        "fields": ("name")
    }
let $query-hits := collection("/db/apps/pocom/people")/person[ft:query(., $q, $facet-query)]
let $facet-prefs := 
    (
        map {
            "name": "alive",
            "label": "Living",
            "max": $alive-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $alive
        },
        map {
            "name": "age-group",
            "label": "Age Group",
            "max": $age-groups-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $age-groups
        },
        map {
            "name": "career-type",
            "label": "Career Type",
            "max": $career-types-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $career-types
        },
        map {
            "name": "role-types",
            "label": "Role Type",
            "max": $role-types-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $role-types
        },
        map {
            "name": "principal-roles",
            "label": "Principal Officer Roles",
            "max": $principal-roles-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $principal-roles
        },
        map {
            "name": "countries-as-chief",
            "label": "Chief of Mission to",
            "max": $countries-as-chief-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $countries-as-chief
        },
        map {
            "name": "country-chief-roles",
            "label": "Country Chief Roles",
            "max": $country-chief-roles-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $country-chief-roles
        },
        map {
            "name": "org-chief-roles",
            "label": "Int’l Org Chief Roles",
            "max": $org-chief-roles-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $org-chief-roles
        },
        map {
            "name": "state-of-residence",
            "label": "State of Residence",
            "max": $states-of-residence-max,
            "sort": "value",
            "order": "ascending",
            "hierarchical": false(),
            "request": $states-of-residence
        }
    )
let $facet-results :=
    array { 
        if ($query-hits) then 
            for $facet in $facet-prefs
            let $values := 
                if ($facet?max eq -1) then 
                    ft:facets(head($query-hits), $facet?name) 
                else if ($facet?hierarchical and exists($facet?request)) then 
                    ft:facets(head($query-hits), $facet?name, $facet?max, $facet?request) 
                else 
                    ft:facets(head($query-hits), $facet?name, $facet?max)
            return
                map:entry($facet?name, 
                    array { 
                        if ($facet?sort eq "value" and $facet?order eq "ascending") then
                            for $key in map:keys($values)
                            let $value := map:get($values, $key)
                            order by $key ascending collation "http://www.w3.org/2013/collation/UCA?numeric=yes"
                            return
                                map { $key: $value }
                        else if ($facet?sort eq "value" and $facet?order eq "descending") then
                            for $key in map:keys($values)
                            let $value := map:get($values, $key)
                            order by $key descending collation "http://www.w3.org/2013/collation/UCA?numeric=yes"
                            return
                                map { $key: $value }
                        else if ($facet?sort eq "count" and $facet?order eq "ascending") then
                            for $key in map:keys($values)
                            let $value := map:get($values, $key)
                            order by $value ascending
                            return
                                map { $key: $value }
                        else if ($facet?sort eq "count" and $facet?order eq "descending") then
                            for $key in map:keys($values)
                            let $value := map:get($values, $key)
                            order by $value descending
                            return
                                map { $key: $value }
                        else (: unordered :)
                            for $key in map:keys($values)
                            let $value := map:get($values, $key)
                            return
                                map { $key: $value }
                    }
                )
        else 
            ()
    }
return
    if ($tsv) then
        let $column-headings := 
            <tr>
                <th>Name</th>
                <th>Surname</th>
                <th>Given Name (Full)</th>
                <th>Given Name (First non-initial)</th>
                <th>Generation Name</th>
                <th>Birth Year</th>
                <th>Death Year</th>
                <th>State of Residence</th>
                <th>Career Status</th>
                <th>Roles</th>
                <th>First Activity Year</th>
                <th>Last Activity Year</th>
                <th>Person ID</th>
                <th>URL</th>
            </tr>/th/string()
        let $ordered-hits := 
            for $hit in $query-hits
            order by ft:field($hit, "name")
            return $hit
        let $hits-to-show := $ordered-hits => subsequence($start, $per-page)
        let $rows :=
            for $hit at $n in $hits-to-show
            let $name := ft:field($hit, "name")
            let $positions := collection("/db/apps/pocom")//person-id[. eq $hit/id]
            let $exact-position-dates := ($positions/..//date)[. ne ""]
            let $nearby-position-dates := ($positions/.. ! (head(preceding-sibling::*), head(following-sibling::*)))//date[. ne ""]
            let $activity-years := 
                if ($exact-position-dates) then 
                    ($exact-position-dates[1], $exact-position-dates[last()]) ! substring(., 1, 4)
                else if ($nearby-position-dates) then
                    ($nearby-position-dates[1], $nearby-position-dates[last()]) ! substring(., 1, 4) ! (. || "~")
                else
                    "(insufficient date information)"
            return
                array {
                    $name,
                    $hit/persName/surname => string(),
                    $hit/persName/forename => string(),
                    tokenize($hit/persName/forename)[not(matches(., "^[A-Z]\.$"))][1] => replace("\p{P}", ""),
                    $hit/persName/genName => string(),
                    $hit/birth => string(),
                    $hit/death => string(),
                    string-join(($hit//state-id ! upper-case(.)), ", "),
                    pc:career-type($hit/career-type),
                    string-join(
                        <ul>{local:format-roles($hit)}</ul>//li,
                        "; "
                    ) => normalize-space(),
                    ($activity-years[1], "")[1],
                    ($activity-years[2], "")[1],
                    $hit/id => string(),
                    "https://history.state.gov/departmenthistory/people/" || $hit/id
                }
        return
            (
                util:declare-option("output:method", "text"),
                util:declare-option("output:media-type", "application/csv"),
                response:set-header("Content-Disposition", 'attachment; filename="pocom-export.tsv"'),
                local:tsv($column-headings, $rows)
            )
    else
        let $content := local:results-to-list($q, $facet-query, $query-hits, $facet-results, $facet-prefs, $start, $per-page, $sort)
        let $title := "Facets"
        return
            local:wrap-html($title, $content, $q, $sort)