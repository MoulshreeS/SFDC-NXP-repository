function replaceQueryString( queryString, keys, newValues ) {
    console.log('keys>> '+keys);
    console.log('newvalues>> '+newValues);
    var parts = queryString.split('&');
    
    // We're going to make an array of querystring key=value strings
    var new_parts = [];
    
    for(var i=0; i<parts.length; i++ ) {
        
        console.log('value of i>> '+i);
        var keyValue = parts[i].split('=');
        console.log('keyValue>> '+keyValue[0]);
        // Use jQuery to see if this key is in our desired set
        var replacePos = jQuery.inArray(keyValue[0],keys);
        console.log('replacePos>>'+replacePos);
        console.log('newValues[replacePos]>> '+newValues[replacePos]);
        // If it is, it will give a non-negative integer, if not it'll give -1
        if( replacePos >= 0 )
            // We want to replace this key so make a new string for the key/value pair
            new_parts.push( keyValue[0] + '=' + newValues[replacePos] );
        else {
            // This isn't the key we want to replace, so leave it alone
            new_parts.push( parts[i] );
        }
        
    }
    
    // glue all the parts together and return them
    return new_parts.join('&');
    console.log('new_parts>>'+new_parts);
}

function changeLink(){
var old_fulladdr = jQuery('.datacategorylinks .datacategoryoption a').attr('href'); 
console.log('old_fulladdr '+old_fulladdr );
var old_addr_parts = old_fulladdr.split('?');
console.log('old_addr_parts '+old_addr_parts );
var tobereplaced = ['criteria', 'feedtype'];
console.log('tobereplaced '+tobereplaced );
var replacements = ['OPENQUESTIONS','RECENT'];
console.log('replacements '+replacements );
var new_query_string = replaceQueryString( old_addr_parts[1], tobereplaced, replacements );
jQuery('.datacategorylinks .datacategoryoption a').attr('href',old_addr_parts[0] + '?' + new_query_string);

}