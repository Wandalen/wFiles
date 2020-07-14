if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var provider = _.FileProvider.Http();

// read sync

var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
var read = provider.fileRead({ filePath : url, encoding : 'utf8', sync : 1 })
console.log( read.length );

// read async

var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
var read = provider.fileRead({ filePath : url, encoding : 'utf8', sync : 0 });
read.finallyGive( ( err, data ) =>
{
  if( err ) throw err;
  console.log( data.length );
});
