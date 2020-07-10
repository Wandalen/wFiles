if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' : {}
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

// directoryMake sync

provider.dirMake({ filePath : '/dir1/dir2/dir3', sync : 1 });
console.log( 'sync dirMake: ', provider.fileExists( '/dir1/dir2/dir3' ) ); // logs: sync dirMake:  true

// directoryMake async

var con = provider.dirMake({ filePath : '/dir1.2/dir2/dir3', sync : 0 });
con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  console.log( 'async dirMake: ', provider.fileExists( '/dir1.2/dir2/dir3' ) ); // logs: async dirMake:  true
})
