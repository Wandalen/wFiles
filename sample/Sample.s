
if( typeof module !== 'undefined' )
require( 'wFiles' );
let _ = wTools;

/**/

var read = _.fileProvider.fileRead( __filename );
console.log( 'read', read );
