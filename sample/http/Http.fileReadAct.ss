
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var provider = _.FileProvider.Http();
debugger;
var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
var read = provider.fileRead({ filePath : url, encoding : 'utf8', sync : 0 })

read.finallyGive( function( err, arg )
{
  if( err ) throw err;

  console.log( arg );
});
