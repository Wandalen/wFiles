if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' :
  {
    'dir2' :
    {
      'fileSync.txt' : 'read sync data...',
      'fileAsync.txt' : 'read async data...',
    }
  }
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

// fileRead sync

var data = provider.fileRead
({
  filePath : '/dir1/dir2/fileSync.txt',
  sync : 1
});
console.log( data );

// fileRead async

provider.fileRead
({
  filePath : '/dir1/dir2/fileAsync.txt',
  sync : 0
})
.finallyGive( ( err, data ) =>
{
  if( err ) throw err;
  console.log( data )
});
