if( typeof module !== 'undefined' )
require( 'wFiles' )

let _ = wTools;

var o =
{
  outputFormat : 'record',
  filePath : _.path.realMainFile()
}

var file = _.fileProvider.filesFind( o );
console.log( file );
