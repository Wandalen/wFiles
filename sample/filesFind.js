if( typeof module !== 'undefined' )
require( '../staging/dwtools/amid/file/FileTop.s' )

var _ = wTools;

var o =
{
  outputFormat : "record",
  filePath : _.pathRealMainFile(),
  _globPath : "*.js",
  relative : null,
}

debugger
var file = _.fileProvider.filesFind( o );
console.log( file );