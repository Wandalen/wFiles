
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

//

var record = _.fileProvider.record( _.path.join( __dirname, 'xxx' ) );
console.log( _.entity.exportString( record, { levels : 5 } ) )

// var files = _.fileProvider.filesFind
// ({
//    filePath : _.join( __dirname, 'xxx' ),
//    outputFormat : 'record',
//    includingTerminals : 1,
//    includingDirectories : 1
// })
// console.log( files )
