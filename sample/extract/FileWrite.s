if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' :
  {
    'dir2' :
    {
      'file.txt' : 'previous data...',
    }
  }
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

// fileWrite sync

provider.fileWrite
({
  filePath : '/dir1/dir2/file.txt',
  data : 'new sync data...',
  sync : 1
});

var result = provider.fileRead({ filePath : '/dir1/dir2/file.txt', sync : 1 });
console.log( result ); // logs: new sync data...

//fileWrite async

provider.fileWrite
({
  filePath : '/dir1/dir2/file.txt',
  data : 'new async data...',
  sync : 0
})
.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  var result = provider.fileRead({ filePath : '/dir1/dir2/file.txt', sync : 1 });
  console.log( result ); // logs: new async data...
});
