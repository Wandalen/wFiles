
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

//

var filePath = _.path.join( __dirname, 'File.txt' );

var record = _.fileProvider.record( filePath );
console.log( _.toStr( record, { levels : 5 } ) );

var files = _.fileProvider.filesFind( filePath );
console.log( files );
