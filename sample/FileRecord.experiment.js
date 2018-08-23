
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

//


debugger
var record = _.fileProvider.fileRecord(  _.join( __dirname, 'xxx' ) );
console.log( _.toStr( record, { levels : 5 } ) )
debugger

// var files = _.fileProvider.filesFind
// ({
//    filePath : _.join( __dirname, 'xxx' ),
//    outputFormat : 'record',
//    includingTerminals : 1,
//    includingDirectories : 1
// })
// console.log( files )