
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

//

var path = _.path.s.join( __dirname, 'file.txt' );

var record = _.fileProvider.record( path );
console.log( _.toStr( record, { levels : 5 } ) );

var files = _.fileProvider.filesFind
({
  filePath : path,
  outputFormat : 'record'
});
console.log( files );
