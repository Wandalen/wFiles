if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var o =
{
  outputFormat : "record",
  filePath : _.fileProvider.path.realMainFile(),
}

var file = _.fileProvider.filesFind( o );
console.log( file );
