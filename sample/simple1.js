
if( typeof module !== 'undefined' )
{
  require( 'wTools' );
  require( 'wFiles' );
}

var _ = wTools;

var files = _.fileFind( __dirname );
console.log( 'at ' + __dirname );
console.log( files );
