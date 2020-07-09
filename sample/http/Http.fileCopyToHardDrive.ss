
if( typeof module !== 'undefined' )
require( 'wFiles' )
debugger;
var _ = wTools;
var provider = _.FileProvider.Http();

var url = 'http://github.com/Wandalen/wTools/archive/master.zip';
provider.fileCopyToHardDrive( url ) // error: self.streamReadAct(...).give is not a function
.got( function( err, data )
{
  if( err )
  throw err;
  else
  console.log( data );
});
