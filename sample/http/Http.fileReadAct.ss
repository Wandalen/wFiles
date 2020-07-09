
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var provider = _.FileProvider.Http();

var url = 'http://github.com/Wandalen/wTools/archive/master.zip';
var read = provider.fileReadAct({ filePath : url, encoding : 'base64', sync : 0, advanced : {}, resolvingSoftLink : 1 } )
// error: self.streamReadAct(...).give is not a function
// console.log( 'read',read );

read.got( function( err, data )
{
  if( err )
  throw err;
  else
  console.log( data );
});
