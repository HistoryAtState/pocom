xquery version "1.0";

import module namespace style = "http://style.syntactica.com/us-state-hist" at "../../../modules/style.xqm";

(: return the longest string in a sequence of strings :)
declare function local:max-length($string-seq as xs:string*) as xs:string {
    let $max := max(for $s in $string-seq
    return
        string-length($s))
    return
        $string-seq[string-length(.) = $max][1]
};

(: the number of blueprint columns to span for this sequnce of strings :)
declare function local:bp-column-width($string-seq as xs:string*) as xs:integer {
    let $chars-per-column := xs:double(6)
    let $max := max(for $s in $string-seq
    return
        string-length($s))
    return
        floor(($max div $chars-per-column) + 1)
};

let $all-codes-path := concat($style:db-path-to-app, '/code-tables/all-codes.xq')

(: not working - perhaps because of rewrite rules? let $code-table := util:eval(xs:anyURI($all-codes-path)) :)
let $all-codes := doc('http://localhost/cms/apps/principals-chiefs/edit/all-codes')/code-tables
let $table-names := $all-codes//code-table/name/text()

let $style2 :=
<style type="text/css"><![CDATA[
.code-table {padding: 10px;}
.metric-label {font-weight: bold;}
]]></style>

let $content :=
<div class="content">
    {$style2}
    Path := {$all-codes-path}<br/>
    Table Count= {count($table-names)}<br/>
    Item Count= {count($all-codes//item)}<br/>
    {
        for $table-name in $table-names
        let $table := $all-codes/code-table[name = $table-name]
        let $max-label-length := local:max-length($table/items/item/label/text())
        let $max-value-length := local:max-length($table/items/item/value/text())
        let $label-bp-columns := local:bp-column-width($table/items/item/label/text())
        let $value-bp-columns := local:bp-column-width($table/items/item/value/text())
        return
            <div class="code-table">
                <div class="metric"><span class="metric-label">Table Name: </span>{$table-name}</div>
                <div class="metric">Description: {$table/description/text()}
                </div>
                <div class="metric">Items in Table: {count($table/items/item)}
                </div>
                <div class="metric">Longest Label: {$max-label-length}
                </div>
                <div class="metric">Longest Value: {$max-value-length}
                </div>
                <!--
            <div class="metric">BP Columns for Label: {$label-bp-columns} </div>
            <div class="metric">BP Columns for Value: {$value-bp-columns} </div>
            -->
                
                <table class="span-{$label-bp-columns + $value-bp-columns + 1}">
                    <thead>
                        <th class="span-{local:bp-column-width($table/items/item/label/text())}">Item</th>
                        <th class="span-{local:bp-column-width($table/items/item/value/text())} last">Value</th>
                    </thead>
                    <tbody>{
                            for $item in $all-codes/code-table[name = $table-name]/items/item
                            return
                                <tr>
                                    <td>{$item/label/text()}</td>
                                    <td>{$item/value/text()}</td>
                                </tr>
                        }</tbody>
                </table>
                <hr/>
            </div>
    }
</div>
return
    style:assemble-page($content)